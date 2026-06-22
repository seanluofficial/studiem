'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { getSocket } from '@/lib/socket';
import { createClient } from '@/lib/supabase/client';
import BattleRoom from '@/components/BattleRoom';
import NavBar from '@/components/NavBar';
import RankBadge from '@/components/RankBadge';
import AddFriendButton from '@/components/AddFriendButton';
import FriendsPanel, { type IncomingChallenge } from '@/components/FriendsPanel';
import PracticeMode, { type PracticeQuestion, getPracticeStats } from '@/components/PracticeMode';

function AnimatedEloSection({ before, after }: { before: number | null; after: number | null }) {
  const [counter, setCounter] = useState<number | null>(null);
  const [showDelta, setShowDelta] = useState(false);

  useEffect(() => {
    if (before === null || after === null) return;
    const fromElo: number = before;
    const toElo: number = after;
    setCounter(fromElo);
    setShowDelta(false);
    const DELAY = 700;
    const DURATION = 1600;
    let rafId: number;
    const t1 = setTimeout(() => {
      setShowDelta(true);
      const start = performance.now();
      function tick() {
        const elapsed = performance.now() - start;
        const t = Math.min(elapsed / DURATION, 1);
        const eased = 1 - Math.pow(1 - t, 3);
        setCounter(Math.round(fromElo + (toElo - fromElo) * eased));
        if (t < 1) rafId = requestAnimationFrame(tick);
      }
      rafId = requestAnimationFrame(tick);
    }, DELAY);
    return () => { clearTimeout(t1); cancelAnimationFrame(rafId); };
  }, [before, after]);

  if (before === null || counter === null) return null;
  const delta = after !== null ? after - before : null;

  return (
    <div className="flex flex-col items-center gap-1.5">
      {delta !== null && delta !== 0 && (
        <p className={`text-xs font-display font-bold tabular-nums transition-all duration-300 ${
          showDelta ? 'opacity-100' : 'opacity-0'
        } ${delta > 0 ? 'text-[#22C55E]' : 'text-[#EF4444]'}`}>
          {delta > 0 ? '+' : ''}{delta}
        </p>
      )}
      <p className="font-display font-black text-xl tabular-nums text-[#F5F0E8]">{counter}</p>
      <RankBadge elo={counter} size="sm" />
    </div>
  );
}

function getUnitAccuracyColor(accuracy: number | null, elo: number): string {
  if (accuracy === null) return 'transparent';
  const threshold = elo < 900 ? 0.65 : elo < 1100 ? 0.70 : elo < 1300 ? 0.75 : elo < 1500 ? 0.82 : 0.88;
  if (accuracy >= threshold) return '#22C55E';
  if (accuracy >= threshold - 0.15) return '#EAB308';
  return '#EF4444';
}

const MVP_SUBJECTS = [
  'AP Biology',
  'AP Chemistry',
  'AP US History',
  'AP Psychology',
  'AP Calculus AB',
];

type AppPhase =
  | 'idle'
  | 'queuing'
  | 'countdown'
  | 'battle'
  | 'finished'
  | 'complete'
  | 'practice-select'
  | 'practice';

interface Question {
  id: string;
  stem: string;
  options: string[];
  correct_index: number;
}

interface BattleState {
  phase: 'question' | 'reveal' | 'waiting';
  question: Question | null;
  qIndex: number;
  qTotal: number;
  selectedIndex: number | null;
  correctIndex: number | null;
  lastCorrect: boolean | null;
  opponentAnswer: number | null;
  myScore: number;
  oppScore: number;
  oppQIndex: number;
}

