'use client';

import { useState, useEffect, useCallback } from 'react';
import AnswerButton, { deriveAnswerState } from '@/components/AnswerButton';
import { recordPracticeAnswer } from '@/lib/practice';
import { createClient } from '@/lib/supabase/client';

// ── Shared types (imported by practice/page.tsx as well) ──────────────────────

export interface PracticeQuestion {
  id: string;           // variant id
  sourceCardId: string; // for stat tracking
  stem: string;
  options: string[];
  correctIndex: number;
  correctExplanation: string | null;
  unit: string;         // for stat tracking and per-unit summary
}

export interface SessionResult {
  totalCorrect: number;
  totalAnswered: number;
  byUnit: Record<string, { correct: number; total: number }>;
  wrongQuestions: PracticeQuestion[];
}

// ── Props ──────────────────────────────────────────────────────────────────────

interface Props {
  questions: PracticeQuestion[];
  subject: string;
  unit: string | null; // null = Practice All
  userId: string;
  onStop: (results: SessionResult) => void;
}

// ── Internal state ─────────────────────────────────────────────────────────────

interface DrillState {
  currentIdx: number;
  selectedIdx: number | null;
  sessionResults: { question: PracticeQuestion; wasCorrect: boolean }[];
}

function compileResults(
  sessionResults: { question: PracticeQuestion; wasCorrect: boolean }[]
): SessionResult {
  const byUnit: Record<string, { correct: number; total: number }> = {};
  const wrongQuestions: PracticeQuestion[] = [];
  let totalCorrect = 0;
  for (const { question, wasCorrect } of sessionResults) {
    if (!byUnit[question.unit]) byUnit[question.unit] = { correct: 0, total: 0 };
    byUnit[question.unit].total++;
    if (wasCorrect) {
      byUnit[question.unit].correct++;
      totalCorrect++;
    } else {
      wrongQuestions.push(question);
    }
  }
  return {
    totalCorrect,
    totalAnswered: sessionResults.length,
    byUnit,
    wrongQuestions,
  };
}

export default function PracticeMode({ questions, subject, unit, userId, onStop }: Props) {
  const [state, setState] = useState<DrillState>({
    currentIdx: 0,
    selectedIdx: null,
    sessionResults: [],
  });

  const supabase = createClient();

  const current = questions[state.currentIdx % questions.length];

  const sessionAnswered = state.sessionResults.length;
  const sessionCorrect = state.sessionResults.filter(r => r.wasCorrect).length;

  const handleStop = useCallback(() => {
    onStop(compileResults(state.sessionResults));
  }, [onStop, state.sessionResults]);

  const handleNext = useCallback(() => {
    setState(prev => ({
      ...prev,
      currentIdx: prev.currentIdx + 1,
      selectedIdx: null,
    }));
  }, []);

  const handleAnswer = useCallback(
    (i: number) => {
      setState(prev => {
        if (prev.selectedIdx !== null) return prev; // already answered
        const wasCorrect = i === current.correctIndex;
        recordPracticeAnswer(supabase, userId, current.sourceCardId, subject, current.unit, wasCorrect).catch(
          (err: unknown) => console.error('[practice]', err)
        );
        return {
          ...prev,
          selectedIdx: i,
          sessionResults: [...prev.sessionResults, { question: current, wasCorrect }],
        };
      });
    },
    [current, supabase, userId, subject]
  );

  // Keyboard navigation
  useEffect(() => {
    function onKeyDown(e: KeyboardEvent) {
      // Ignore if typing in an input
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return;

      const isAnswered = state.selectedIdx !== null;

      if (!isAnswered) {
        // Keys 1-4 or a-d select answers
        let idx: number | null = null;
        if (e.key === '1' || e.key.toLowerCase() === 'a') idx = 0;
        else if (e.key === '2' || e.key.toLowerCase() === 'b') idx = 1;
        else if (e.key === '3' || e.key.toLowerCase() === 'c') idx = 2;
        else if (e.key === '4' || e.key.toLowerCase() === 'd') idx = 3;
        if (idx !== null) {
          e.preventDefault();
          handleAnswer(idx);
        }
      } else {
        // Enter or Space to advance
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          handleNext();
        }
      }

      // Escape to stop
      if (e.key === 'Escape') {
        e.preventDefault();
        handleStop();
      }
    }

    document.addEventListener('keydown', onKeyDown);
    return () => document.removeEventListener('keydown', onKeyDown);
  }, [state.selectedIdx, handleAnswer, handleNext, handleStop]);

  if (!current) return null;

  const isAnswered = state.selectedIdx !== null;
  const unitLabel = unit != null ? unit.replace(/^Unit \d+: /, '') : 'All Units';

  return (
    <main className="min-h-screen text-[#F5F0E8] flex flex-col">
      {/* Header */}
      <div className="panel border-x-0 border-t-0 px-5 pt-4 pb-3">
        <div className="flex items-center justify-between max-w-xl mx-auto">
          {/* Left: Stop + unit label */}
          <div className="flex items-center gap-4 min-w-0">
            <button
              onClick={handleStop}
              className="text-[#F5F0E8]/25 hover:text-[#EF4444]/70 text-xs uppercase tracking-widest transition-colors flex-shrink-0"
            >
              Stop
            </button>
            <div className="flex flex-col min-w-0">
              <p className="text-[9px] text-[#F5F0E8]/30 uppercase tracking-[0.25em]">
                {subject.replace('AP ', '')}
              </p>
              <p className="text-[11px] text-[#C9A84C] font-display font-bold uppercase tracking-[0.1em] truncate max-w-[200px]">
                {unitLabel}
              </p>
            </div>
          </div>

          {/* Right: session score */}
          <p className="text-[10px] text-[#F5F0E8]/35 uppercase tracking-[0.2em] tabular-nums flex-shrink-0">
            <span className="text-[#22C55E]">{sessionCorrect}</span>
            <span className="text-[#F5F0E8]/25"> / {sessionAnswered}</span>
          </p>
        </div>
      </div>

      {/* Question + Options */}
      <div className="flex-1 flex flex-col justify-center px-5 py-6 max-w-xl mx-auto w-full">
        <div
          key={`${current.id}-${state.currentIdx}`}
          className="panel-raised panel-accent-top px-6 py-6 mb-6 animate-rise-in"
        >
          <p className="text-base font-medium leading-relaxed text-[#F5F0E8]">{current.stem}</p>
        </div>

        <div className="flex flex-col gap-2">
          {current.options.map((opt, i) => (
            <AnswerButton
              key={i}
              index={i}
              text={opt}
              state={deriveAnswerState({
                index: i,
                selectedIndex: state.selectedIdx,
                correctIndex: current.correctIndex,
                isReveal: isAnswered,
              })}
              disabled={isAnswered}
              onClick={handleAnswer}
              animationDelay={0.05 * i}
            />
          ))}
        </div>

        {/* Explanation — always shown after answering if available */}
        {isAnswered && current.correctExplanation && (
          <div className="mt-5 panel px-5 py-4 border-l-2 border-[#C9A84C]/40 animate-fade-up">
            <p className="text-[9px] text-[#C9A84C]/60 uppercase tracking-[0.25em] mb-2">Explanation</p>
            <p className="text-sm text-[#F5F0E8]/70 leading-relaxed">{current.correctExplanation}</p>
          </div>
        )}

        {/* Next button */}
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
