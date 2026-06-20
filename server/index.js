require('dotenv').config();

process.on('uncaughtException', (err) => console.error('[crash] uncaughtException:', err));
process.on('unhandledRejection', (reason) => console.error('[crash] unhandledRejection:', reason));

const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const ws = require('ws');
const { pickQuestions } = require('./questions');
const { updateElo } = require('./elo');
const { updateStreak } = require('./streak');

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*' },
  pingTimeout: 5000,
  pingInterval: 10000,
});

// ─── Supabase ─────────────────────────────────────────────────────────────────

let _supabase = null;
function getSupabase() {
  if (!_supabase) {
    _supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY,
      { realtime: { transport: ws } }
    );
  }
  return _supabase;
}

// ─── Constants ────────────────────────────────────────────────────────────────

const KNOWN_SUBJECTS = new Set(['AP Chemistry', 'AP Biology', 'AP US History', 'AP Psychology', 'AP Calculus AB']);
const ELO_MIN = 100;
const ELO_MAX = 3000;
const DISPLAY_NAME_MAX = 32;
const CLIENT_TIME_MIN_MS = 500;
const CLIENT_TIME_MAX_MS = 300000;
const FRIEND_CHALLENGE_TTL_MS = 5 * 60 * 1000; // 5 minutes

// ─── Battle state ─────────────────────────────────────────────────────────────

// queue entry: { socketId, userId, displayName, elo, subject, joinedAt }
const queue = [];

// roomId → { roomId, players, questions, subject, battleStartedAt, progress }
const battles = new Map();

// ─── Presence & social state ──────────────────────────────────────────────────

const userSockets      = new Map(); // userId → Set<socketId>
const socketToUser     = new Map(); // socketId → userId
const userActivity     = new Map(); // userId → { subject, phase } | null
const userProfiles     = new Map(); // userId → { displayName, elo }
const directChallenges = new Map(); // challengeId → { fromUserId, toUserId, subject, timerId }

// ─── Presence helpers ─────────────────────────────────────────────────────────

async function getAcceptedFriendIds(userId) {
  if (!process.env.SUPABASE_URL) return [];
  try {
    const supabase = getSupabase();
    const { data } = await supabase
      .from('friendships')
      .select('requester_id, addressee_id')
      .or(`requester_id.eq.${userId},addressee_id.eq.${userId}`)
      .eq('status', 'accepted');
    if (!data) return [];
    return data.map(r => r.requester_id === userId ? r.addressee_id : r.requester_id);
  } catch {
    return [];
  }
}

async function emitToOnlineFriends(userId, event, data) {
  try {
    const friendIds = await getAcceptedFriendIds(userId);
    for (const fid of friendIds) {
      if (userSockets.has(fid)) {
        io.to(`user:${fid}`).emit(event, data);
      }
    }
  } catch (err) {
    console.error('[presence] emitToOnlineFriends failed:', err);
  }
}

// ─── Matchmaking ──────────────────────────────────────────────────────────────

function tryMatch() {
  if (queue.length < 2) return;

  const now = Date.now();

  for (let i = queue.length - 1; i >= 0; i--) {
    const p = queue[i];
    if (now - p.joinedAt >= 60000) {
      queue.splice(i, 1);
      io.to(p.socketId).emit('queue_timeout');
      console.log(`[queue] timeout: ${p.displayName}`);
    }
  }

  for (let i = 0; i < queue.length; i++) {
    const p1 = queue[i];
    const elapsed = now - p1.joinedAt;
    const bracket = elapsed >= 30000 ? 400 : 200;

    for (let j = i + 1; j < queue.length; j++) {
      const p2 = queue[j];
      if (p1.subject !== p2.subject) continue;
      if (Math.abs((p1.elo ?? 1000) - (p2.elo ?? 1000)) > bracket) continue;

      queue.splice(j, 1);
      queue.splice(i, 1);
      createBattle(p1, p2);
      return;
    }
  }
}

setInterval(tryMatch, 5000);

