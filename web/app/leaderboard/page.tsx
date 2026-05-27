import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';

const MVP_SUBJECTS = [
  'AP Biology',
  'AP Chemistry',
  'AP US History',
  'AP Psychology',
  'AP Calculus AB',
];

interface LeaderboardEntry {
  rank: number;
  display_name: string;
  rating: number;
  user_id: string;
}

interface PageProps {
  searchParams: Promise<{ subject?: string }>;
}

export default async function LeaderboardPage({ searchParams }: PageProps) {
  const { subject: subjectParam } = await searchParams;
  const subject = MVP_SUBJECTS.includes(subjectParam ?? '') ? (subjectParam ?? MVP_SUBJECTS[0]) : MVP_SUBJECTS[0];

  const supabase = await createClient();
  const { data: rows } = await supabase
    .from('leaderboard')
    .select('rank, display_name, rating, user_id')
    .eq('subject', subject)
    .order('rank', { ascending: true })
    .limit(50);

  const entries: LeaderboardEntry[] = (rows ?? []).map(r => ({
    rank: r.rank as number,
    display_name: r.display_name as string,
    rating: r.rating as number,
    user_id: r.user_id as string,
  }));

  return (
    <main className="min-h-screen bg-[#0f0f14] text-white px-4 py-10 flex flex-col items-center gap-6">
      <div className="w-full max-w-xl">
        <Link href="/" className="text-gray-600 hover:text-gray-400 text-sm transition">← Back</Link>
      </div>

      <h1 className="text-2xl font-bold tracking-tight">Leaderboard</h1>

      {/* Subject tabs */}
      <div className="w-full max-w-xl flex flex-wrap gap-1">
        {MVP_SUBJECTS.map(s => (
          <Link
            key={s}
            href={`/leaderboard?subject=${encodeURIComponent(s)}`}
            className={`px-3 py-1 text-sm transition ${
              s === subject
                ? 'bg-indigo-600 text-white'
                : 'bg-gray-800 text-gray-400 hover:bg-gray-700 hover:text-white'
            }`}
          >
            {s.replace('AP ', '')}
          </Link>
        ))}
      </div>

      {/* Table */}
      <div className="w-full max-w-xl">
        {entries.length === 0 ? (
          <p className="text-gray-600 text-sm text-center py-8">No ratings yet for {subject}.</p>
        ) : (
          <div className="flex flex-col gap-px">
            <div className="flex text-xs text-gray-600 uppercase tracking-wider px-4 py-2">
              <span className="w-10">#</span>
              <span className="flex-1">Player</span>
              <span className="w-20 text-right">ELO</span>
            </div>
            {entries.map((entry, i) => (
              <div
                key={entry.user_id}
                className={`flex items-center px-4 py-3 text-sm ${
                  i === 0 ? 'bg-yellow-900/30' : i === 1 ? 'bg-gray-700/40' : i === 2 ? 'bg-orange-900/20' : 'bg-gray-900'
                }`}
              >
                <span className={`w-10 font-bold tabular-nums ${
                  i === 0 ? 'text-yellow-400' : i === 1 ? 'text-gray-300' : i === 2 ? 'text-orange-400' : 'text-gray-600'
                }`}>
                  {entry.rank}
                </span>
                <span className="flex-1 text-gray-200">{entry.display_name}</span>
                <span className="w-20 text-right text-yellow-400 font-semibold tabular-nums">
                  {entry.rating}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>
    </main>
  );
}
