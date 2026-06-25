const { getSupabase } = require('./supabase');

async function updateCardStat(userId, sourceCardId, subject, unit, correct) {
  if (!userId || !sourceCardId || !subject || !unit) return;
  const supabase = getSupabase();
  const { error } = await supabase.rpc('upsert_card_stat', {
    p_user_id: userId,
    p_source_card_id: sourceCardId,
    p_subject: subject,
    p_unit: unit,
    p_correct: correct,
  });
  if (error) throw error;
}

module.exports = { updateCardStat };