function createBattle(p1, p2) {
  const roomId = `battle_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;

  const state = {
    roomId,
    players: {
      [p1.socketId]: { ...p1 },
      [p2.socketId]: { ...p2 },
    },
    questions: [],
    subject: p1.subject,
    battleStartedAt: null,
    progress: {
      [p1.socketId]: { questionIndex: 0, score: 0, done: false, startedAt: null, finishedAt: null, clientTimeTakenMs: null, answeredCurrent: false, readyToAdvance: false },
      [p2.socketId]: { questionIndex: 0, score: 0, done: false, startedAt: null, finishedAt: null, clientTimeTakenMs: null, answeredCurrent: false, readyToAdvance: false },
    },
  };

  battles.set(roomId, state);
  io.sockets.sockets.get(p1.socketId)?.join(roomId);
  io.sockets.sockets.get(p2.socketId)?.join(roomId);

  io.to(p1.socketId).emit('match_found', {
    roomId,
    opponent: { userId: p2.userId, displayName: p2.displayName, elo: p2.elo ?? 1000 },
    myElo: p1.elo ?? 1000,
  });
  io.to(p2.socketId).emit('match_found', {
    roomId,
    opponent: { userId: p1.userId, displayName: p1.displayName, elo: p1.elo ?? 1000 },
    myElo: p2.elo ?? 1000,
  });

  console.log(`[match] ${p1.displayName} vs ${p2.displayName} → ${roomId} (${p1.subject})`);

  // Notify friends of activity change
  for (const p of [p1, p2]) {
    if (p.userId) {
      userActivity.set(p.userId, { subject: p.subject, phase: 'battle' });
      emitToOnlineFriends(p.userId, 'friend_activity_update', {
        userId: p.userId,
        activity: { subject: p.subject, phase: 'battle' },
      }).catch(() => {});
    }
  }

  setTimeout(() => startBattle(roomId), 3000);
}

// ─── Battle flow ──────────────────────────────────────────────────────────────

async function startBattle(roomId) {
  const state = battles.get(roomId);
  if (!state) return;

  state.questions = await pickQuestions(state.subject, 1);
  state.battleStartedAt = Date.now();
  for (const sid of Object.keys(state.players)) {
    sendNextQuestion(roomId, sid);
  }
}

function sendNextQuestion(roomId, socketId) {
  const state = battles.get(roomId);
  if (!state) return;
  const prog = state.progress[socketId];
  if (!prog || prog.done) return;

  const q = state.questions[prog.questionIndex];
  if (!q) {
    finishPlayer(roomId, socketId);
    return;
  }

  if (prog.questionIndex === 0) prog.startedAt = Date.now();

  io.to(socketId).emit('question', {
    index: prog.questionIndex,
    total: state.questions.length,
    question: q,
  });
}

function getOpponentScore(state, mySocketId) {
  const oppId = Object.keys(state.players).find(id => id !== mySocketId);
  return oppId ? (state.progress[oppId]?.score ?? 0) : 0;
}

function handleAnswer(roomId, socketId, answerIndex, clientTimeTakenMs) {
  const state = battles.get(roomId);
  if (!state) return;

  const prog = state.progress[socketId];
  if (!prog || prog.done || prog.answeredCurrent) return;

  const q = state.questions[prog.questionIndex];
  if (!q) return;

  if (typeof clientTimeTakenMs === 'number' &&
      clientTimeTakenMs >= CLIENT_TIME_MIN_MS &&
      clientTimeTakenMs <= CLIENT_TIME_MAX_MS) {
    prog.clientTimeTakenMs = clientTimeTakenMs;
  }

  const correct = answerIndex === q.correct_index;
  if (correct) prog.score++;
  prog.answeredCurrent = true;
  prog.readyToAdvance = false;

  io.to(socketId).emit('question_result', {
    correct_index: q.correct_index,
    your_answer: answerIndex,
    correct,
    score: prog.score,
    opponent_score: getOpponentScore(state, socketId),
  });

  const oppId = Object.keys(state.players).find(id => id !== socketId);
  if (oppId) {
    io.to(oppId).emit('opponent_progress', {
      score: prog.score,
      questionIndex: prog.questionIndex,
      done: prog.done,
      answeredCurrent: true,
    });
  }

  setTimeout(() => {
    const currentState = battles.get(roomId);
    if (!currentState) return;
    const currentProg = currentState.progress[socketId];
    if (!currentProg || currentProg.done) return;
    currentProg.readyToAdvance = true;
    tryAdvanceQuestion(roomId);
  }, 1500);
}

function tryAdvanceQuestion(roomId) {
  const state = battles.get(roomId);
  if (!state) return;
  const sids = Object.keys(state.players);

  const allReady = sids.every(sid => {
    const p = state.progress[sid];
    return !p || p.done || p.readyToAdvance;
  });

  if (allReady) {
    for (const sid of sids) {
      const p = state.progress[sid];
      if (!p || p.done) continue;
      p.questionIndex++;
      p.answeredCurrent = false;
      p.readyToAdvance = false;
      if (p.questionIndex >= state.questions.length) {
        finishPlayer(roomId, sid);
      } else {
        sendNextQuestion(roomId, sid);
      }
    }
    return;
  }

  for (const sid of sids) {
    const p = state.progress[sid];
    if (p && p.readyToAdvance && !p.done) {
      io.to(sid).emit('waiting_for_opponent', {
        myScore: p.score,
        opponentScore: getOpponentScore(state, sid),
      });
    }
  }
}

function finishPlayer(roomId, socketId) {
  const state = battles.get(roomId);
  if (!state) return;
  const prog = state.progress[socketId];
  if (!prog) return;

  prog.done = true;
  prog.finishedAt = Date.now();

  io.to(socketId).emit('you_finished', {
    score: prog.score,
    opponent_score: getOpponentScore(state, socketId),
  });

  const allDone = Object.values(state.progress).every(p => p.done);
  if (allDone) endBattle(roomId);
}

async function endBattle(roomId, forfeitedBy = null) {
  const state = battles.get(roomId);
  if (!state || state.ending) return;
  state.ending = true;

  const sids = Object.keys(state.players);
  const scores = Object.fromEntries(sids.map(sid => [sid, state.progress[sid].score]));

  const timeTakenMs = Object.fromEntries(
    sids.map(sid => {
      const prog = state.progress[sid];
      const serverFallback = (prog.finishedAt && prog.startedAt) ? prog.finishedAt - prog.startedAt : null;
      return [sid, prog.clientTimeTakenMs ?? serverFallback];
    })
  );

  let winner = null;
  if (forfeitedBy) {
    winner = sids.find(id => id !== forfeitedBy) ?? null;
  } else {
    const [s1, s2] = sids.map(sid => scores[sid]);
    if (s1 > s2) winner = sids[0];
    else if (s2 > s1) winner = sids[1];
    else {
      const ct1 = state.progress[sids[0]].clientTimeTakenMs;
      const ct2 = state.progress[sids[1]].clientTimeTakenMs;
      const t1 = ct1 ?? (state.progress[sids[0]].finishedAt - state.progress[sids[0]].startedAt);
      const t2 = ct2 ?? (state.progress[sids[1]].finishedAt - state.progress[sids[1]].startedAt);
      if (t1 < t2) winner = sids[0];
      else if (t2 < t1) winner = sids[1];
      else winner = sids[0];
    }
  }

  const stateForElo = { ...state };

  let eloDeltas = {};
  try {
    eloDeltas = await updateElo(stateForElo, winner);
  } catch (err) {
    console.error('[elo] update failed:', err);
  }

  for (const sid of sids) {
    const { userId } = state.players[sid];
    try { await updateStreak(userId); } catch (err) { console.error('[streak]', err); }
  }

  io.to(roomId).emit('battle_complete', {
    scores,
    winner,
    timeTakenMs,
    eloDeltas,
    forfeit: !!forfeitedBy,
    forfeitedBy: forfeitedBy ?? null,
  });

  // Notify friends players are back to idle
  for (const [, player] of Object.entries(state.players)) {
    if (player.userId) {
      userActivity.delete(player.userId);
      emitToOnlineFriends(player.userId, 'friend_activity_update', {
        userId: player.userId,
        activity: null,
      }).catch(() => {});
    }
  }

  battles.delete(roomId);
  console.log(`[complete] ${roomId} — ${JSON.stringify(scores)}${forfeitedBy ? ` (forfeit by ${forfeitedBy})` : ''}`);
}

// ─── Disconnect ───────────────────────────────────────────────────────────────

function handleDisconnect(socketId) {
  const qi = queue.findIndex(p => p.socketId === socketId);
  if (qi !== -1) queue.splice(qi, 1);

  for (const [roomId, state] of battles.entries()) {
    if (!state.players[socketId]) continue;

    const player = state.players[socketId];
    const remainingId = Object.keys(state.players).find(id => id !== socketId);

    if (!remainingId) {
      battles.delete(roomId);
      break;
    }

    if (state.progress[socketId]) {
      state.progress[socketId].done = true;
      state.progress[socketId].finishedAt = Date.now();
    }
    io.to(remainingId).emit('opponent_disconnected');
    console.log(`[disconnect] ${player.displayName} forfeited ${roomId}`);
    endBattle(roomId, socketId);
    break;
  }

  // Presence cleanup
  const userId = socketToUser.get(socketId);
  if (userId) {
    socketToUser.delete(socketId);
    const sockets = userSockets.get(userId);
    if (sockets) {
      sockets.delete(socketId);
      if (sockets.size === 0) {
        userSockets.delete(userId);
        userActivity.delete(userId);
        emitToOnlineFriends(userId, 'friend_offline', { userId }).catch(() => {});

        // Cancel pending direct challenges for this user
        for (const [cid, dc] of directChallenges.entries()) {
          if (dc.fromUserId === userId || dc.toUserId === userId) {
            clearTimeout(dc.timerId);
            directChallenges.delete(cid);
          }
        }
      }
    }
  }
}

// ─── Socket events ────────────────────────────────────────────────────────────

io.on('connection', (socket) => {
  console.log(`[connect] ${socket.id}`);

  // ── Presence ──────────────────────────────────────────────────────────────

  socket.on('register_presence', async ({ userId }) => {
    if (!userId || typeof userId !== 'string') return;

    socketToUser.set(socket.id, userId);
    if (!userSockets.has(userId)) userSockets.set(userId, new Set());
    userSockets.get(userId).add(socket.id);
    socket.join(`user:${userId}`);

    // Cache display name so friend_challenge has a real name to send
    if (process.env.SUPABASE_URL && !userProfiles.has(userId)) {
      try {
        const supabase = getSupabase();
        const { data: p } = await supabase
          .from('profiles')
          .select('display_name')
          .eq('id', userId)
          .maybeSingle();
        if (p) userProfiles.set(userId, { displayName: p.display_name, elo: 1000 });
      } catch { /* non-fatal */ }
    }

    try {
      const friendIds = await getAcceptedFriendIds(userId);
      const onlineIds = friendIds.filter(fid => userSockets.has(fid));
      socket.emit('presence_init', { onlineUserIds: onlineIds });
      for (const fid of onlineIds) {
        io.to(`user:${fid}`).emit('friend_online', { userId });
      }
    } catch (err) {
      console.error('[presence] register_presence failed:', err);
    }
  });

  // ── Matchmaking ───────────────────────────────────────────────────────────

  socket.on('join_queue', ({ userId, displayName, elo, subject }) => {
    for (const state of battles.values()) {
      if (state.players[socket.id]) {
        socket.emit('queue_error', { error: 'Already in a battle' });
        return;
      }
    }

    const safeName = typeof displayName === 'string' ? displayName.trim().slice(0, DISPLAY_NAME_MAX) : '';
    if (!safeName) { socket.emit('queue_error', { error: 'Display name required' }); return; }

    const safeSubject = typeof subject === 'string' && KNOWN_SUBJECTS.has(subject) ? subject : null;
    if (!safeSubject) { socket.emit('queue_error', { error: 'Unknown subject' }); return; }

    const rawElo = typeof elo === 'number' && isFinite(elo) ? elo : 1000;
    const safeElo = Math.max(ELO_MIN, Math.min(ELO_MAX, Math.round(rawElo)));

    const existing = queue.findIndex(p => p.socketId === socket.id);
    if (existing !== -1) queue.splice(existing, 1);

    queue.push({ socketId: socket.id, userId, displayName: safeName, elo: safeElo, subject: safeSubject, joinedAt: Date.now() });
    socket.emit('queue_joined', { position: queue.length });
    console.log(`[queue] ${safeName} joined (${safeSubject}, elo=${safeElo}, queue=${queue.length})`);

    // Cache profile for friend challenge display names
    if (userId) userProfiles.set(userId, { displayName: safeName, elo: safeElo });

    // Notify friends of queuing activity
    const qUserId = socketToUser.get(socket.id) ?? userId;
    if (qUserId) {
      userActivity.set(qUserId, { subject: safeSubject, phase: 'queuing' });
      emitToOnlineFriends(qUserId, 'friend_activity_update', {
        userId: qUserId,
        activity: { subject: safeSubject, phase: 'queuing' },
      }).catch(() => {});
    }

    tryMatch();
  });

  socket.on('leave_queue', () => {
    const i = queue.findIndex(p => p.socketId === socket.id);
    if (i !== -1) { queue.splice(i, 1); socket.emit('queue_left'); }

    const userId = socketToUser.get(socket.id);
    if (userId) {
      userActivity.delete(userId);
      emitToOnlineFriends(userId, 'friend_activity_update', { userId, activity: null }).catch(() => {});
    }
  });

  socket.on('submit_answer', ({ roomId, answerIndex, clientTimeTakenMs }) => {
    handleAnswer(roomId, socket.id, answerIndex, clientTimeTakenMs);
  });

  // ── Messaging ─────────────────────────────────────────────────────────────

  socket.on('send_message', async ({ toUserId, content }) => {
    const fromUserId = socketToUser.get(socket.id);
    if (!fromUserId || !toUserId || typeof content !== 'string') return;

    const safeContent = content.trim().slice(0, 500);
    if (!safeContent || !process.env.SUPABASE_URL) return;

    const supabase = getSupabase();

    // Verify accepted friendship (not blocked)
    const { data: friendship } = await supabase
      .from('friendships')
      .select('status')
      .or(`and(requester_id.eq.${fromUserId},addressee_id.eq.${toUserId}),and(requester_id.eq.${toUserId},addressee_id.eq.${fromUserId})`)
      .eq('status', 'accepted')
      .maybeSingle();

    if (!friendship) return;

    const { data: msg, error } = await supabase
      .from('messages')
      .insert({ sender_id: fromUserId, receiver_id: toUserId, content: safeContent })
      .select('id, created_at')
      .single();

    if (error || !msg) { console.error('[msg] insert failed:', error); return; }

    io.to(`user:${toUserId}`).emit('new_message', {
      messageId: msg.id,
      fromUserId,
      content: safeContent,
      sentAt: msg.created_at,
    });

    // Prune conversation to last 50
    try {
      const { data: old } = await supabase
        .from('messages')
        .select('id')
        .or(`and(sender_id.eq.${fromUserId},receiver_id.eq.${toUserId}),and(sender_id.eq.${toUserId},receiver_id.eq.${fromUserId})`)
        .order('created_at', { ascending: false })
        .range(50, 9999);
      if (old && old.length > 0) {
        await supabase.from('messages').delete().in('id', old.map(m => m.id));
      }
    } catch (err) {
      console.error('[msg] prune failed:', err);
    }
  });

  socket.on('mark_messages_read', async ({ fromUserId }) => {
    const myUserId = socketToUser.get(socket.id);
    if (!myUserId || !fromUserId || !process.env.SUPABASE_URL) return;
    const supabase = getSupabase();
    await supabase
      .from('messages')
      .update({ read_at: new Date().toISOString() })
      .eq('sender_id', fromUserId)
      .eq('receiver_id', myUserId)
      .is('read_at', null);
  });

  // ── Direct challenges ─────────────────────────────────────────────────────

  socket.on('friend_challenge', async ({ toUserId, subject }) => {
    const fromUserId = socketToUser.get(socket.id);
    if (!fromUserId || !toUserId || !KNOWN_SUBJECTS.has(subject) || !process.env.SUPABASE_URL) return;

    const supabase = getSupabase();
    const { data: friendship } = await supabase
      .from('friendships')
      .select('status')
      .or(`and(requester_id.eq.${fromUserId},addressee_id.eq.${toUserId}),and(requester_id.eq.${toUserId},addressee_id.eq.${fromUserId})`)
      .eq('status', 'accepted')
      .maybeSingle();

    if (!friendship) return;

    const challengeId = `dc_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;

    // Resolve challenger's real name + subject-specific ELO (cache may be stale on elo)
    let fromProfile = userProfiles.get(fromUserId) ?? { displayName: 'A friend', elo: 1000 };
    try {
      const [{ data: p }, { data: eloRow }] = await Promise.all([
        supabase.from('profiles').select('display_name').eq('id', fromUserId).maybeSingle(),
        supabase.from('elo_ratings').select('rating').eq('user_id', fromUserId).eq('subject', subject).maybeSingle(),
      ]);
      fromProfile = {
        displayName: p?.display_name ?? fromProfile.displayName,
        elo: eloRow?.rating ?? fromProfile.elo,
      };
      userProfiles.set(fromUserId, fromProfile);
    } catch { /* use cached value */ }

    const timerId = setTimeout(() => {
      directChallenges.delete(challengeId);
      io.to(`user:${fromUserId}`).emit('friend_challenge_expired', { challengeId });
      io.to(`user:${toUserId}`).emit('friend_challenge_expired', { challengeId });
    }, FRIEND_CHALLENGE_TTL_MS);

    directChallenges.set(challengeId, { fromUserId, toUserId, subject, timerId });

    io.to(`user:${toUserId}`).emit('friend_challenge_received', {
      challengeId,
      fromUserId,
      fromDisplayName: fromProfile.displayName,
      fromElo: fromProfile.elo,
      subject,
    });
  });

  socket.on('accept_friend_challenge', ({ challengeId }) => {
    const myUserId = socketToUser.get(socket.id);
    const dc = directChallenges.get(challengeId);
    if (!dc || dc.toUserId !== myUserId) return;

    clearTimeout(dc.timerId);
    directChallenges.delete(challengeId);

    const fromSockets = userSockets.get(dc.fromUserId);
    if (!fromSockets || fromSockets.size === 0) {
      socket.emit('friend_challenge_expired', { challengeId });
      return;
    }

    const fromSocketId = [...fromSockets][0];
    const fromProfile = userProfiles.get(dc.fromUserId) ?? { displayName: 'Player', elo: 1000 };
    const toProfile   = userProfiles.get(myUserId)       ?? { displayName: 'Player', elo: 1000 };

    const p1 = { socketId: fromSocketId, userId: dc.fromUserId, displayName: fromProfile.displayName, elo: fromProfile.elo, subject: dc.subject };
    const p2 = { socketId: socket.id,    userId: myUserId,      displayName: toProfile.displayName,   elo: toProfile.elo,   subject: dc.subject };

    createBattle(p1, p2);
  });

  socket.on('decline_friend_challenge', ({ challengeId }) => {
    const myUserId = socketToUser.get(socket.id);
    const dc = directChallenges.get(challengeId);
    if (!dc || dc.toUserId !== myUserId) return;

    clearTimeout(dc.timerId);
    directChallenges.delete(challengeId);

    io.to(`user:${dc.fromUserId}`).emit('friend_challenge_declined', { challengeId });
  });

  // ── Core ──────────────────────────────────────────────────────────────────

  socket.on('disconnect', () => {
    console.log(`[disconnect] ${socket.id}`);
    handleDisconnect(socket.id);
  });
});

