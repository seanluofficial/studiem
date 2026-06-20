'use client';

import { useState } from 'react';

export interface PracticeQuestion {
  id: string;
  stem: string;
  options: string[];
  correctIndex: number;
  correctExplanation: string | null;
}

interface Props {
  questions: PracticeQuestion[];
  subject: string;
  unit: string;
  onEnd: () => void;
  onRetry: () => void;
}

const LABELS = ['A', 'B', 'C', 'D'];

export default function PracticeMode({ questions, subject, unit, onEnd, onRetry }: Props) {
  const [currentIdx, setCurrentIdx] = useState(0);
  const [selectedIdx, setSelectedIdx] = useState<number | null>(null);
  const [correctCount, setCorrectCount] = useState(0);
  const [wrongQuestions, setWrongQuestions] = useState<PracticeQuestion[]>([]);
  const [done, setDone] = useState(false);

  const total = questions.length;
  const current = questions[currentIdx];

  function handleAnswer(i: number) {
    if (selectedIdx !== null || !current) return;
    setSelectedIdx(i);
    if (i === current.correctIndex) {
      setCorrectCount(c => c + 1);
      setTimeout(() => advance(), 1200);
    } else {
      setWrongQuestions(prev => [...prev, current]);
    }
  }

  function advance() {
    setCurrentIdx(idx => {
      const next = idx + 1;
      if (next >= total) { setDone(true); return idx; }
      setSelectedIdx(null);
      return next;
    });
  }

  // ── Session complete ─────────────────────────────────────────────────────────
  if (done || !current) {
    const pct = total > 0 ? Math.round((correctCount / total) * 100) : 0;
    const grade =
      pct >= 90 ? 'Excellent' :
      pct >= 70 ? 'Good' :
      pct >= 50 ? 'Fair' :
      'Keep Practicing';
    const gradeColor =
      pct >= 90 ? '#22C55E' :
      pct >= 70 ? '#C9A84C' :
      pct >= 50 ? '#F59E0B' :
      '#EF4444';

    return (
      <main className="min-h-screen text-[#F5F0E8] flex flex-col items-center justify-center px-4 py-16">
        <div className="relative w-full max-w-md flex flex-col items-center">
          <div className="glow-focus animate-glow-pulse" />
          <div className="panel-raised panel-accent-top relative z-10 w-full px-8 py-10 flex flex-col items-center gap-6 animate-rise-in">

            <div className="flex flex-col items-center gap-1">
              <p className="text-[10px] text-[#F5F0E8]/30 uppercase tracking-[0.4em]">Practice Complete</p>
              <p className="font-display font-black text-4xl uppercase tracking-[0.12em]" style={{ color: gradeColor }}>
                {grade}
              </p>
            </div>

            <div className="rule-gold w-full" />

            <div className="flex items-center justify-center gap-10 w-full">
              <div className="flex flex-col items-center gap-1">
                <p className="font-display font-black text-5xl tabular-nums" style={{ color: gradeColor }}>{pct}%</p>
                <p className="text-[10px] text-[#F5F0E8]/35 uppercase tracking-[0.2em]">Accuracy</p>
              </div>
              <div className="flex flex-col items-center gap-1">
                <p className="font-display font-black text-5xl tabular-nums text-[#F5F0E8]">
                  {correctCount}
                  <span className="text-[#F5F0E8]/25 text-2xl">/{total}</span>
                </p>
                <p className="text-[10px] text-[#F5F0E8]/35 uppercase tracking-[0.2em]">Correct</p>
              </div>
            </div>

            {wrongQuestions.length > 0 && (
              <>
                <div className="rule-gold w-2/3" />
                <div className="w-full flex flex-col gap-2">
                  <p className="text-[9px] text-[#F5F0E8]/30 uppercase tracking-[0.25em]">Missed</p>
                  <div className="max-h-44 overflow-y-auto flex flex-col gap-1.5">
                    {wrongQuestions.map((q, i) => (
                      <div key={i} className="flex gap-3 panel px-3 py-2">
                        <span className="text-[#22C55E]/70 text-[10px] font-display font-bold uppercase tracking-[0.12em] flex-shrink-0 mt-0.5">
                          {LABELS[q.correctIndex]}
                        </span>
                        <p className="text-[11px] text-[#F5F0E8]/50 leading-snug line-clamp-2">{q.stem}</p>
                      </div>
                    ))}
                  </div>
                </div>
              </>
            )}

            <div className="flex gap-3 w-full mt-1">
              <button
                onClick={onRetry}
                className="flex-1 btn-gold font-display font-black text-sm uppercase tracking-[0.18em] px-4 py-3"
              >
                Retry Unit
              </button>
              <button
                onClick={onEnd}
                className="flex-1 btn-ghost font-display font-bold text-sm uppercase tracking-[0.18em] px-4 py-3"
              >
                Lobby
              </button>
            </div>
          </div>
        </div>
      </main>
    );
  }

  // ── Question drill ───────────────────────────────────────────────────────────
  const isAnswered = selectedIdx !== null;
  const isCorrect = isAnswered && selectedIdx === current.correctIndex;

  return (
    <main className="min-h-screen text-[#F5F0E8] flex flex-col">
      {/* Header */}
      <div className="panel border-x-0 border-t-0 px-5 pt-4 pb-3">
        <div className="flex items-center justify-between max-w-xl mx-auto">
          <div className="flex flex-col min-w-0">
            <p className="text-[9px] text-[#F5F0E8]/30 uppercase tracking-[0.25em]">Practice · {subject.replace('AP ', '')}</p>
            <p className="text-[11px] text-[#C9A84C] font-display font-bold uppercase tracking-[0.1em] truncate max-w-[180px]">
              {unit.replace(/^Unit d+: /, '')}
            </p>
          </div>
          <div className="flex items-center gap-4 flex-shrink-0">
            <p className="text-[10px] text-[#F5F0E8]/35 uppercase tracking-[0.2em] tabular-nums">
              <span className="text-[#22C55E]">{correctCount}</span> / {currentIdx} correct
            </p>
            <p className="text-[10px] text-[#C9A84C] font-display font-bold tabular-nums">
              {currentIdx + 1} / {total}
            </p>
          </div>
        </div>
        <div className="max-w-xl mx-auto mt-3 h-0.5 bg-[#1C1C1C]">
          <div
            className="h-full bg-[#C9A84C] transition-all duration-500"
            style={{ width: `${(currentIdx / total) * 100}%` }}
          />
        </div>
      </div>

      {/* Question + Options */}
      <div className="flex-1 flex flex-col justify-center px-5 py-6 max-w-xl mx-auto w-full">
        <div key={current.id} className="panel-raised panel-accent-top px-6 py-6 mb-6 animate-slide-in">
          <p className="text-[#C9A84C]/70 text-xs font-display font-bold uppercase tracking-[0.25em] mb-3">
            Question {currentIdx + 1}
          </p>
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
              containerCls = 'border border-[#22C55E] bg-[#22C55E]/10 animate-correct';
              badgeCls     = 'border border-[#22C55E] text-[#22C55E] bg-[#22C55E]/20';
              textCls      = 'text-[#22C55E]';
            } else if (isThisWrong) {
              containerCls = 'border border-[#EF4444] bg-[#EF4444]/10 animate-shake';
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

        {/* Next button — only shown on wrong answer; correct auto-advances */}
        {isAnswered && !isCorrect && (
          <button
            onClick={advance}
            className="mt-4 btn-gold w-full font-display font-black text-sm uppercase tracking-[0.18em] py-3"
          >
            {currentIdx + 1 >= total ? 'See Results' : 'Next Question →'}
          </button>
        )}

        {isAnswered && isCorrect && (
          <p className="mt-5 text-center text-[10px] text-[#22C55E]/40 uppercase tracking-[0.25em] animate-fade-up">
            Correct — next question loading…
          </p>
        )}
      </div>
    </main>
  );
}
