const { createClient } = require('@supabase/supabase-js');
const ws = require('ws');

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

async function updateStreak(userId) {
  const supabase = getSupabase();
  const { data: profile } = await supabase
    .from('profiles')
    .select('current_streak, longest_streak, last_battle_date')
    .eq('id', userId)
    .single();

  if (!profile) return;

  const today = new Date().toISOString().slice(0, 10);
  const last = profile.last_battle_date;

  let newStreak = profile.current_streak ?? 0;

  if (last === today) {
    // Already battled today — no change
    return;
  }

  const yesterday = new Date();
  yesterday.setUTCDate(yesterday.getUTCDate() - 1);
  const yesterdayStr = yesterday.toISOString().slice(0, 10);

  if (last === yesterdayStr) {
    newStreak += 1;
  } else {
    newStreak = 1;
  }

  const longest = Math.max(newStreak, profile.longest_streak ?? 0);

  await supabase.from('profiles').update({
    current_streak: newStreak,
    longest_streak: longest,
    last_battle_date: today,
  }).eq('id', userId);
}

module.exports = { updateStreak };
