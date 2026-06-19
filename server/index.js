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
const CLIENT_TIME_MIN_MS = 500;   // no human answers in <500ms
const CLIENT_TIME_MAX_MS = 300000; // 5-minute ceiling

// ─── State ────────────────────────────────────────────────────────────────────

// queue entry: { socketId, userId, displayName, elo, subject, joinedAt }
const queue = [];

// roomId → { roomId, players, questions, subject, battleStartedAt, progress }
// players[socketId] = { socketId, userId, displayName, elo, subject }
// progress[socketId] = { questionIndex, score, done, startedAt, finishedAt, clientTimeTakenMs }
const battles = new Map();

// ─── Matchmaking ──────────────────────────────────────────────────────────────

function tryMatch() {
  if (queue.length < 2) return;

  const now = Date.now();

  // Expire players in queue > 60s
  for (let i = queue.length - 1; i >= 0; i--) {
    const p = queue[i];
    if (now - p.joinedAt >= 60000) {
      queue.splice(i, 1);
      io.to(p.socketId).emit('queue_timeout');
      console.log(`[queue] timeout: ${p.displayName}`);
    }
  }

  // Find a match for each waiting player
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

// Run matchmaking on a 5-second interval (supplements event-driven matching)
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
  setTimeout(() => startBattle(roomId), 3000);
}

// ─── Battle flow ──────────────────────────────────────────────────────────────

async function startBattle(roomId) {
  const state = battles.get(roomId);
  if (!state) return;

  state.questions = await pickQuestions(state.subject, 1);
  state.battleStartedAt = Date.now();
  // Send each player their first question independently
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

  // Immediate per-player feedback
  io.to(socketId).emit('question_result', {
    correct_index: q.correct_index,
    your_answer: answerIndex,
    correct,
    score: prog.score,
    opponent_score: getOpponentScore(state, socketId),
  });

  // Tell opponent about progress (score updated; index advances when both ready)
  const oppId = Object.keys(state.players).find(id => id !== socketId);
  if (oppId) {
    io.to(oppId).emit('opponent_progress', {
      score: prog.score,
      questionIndex: prog.questionIndex,
      done: prog.done,
      answeredCurrent: true,
    });
  }

  // After the reveal window, mark this player ready and try to advance both
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

  // Someone is ready but waiting on the opponent — show waiting overlay
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
    sids.map(sid => [sid, state.progress[sid].clientTimeTakenMs ?? null])
  );

  let winner = null;
  if (forfeitedBy) {
    // Disconnecting player forfeits — remaining player wins regardless of score.
    winner = sids.find(id => id !== forfeitedBy) ?? null;
  } else {
    const [s1, s2] = sids.map(sid => scores[sid]);
    if (s1 > s2) winner = sids[0];
    else if (s2 > s1) winner = sids[1];
    else {
      // Equal scores — faster answer wins.
      // Prefer client-reported time (same value shown on result screen).
      // Fall back to server-side per-player delta if client time wasn't received.
      const ct1 = state.progress[sids[0]].clientTimeTakenMs;
      const ct2 = state.progress[sids[1]].clientTimeTakenMs;
      const t1 = ct1 ?? (state.progress[sids[0]].finishedAt - state.progress[sids[0]].startedAt);
      const t2 = ct2 ?? (state.progress[sids[1]].finishedAt - state.progress[sids[1]].startedAt);
      if (t1 < t2) winner = sids[0];
      else if (t2 < t1) winner = sids[1];
      else winner = sids[0]; // true tie — arbitrary, no draws
    }
  }

  const stateForElo = { ...state };

  let eloDeltas = {};
  try {
    eloDeltas = await updateElo(stateForElo, winner);
  } catch (err) {
    console.error('[elo] update failed:', err);
  }

  // Update streaks
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

    // Immediate forfeit — no grace period. Prevents dodge-via-disconnect.
    if (state.progress[socketId]) {
      state.progress[socketId].done = true;
      state.progress[socketId].finishedAt = Date.now();
    }
    io.to(remainingId).emit('opponent_disconnected');
    console.log(`[disconnect] ${player.displayName} forfeited ${roomId}`);
    endBattle(roomId, socketId);
    break;
  }
}