export default function Home() {
  const router = useRouter();
  const [appPhase, setAppPhase] = useState<AppPhase>('idle');
  const [userId, setUserId] = useState<string | null>(null);
  const [displayName, setDisplayName] = useState('');
  const [subject, setSubject] = useState('AP Chemistry');
  const [roomId, setRoomId] = useState<string | null>(null);
  const [opponent, setOpponent] = useState<{ displayName: string; userId: string } | null>(null);
  const [countdown, setCountdown] = useState(3);
  const [winner, setWinner] = useState<string | null>(null);
  const [forfeit, setForfeit] = useState<{ forfeitedBy: string | null } | null>(null);
  const [finalScores, setFinalScores] = useState<Record<string, number>>({});
  const [finalTimes, setFinalTimes] = useState<Record<string, number | null>>({});
  const [myElo, setMyElo] = useState<number | null>(null);
  const [myEloBefore, setMyEloBefore] = useState<number | null>(null);
  const [eloDelta, setEloDelta] = useState<number | null>(null);
  const [opponentElo, setOpponentElo] = useState<number | null>(null);
  const [opponentEloAfter, setOpponentEloAfter] = useState<number | null>(null);
  const [opponentEloDelta, setOpponentEloDelta] = useState<number | null>(null);
  const [isOpponentFriend, setIsOpponentFriend] = useState(false);
  const [practiceUnit, setPracticeUnit] = useState<string | null>(null);
  const [practiceUnits, setPracticeUnits] = useState<string[]>([]);
  const [practiceUnitsLoading, setPracticeUnitsLoading] = useState(false);
  const [practiceQuestions, setPracticeQuestions] = useState<PracticeQuestion[]>([]);
  const questionStartedAt = useRef<number | null>(null);
  const userIdRef = useRef<string | null>(null);

  // ── Friends state ──────────────────────────────────────────────────────────
  const [friendsPanelOpen, setFriendsPanelOpen] = useState(false);
  const [friendsPendingCount, setFriendsPendingCount] = useState(0);
  const [friendsUnreadCount, setFriendsUnreadCount] = useState(0);
  const [onlineFriendIds, setOnlineFriendIds] = useState<Set<string>>(new Set());
  const [friendActivity, setFriendActivity] = useState<Record<string, { subject: string; phase: string } | null>>({});
  const [incomingChallenge, setIncomingChallenge] = useState<IncomingChallenge | null>(null);

  const [battle, setBattle] = useState<BattleState>({
    phase: 'question',
    question: null,
    qIndex: 0,
    qTotal: 0,
    selectedIndex: null,
    correctIndex: null,
    lastCorrect: null,
    opponentAnswer: null,
    myScore: 0,
    oppScore: 0,
    oppQIndex: 0,
  });

  useEffect(() => {
    const supabase = createClient();
    supabase.auth.getUser().then(async ({ data: { user } }) => {
      if (!user) { router.push('/login'); return; }
      setUserId(user.id);
      userIdRef.current = user.id;
      const { data } = await supabase
        .from('profiles')
        .select('display_name')
        .eq('id', user.id)
        .single();
      if (data) setDisplayName(data.display_name);
      // Register presence if socket is already connected
      const sock = getSocket();
      if (sock.connected) sock.emit('register_presence', { userId: user.id });
      const { data: eloRow } = await supabase
        .from('elo_ratings')
        .select('rating')
        .eq('user_id', user.id)
        .eq('subject', subject)
        .maybeSingle();
      setMyElo(eloRow?.rating ?? 1000);
    });
  }, [router, subject]);

  useEffect(() => {
    if (!userId) return;
    const supabase = createClient();
    supabase
      .from('elo_ratings')
      .select('rating')
      .eq('user_id', userId)
      .eq('subject', subject)
      .single()
      .then(({ data }) => setMyElo(data?.rating ?? 1000));
  }, [userId, subject]);

  const resetBattleState = useCallback(() => {
    questionStartedAt.current = null;
    setBattle({
      phase: 'question',
      question: null,
      qIndex: 0,
      qTotal: 0,
      selectedIndex: null,
      correctIndex: null,
      lastCorrect: null,
      opponentAnswer: null,
      myScore: 0,
      oppScore: 0,
      oppQIndex: 0,
    });
    setRoomId(null);
    setOpponent(null);
    setWinner(null);
    setForfeit(null);
    setFinalScores({});
    setEloDelta(null);
    setMyEloBefore(null);
    setOpponentEloAfter(null);
    setOpponentEloDelta(null);
    setIsOpponentFriend(false);
  }, []);

  useEffect(() => {
    const socket = getSocket();
    socket.connect();
    socket.on('connect', () => {
      console.log('[socket] connected:', socket.id);
      if (userIdRef.current) socket.emit('register_presence', { userId: userIdRef.current });
    });
    socket.on('connect_error', (err) => console.error('[socket] error:', err.message));

    // ── Friends / presence events ──────────────────────────────────────────
    socket.on('presence_init', ({ onlineUserIds }: { onlineUserIds: string[] }) => {
      setOnlineFriendIds(new Set(onlineUserIds));
    });
    socket.on('friend_online', ({ userId: uid }: { userId: string }) => {
      setOnlineFriendIds(prev => new Set([...prev, uid]));
    });
    socket.on('friend_offline', ({ userId: uid }: { userId: string }) => {
      setOnlineFriendIds(prev => { const s = new Set(prev); s.delete(uid); return s; });
    });
    socket.on('friend_activity_update', ({ userId: uid, activity }: { userId: string; activity: { subject: string; phase: string } | null }) => {
      setFriendActivity(prev => {
        const next = { ...prev };
        if (activity === null) delete next[uid]; else next[uid] = activity;
        return next;
      });
    });
    socket.on('friend_challenge_received', ({ challengeId, fromUserId, fromDisplayName, subject }: { challengeId: string; fromUserId: string; fromDisplayName: string; subject: string }) => {
      setIncomingChallenge({ challengeId, fromUserId, fromDisplayName, subject, receivedAt: Date.now() });
    });
    socket.on('friend_challenge_declined', () => setIncomingChallenge(null));
    socket.on('friend_challenge_expired', () => setIncomingChallenge(null));
    socket.on('new_message', () => {
      // Only increment the NavBar badge when the panel is not open
      // (FriendsPanel manages per-friend counts internally when open)
      setFriendsPanelOpen(open => {
        if (!open) setFriendsUnreadCount(prev => prev + 1);
        return open;
      });
    });

    socket.on('queue_joined', () => setAppPhase('queuing'));
    socket.on('queue_left', () => setAppPhase('idle'));
    socket.on('queue_timeout', () => setAppPhase('idle'));

    socket.on('match_found', ({ roomId: rid, opponent: opp, myElo: serverMyElo }) => {
      setRoomId(rid);
      setOpponent({ displayName: opp.displayName, userId: opp.userId ?? '' });
      setOpponentElo(opp?.elo ?? 1000);
      if (typeof serverMyElo === 'number') setMyElo(serverMyElo);
      setAppPhase('countdown');
      // Check friendship with opponent
      if (userIdRef.current && opp?.userId) {
        const myUid = userIdRef.current;
        const oppUid = opp.userId;
        createClient()
          .from('friendships')
          .select('status')
          .or(`and(requester_id.eq.${myUid},addressee_id.eq.${oppUid}),and(requester_id.eq.${oppUid},addressee_id.eq.${myUid})`)
          .eq('status', 'accepted')
          .maybeSingle()
          .then(({ data }) => setIsOpponentFriend(!!data));
      }
      let n = 3;
      setCountdown(n);
      const t = setInterval(() => {
        n--;
        setCountdown(n);
        if (n <= 0) { clearInterval(t); setAppPhase('battle'); }
      }, 1000);
    });

    socket.on('question', ({ index, total, question }) => {
      if (index === 0) questionStartedAt.current = Date.now();
      setAppPhase('battle');
      setBattle(prev => ({
        ...prev,
        phase: 'question',
        question,
        qIndex: index + 1,
        qTotal: total,
        selectedIndex: null,
        correctIndex: null,
        lastCorrect: null,
        opponentAnswer: null,
      }));
    });

    socket.on('question_result', ({ correct_index, your_answer, correct, score, opponent_score }: {
      correct_index: number;
      your_answer: number;
      correct: boolean;
      score: number;
      opponent_score: number;
    }) => {
      setBattle(prev => ({
        ...prev,
        phase: 'reveal',
        correctIndex: correct_index,
        selectedIndex: your_answer ?? prev.selectedIndex,
        lastCorrect: correct,
        opponentAnswer: null,
        myScore: score,
        oppScore: opponent_score,
      }));
    });

    socket.on('opponent_progress', ({ score, questionIndex }: { score: number; questionIndex: number }) => {
      setBattle(prev => ({ ...prev, oppScore: score, oppQIndex: questionIndex }));
    });

    socket.on('waiting_for_opponent', ({ myScore, opponentScore }: { myScore: number; opponentScore: number }) => {
      setBattle(prev => ({ ...prev, phase: 'waiting', myScore, oppScore: opponentScore }));
    });

    socket.on('you_finished', ({ score, opponent_score }: { score: number; opponent_score: number }) => {
      setBattle(prev => ({ ...prev, myScore: score, oppScore: opponent_score }));
      setAppPhase('finished');
    });

    socket.on('battle_complete', ({ scores, winner: w, timeTakenMs, eloDeltas, forfeit: didForfeit, forfeitedBy }: { scores: Record<string, number>; winner: string | null; timeTakenMs: Record<string, number | null>; eloDeltas: Record<string, { before: number; after: number; delta: number }>; forfeit: boolean; forfeitedBy: string | null }) => {
      setFinalScores(scores);
      setFinalTimes(timeTakenMs ?? {});
      setWinner(w);
      setForfeit(didForfeit ? { forfeitedBy: forfeitedBy ?? null } : null);
      const myId = getSocket().id;
      if (myId && eloDeltas?.[myId]) {
        setMyEloBefore(eloDeltas[myId].before);
        setMyElo(eloDeltas[myId].after);
        setEloDelta(eloDeltas[myId].delta);
      }
      const oppSocketId = Object.keys(eloDeltas ?? {}).find(id => id !== myId);
      if (oppSocketId && eloDeltas?.[oppSocketId]) {
        setOpponentElo(eloDeltas[oppSocketId].before);
        setOpponentEloAfter(eloDeltas[oppSocketId].after);
        setOpponentEloDelta(eloDeltas[oppSocketId].delta);
      }
      setAppPhase('complete');
    });

    socket.on('opponent_disconnected', () => {
      // Informational only — server sends battle_complete immediately.
    });

    return () => { socket.disconnect(); };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function startPracticeSelect() {
    setPracticeUnitsLoading(true);
    setAppPhase('practice-select');
    const supabase = createClient();
    const { data } = await supabase
      .from('source_cards')
      .select('unit')
      .eq('subject', subject)
      .eq('reviewed', true);
    const units = [...new Set((data ?? []).map((r: { unit: string }) => r.unit))].sort();
    setPracticeUnits(units);
    setPracticeUnitsLoading(false);
  }

  async function startPractice(unit: string) {
    setPracticeUnit(unit);
    setAppPhase('practice');
    const supabase = createClient();
    const { data: cards } = await supabase
      .from('source_cards')
      .select('id, content')
      .eq('subject', subject)
      .eq('unit', unit)
      .eq('reviewed', true);
    if (!cards || cards.length === 0) { setAppPhase('practice-select'); return; }
    const cardIds = cards.map(c => c.id);
    interface CardContent { correct_explanation?: string }
    const contentMap: Record<string, CardContent | null> = Object.fromEntries(
      cards.map(c => [c.id, c.content as CardContent | null])
    );
    const { data: variants } = await supabase
      .from('question_variants')
      .select('id, rendered_stem, rendered_options, correct_index, source_card_id')
      .in('source_card_id', cardIds)
      .limit(150);
    const shuffled = [...(variants ?? [])].sort(() => Math.random() - 0.5).slice(0, 20);
    const questions: PracticeQuestion[] = shuffled.map(v => ({
      id: v.id as string,
      stem: v.rendered_stem as string,
      options: (v.rendered_options as string[]) ?? [],
      correctIndex: (v.correct_index as number) ?? 0,
      correctExplanation: contentMap[v.source_card_id as string]?.correct_explanation ?? null,
    }));
    setPracticeQuestions(questions);
  }

  function exitPractice() {
    setPracticeUnit(null);
    setPracticeQuestions([]);
    setAppPhase('practice-select');
  }

  function exitPracticeToLobby() {
    setPracticeUnit(null);
    setPracticeUnits([]);
    setPracticeQuestions([]);
    setAppPhase('idle');
  }

  function joinQueue() {
    const socket = getSocket();
    socket.emit('join_queue', { userId: userId ?? socket.id, displayName, elo: myElo ?? 1000, subject });
  }

  function leaveQueue() {
    getSocket().emit('leave_queue');
  }

  async function handleSignOut() {
    await createClient().auth.signOut();
    router.push('/login');
  }

  function submitAnswer(index: number) {
    if (battle.selectedIndex !== null || battle.phase === 'reveal') return;
    setBattle(prev => ({ ...prev, selectedIndex: index }));
    const clientTimeTakenMs = questionStartedAt.current != null ? Date.now() - questionStartedAt.current : null;
    getSocket().emit('submit_answer', { roomId, answerIndex: index, clientTimeTakenMs });
  }

  function playAgain() {
    resetBattleState();
    setAppPhase('queuing');
    const socket = getSocket();
    socket.emit('join_queue', { userId: userId ?? socket.id, displayName, elo: myElo ?? 1000, subject });
  }

  function returnToLobby() {
    resetBattleState();
    setAppPhase('idle');
  }

  function handleAcceptChallenge(challengeId: string) {
    getSocket().emit('accept_friend_challenge', { challengeId });
    setIncomingChallenge(null);
  }

  function handleDeclineChallenge(challengeId: string) {
    getSocket().emit('decline_friend_challenge', { challengeId });
    setIncomingChallenge(null);
  }

  // ── Practice ──────────────────────────────────────────────────────────────
  if (appPhase === 'practice') {
    return (
      <PracticeMode
        questions={practiceQuestions}
        subject={subject}
        unit={practiceUnit ?? ''}
        onExit={exitPractice}
      />
    );
  }

  // ── Complete ───────────────────────────────────────────────────────────────
  if (appPhase === 'complete') {
    const socket = getSocket();
    const myScore = finalScores[socket.id ?? ''] ?? battle.myScore;
    const oppScore = Object.entries(finalScores).find(([id]) => id !== socket.id)?.[1] ?? battle.oppScore;
    const myTimeMs = finalTimes[socket.id ?? ''] ?? null;
    const oppTimeMs = Object.entries(finalTimes).find(([id]) => id !== socket.id)?.[1] ?? null;
    const fmtTime = (ms: number | null) => ms != null ? `${(ms / 1000).toFixed(2)}s` : null;
    const iWon = winner === socket.id;
    const tied = winner === null;
    const wasForfeit = forfeit !== null;

    return (
      <main className="min-h-screen text-[#F5F0E8] flex flex-col items-center justify-center px-4 py-16">
        <div className="relative w-full max-w-md flex flex-col items-center">
          <div className="glow-focus animate-glow-pulse" />

          <div className="panel-raised panel-accent-top relative z-10 w-full px-8 py-10 flex flex-col items-center gap-7 animate-gold-burst">
            {/* Result heading */}
            <div className="flex flex-col items-center gap-2">
              <p className="text-[10px] text-[#F5F0E8]/30 uppercase tracking-[0.4em]">Match Result</p>
              <h2 className={`font-display font-black uppercase leading-none animate-vs-clash ${
                tied
                  ? 'text-6xl text-[#F5F0E8]/40 tracking-[0.15em]'
                  : iWon
                  ? 'text-7xl text-foil tracking-[0.12em]'
                  : 'text-7xl text-[#F5F0E8]/25 tracking-[0.15em]'
              }`}>
                {tied ? 'DRAW' : iWon ? 'VICTORY' : 'DEFEAT'}
              </h2>
            </div>

            {wasForfeit && (
              <p className={`text-[11px] uppercase tracking-[0.2em] font-medium text-center ${iWon ? 'text-[#22C55E]' : 'text-[#EF4444]/60'}`}>
                {iWon ? 'Opponent disconnected — you win' : 'You disconnected — counted as a loss'}
              </p>
            )}

            <div className="rule-gold w-full" />

            {/* Scores + animated ELO */}
            <div className="flex items-center justify-center gap-8 w-full">
              <div className="flex flex-col items-center gap-2 flex-1">
                <p className="text-[11px] text-[#F5F0E8]/40 uppercase tracking-[0.18em] truncate max-w-[8rem]">{displayName || 'You'}</p>
                <p className="font-display font-black text-6xl tabular-nums text-[#F5F0E8]">{myScore}</p>
                {fmtTime(myTimeMs) && (
                  <p className="text-[11px] text-[#C9A84C]/70 uppercase tracking-[0.2em] tabular-nums">{fmtTime(myTimeMs)}</p>
                )}
                {myEloBefore !== null
                  ? <AnimatedEloSection before={myEloBefore} after={myElo ?? myEloBefore} />
                  : <RankBadge elo={myElo} size="sm" />
                }
              </div>
              <span className="font-display font-black text-2xl uppercase tracking-[0.1em] text-[#2A2A2A] select-none">vs</span>
              <div className="flex flex-col items-center gap-2 flex-1">
                <p className="text-[11px] text-[#F5F0E8]/40 uppercase tracking-[0.18em] truncate max-w-[8rem]">{opponent?.displayName ?? 'Opponent'}</p>
                <p className="font-display font-black text-6xl tabular-nums text-[#F5F0E8]">{oppScore}</p>
                {fmtTime(oppTimeMs) && (
                  <p className="text-[11px] text-[#C9A84C]/70 uppercase tracking-[0.2em] tabular-nums">{fmtTime(oppTimeMs)}</p>
                )}
                {opponentEloAfter !== null
                  ? <AnimatedEloSection before={opponentElo ?? 1000} after={opponentEloAfter} />
                  : <RankBadge elo={opponentElo} size="sm" />
                }
              </div>
            </div>

            {/* Add friend */}
            {opponent?.userId && userId && opponent.userId !== userId && !isOpponentFriend && (
              <div className="flex justify-center w-full">
                <AddFriendButton
                  viewerId={userId}
                  targetId={opponent.userId}
                  initialStatus="none"
                  friendshipId={null}
                />
              </div>
            )}

            {/* Actions */}
            <div className="flex gap-3 mt-1 w-full">
              <button
                onClick={playAgain}
                className="btn-gold flex-1 font-display font-black text-sm uppercase tracking-[0.18em] px-6 py-3"
              >
                Play Again
              </button>
              <button
                onClick={returnToLobby}
                className="btn-ghost flex-1 font-display font-bold text-sm uppercase tracking-[0.18em] px-6 py-3"
              >
                Lobby
              </button>
            </div>
          </div>
        </div>
      </main>
    );
  }

  // ── Battle ─────────────────────────────────────────────────────────────────
  if (appPhase === 'battle' && battle.question) {
    const socket = getSocket();
    return (
      <BattleRoom
        battle={battle}
        opponent={opponent!}
        mySocketId={socket.id!}
        onSubmit={submitAnswer}
        myElo={myElo}
        opponentElo={opponentElo}
        displayName={displayName}
      />
    );
  }

  // ── Lobby / Queue / Countdown / Finished ───────────────────────────────────
  return (
    <>
      {(appPhase === 'idle' || appPhase === 'queuing') && (
        <NavBar
          displayName={displayName}
          elo={myElo}
          subject={appPhase === 'idle' ? subject : undefined}
          onFriendsClick={() => { setFriendsPanelOpen(o => !o); setFriendsUnreadCount(0); }}
          friendsBadge={friendsPendingCount + friendsUnreadCount + (incomingChallenge ? 1 : 0)}
        />
      )}

      {userId && (appPhase === 'idle' || appPhase === 'queuing') && (
        <FriendsPanel
          isOpen={friendsPanelOpen}
          onClose={() => setFriendsPanelOpen(false)}
          userId={userId}
          viewerSubject={subject}
          onlineUserIds={onlineFriendIds}
          friendActivity={friendActivity}
          incomingChallenge={incomingChallenge}
          onChallengeAccept={handleAcceptChallenge}
          onChallengeDecline={handleDeclineChallenge}
          onPendingCount={setFriendsPendingCount}
        />
      )}

      <main className="min-h-screen text-[#F5F0E8] flex flex-col items-center justify-center px-4 pt-12">

        {/* ── Idle ── */}
        {appPhase === 'idle' && (
          <div className="w-full max-w-5xl mx-auto animate-fade-up">
            <div className="flex flex-col lg:flex-row gap-6 items-start">

              {/* ── Left: Player card ── */}
              <div className="w-full lg:w-64 flex-shrink-0 flex flex-col gap-3">
                <div className="border border-[#2A2A2A] bg-[#141414] p-6 flex flex-col gap-5">
                  <div>
                    <p className="text-[10px] text-[#F5F0E8]/25 uppercase tracking-[0.3em] mb-2">Your ELO</p>
                    <p className="font-display font-black text-5xl tabular-nums text-[#C9A84C] leading-none">{myElo ?? 1000}</p>
                  </div>
                  <div className="h-px bg-[#2A2A2A]" />
                  <div>
                    <p className="text-[10px] text-[#F5F0E8]/25 uppercase tracking-[0.3em] mb-1">Player</p>
                    <p className="text-sm text-[#F5F0E8]/70 font-medium truncate">{displayName || '—'}</p>
                  </div>
                  <div>
                    <p className="text-[10px] text-[#F5F0E8]/25 uppercase tracking-[0.3em] mb-1">Subject</p>
                    <p className="text-sm text-[#C9A84C] font-semibold">{subject.replace('AP ', '')}</p>
                  </div>
                </div>
                <button
                  onClick={handleSignOut}
                  className="text-[#F5F0E8]/15 hover:text-[#F5F0E8]/40 text-[10px] uppercase tracking-[0.3em] transition-colors text-left px-1 py-1"
                >
                  Sign out
                </button>
              </div>

              {/* ── Right: Subject + CTA ── */}
              <div className="flex-1 flex flex-col gap-5">
                <div>
                  <p className="text-[10px] text-[#F5F0E8]/25 uppercase tracking-[0.3em] mb-4">Select Subject</p>
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2">
                    {MVP_SUBJECTS.map(s => {
                      const isLive = s === 'AP Chemistry' || s === 'AP Biology';
                      const isSelected = subject === s;
                      return (
                        <button
                          key={s}
                          onClick={() => isLive && setSubject(s)}
                          disabled={!isLive}
                          className={`relative flex flex-col items-start px-5 py-4 border transition-all text-left ${
                            isSelected
                              ? 'border-[#C9A84C] bg-[#C9A84C]/10'
                              : isLive
                              ? 'border-[#2A2A2A] bg-[#141414] hover:border-[#C9A84C]/40 hover:bg-[#1C1C1C]'
                              : 'border-[#1C1C1C] bg-[#0D0D0D] opacity-40 cursor-not-allowed'
                          }`}
                        >
                          <div className="flex items-center justify-between w-full mb-2">
                            <span className={`text-[9px] uppercase tracking-[0.3em] font-bold ${
                              isSelected ? 'text-[#C9A84C]' : isLive ? 'text-[#22C55E]' : 'text-[#F5F0E8]/20'
                            }`}>
                              {isLive ? 'Live' : 'Soon'}
                            </span>
                            {isSelected && (
                              <span className="w-1.5 h-1.5 bg-[#C9A84C]" />
                            )}
                          </div>
                          <span className={`font-display font-bold text-sm uppercase tracking-wide leading-tight ${
                            isSelected ? 'text-[#C9A84C]' : isLive ? 'text-[#F5F0E8]/80' : 'text-[#F5F0E8]/25'
                          }`}>
                            {s.replace('AP ', '')}
                          </span>
                          <span className={`text-[10px] mt-0.5 ${isSelected ? 'text-[#C9A84C]/60' : 'text-[#F5F0E8]/20'}`}>
                            AP {s.includes('Calculus') ? 'Exam' : 'Exam'}
                          </span>
                        </button>
                      );
                    })}
                  </div>
                </div>

                <button
                  onClick={joinQueue}
                  disabled={!displayName || (subject !== 'AP Chemistry' && subject !== 'AP Biology')}
                  className="w-full bg-[#C9A84C] hover:bg-[#D4B565] disabled:opacity-30 disabled:cursor-not-allowed text-[#0A0A0A] font-display font-black text-xl uppercase tracking-[0.2em] py-5 transition-colors"
                >
                  Find Match
                </button>
                <button
                  onClick={startPracticeSelect}
                  disabled={!displayName}
                  className="w-full text-[#F5F0E8]/35 hover:text-[#F5F0E8]/65 disabled:opacity-20 disabled:cursor-not-allowed text-sm font-display font-bold uppercase tracking-[0.2em] py-2 transition-colors"
                >
                  Practice Solo
                </button>
              </div>
            </div>
          </div>
        )}

        {/* ── Practice Select ── */}
        {appPhase === 'practice-select' && (
          <div className="w-full max-w-xl mx-auto animate-fade-up">
            <button
              onClick={exitPracticeToLobby}
              className="text-[#F5F0E8]/25 hover:text-[#F5F0E8]/60 text-xs uppercase tracking-widest mb-8 block transition-colors"
            >
              ← Back
            </button>
            <div className="flex flex-col gap-5">
              <div>
                <p className="text-[10px] text-[#F5F0E8]/25 uppercase tracking-[0.3em] mb-1">Practice Mode</p>
                <h2 className="font-display font-black text-3xl uppercase tracking-[0.1em] text-[#F5F0E8]">
                  {subject.replace('AP ', '')}
                </h2>
              </div>
              <p className="text-[10px] text-[#F5F0E8]/30 uppercase tracking-[0.25em]">Select a unit</p>
              {practiceUnitsLoading ? (
                <div className="flex gap-2">
                  <span className="w-2 h-2 bg-[#C9A84C] dot-1" />
                  <span className="w-2 h-2 bg-[#C9A84C] dot-2" />
                  <span className="w-2 h-2 bg-[#C9A84C] dot-3" />
                </div>
              ) : practiceUnits.length === 0 ? (
                <p className="text-[#F5F0E8]/25 text-sm uppercase tracking-widest">No practice questions available yet.</p>
              ) : (
                <div className="flex flex-col gap-2">
                  {practiceUnits.map(unit => {
                    const allStats = getPracticeStats(subject);
                    const unitStats = allStats[unit];
                    const accuracy = unitStats && unitStats.total > 0 ? unitStats.correct / unitStats.total : null;
                    const color = getUnitAccuracyColor(accuracy, myElo ?? 1000);
                    return (
                      <button
                        key={unit}
                        onClick={() => startPractice(unit)}
                        className="text-left panel hover:bg-[#1C1C1C] hover:border-[#C9A84C]/40 px-5 py-4 transition-all group flex items-center gap-3"
                      >
                        <div className="flex flex-col min-w-0 flex-1">
                          <p className="text-[9px] text-[#F5F0E8]/25 uppercase tracking-[0.2em] mb-1">
                            {unit.match(/^Unit \d+/)?.[0] ?? 'Unit'}
                          </p>
                          <p className="font-display font-bold text-sm uppercase tracking-wide text-[#F5F0E8]/70 group-hover:text-[#F5F0E8] transition-colors">
                            {unit.replace(/^Unit \d+: /, '')}
                          </p>
                        </div>
                        {accuracy !== null && (
                          <span
                            className="flex-shrink-0 font-display font-black text-sm tabular-nums"
                            style={{ color }}
                          >
                            {Math.round(accuracy * 100)}%
                          </span>
                        )}
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        )}

        {/* ── Queuing ── */}
        {appPhase === 'queuing' && (
          <div className="relative flex flex-col items-center">
            <div className="glow-focus animate-glow-pulse" />
            <div className="panel-raised relative z-10 px-12 py-10 flex flex-col items-center gap-5 animate-rise-in">
              <p className="text-[10px] text-[#F5F0E8]/30 uppercase tracking-[0.4em]">Searching</p>
              <p className="font-display font-bold text-3xl uppercase tracking-[0.15em] text-[#F5F0E8]/60">
                Finding Opponent
              </p>
              <div className="rule-gold w-32" />
              <p className="text-[#C9A84C] text-xs uppercase tracking-[0.25em] font-bold">{subject}</p>
              <div className="flex gap-2 mt-1">
                <span className="w-2 h-2 bg-[#C9A84C] dot-1" />
                <span className="w-2 h-2 bg-[#C9A84C] dot-2" />
                <span className="w-2 h-2 bg-[#C9A84C] dot-3" />
              </div>
              <button
                onClick={leaveQueue}
                className="mt-2 text-[#F5F0E8]/20 hover:text-[#F5F0E8]/50 text-xs uppercase tracking-widest transition-colors"
              >
                Cancel
              </button>
            </div>
          </div>
        )}

        {/* ── Countdown ── */}
        {appPhase === 'countdown' && (
          <div className="relative flex flex-col items-center gap-10 w-full max-w-lg">
            <div className="glow-focus animate-glow-pulse" />

            {/* VS matchup */}
            <div className="relative z-10 flex items-center justify-center gap-6 w-full animate-rise-in">
              <div className="flex flex-col items-center gap-2 flex-1 text-right">
                <p className="font-display font-black text-xl uppercase tracking-[0.12em] text-[#F5F0E8] truncate max-w-full">
                  {displayName || 'You'}
                </p>
                <RankBadge elo={myElo} size="sm" />
              </div>
              <span className="font-display font-black text-3xl uppercase text-[#C9A84C] animate-vs-clash select-none">
                VS
              </span>
              <div className="flex flex-col items-center gap-2 flex-1 text-left">
                <p className="font-display font-black text-xl uppercase tracking-[0.12em] text-[#F5F0E8] truncate max-w-full">
                  {opponent?.displayName}
                </p>
                <RankBadge elo={opponentElo} size="sm" />
              </div>
            </div>

            <div className="rule-gold relative z-10 w-2/3" />

            {isOpponentFriend && (
              <div className="relative z-10 flex items-center gap-1.5 px-3 py-1 border border-[#22C55E]/30 bg-[#22C55E]/5">
                <span className="w-1.5 h-1.5 bg-[#22C55E]" />
                <span className="text-[9px] text-[#22C55E]/70 uppercase tracking-[0.2em] font-display font-bold">Friends</span>
              </div>
            )}

            <p
              key={countdown}
              className="relative z-10 font-display font-black text-[10rem] leading-none text-foil tabular-nums animate-count-in select-none"
            >
              {countdown}
            </p>
          </div>
        )}

        {/* ── Finished (you answered all, waiting for opponent) ── */}
        {appPhase === 'finished' && (
          <div className="relative w-full max-w-md flex flex-col items-center">
            <div className="glow-focus animate-glow-pulse" />
            <div className="panel-raised panel-accent-top relative z-10 w-full px-8 py-9 flex flex-col items-center gap-6 animate-rise-in">
              <div className="flex flex-col items-center gap-1">
                <p className="font-display font-bold text-2xl uppercase tracking-[0.15em] text-[#F5F0E8]/55">
                  All Done
                </p>
                <p className="text-[#F5F0E8]/25 text-[11px] uppercase tracking-[0.2em]">Waiting for opponent to finish</p>
              </div>

              <div className="rule-gold w-full" />

              <div className="flex items-center justify-center gap-8 w-full">
                <div className="flex flex-col items-center gap-2 flex-1">
                  <p className="text-[11px] text-[#F5F0E8]/40 uppercase tracking-[0.18em] truncate max-w-[8rem]">{displayName || 'You'}</p>
                  <p className="font-display font-black text-6xl tabular-nums text-[#F5F0E8]">{battle.myScore}</p>
                  <RankBadge elo={myElo} size="sm" />
                </div>
                <span className="font-display font-black text-2xl uppercase tracking-[0.1em] text-[#2A2A2A] select-none">vs</span>
                <div className="flex flex-col items-center gap-2 flex-1">
                  <p className="text-[11px] text-[#F5F0E8]/40 uppercase tracking-[0.18em] truncate max-w-[8rem]">{opponent?.displayName}</p>
                  <p className="font-display font-black text-6xl tabular-nums text-[#F5F0E8]">{battle.oppScore}</p>
                  <RankBadge elo={opponentElo} size="sm" />
                </div>
              </div>

              <div className="flex gap-2">
                <span className="w-2 h-2 bg-[#C9A84C] dot-1" />
                <span className="w-2 h-2 bg-[#C9A84C] dot-2" />
                <span className="w-2 h-2 bg-[#C9A84C] dot-3" />
              </div>
            </div>
          </div>
        )}
      </main>
    </>
  );
}