// ─── HTTP ─────────────────────────────────────────────────────────────────────

// Invite code lookup
app.get('/invite/:code', async (req, res) => {
  if (!process.env.SUPABASE_URL) return res.status(503).json({ error: 'Database not configured' });
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('profiles')
    .select('id, display_name')
    .eq('invite_code', req.params.code.toUpperCase())
    .maybeSingle();
  if (error || !data) return res.status(404).json({ error: 'No user found with that code' });
  return res.json({ userId: data.id, displayName: data.display_name });
});

// Async challenge creation
app.post('/challenge', async (req, res) => {
  try {
    const { challengerId, subject = 'AP Chemistry' } = req.body;
    if (!challengerId) return res.status(400).json({ error: 'challengerId required' });
    if (!process.env.SUPABASE_URL) return res.status(503).json({ error: 'Database not configured' });

    const questions = await pickQuestions(subject, 1);
    const questionIds = questions.map(q => q.id);

    const supabase = getSupabase();
    const { data, error } = await supabase.from('challenges').insert({
      challenger_id: challengerId,
      subject,
      question_ids: questionIds,
      questions_json: questions,
      status: 'pending',
    }).select('id').single();

    if (error) throw error;
    return res.json({ challengeId: data.id, questions });
  } catch (err) {
    console.error('[challenge] create failed:', err);
    return res.status(500).json({ error: 'Failed to create challenge' });
  }
});

