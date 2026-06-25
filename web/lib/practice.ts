import type { SupabaseClient } from '@supabase/supabase-js';

// ── Types ────────────────────────────────────────────────────────────────────

export interface CardStat {
  correct: number;
  total: number;
}

export interface UnitStat {
  correct: number;
  total: number;
}

// ── ELO-based accuracy thresholds ────────────────────────────────────────────

export function getAccuracyThreshold(elo: number): number {
  if (elo < 900) return 0.65;
  if (elo < 1100) return 0.70;
  if (elo < 1300) return 0.75;
  if (elo < 1500) return 0.82;
  return 0.88;
}

export function getAccuracyColor(accuracy: number | null, elo: number): string {
  if (accuracy === null) return 'transparent';
  const threshold = getAccuracyThreshold(elo);
  if (accuracy >= threshold) return '#22C55E';
  if (accuracy >= threshold - 0.15) return '#EAB308';
  return '#EF4444';
}

// 'recommended' = below ELO threshold (needs work)
// 'ok'          = at or above threshold
// 'unstarted'   = no data yet
export function getUnitRecommendation(
  accuracy: number | null,
  elo: number
): 'recommended' | 'ok' | 'unstarted' {
  if (accuracy === null) return 'unstarted';
  return accuracy < getAccuracyThreshold(elo) ? 'recommended' : 'ok';
}

// ── DB utilities ─────────────────────────────────────────────────────────────

// Aggregates user_card_stats rows into per-unit totals for the given subject.
export async function fetchUnitStats(
  supabase: SupabaseClient,
  userId: string,
  subject: string
): Promise<Record<string, UnitStat>> {
  const { data } = await supabase
    .from('user_card_stats')
    .select('unit, correct_count, total_count')
    .eq('user_id', userId)
    .eq('subject', subject);

  if (!data) return {};
  const result: Record<string, UnitStat> = {};
  for (const row of data) {
    const u = row.unit as string;
    if (!result[u]) result[u] = { correct: 0, total: 0 };
    result[u].correct += row.correct_count as number;
    result[u].total   += row.total_count as number;
  }
  return result;
}

// Fetches per-card stats for a specific set of source card IDs.
export async function fetchCardStats(
  supabase: SupabaseClient,
  userId: string,
  sourceCardIds: string[]
): Promise<Record<string, CardStat>> {
  if (sourceCardIds.length === 0) return {};
  const { data } = await supabase
    .from('user_card_stats')
    .select('source_card_id, correct_count, total_count')
    .eq('user_id', userId)
    .in('source_card_id', sourceCardIds);

  if (!data) return {};
  return Object.fromEntries(
    data.map(row => [
      row.source_card_id as string,
      { correct: row.correct_count as number, total: row.total_count as number },
    ])
  );
}

// ── Weighted sampling ─────────────────────────────────────────────────────────

// Selects n items from pool weighted so lower-accuracy cards appear more often.
// Unseen cards (no stats) get weight 0.5. Minimum weight 0.1 keeps all cards reachable.
export function weightedSample<T extends { sourceCardId: string }>(
  pool: T[],
  stats: Record<string, CardStat>,
  n: number
): T[] {
  if (pool.length === 0) return [];
  const weighted = pool.map(item => {
    const stat = stats[item.sourceCardId];
    const accuracy = !stat || stat.total === 0 ? 0.5 : stat.correct / stat.total;
    return { item, sortKey: Math.max(0.1, 1 - accuracy) * Math.random() };
  });
  weighted.sort((a, b) => b.sortKey - a.sortKey);
  return weighted.slice(0, Math.min(n, pool.length)).map(w => w.item);
}

// For "Practice All" mode: weights by both unit accuracy (60%) and card accuracy (40%).
export function weightedUnitSample<T extends { sourceCardId: string; unit: string }>(
  pool: T[],
  unitStats: Record<string, UnitStat>,
  cardStats: Record<string, CardStat>,
  n: number
): T[] {
  if (pool.length === 0) return [];
  const weighted = pool.map(item => {
    const us = unitStats[item.unit];
    const unitAcc = !us || us.total === 0 ? 0.5 : us.correct / us.total;
    const cs = cardStats[item.sourceCardId];
    const cardAcc = !cs || cs.total === 0 ? 0.5 : cs.correct / cs.total;
    const combined = Math.max(0.1, 1 - unitAcc) * 0.6 + Math.max(0.1, 1 - cardAcc) * 0.4;
    return { item, sortKey: combined * Math.random() };
  });
  weighted.sort((a, b) => b.sortKey - a.sortKey);
  return weighted.slice(0, Math.min(n, pool.length)).map(w => w.item);
}

// ── Stat recording ────────────────────────────────────────────────────────────

// Records a practice answer via the atomic upsert_card_stat RPC.
// Caller should .catch() for non-fatal error logging.
export async function recordPracticeAnswer(
  supabase: SupabaseClient,
  userId: string,
  sourceCardId: string,
  subject: string,
  unit: string,
  correct: boolean
): Promise<void> {
  const { error } = await supabase.rpc('upsert_card_stat', {
    p_user_id: userId,
    p_source_card_id: sourceCardId,
    p_subject: subject,
    p_unit: unit,
    p_correct: correct,
  });
  if (error) throw error;
}
