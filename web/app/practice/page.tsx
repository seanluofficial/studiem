'use client';

import { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import NavBar from '@/components/NavBar';
import PracticeMode, { type PracticeQuestion, type SessionResult } from '@/components/PracticeMode';
import { createClient } from '@/lib/supabase/client';
import {
  fetchUnitStats,
  fetchCardStats,
  weightedSample,
  weightedUnitSample,
  getAccuracyColor,
  getUnitRecommendation,
  type UnitStat,
  type CardStat,
} from '@/lib/practice';

// ── Constants ─────────────────────────────────────────────────────────────────

const SUBJECTS = [
  'AP Chemistry',
  'AP Biology',
  'AP US History',
  'AP Psychology',
  'AP Calculus AB',
] as const;

type Subject = (typeof SUBJECTS)[number];

const LIVE_SUBJECTS: Set<string> = new Set(['AP Chemistry', 'AP Biology']);

// ── Types ─────────────────────────────────────────────────────────────────────

type Phase = 'select' | 'drill' | 'summary';

interface SourceCardRow {
  id: string;
  unit: string;
  content: { correct_explanation?: string | null } | null;
}

interface VariantRow {
  id: string;
  rendered_stem: string;
  rendered_options: string[] | null;
  correct_index: number;
  source_card_id: string;
}

// Snapshot of unit stats taken before a session (for delta computation)
type BeforeStats = Record<string, { correct: number; total: number }>;

// ── Helper ────────────────────────────────────────────────────────────────────

function accuracyPct(stat: UnitStat | undefined): number | null {
  if (!stat || stat.total === 0) return null;
  return stat.correct / stat.total;
}

function fmtPct(value: number | null): string {
  if (value === null) return '—';
  return `${Math.round(value * 100)}%`;
}

function deltaPct(
  beforeStat: { correct: number; total: number } | undefined,
  sessionCorrect: number,
  sessionTotal: number
): string | null {
  if (sessionTotal === 0) return null;
  const before = beforeStat ?? { correct: 0, total: 0 };
  if (before.total === 0) return null; // never practiced, show session accuracy but no delta
  const beforeAcc = before.correct / before.total;
  const afterAcc = (before.correct + sessionCorrect) / (before.total + sessionTotal);
  const d = afterAcc - beforeAcc;
  const sign = d >= 0 ? '+' : '';
  return `${sign}${(d * 100).toFixed(1)}%`;
}

// ── Component ─────────────────────────────────────────────────────────────────

export default function PracticePage() {
  const router = useRouter();
  const supabase = createClient();

  // Auth
  const [userId, setUserId] = useState<string | null>(null);
  const [displayName, setDisplayName] = useState<string | null>(null);

  // Phase
  const [phase, setPhase] = useState<Phase>('select');

  // Select phase
  const [selectedSubject, setSelectedSubject] = useState<Subject>('AP Chemistry');
  const [myElo, setMyElo] = useState<number | null>(null);
  const [availableUnits, setAvailableUnits] = useState<string[]>([]);
  const [unitStats, setUnitStats] = useState<Record<string, UnitStat>>({});
  const [loadingUnits, setLoadingUnits] = useState(false);

  // Drill phase
  const [drillQuestions, setDrillQuestions] = useState<PracticeQuestion[]>([]);
  const [drillUnit, setDrillUnit] = useState<string | null>(null);
  const [loadingDrill, setLoadingDrill] = useState(false);
  const [drillError, setDrillError] = useState<string | null>(null);
  const [beforeStats, setBeforeStats] = useState<BeforeStats>({});

  // Summary phase
  const [sessionResult, setSessionResult] = useState<SessionResult | null>(null);

  // ── Auth on mount ───────────────────────────────────────────────────────────

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => {
      if (!data.user) {
        router.push('/login');
        return;
      }
      setUserId(data.user.id);
      const meta = data.user.user_metadata as { full_name?: string; display_name?: string } | undefined;
      setDisplayName(meta?.display_name ?? meta?.full_name ?? data.user.email ?? null);
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // ── Fetch ELO + units whenever subject or userId changes ───────────────────

  const loadSubjectData = useCallback(
    async (subject: string, uid: string) => {
      setLoadingUnits(true);
      setAvailableUnits([]);
      setUnitStats({});
      setMyElo(null);

      // ELO
      const { data: eloData } = await supabase
        .from('elo_ratings')
        .select('rating')
        .eq('user_id', uid)
        .eq('subject', subject)
        .maybeSingle();
      setMyElo((eloData as { rating: number } | null)?.rating ?? null);

      // Available units
      const { data: unitRows } = await supabase
        .from('source_cards')
        .select('unit')
        .eq('subject', subject)
        .eq('reviewed', true);

      if (unitRows) {
        const deduped = [...new Set((unitRows as { unit: string }[]).map(r => r.unit))].sort();
        setAvailableUnits(deduped);
      }

      // Unit stats
      const stats = await fetchUnitStats(supabase, uid, subject);
      setUnitStats(stats);

      setLoadingUnits(false);
    },
    [supabase]
  );

  useEffect(() => {
    if (!userId) return;
    void loadSubjectData(selectedSubject, userId);
  }, [userId, selectedSubject, loadSubjectData]);

  // ── Build drill questions ───────────────────────────────────────────────────

  const startDrill = useCallback(
    async (unit: string | null) => {
      if (!userId) return;
      setDrillError(null);
      setLoadingDrill(true);
      setDrillUnit(unit);

      try {
        let cardPool: { sourceCardId: string; unit: string }[];
        let contentMap: Record<string, string | null>;
        let cardStats: Record<string, CardStat>;
        let currentUnitStats: Record<string, UnitStat>;
        let selectedIds: string[];

        if (unit !== null) {
          // Single unit
          const { data: cards, error } = await supabase
            .from('source_cards')
            .select('id, content')
            .eq('subject', selectedSubject)
            .eq('unit', unit)
            .eq('reviewed', true);

          if (error) throw error;

          const typedCards = (cards ?? []) as { id: string; content: { correct_explanation?: string | null } | null }[];
          contentMap = Object.fromEntries(
            typedCards.map(c => [c.id, c.content?.correct_explanation ?? null])
          );
          cardPool = typedCards.map(c => ({ sourceCardId: c.id, unit }));
          cardStats = await fetchCardStats(supabase, userId, cardPool.map(c => c.sourceCardId));
          currentUnitStats = unitStats;

          const sampled = weightedSample(cardPool, cardStats, 50);
          selectedIds = sampled.map(c => c.sourceCardId);
        } else {
          // Practice All
          const { data: cards, error } = await supabase
            .from('source_cards')
            .select('id, unit, content')
            .eq('subject', selectedSubject)
            .eq('reviewed', true);

          if (error) throw error;

          const typedCards = (cards ?? []) as SourceCardRow[];
          contentMap = Object.fromEntries(
            typedCards.map(c => [c.id, c.content?.correct_explanation ?? null])
          );
          cardPool = typedCards.map(c => ({ sourceCardId: c.id, unit: c.unit }));
          cardStats = await fetchCardStats(supabase, userId, cardPool.map(c => c.sourceCardId));
          currentUnitStats = await fetchUnitStats(supabase, userId, selectedSubject);

          const sampled = weightedUnitSample(cardPool, currentUnitStats, cardStats, 50);
          selectedIds = sampled.map(c => c.sourceCardId);
        }

        if (selectedIds.length === 0) {
          setDrillError('No questions available for this unit yet.');
          setLoadingDrill(false);
          return;
        }

        // Fetch variants
        const { data: variants, error: variantError } = await supabase
          .from('question_variants')
          .select('id, rendered_stem, rendered_options, correct_index, source_card_id')
          .in('source_card_id', selectedIds)
          .not('rendered_options', 'is', null);

        if (variantError) throw variantError;

        const typedVariants = (variants ?? []) as VariantRow[];

        if (typedVariants.length === 0) {
          setDrillError('No questions available for this unit yet.');
          setLoadingDrill(false);
          return;
        }

        // Map to PracticeQuestion
        const unitForCard: Record<string, string> = Object.fromEntries(
          cardPool.map(c => [c.sourceCardId, c.unit])
        );

        const questions: PracticeQuestion[] = typedVariants.map(v => ({
          id: v.id,
          sourceCardId: v.source_card_id,
          stem: v.rendered_stem,
          options: v.rendered_options!,
          correctIndex: v.correct_index,
          correctExplanation: contentMap[v.source_card_id] ?? null,
          unit: unitForCard[v.source_card_id] ?? unit ?? '',
        }));

        // Snapshot unit stats before the session for delta
        const snapshot: BeforeStats = {};
        for (const u of Object.keys(currentUnitStats)) {
          snapshot[u] = { ...currentUnitStats[u] };
        }
        setBeforeStats(snapshot);

        setDrillQuestions(questions);
        setPhase('drill');
      } catch (err) {
        console.error('[practice] startDrill error', err);
        setDrillError('Failed to load questions. Please try again.');
      } finally {
        setLoadingDrill(false);
      }
    },
    [userId, selectedSubject, supabase, unitStats]
  );

  // ── Session stop handler ────────────────────────────────────────────────────

  const handleStop = useCallback(
    (results: SessionResult) => {
      setSessionResult(results);
      setPhase('summary');
    },
    []
  );

  // ── Render ─────────────────────────────────────────────────────────────────

  if (phase === 'drill' && userId) {
    return (
      <PracticeMode
        questions={drillQuestions}
        subject={selectedSubject}
        unit={drillUnit}
        userId={userId}
        onStop={handleStop}
      />
    );
  }

  if (phase === 'summary' && sessionResult) {
    return (
      <SummaryView
        result={sessionResult}
        beforeStats={beforeStats}
        subject={selectedSubject}
        displayName={displayName}
        myElo={myElo}
        onPracticeMore={() => {
          if (userId) void loadSubjectData(selectedSubject, userId);
          setPhase('select');
        }}
        onBattle={() => router.push('/')}
      />
    );
  }

  // Select phase
  return (
    <div className="min-h-screen text-[#F5F0E8]">
      <NavBar displayName={displayName} elo={myElo} subject={selectedSubject} />

      <div className="pt-16 px-5 pb-10 max-w-xl mx-auto">
        {/* Subject picker */}
        <div className="mb-8">
          <p className="text-[9px] text-[#F5F0E8]/30 uppercase tracking-[0.3em] mb-3">Subject</p>
          <div className="flex flex-wrap gap-2">
            {SUBJECTS.map(s => {
              const live = LIVE_SUBJECTS.has(s);
              const active = s === selectedSubject;
              return (
                <button
                  key={s}
                  onClick={() => live && setSelectedSubject(s)}
                  disabled={!live}
                  className={[
                    'px-3 py-1.5 text-[10px] font-display font-bold uppercase tracking-[0.15em] border transition-all',
                    active
                      ? 'border-[#C9A84C] bg-[#C9A84C]/10 text-[#C9A84C]'
                      : live
                      ? 'border-[#2A2A2A] bg-[#141414] text-[#F5F0E8]/50 hover:border-[#C9A84C]/40 hover:text-[#F5F0E8]/80'
                      : 'border-[#1E1E1E] bg-[#0F0F0F] text-[#374151] cursor-not-allowed',
                  ].join(' ')}
                >
                  {s.replace('AP ', '')}
                  {!live && (
                    <span className="ml-1.5 text-[8px] text-[#374151] normal-case tracking-normal">
                      soon
                    </span>
                  )}
                </button>
              );
            })}
          </div>
        </div>

        {/* Unit list */}
        <div>
          <p className="text-[9px] text-[#F5F0E8]/30 uppercase tracking-[0.3em] mb-3">
            Select a unit
          </p>

          {loadingUnits && (
            <p className="text-[#F5F0E8]/30 text-xs animate-pulse">Loading units…</p>
          )}

          {drillError && !loadingDrill && (
            <div className="panel px-4 py-3 mb-4 border-[#EF4444]/40">
              <p className="text-sm text-[#EF4444]">{drillError}</p>
              <button
                className="mt-2 text-xs text-[#F5F0E8]/40 hover:text-[#F5F0E8]/70 underline"
                onClick={() => setDrillError(null)}
              >
                Dismiss
              </button>
            </div>
          )}

          {!loadingUnits && LIVE_SUBJECTS.has(selectedSubject) && (
            <div className="flex flex-col gap-2">
              {/* Practice All button */}
              <button
                onClick={() => void startDrill(null)}
                disabled={loadingDrill}
                className="panel hover:bg-[#1C1C1C] hover:border-[#C9A84C]/50 px-5 py-4 flex items-center justify-between transition-all disabled:opacity-50 disabled:cursor-wait"
              >
                <div className="text-left">
                  <p className="text-sm font-display font-bold uppercase tracking-[0.12em] text-[#C9A84C]">
                    Practice All {selectedSubject.replace('AP ', '')}
                  </p>
                  <p className="text-[10px] text-[#F5F0E8]/35 mt-0.5">All units · weighted</p>
                </div>
                <span className="text-[#C9A84C]/40 text-lg flex-shrink-0">→</span>
              </button>

              {/* Per-unit buttons */}
              {availableUnits.map(u => {
                const stat = unitStats[u];
                const acc = accuracyPct(stat);
                const elo = myElo ?? 1000;
                const rec = getUnitRecommendation(acc, elo);
                const color = getAccuracyColor(acc, elo);

                return (
                  <button
                    key={u}
                    onClick={() => void startDrill(u)}
                    disabled={loadingDrill}
                    className="panel hover:bg-[#1C1C1C] hover:border-[#C9A84C]/50 px-5 py-4 flex items-center justify-between transition-all disabled:opacity-50 disabled:cursor-wait"
                  >
                    <div className="text-left min-w-0 flex-1">
                      <p className="text-sm font-medium text-[#F5F0E8]/90 truncate pr-2">
                        {u}
                      </p>
                      <div className="flex items-center gap-2 mt-1">
                        {acc !== null && (
                          <span
                            className="text-[10px] font-display font-bold tabular-nums"
                            style={{ color }}
                          >
                            {fmtPct(acc)}
                          </span>
                        )}
                        {rec === 'recommended' && (
                          <span className="flex items-center gap-1 text-[9px] text-[#C9A84C] uppercase tracking-[0.2em]">
                            <span
                              className="w-1.5 h-1.5 rounded-full flex-shrink-0"
                              style={{ background: '#C9A84C' }}
                            />
                            Suggested
                          </span>
                        )}
                        {rec === 'ok' && (
                          <span className="text-[9px] text-[#22C55E] uppercase tracking-[0.2em]">✓</span>
                        )}
                        {rec === 'unstarted' && (
                          <span className="text-[9px] text-[#F5F0E8]/30 uppercase tracking-[0.2em]">
                            New
                          </span>
                        )}
                      </div>
                    </div>
                    <span className="text-[#F5F0E8]/20 text-lg flex-shrink-0">→</span>
                  </button>
                );
              })}
            </div>
          )}

          {!loadingUnits && !LIVE_SUBJECTS.has(selectedSubject) && (
            <p className="text-[#F5F0E8]/30 text-sm">
              {selectedSubject} is coming soon. Switch to AP Chemistry or AP Biology to practice.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}

// ── Summary View ──────────────────────────────────────────────────────────────

interface SummaryViewProps {
  result: SessionResult;
  beforeStats: BeforeStats;
  subject: string;
  displayName: string | null;
  myElo: number | null;
  onPracticeMore: () => void;
  onBattle: () => void;
}

function SummaryView({
  result,
  beforeStats,
  subject,
  displayName,
  myElo,
  onPracticeMore,
  onBattle,
}: SummaryViewProps) {
  const [showWrong, setShowWrong] = useState(false);

  const units = Object.keys(result.byUnit).sort();

  // Animated accuracy counters: starts at beforeAcc, counts up to afterAcc
  const [animPcts, setAnimPcts] = useState<Record<string, number>>(() =>
    Object.fromEntries(
      units.map(u => {
        const before = beforeStats[u];
        const beforeAcc = before && before.total > 0 ? before.correct / before.total : 0;
        return [u, beforeAcc];
      })
    )
  );
  const [animDone, setAnimDone] = useState(false);

  useEffect(() => {
    if (units.length === 0) { setAnimDone(true); return; }

    const initials: Record<string, number> = {};
    const targets: Record<string, number> = {};
    for (const u of units) {
      const bySess = result.byUnit[u];
      const before = beforeStats[u];
      const beforeAcc = before && before.total > 0 ? before.correct / before.total : 0;
      const afterAcc =
        before && before.total > 0
          ? (before.correct + bySess.correct) / (before.total + bySess.total)
          : bySess.total > 0
          ? bySess.correct / bySess.total
          : 0;
      initials[u] = beforeAcc;
      targets[u] = afterAcc;
    }

    const DURATION = 900;
    const startTime = performance.now();
    let raf: number;

    // 500ms delay so the page settle animation completes first
    const timer = setTimeout(() => {
      function tick(now: number) {
        const elapsed = now - startTime;
        const progress = Math.min(elapsed / DURATION, 1);
        // ease-out cubic
        const eased = 1 - Math.pow(1 - progress, 3);
        setAnimPcts(
          Object.fromEntries(units.map(u => [u, initials[u] + (targets[u] - initials[u]) * eased]))
        );
        if (progress < 1) {
          raf = requestAnimationFrame(tick);
        } else {
          setAnimDone(true);
        }
      }
      raf = requestAnimationFrame(tick);
    }, 500);

    return () => {
      clearTimeout(timer);
      cancelAnimationFrame(raf);
    };
    // result and beforeStats are frozen at mount — deps intentionally omitted
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const overallPct =
    result.totalAnswered > 0
      ? Math.round((result.totalCorrect / result.totalAnswered) * 100)
      : 0;

  return (
    <div className="min-h-screen text-[#F5F0E8]">
      <NavBar displayName={displayName} elo={myElo} subject={subject} />

      <div className="pt-16 px-5 pb-10 max-w-xl mx-auto">
        {/* Big session accuracy */}
        <div className="panel-raised panel-accent-top px-6 py-8 mb-6 text-center animate-rise-in">
          <p className="text-[9px] text-[#F5F0E8]/30 uppercase tracking-[0.3em] mb-3">
            Session Result
          </p>
          <p className="font-display font-black text-5xl text-[#C9A84C] tabular-nums">
            {overallPct}%
          </p>
          <p className="text-sm text-[#F5F0E8]/40 mt-2">
            {result.totalCorrect} / {result.totalAnswered} correct
          </p>
        </div>

        {/* Per-unit breakdown */}
        {units.length > 0 && (
          <div className="panel px-0 py-0 mb-5 overflow-hidden">
            <p className="text-[9px] text-[#F5F0E8]/30 uppercase tracking-[0.3em] px-5 pt-4 pb-3 border-b border-[#2A2A2A]">
              By Unit
            </p>
            {units.map((u, idx) => {
              const bySess = result.byUnit[u];
              const sessAcc = bySess.total > 0 ? bySess.correct / bySess.total : 0;
              const before = beforeStats[u];
              const hasHistory = before != null && before.total > 0;
              const currentPct = animPcts[u] ?? 0;
              const d = deltaPct(beforeStats[u], bySess.correct, bySess.total);

              return (
                <div
                  key={u}
                  className={`px-5 py-4 ${idx !== units.length - 1 ? 'border-b border-[#2A2A2A]' : ''}`}
                >
                  {/* Row 1: unit name + session score */}
                  <div className="flex items-center justify-between">
                    <p className="text-xs text-[#F5F0E8]/70 flex-1 min-w-0 truncate pr-3">{u}</p>
                    <span className="text-[10px] tabular-nums text-[#F5F0E8]/35 flex-shrink-0">
                      {bySess.correct}/{bySess.total}
                      <span className="ml-1.5 text-[#F5F0E8]/55">{Math.round(sessAcc * 100)}% this session</span>
                    </span>
                  </div>

                  {/* Row 2: animated lifetime accuracy + delta badge */}
                  <div className="flex items-center gap-3 mt-2">
                    <span className="text-[9px] text-[#F5F0E8]/25 uppercase tracking-[0.2em] w-16 flex-shrink-0">
                      {hasHistory ? 'Accuracy' : 'New'}
                    </span>
                    <span className="text-base font-display font-black tabular-nums text-[#F5F0E8]">
                      {Math.round(currentPct * 100)}%
                    </span>
                    {animDone && d !== null && (
                      <span
                        className={`text-[10px] font-bold tabular-nums animate-fade-up ${
                          d.startsWith('+') ? 'text-[#22C55E]' : 'text-[#EF4444]'
                        }`}
                      >
                        {d}
                      </span>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}

        {/* Wrong questions */}
        {result.wrongQuestions.length > 0 && (
          <div className="panel mb-6">
            <button
              onClick={() => setShowWrong(v => !v)}
              className="w-full flex items-center justify-between px-5 py-4 text-left"
            >
              <p className="text-[9px] text-[#F5F0E8]/30 uppercase tracking-[0.3em]">
                Missed ({result.wrongQuestions.length})
              </p>
              <span className="text-[#F5F0E8]/25 text-xs">{showWrong ? '▲' : '▼'}</span>
            </button>
            {showWrong && (
              <div className="border-t border-[#2A2A2A] divide-y divide-[#2A2A2A]">
                {result.wrongQuestions.map(q => (
                  <div key={`${q.id}-wrong`} className="px-5 py-4">
                    <p className="text-sm text-[#F5F0E8]/80 leading-snug mb-2">{q.stem}</p>
                    <p className="text-[10px] text-[#22C55E]">✓ {q.options[q.correctIndex]}</p>
                    {q.correctExplanation && (
                      <p className="text-[10px] text-[#F5F0E8]/35 mt-1 leading-relaxed">
                        {q.correctExplanation}
                      </p>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Action buttons */}
        <div className="flex gap-3">
          <button
            onClick={onPracticeMore}
            className="btn-gold flex-1 font-display font-black text-sm uppercase tracking-[0.18em] py-3"
          >
            Practice More
          </button>
          <button
            onClick={onBattle}
            className="flex-1 border border-[#2A2A2A] bg-[#141414] hover:border-[#C9A84C]/40 hover:bg-[#1C1C1C] text-[#F5F0E8]/60 hover:text-[#F5F0E8]/90 font-display font-bold text-sm uppercase tracking-[0.18em] py-3 transition-all"
          >
            Queue for Battle
          </button>
        </div>
      </div>
    </div>
  );
}
