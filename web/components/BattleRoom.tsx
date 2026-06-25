'use client';

import { useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import RankBadge from '@/components/RankBadge';
import AnswerButton, { deriveAnswerState } from '@/components/AnswerButton';

interface Question {
  id: string;
  stem: string;
  options: string[];
  correct_index: number;
}

interface BattleState {
  phase: 'question' | 'reveal' | 'waiting';
  question: Question | null;
  qIndex: number;
  qTotal: number;
  selectedIndex: number | null;
  correctIndex: number | null;
  lastCorrect: boolean | null;
  opponentAnswer: number | null;
  myScore: number;
  oppScore: number;
  oppQIndex: number;
}

interface Props {
  battle: BattleState;
  opponent: { displayName: string };
  mySocketId: string;
  onSubmit: (index: number) => void;
  myElo: number | null;
  opponentElo: number | null;
  displayName: string;
}

export default function BattleRoom({ battle, opponent, onSubmit, myElo, opponentElo, displayName }: Props) {
  const { phase, question, qIndex, qTotal, selectedIndex, correctIndex, lastCorrect, myScore, oppScore } = battle;
  const [reportSent, setReportSent] = useState(false);

  async function sendReport() {
    if (!question || reportSent) return;
    setReportSent(true);
    const supabase = createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;
    await supabase.from('question_reports').insert({
      question_variant_id: question.id,
      reporter_id: user.id,
      reason: 'user_flag',
    });
  }

  if (!question) {
    return (
      <main className="min-h-screen text-[#F5F0E8] flex flex-col items-center justify-center gap-5">
        <p className="font-display font-bold text-xs uppercase tracking-[0.3em] text-[#F5F0E8]/30">
          Loading Match
        </p>
        <div className="flex gap-2">
          <span className="w-2 h-2 bg-[#C9A84C] dot-1" />
          <span className="w-2 h-2 bg-[#C9A84C] dot-2" />
          <span className="w-2 h-2 bg-[#C9A84C] dot-3" />
        </div>
      </main>
    );
  }

  // ── Waiting phase ──────────────────────────────────────────────────────────
  if (phase === 'waiting') {
    return (
      <main className="min-h-screen text-[#F5F0E8] flex flex-col items-center justify-center px-4">
        <div className="relative w-full max-w-xl flex flex-col items-center px-6 py-12 animate-rise-in panel panel-accent-top">
          <div className="glow-focus animate-glow-pulse" />

          <div className="relative z-10 flex flex-col items-center w-full">
            <p className="font-display font-black text-2xl uppercase tracking-[0.25em] text-[#C9A84C]">
              Answer Locked
            </p>
            <div className="rule-gold w-32 my-4" />
            <div className="flex items-center gap-2 mb-8">
              <p className="text-[#F5F0E8]/30 text-xs uppercase tracking-[0.3em]">Awaiting opponent</p>
              <span className="flex gap-1">
                <span className="w-1.5 h-1.5 bg-[#C9A84C] dot-1" />
                <span className="w-1.5 h-1.5 bg-[#C9A84C] dot-2" />
                <span className="w-1.5 h-1.5 bg-[#C9A84C] dot-3" />
              </span>
            </div>

            <div className="flex items-stretch justify-center gap-6 w-full">
              <div className="flex-1 flex flex-col items-center text-center gap-2">
                <p className="text-xs text-[#F5F0E8]/35 uppercase tracking-[0.2em] truncate max-w-full">{displayName || 'You'}</p>
                <p className="font-display font-black text-6xl tabular-nums text-[#F5F0E8]">{myScore}</p>
                <RankBadge elo={myElo} size="sm" />
              </div>
              <div className="flex items-center">
                <span className="font-display font-black text-3xl text-[#2A2A2A] animate-vs-clash">vs</span>
              </div>
              <div className="flex-1 flex flex-col items-center text-center gap-2">
                <p className="text-xs text-[#F5F0E8]/35 uppercase tracking-[0.2em] truncate max-w-full">{opponent.displayName}</p>
                <p className="font-display font-black text-6xl tabular-nums text-[#F5F0E8]">{oppScore}</p>
                <RankBadge elo={opponentElo} size="sm" />
              </div>
            </div>

            <p className="text-[#F5F0E8]/25 text-xs uppercase tracking-[0.3em] tabular-nums mt-8">
              Question {qIndex} / {qTotal}
            </p>
          </div>
        </div>
      </main>
    );
  }

  // ── Question / Reveal phase ────────────────────────────────────────────────
  const isReveal = phase === 'reveal';

  return (
    <main className="min-h-screen text-[#F5F0E8] flex flex-col">
      {/* Match HUD */}
      <div className="relative z-10 panel border-x-0 border-t-0 px-5 pt-4 pb-3">
        <div className="flex items-stretch justify-between max-w-xl mx-auto gap-3">
          {/* Me */}
          <div className="flex items-center gap-3 min-w-0 flex-1">
            <span className="font-display font-black text-4xl tabular-nums text-[#F5F0E8] leading-none">{myScore}</span>
            <div className="flex flex-col items-start min-w-0 gap-1">
              <p className="text-[#F5F0E8]/45 text-xs uppercase tracking-[0.18em] truncate max-w-[110px]">
                {displayName || 'You'}
              </p>
              <RankBadge elo={myElo} size="sm" />
            </div>
          </div>

          {/* Progress */}
          <div className="flex flex-col items-center justify-center gap-1.5 flex-shrink-0 px-1">
            <p className="text-[#C9A84C] text-xs font-display font-bold uppercase tracking-[0.2em] tabular-nums">
              {qIndex} / {qTotal}
            </p>
            <div className="flex gap-1">
              {Array.from({ length: qTotal }).map((_, i) => (
                <span
                  key={i}
                  className={`w-1.5 h-1.5 transition-colors duration-300 ${i < qIndex ? 'bg-[#C9A84C]' : 'bg-[#2A2A2A]'}`}
                />
              ))}
            </div>
          </div>

          {/* Opponent */}
          <div className="flex items-center justify-end gap-3 min-w-0 flex-1">
            <div className="flex flex-col items-end min-w-0 gap-1">
              <p className="text-[#F5F0E8]/45 text-xs uppercase tracking-[0.18em] truncate max-w-[110px]">
                {opponent.displayName}
              </p>
              <RankBadge elo={opponentElo} size="sm" />
            </div>
            <span className="font-display font-black text-4xl tabular-nums text-[#F5F0E8] leading-none">{oppScore}</span>
          </div>
        </div>

        {/* Gold progress bar */}
        <div className="max-w-xl mx-auto mt-3 h-0.5 bg-[#1C1C1C]">
          <div
            className="h-full bg-[#C9A84C] transition-all duration-500 score-bar"
            style={{ width: `${(qIndex / (qTotal || 1)) * 100}%` }}
          />
        </div>
      </div>

      {/* Question + Options */}
      <div className="relative z-10 flex-1 flex flex-col justify-center px-5 py-6 max-w-xl mx-auto w-full">
        {/* Question */}
        <div
          key={question.id}
          className="panel-raised panel-accent-top px-6 py-6 mb-6 animate-slide-in"
        >
          <p className="text-[#C9A84C]/70 text-xs font-display font-bold uppercase tracking-[0.25em] mb-3">
            Question {qIndex}
          </p>
          <p className="text-base font-medium leading-relaxed text-[#F5F0E8]">
            {question.stem}
          </p>
        </div>

        {/* Answer buttons */}
        <div className="flex flex-col gap-2">
          {question.options.map((opt, i) => (
            <AnswerButton
              key={i}
              index={i}
              text={opt}
              state={deriveAnswerState({
                index: i,
                selectedIndex,
                correctIndex,
                isReveal,
              })}
              disabled={selectedIndex !== null || isReveal}
              onClick={onSubmit}
              animationDelay={0.05 * i}
            />
          ))}
        </div>

        {/* Reveal feedback */}
        {isReveal && lastCorrect !== null && (
          <p className={`text-center text-xs uppercase tracking-[0.3em] font-display font-black mt-5 animate-fade-up ${
            lastCorrect ? 'text-[#22C55E]' : 'text-[#EF4444]'
          }`}>
            {lastCorrect ? 'Correct' : 'Incorrect'}
            <span className="block mt-1 text-[10px] tracking-[0.3em] text-[#F5F0E8]/25 font-bold">Next Question Loading</span>
          </p>
        )}

        {/* Report */}
        <div className="flex justify-end mt-5">
          <button
            onClick={sendReport}
            disabled={reportSent}
            className="text-xs text-[#F5F0E8]/15 hover:text-[#F5F0E8]/40 transition-colors disabled:opacity-30 uppercase tracking-[0.18em]"
          >
            {reportSent ? 'Reported' : 'Report Question'}
          </button>
        </div>
      </div>
    </main>
  );
}