app.post('/challenge/:id/submit', async (req, res) => {
  try {
    const { id } = req.params;
    const { userId, answers, timeMs } = req.body;
    if (!userId || !answers) return res.status(400).json({ error: 'userId and answers required' });
    if (!process.env.SUPABASE_URL) return res.status(503).json({ error: 'Database not configured' });

    const supabase = getSupabase();
    const { data: challenge, error: fetchErr } = await supabase
      .from('challenges').select('*').eq('id', id).single();

    if (fetchErr || !challenge) return res.status(404).json({ error: 'Challenge not found' });
    if (challenge.status !== 'pending') return res.status(400).json({ error: 'Challenge already completed' });

    const questions = challenge.questions_json;
    let score = 0;
    for (let i = 0; i < questions.length; i++) {
      if (answers[i] === questions[i].correct_index) score++;
    }

    const isChallenger = challenge.challenger_id === userId;
    const update = isChallenger
      ? { challenger_answers: answers, challenger_score: score, challenger_time_ms: timeMs }
      : { opponent_id: userId, opponent_answers: answers, opponent_score: score, opponent_time_ms: timeMs };

    let resolvedUpdate = {};
    if (!isChallenger && challenge.challenger_answers) {
      const cs = challenge.challenger_score ?? 0;
      const ct = challenge.challenger_time_ms ?? null;
      let winnerId = score > cs ? userId : cs > score ? challenge.challenger_id : null;
      if (winnerId === null) {
        const ot = typeof timeMs === 'number' && isFinite(timeMs) ? timeMs : null;
        if (ot !== null && ct !== null) winnerId = ot < ct ? userId : challenge.challenger_id;
        else winnerId = challenge.challenger_id;
      }
      resolvedUpdate = { status: 'completed', winner_id: winnerId };

      try {
        const stateForElo = {
          subject: challenge.subject,
          players: { p1: { userId: challenge.challenger_id, elo: 1000 }, p2: { userId, elo: 1000 } },
          progress: { p1: { score: cs }, p2: { score } },
        };
        await updateElo(stateForElo, winnerId === challenge.challenger_id ? 'p1' : winnerId === userId ? 'p2' : null);
      } catch (e) { console.error('[challenge-elo]', e); }
    }

    await supabase.from('challenges').update({ ...update, ...resolvedUpdate }).eq('id', id);
    return res.json({ score, total: questions.length, ...resolvedUpdate });
  } catch (err) {
    console.error('[challenge] submit failed:', err);
    return res.status(500).json({ error: 'Submission failed' });
  }
});

app.get('/challenge/:id', async (req, res) => {
  if (!process.env.SUPABASE_URL) return res.status(503).json({ error: 'Database not configured' });
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('challenges')
    .select('id, subject, questions_json, status, expires_at, challenger_id, challenger_score, opponent_score, winner_id')
    .eq('id', req.params.id).single();
  if (error || !data) return res.status(404).json({ error: 'Not found' });
  return res.json(data);
});

app.get('/health', (_, res) => {
  res.json({ ok: true, queue: queue.length, battles: battles.size });
});

const PORT = process.env.PORT || 4000;
console.log(`[startup] PORT env = "${process.env.PORT}" → binding :${PORT}`);
server.listen(PORT, '0.0.0.0', () => console.log(`[startup] Battle server listening on 0.0.0.0:${PORT}`));
