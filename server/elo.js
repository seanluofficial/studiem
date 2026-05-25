const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

const K = 32;

function calcNewRating(myRating, oppRating, result) {
  // result: 1 = win, 0 = loss, 0.5 = tie
  const expected = 1 / (1 + Math.pow(10, (oppRating - myRating) / 400));
  return Math.round(myRating + K * (result - expected));
}

async function updateElo(state, winnerSocketId) {
  const socketIds = Object.keys(state.players);
  const [sid1, sid2] = socketIds;

  const userId1 = state.players[sid1].userId;
  const userId2 = state.players[sid2].userId;

  // Fetch current ratings (default 1000 if no row yet)
  const { data: rows } = await supabase
    .from('elo_ratings')
    .select('user_id, rating')
    .in('user_id', [userId1, userId2])
    .eq('subject', 'apchem');

  const ratingMap = Object.fromEntries((rows ?? []).map(r => [r.user_id, r.rating]));
  const r1 = ratingMap[userId1] ?? 1000;
  const r2 = ratingMap[userId2] ?? 1000;

  const tied = winnerSocketId === null;
  const p1Wins = winnerSocketId === sid1;

  const result1 = tied ? 0.5 : p1Wins ? 1 : 0;
  const result2 = tied ? 0.5 : p1Wins ? 0 : 1;

  const new1 = calcNewRating(r1, r2, result1);
  const new2 = calcNewRating(r2, r1, result2);

  // Upsert ratings
  await supabase.from('elo_ratings').upsert([
    { user_id: userId1, subject: 'apchem', rating: new1, updated_at: new Date().toISOString() },
    { user_id: userId2, subject: 'apchem', rating: new2, updated_at: new Date().toISOString() },
  ], { onConflict: 'user_id,subject' });

  // Record battle
  await supabase.from('battles').insert({
    player1_id: userId1,
    player2_id: userId2,
    winner_id: tied ? null : (p1Wins ? userId1 : userId2),
    subject: 'apchem',
    scores: {
      [userId1]: state.progress[sid1].score,
      [userId2]: state.progress[sid2].score,
    },
  });

  console.log(`[elo] ${userId1}: ${r1} → ${new1}  |  ${userId2}: ${r2} → ${new2}`);

  // Return deltas keyed by socketId so client can look up their own
  return {
    [sid1]: { before: r1, after: new1, delta: new1 - r1 },
    [sid2]: { before: r2, after: new2, delta: new2 - r2 },
  };
}

module.exports = { updateElo };
