'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { getSocket } from '@/lib/socket';
import { createClient } from '@/lib/supabase/client';
import BattleRoom from '@/components/BattleRoom';

type AppPhase = 'idle' | 'queuing' | 'countdown' | 'battle' | 'finished' | 'complete';

interface Question {
  id: string;
  stem: string;
  options: string[];
  correct_index: number;
}

interface BattleState {
  phase: 'question' | 'reveal';
  question: Question | null;
  qIndex: number;
  qTotal: number;
  selectedIndex: number | null;
  correctIndex: number | null;
  lastCorrect: boolean | null;
  myScore: number;
  oppScore: number;
  oppQIndex: number;
}

export default function Home() {
  const router = useRouter();
  const [appPhase, setAppPhase] = useState<AppPhase>('idle');
  const [userId, setUserId] = useState<string | null>(null);
  const [displayName, setDisplayName] = useState('');
  const [roomId, setRoomId] = useState<string | null>(null);
  const [opponent, setOpponent] = useState<{ displayName: string } | null>(null);
  const [countdown, setCountdown] = useState(3);
  const [winner, setWinner] = useState<string | null>(null);
  const [finalScores, setFinalScores] = useState<Record<string, number>>({});
  const [myElo, setMyElo] = useState<number | null>(null);
  const [eloDelta, setEloDelta] = useState<number | null>(null);
  const [opponentElo, setOpponentElo] = useState<number | null>(null);
  const [battle, setBattle] = useState<BattleState>({
    phase: 'question',
    question: null,
    qIndex: 0,
    qTotal: 0,
    selectedIndex: null,
    correctIndex: null,
    lastCorrect: null,
    myScore: 0,
    oppScore: 0,
    oppQIndex: 0,
  });

  // Load logged-in user's profile
  useEffect(() => {
    const supabase = createClient();
    supabase.auth.getUser().then(async ({ data: { user } }) => {
      if (!user) { router.push('/login'); return; }
      setUserId(user.id);
      const { data } = await supabase
        .from('profiles')
        .select('display_name')
        .eq('id', user.id)
        .single();
      if (data) setDisplayName(data.display_name);

      // Load current ELO
      const { data: eloRow } = await supabase
        .from('elo_ratings')
        .select('rating')
        .eq('user_id', user.id)
        .eq('subject', 'apchem')
        .single();
      setMyElo(eloRow?.rating ?? 1000);
    });
  }, [router]);

  useEffect(() => {
    const socket = getSocket();
    socket.connect();

    socket.on('queue_joined', () => setAppPhase('queuing'));
    socket.on('queue_left', () => setAppPhase('idle'));

    socket.on('match_found', ({ roomId, opponent }) => {
      setRoomId(roomId);
      setOpponent(opponent);
      setOpponentElo(null);
      setAppPhase('countdown');

      // Fetch opponent's ELO from Supabase
      createClient()
        .from('elo_ratings')
        .select('rating')
        .eq('user_id', opponent.userId)
        .eq('subject', 'apchem')
        .single()
        .then(({ data }) => setOpponentElo(data?.rating ?? 1000));
      let n = 3;
      setCountdown(n);
      const t = setInterval(() => {
        n--;
        setCountdown(n);
        if (n <= 0) { clearInterval(t); setAppPhase('battle'); }
      }, 1000);
    });

    // New independent-racing events
    socket.on('question', ({ index, total, question }) => {
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
      }));
    });

    // Per-player result — only this player sees it immediately
    socket.on('question_result', ({ correct_index, your_answer, correct, score, opponent_score }) => {
      setBattle(prev => ({
        ...prev,
        phase: 'reveal',
        correctIndex: correct_index,
        selectedIndex: your_answer ?? prev.selectedIndex,
        lastCorrect: correct,
        myScore: score,
        oppScore: opponent_score,
      }));
    });

    // Opponent made progress (answered or timed out)
    socket.on('opponent_progress', ({ score, questionIndex }) => {
      setBattle(prev => ({ ...prev, oppScore: score, oppQIndex: questionIndex }));
    });

    socket.on('you_finished', ({ score, opponent_score }) => {
      setBattle(prev => ({ ...prev, myScore: score, oppScore: opponent_score }));
      setAppPhase('finished');
    });

    socket.on('battle_complete', ({ scores, winner, eloDeltas }) => {
      setFinalScores(scores);
      setWinner(winner);
      const myId = getSocket().id;
      if (myId && eloDeltas?.[myId]) {
        const { after, delta } = eloDeltas[myId];
        setMyElo(after);
        setEloDelta(delta);
      }
      setAppPhase('complete');
    });

    socket.on('opponent_disconnected', () => {
      const socket = getSocket();
      setWinner(socket.id ?? null);
      setAppPhase('complete');
    });

    return () => { socket.disconnect(); };
  }, []);

  function joinQueue() {
    const socket = getSocket();
    socket.emit('join_queue', { userId: userId ?? socket.id, displayName, elo: 1000 });
  }

  async function handleSignOut() {
    await createClient().auth.signOut();
    router.push('/login');
  }

  function leaveQueue() {
    getSocket().emit('leave_queue');
  }

  function submitAnswer(index: number) {
    if (battle.selectedIndex !== null || battle.phase === 'reveal') return;
    setBattle(prev => ({ ...prev, selectedIndex: index }));
    getSocket().emit('submit_answer', { roomId, answerIndex: index });
  }

  // ── Complete screen ────────────────────────────────────────────────────────
  if (appPhase === 'complete') {
    const socket = getSocket();
    const myScore = finalScores[socket.id ?? ''] ?? battle.myScore;
    const oppScore = Object.entries(finalScores).find(([id]) => id !== socket.id)?.[1] ?? battle.oppScore;
    const iWon = winner === socket.id;
    const tied = winner === null;

    return (
      <main className="min-h-screen bg-gray-950 text-white flex flex-col items-center justify-center gap-6">
        <h2 className="text-3xl font-bold">{tied ? "It's a tie!" : iWon ? 'You win! 🏆' : 'You lose'}</h2>
        <p className="text-gray-400">{myScore} – {oppScore} vs {opponent?.displayName}</p>
        {eloDelta !== null && (
          <p className={`text-lg font-semibold ${eloDelta >= 0 ? 'text-green-400' : 'text-red-400'}`}>
            {eloDelta >= 0 ? '+' : ''}{eloDelta} ELO → {myElo}
          </p>
        )}
        <button onClick={() => window.location.reload()}
          className="bg-indigo-600 hover:bg-indigo-500 text-white font-semibold px-8 py-3 rounded-lg transition">
          Play Again
        </button>
      </main>
    );
  }

  // ── Finished — waiting for opponent ───────────────────────────────────────
  if (appPhase === 'finished') {
    return (
      <main className="min-h-screen bg-gray-950 text-white flex flex-col items-center justify-center gap-4">
        <p className="text-2xl font-bold">You finished!</p>
        <p className="text-gray-400">
          Your score: <strong className="text-white">{battle.myScore}</strong>
          {' · '}
          {opponent?.displayName}: <strong className="text-white">{battle.oppScore}</strong>
        </p>
        <p className="text-gray-500 animate-pulse text-sm">Waiting for opponent to finish…</p>
      </main>
    );
  }

  // ── Battle screen ──────────────────────────────────────────────────────────
  if (appPhase === 'battle') {
    const socket = getSocket();
    return (
      <BattleRoom
        battle={battle}
        opponent={opponent!}
        mySocketId={socket.id!}
        onSubmit={submitAnswer}
      />
    );
  }

  // ── Lobby / queue / countdown ──────────────────────────────────────────────
  return (
    <main className="min-h-screen bg-gray-950 text-white flex flex-col items-center justify-center gap-8">
      <h1 className="text-4xl font-bold tracking-tight">StudyArena</h1>

      {appPhase === 'idle' && (
        <div className="flex flex-col items-center gap-4">
          {displayName && (
            <p className="text-gray-400 text-sm">
              Playing as <strong className="text-white">{displayName}</strong>
              {myElo !== null && <span className="ml-2 text-indigo-400 font-semibold">{myElo} ELO</span>}
            </p>
          )}
          <button onClick={joinQueue} disabled={!displayName}
            className="bg-indigo-600 hover:bg-indigo-500 disabled:opacity-40 text-white font-semibold px-8 py-3 rounded-lg transition">
            Find Match
          </button>
          <button onClick={handleSignOut} className="text-xs text-gray-600 hover:text-gray-400 transition">
            Sign out
          </button>
        </div>
      )}

      {appPhase === 'queuing' && (
        <div className="flex flex-col items-center gap-4">
          <p className="text-gray-400 animate-pulse">Searching for opponent…</p>
          <button onClick={leaveQueue} className="text-sm text-gray-500 hover:text-gray-300 transition">Cancel</button>
        </div>
      )}

      {appPhase === 'countdown' && (
        <div className="flex flex-col items-center gap-4">
          <p className="text-gray-400">
            Matched vs <span className="text-white font-semibold">{opponent?.displayName}</span>
            {opponentElo !== null && (
              <span className="ml-2 text-indigo-400 font-semibold">{opponentElo} ELO</span>
            )}
          </p>
          <p className="text-6xl font-bold text-indigo-400">{countdown}</p>
        </div>
      )}
    </main>
  );
}
