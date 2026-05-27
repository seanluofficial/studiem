'use client';

import { useState, useEffect, useCallback } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';

const SOCKET_URL = process.env.NEXT_PUBLIC_SOCKET_URL ?? 'http://localhost:4000';

interface Question {
  id: string;
  stem: string;
  options: string[];
  correct_index: number;
}

interface ChallengeData {
  id: string;
  subject: string;
  questions_json: Question[];
  status: string;
  expires_at: string;
  challenger_id: string;
  challenger_score: number | null;
  opponent_score: number | null;
  winner_id: string | null;
}

type Phase = 'loading' | 'ready' | 'playing' | 'done' | 'error';

export default function ChallengePage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const [challenge, setChallenge] = useState<ChallengeData | null>(null);
  const [userId, setUserId] = useState<string | null>(null);
  const [phase, setPhase] = useState<Phase>('loading');
  const [error, setError] = useState<string | null>(null);
  const [currentQ, setCurrentQ] = useState(0);
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);
  const [startTime, setStartTime] = useState<number>(0);
  const [result, setResult] = useState<{ score: number; total: number } | null>(null);
  const [shareUrl, setShareUrl] = useState('');

  useEffect(() => {
    setShareUrl(window.location.href);
    const supabase = createClient();
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (!user) { router.push('/login'); return; }
      setUserId(user.id);
    });
  }, [router]);

  useEffect(() => {
    if (!id) return;
    fetch(`${SOCKET_URL}/challenge/${id}`)
      .then(r => r.json())
      .then((data: ChallengeData) => {
        setChallenge(data);
        if (data.status !== 'pending') setPhase('done');
        else setPhase('ready');
      })
      .catch(() => { setError('Challenge not found.'); setPhase('error'); });
  }, [id]);

  const startPlaying = useCallback(() => {
    setPhase('playing');
    setStartTime(Date.now());
    setCurrentQ(0);
    setAnswers({});
    setSelectedIndex(null);
  }, []);

  async function submitAnswer(idx: number) {
    if (selectedIndex !== null) return;
    setSelectedIndex(idx);

    const newAnswers = { ...answers, [currentQ]: idx };
    setAnswers(newAnswers);

    await new Promise(r => setTimeout(r, 1000)); // brief reveal

    if (currentQ + 1 < (challenge?.questions_json.length ?? 0)) {
      setCurrentQ(prev => prev + 1);
      setSelectedIndex(null);
    } else {
      // Submit
      const timeMs = Date.now() - startTime;
      try {
        const answersArr = (challenge?.questions_json ?? []).map((_, i) => newAnswers[i] ?? -1);
        const res = await fetch(`${SOCKET_URL}/challenge/${id}/submit`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ userId, answers: answersArr, timeMs }),
        });
        const data = await res.json() as { score: number; total: number };
        setResult(data);
      } catch {
        setResult({ score: 0, total: challenge?.questions_json.length ?? 10 });
      }
      setPhase('done');
    }
  }

  async function copyLink() {
    await navigator.clipboard.writeText(shareUrl);
  }

  if (phase === 'loading') {
    return (
      <main className="min-h-screen bg-[#0f0f14] text-white flex items-center justify-center">
        <p className="text-gray-400 animate-pulse">Loading challenge…</p>
      </main>
    );
  }

  if (phase === 'error' || !challenge) {
    return (
      <main className="min-h-screen bg-[#0f0f14] text-white flex flex-col items-center justify-center gap-4">
        <p className="text-red-400">{error ?? 'Challenge not found.'}</p>
        <a href="/" className="text-indigo-400 text-sm hover:underline">Go home</a>
      </main>
    );
  }

  if (phase === 'ready') {
    const isChallenger = userId === challenge.challenger_id;
    const expiresAt = new Date(challenge.expires_at).toLocaleString();
    return (
      <main className="min-h-screen bg-[#0f0f14] text-white flex flex-col items-center justify-center gap-6 px-4">
        <h1 className="text-2xl font-bold">Challenge</h1>
        <p className="text-gray-400 text-sm">{challenge.subject}</p>
        {!isChallenger && (
          <p className="text-gray-500 text-sm text-center max-w-sm">
            Someone challenged you! Answer 10 questions and see if you can beat their score. Expires {expiresAt}.
          </p>
        )}
        {isChallenger && (
          <p className="text-gray-500 text-sm text-center max-w-sm">
            Play these 10 questions to set your score, then share the link with a friend.
          </p>
        )}
        <button
          onClick={startPlaying}
          className="bg-indigo-600 hover:bg-indigo-500 text-white font-bold px-8 py-3 transition"
        >
          Start
        </button>
      </main>
    );
  }

  if (phase === 'done') {
    const isChallenger = userId === challenge.challenger_id;
    return (
      <main className="min-h-screen bg-[#0f0f14] text-white flex flex-col items-center justify-center gap-6 px-4">
        <h2 className="text-2xl font-bold">
          {challenge.status === 'completed' && challenge.winner_id === userId ? 'You win!' :
           challenge.status === 'completed' && challenge.winner_id !== null ? 'You lose' :
           result ? 'Done!' : 'Challenge complete'}
        </h2>
        {result && (
          <p className="text-3xl font-bold tabular-nums">
            {result.score} / {result.total}
          </p>
        )}
        {isChallenger && challenge.status === 'pending' && (
          <div className="flex flex-col items-center gap-3">
            <p className="text-gray-400 text-sm text-center">Share this link with your opponent:</p>
            <div className="flex gap-2 items-center">
              <input
                readOnly
                value={shareUrl}
                className="bg-gray-800 border border-gray-700 px-3 py-2 text-sm text-gray-300 w-64"
              />
              <button
                onClick={copyLink}
                className="bg-gray-700 hover:bg-gray-600 px-3 py-2 text-sm transition"
              >
                Copy
              </button>
            </div>
          </div>
        )}
        <a href="/" className="text-indigo-400 text-sm hover:underline">Back to lobby</a>
      </main>
    );
  }

  // Playing
  const questions = challenge.questions_json;
  const q = questions[currentQ];
  if (!q) return null;

  return (
    <main className="min-h-screen bg-[#0f0f14] text-white flex flex-col items-center justify-center gap-6 px-4">
      <div className="w-full max-w-xl flex justify-between text-sm text-gray-500">
        <span>Q {currentQ + 1}/{questions.length}</span>
        <span>{challenge.subject}</span>
      </div>
      <div className="w-full max-w-xl h-1 bg-gray-800">
        <div className="h-1 bg-indigo-500 transition-all" style={{ width: `${((currentQ) / questions.length) * 100}%` }} />
      </div>
      <div className="w-full max-w-xl flex flex-col gap-4">
        <p className="text-lg font-medium leading-relaxed">{q.stem}</p>
        <div className="flex flex-col gap-2">
          {q.options.map((opt, i) => {
            let cls = 'bg-gray-800 hover:bg-gray-700 border border-gray-700 text-gray-200';
            if (selectedIndex !== null) {
              if (i === q.correct_index) cls = 'bg-green-900 border border-green-500 text-green-200';
              else if (i === selectedIndex) cls = 'bg-red-900 border border-red-600 text-red-200';
              else cls = 'bg-gray-900 border border-gray-800 text-gray-600';
            }
            return (
              <button
                key={i}
                onClick={() => submitAnswer(i)}
                disabled={selectedIndex !== null}
                className={`w-full text-left px-4 py-3 transition ${cls}`}
              >
                <span className="font-bold mr-2 text-gray-500">{String.fromCharCode(65 + i)}.</span>
                {opt}
              </button>
            );
          })}
        </div>
      </div>
    </main>
  );
}
