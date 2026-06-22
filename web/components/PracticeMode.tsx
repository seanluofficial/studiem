'use client';

import { useState } from 'react';

export interface PracticeQuestion {
  id: string;
  stem: string;
  options: string[];
  correctIndex: number;
  correctExplanation: string | null;
}

export function getPracticeStats(subject: string): Record<string, { correct: number; total: number }> {
  if (typeof window === 'undefined') return {};
  try {
    return JSON.parse(localStorage.getItem(`studiem_practice_${subject}`) ?? '{}');
  } catch { return {}; }
}

export function updatePracticeStats(subject: string, unit: string, wasCorrect: boolean): void {
  if (typeof window === 'undefined') return;
  const stats = getPracticeStats(subject);
  const entry = stats[unit] ?? { correct: 0, total: 0 };
  stats[unit] = { correct: entry.correct + (wasCorrect ? 1 : 0), total: entry.total + 1 };
  localStorage.setItem(`studiem_practice_${subject}`, JSON.stringify(stats));
}

interface Props {
  questions: PracticeQuestion[];
  subject: string;
  unit: string;
  onExit: () => void;
}

const LABELS = ['A', 'B', 'C', 'D'];

export default function PracticeMode({ questions, subject, unit, onExit }: Props) {
  const [pool] = useState(() => [...questions].sort(() => Math.random() - 0.5));
  const [currentIdx, setCurrentIdx] = useState(0);
  const [selectedIdx, setSelectedIdx] = useState<number | null>(null);
  const [sessionCorrect, setSessionCorrect] = useState(0);
  const [sessionTotal, setSessionTotal] = useState(0);

  const current = pool[currentIdx % pool.length];

  function handleAnswer(i: number) {
    if (selectedIdx !== null || !current) return;
    setSelectedIdx(i);
    const wasCorrect = i === current.correctIndex;
    updatePracticeStats(subject, unit, wasCorrect);
    setSessionTotal(t => t + 1);
    if (wasCorrect) setSessionCorrect(c => c + 1);
  }

  function handleNext() {
    setCurrentIdx(idx => (idx + 1) % pool.length);
    setSelectedIdx(null);
  }

  if (!current) return null;

  const isAnswered = selectedIdx !== null;
  const isCorrect = isAnswered && selectedIdx === current.correctIndex;

  return (
    <main className="min-h-screen text-[#F5F0E8] flex flex-col">
      {/* Header */}
      <div className="panel border-x-0 border-t-0 px-5 pt-4 pb-3">
        <div className="flex items-center justify-between max-w-xl mx-auto">
          <div className="flex items-center gap-4 min-w-0">
            <button
              onClick={onExit}
              className="text-[#F5F0E8]/25 hover:text-[#F5F0E8]/60 text-xs uppercase tracking-widest transition-colors flex-shrink-0"
            >
              ← Units
            </button>
            <div className="flex flex-col min-w-0">
              <p className="text-[9px] text-[#F5F0E8]/30 uppercase tracking-[0.25em]">{subject.replace('AP ', '')}</p>
              <p className="text-[11px] text-[#C9A84C] font-display font-bold uppercase tracking-[0.1em] truncate max-w-[180px]">
                {unit.replace(/^Unit \d+: /, '')}
              </p>
            </div>
          </div>
          {sessionTotal > 0 && (
            <p className="text-[10px] text-[#F5F0E8]/35 uppercase tracking-[0.2em] tabular-nums flex-shrink-0">
              <span className="text-[#22C55E]">{sessionCorrect}</span>
              <span className="text-[#F5F0E8]/25"> / {sessionTotal}</span>
            </p>
          )}
        </div>
      </div>

      {/* Question + Options */}
      <div className="flex-1 flex flex-col justify-center px-5 py-6 max-w-xl mx-auto w-full">
        <div
          key={`${current.id}-${currentIdx}`}
          className="panel-raised panel-accent-top px-6 py-6 mb-6 animate-slide-in"
        >
          <p className="text-base font-medium leading-relaxed text-[#F5F0E8]">{current.stem}</p>
        </div>

        <div className="flex flex-col gap-2">
          {current.options.map((opt, i) => {
            const isThisCorrect = isAnswered && i === current.correctIndex;
            const isThisWrong   = isAnswered && i === selectedIdx && i !== current.correctIndex;
            const isDimmed      = isAnswered && i !== current.correctIndex && i !== selectedIdx;

            let containerCls = 'panel hover:bg-[#1C1C1C] hover:border-[#C9A84C]/50';
            let badgeCls     = 'border border-[#C9A84C]/30 text-[#C9A84C]/60';
            let textCls      = 'text-[#F5F0E8]/80';

            if (isThisCorrect) {
              containerCls = 'border border-[#22C55E] bg-[#22C55E]/10';
              badgeCls     = 'border border-[#22C55E] text-[#22C55E] bg-[#22C55E]/20';
              textCls      = 'text-[#22C55E]';
            } else if (isThisWrong) {
              containerCls = 'border border-[#EF4444] bg-[#EF4444]/10';
              badgeCls     = 'border border-[#EF4444] text-[#EF4444] bg-[#EF4444]/20';
              textCls      = 'text-[#EF4444]';
            } else if (isDimmed) {
              containerCls = 'panel opacity-35';
              badgeCls     = 'border border-[#2A2A2A] text-[#374151]';
              textCls      = 'text-[#374151]';
            }

            return (
              <button
                key={i}
                onClick={() => handleAnswer(i)}
                disabled={isAnswered}
                style={{ animationDelay: `${0.05 * i}s` }}
                className={`w-full flex items-center gap-4 px-4 py-4 transition-all duration-150 animate-rise-in focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#D4B565] disabled:cursor-default ${containerCls}`}
              >
                <span className={`w-8 h-8 flex-shrink-0 flex items-center justify-center text-sm font-display font-bold ${badgeCls}`}>
                  {LABELS[i]}
                </span>
                <span className={`text-left text-sm font-medium leading-snug ${textCls}`}>{opt}</span>
                {isThisCorrect && <span className="ml-auto text-[#22C55E] font-bold flex-shrink-0">✓</span>}
                {isThisWrong   && <span className="ml-auto text-[#EF4444] font-bold flex-shrink-0">✕</span>}
              </button>
            );
          })}
        </div>

        {/* Explanation on wrong answer */}
        {isAnswered && !isCorrect && current.correctExplanation && (
          <div className="mt-5 panel px-5 py-4 border-l-2 border-[#C9A84C]/40 animate-fade-up">
            <p className="text-[9px] text-[#C9A84C]/60 uppercase tracking-[0.25em] mb-2">Why the correct answer is right</p>
            <p className="text-sm text-[#F5F0E8]/70 leading-relaxed">{current.correctExplanation}</p>
          </div>
        )}

        {/* Next button — always shown after answering */}
        {isAnswered && (
          <button
            onClick={handleNext}
            className="mt-4 btn-gold w-full font-display font-black text-sm uppercase tracking-[0.18em] py-3"
          >
            Next →
          </button>
        )}
      </div>
    </main>
  );
}
