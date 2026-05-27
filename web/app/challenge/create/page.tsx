'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';

const MVP_SUBJECTS = [
  'AP Biology',
  'AP Chemistry',
  'AP US History',
  'AP Psychology',
  'AP Calculus AB',
];

const SOCKET_URL = process.env.NEXT_PUBLIC_SOCKET_URL ?? 'http://localhost:4000';

export default function CreateChallengePage() {
  const router = useRouter();
  const [subject, setSubject] = useState('AP Chemistry');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function createChallenge() {
    setLoading(true);
    setError(null);
    try {
      const supabase = createClient();
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { router.push('/login'); return; }

      const res = await fetch(`${SOCKET_URL}/challenge`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ challengerId: user.id, subject }),
      });

      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error((err as { error?: string }).error ?? 'Failed to create challenge');
      }

      const { challengeId } = await res.json() as { challengeId: string };
      router.push(`/challenge/${challengeId}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Something went wrong');
      setLoading(false);
    }
  }

  return (
    <main className="min-h-screen bg-[#0f0f14] text-white flex flex-col items-center justify-center gap-6 px-4">
      <div className="w-full max-w-sm">
        <Link href="/" className="text-gray-600 hover:text-gray-400 text-sm transition">← Back</Link>
      </div>
      <h1 className="text-2xl font-bold">Create Challenge</h1>
      <p className="text-gray-500 text-sm text-center max-w-sm">
        Play 10 questions, then share a link. Your friend has 24 hours to beat your score.
      </p>

      <div className="w-full max-w-sm flex flex-col gap-4">
        <div>
          <label className="block text-xs text-gray-600 uppercase tracking-wider mb-2">Subject</label>
          <div className="flex flex-col gap-1">
            {MVP_SUBJECTS.map(s => (
              <button
                key={s}
                onClick={() => setSubject(s)}
                className={`text-left px-4 py-2 text-sm transition ${
                  subject === s
                    ? 'bg-indigo-600 text-white'
                    : 'bg-gray-800 text-gray-400 hover:bg-gray-700'
                }`}
              >
                {s}
                {s !== 'AP Chemistry' && <span className="ml-2 text-xs text-gray-600">Coming soon</span>}
              </button>
            ))}
          </div>
        </div>

        {error && <p className="text-red-400 text-sm">{error}</p>}

        <button
          onClick={createChallenge}
          disabled={loading || subject !== 'AP Chemistry'}
          className="bg-indigo-600 hover:bg-indigo-500 disabled:opacity-40 text-white font-bold px-8 py-3 transition"
        >
          {loading ? 'Creating…' : 'Start Challenge'}
        </button>
      </div>
    </main>
  );
}