// ─── Socket events ────────────────────────────────────────────────────────────

io.on('connection', (socket) => {
  console.log(`[connect] ${socket.id}`);

  socket.on('join_queue', ({ userId, displayName, elo, subject }) => {
    // Reject if socket is already in an active battle
    for (const state of battles.values()) {
      if (state.players[socket.id]) {
        socket.emit('queue_error', { error: 'Already in a battle' });
        return;
      }
    }

    // Validate and sanitize inputs
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
    tryMatch();
  });

  socket.on('leave_queue', () => {
    const i = queue.findIndex(p => p.socketId === socket.id);
    if (i !== -1) { queue.splice(i, 1); socket.emit('queue_left'); }
  });

  socket.on('submit_answer', ({ roomId, answerIndex, clientTimeTakenMs }) => {
    handleAnswer(roomId, socket.id, answerIndex, clientTimeTakenMs);
  });

  socket.on('disconnect', () => {
    console.log(`[disconnect] ${socket.id}`);
    handleDisconnect(socket.id);
  });
});

// ─── HTTP ─────────────────────────────────────────────────────────────────────

// Challenge creation endpoint (task #15)
app.post('/challenge', async (req, res) => {
  try {
    const { challengerId, subject = 'AP Chemistry' } = req.body;
    if (!challengerId) return res.status(400).json({ error: 'challengerId required' });

    if (!process.env.SUPABASE_URL) {
      return res.status(503).json({ error: 'Database not configured' });
    }

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

// Challenge submission endpoint
app.post('/challenge/:id/submit', async (req, res) => {
  try {
    const { id } = req.params;
    const { userId, answers, timeMs } = req.body;
    if (!userId || !answers) return res.status(400).json({ error: 'userId and answers required' });

    if (!process.env.SUPABASE_URL) return res.status(503).json({ error: 'Database not configured' });

    const supabase = getSupabase();
    const { data: challenge, error: fetchErr } = await supabase
      .from('challenges')
      .select('*')
      .eq('id', id)
      .single();

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

    // Resolve if opponent just submitted (challenger already submitted)
    let resolvedUpdate = {};
    if (!isChallenger && challenge.challenger_answers) {
      const cs = challenge.challenger_score ?? 0;
      const ct = challenge.challenger_time_ms ?? null;
      let winnerId = score > cs ? userId
        : cs > score ? challenge.challenger_id
        : null;
      // Score tie — faster time wins
      if (winnerId === null) {
        const opponentTime = typeof timeMs === 'number' && isFinite(timeMs) ? timeMs : null;
        if (opponentTime !== null && ct !== null) {
          winnerId = opponentTime < ct ? userId : challenge.challenger_id;
        } else {
          winnerId = challenge.challenger_id; // fallback — no draws
        }
      }
      resolvedUpdate = { status: 'completed', winner_id: winnerId };

      // Update ELO
      try {
        const stateForElo = {
          subject: challenge.subject,
          players: {
            'p1': { userId: challenge.challenger_id, elo: 1000 },
            'p2': { userId, elo: 1000 },
          },
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
    .eq('id', req.params.id)
    .single();
  if (error || !data) return res.status(404).json({ error: 'Not found' });
  return res.json(data);
});

app.get('/health', (_, res) => {
  res.json({ ok: true, queue: queue.length, battles: battles.size });
});

const PORT = process.env.PORT || 4000;
console.log(`[startup] PORT env = "${process.env.PORT}" → binding :${PORT}`);
server.listen(PORT, '0.0.0.0', () => console.log(`[startup] Battle server listening on 0.0.0.0:${PORT}`));
