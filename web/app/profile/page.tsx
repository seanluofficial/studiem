import { redirect } from 'next/navigation';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';

const MVP_SUBJECTS = [
  'AP Biology',
  'AP Chemistry',
  'AP US History',
  'AP Psychology',
  'AP Calculus AB',
];

export default async function ProfilePage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const [profileRes, eloRes, battlesRes] = await Promise.all([
    supabase
      .from('profiles')
      .select('display_name, current_streak, longest_streak')
      .eq('id', user.id)
      .single(),
    supabase
      .from('elo_ratings')
      .select('subject, rating')
      .eq('user_id', user.id),
    supabase
      .from('battles')
      .select('id, subject, scores, winner_id, created_at, player1_id, player2_id')
      .or(`player1_id.eq.${user.id},player2_id.eq.${user.id}`)
      .order('created_at', { ascending: false })
      .limit(10),
  ]);

  const profile = profileRes.data;
  const eloRows = eloRes.data ?? [];
  const recentBattles = battlesRes.data ?? [];

  // Collect opponent IDs and look up display names
  const opponentIds = [
    ...new Set(
      recentBattles.map(b => (b.player1_id === user.id ? b.player2_id : b.player1_id)).filter(Boolean)
    ),
  ] as string[];

  const { data: opponentProfiles } = opponentIds.length
    ? await supabase.from('profiles').select('id, display_name').in('id', opponentIds)
    : { data: [] };

  const opponentNameMap = Object.fromEntries(
    (opponentProfiles ?? []).map(p => [p.id, p.display_name])
  );

  const eloMap = Object.fromEntries(eloRows.map(r => [r.subject, r.rating]));

  let wins = 0, losses = 0, draws = 0;
  for (const b of recentBattles) {
    if (b.winner_id === user.id) wins++;
    else if (b.winner_id === null) draws++;
    else losses++;
  }

  const initials = profile?.display_name?.slice(0, 2).toUpperCase() ?? '??';

  return (
    <main className="min-h-screen bg-[#0f0f14] text-white px-4 py-10 flex flex-col items-center gap-8">
      <div className="w-full max-w-xl">
        <Link href="/" className="text-gray-600 hover:text-gray-400 text-sm transition">← Back</Link>
      </div>

      {/* Avatar + name */}
      <div className="flex flex-col items-center gap-3">
        <div className="w-16 h-16 bg-indigo-700 flex items-center justify-center text-2xl font-bold">
          {initials}
        </div>
        <h1 className="text-2xl font-bold">{profile?.display_name ?? '—'}</h1>
        <div className="flex gap-6 text-sm text-gray-400">
          <span>🔥 Streak: <strong className="text-white">{profile?.current_streak ?? 0}</strong></span>
          <span>Best: <strong className="text-white">{profile?.longest_streak ?? 0}</strong></span>
        </div>
        <div className="flex gap-6 text-sm">
          <span className="text-green-400 font-semibold">{wins}W</span>
          <span className="text-red-400 font-semibold">{losses}L</span>
          <span className="text-gray-500">{draws}D</span>
        </div>
      </div>

      {/* ELO per subject */}
      <div className="w-full max-w-xl">
        <h2 className="text-xs text-gray-600 uppercase tracking-wider mb-3">ELO Ratings</h2>
        <div className="flex flex-col gap-1">
          {MVP_SUBJECTS.map(s => (
            <div key={s} className="flex justify-between items-center bg-gray-900 px-4 py-2 text-sm">
              <span className="text-gray-300">{s}</span>
              <span className="text-yellow-400 font-semibold tabular-nums">
                {eloMap[s] ?? 1000}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Recent battles */}
      <div className="w-full max-w-xl">
        <h2 className="text-xs text-gray-600 uppercase tracking-wider mb-3">Recent Battles</h2>
        {recentBattles.length === 0 ? (
          <p className="text-gray-600 text-sm">No battles yet.</p>
        ) : (
          <div className="flex flex-col gap-1">
            {recentBattles.map(b => {
              const oppId = b.player1_id === user.id ? b.player2_id : b.player1_id;
              const opponentName = oppId ? (opponentNameMap[oppId] ?? 'Unknown') : 'Unknown';

              const scoresObj = b.scores as Record<string, number> | null;
              const myScore = scoresObj?.[user.id] ?? 0;
              const oppScore = oppId ? (scoresObj?.[oppId] ?? 0) : 0;

              let result = 'Draw';
              let resultCls = 'text-gray-500';
              if (b.winner_id === user.id) { result = 'Win'; resultCls = 'text-green-400'; }
              else if (b.winner_id !== null) { result = 'Loss'; resultCls = 'text-red-400'; }

              return (
                <div key={b.id} className="flex justify-between items-center bg-gray-900 px-4 py-2 text-sm">
                  <span className={`font-semibold w-12 ${resultCls}`}>{result}</span>
                  <span className="text-gray-400 flex-1 truncate mx-3">vs {opponentName}</span>
                  <span className="text-gray-300 tabular-nums mr-3">{myScore}–{oppScore}</span>
                  <span className="text-gray-600 text-xs">
                    {new Date(b.created_at).toLocaleDateString()}
                  </span>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </main>
  );
}
