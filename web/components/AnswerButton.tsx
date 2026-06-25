'use client';

// Shared answer-option button used by both BattleRoom and PracticeMode.

const LABELS = ['A', 'B', 'C', 'D'];

export type AnswerState = 'idle' | 'selected' | 'correct' | 'wrong' | 'dimmed';

interface AnswerButtonProps {
  index: number;
  text: string;
  state: AnswerState;
  disabled: boolean;
  onClick: (index: number) => void;
  animationDelay?: number;
}

export default function AnswerButton({
  index,
  text,
  state,
  disabled,
  onClick,
  animationDelay = 0,
}: AnswerButtonProps) {
  let containerCls = 'panel hover:bg-[#1C1C1C] hover:border-[#C9A84C]/50 hover:translate-x-0.5';
  let badgeCls = 'border border-[#C9A84C]/30 text-[#C9A84C]/60';
  let textCls = 'text-[#F5F0E8]/80';

  if (state === 'correct') {
    containerCls = 'border border-[#22C55E] bg-[#22C55E]/10 animate-correct';
    badgeCls = 'border border-[#22C55E] text-[#22C55E] bg-[#22C55E]/20';
    textCls = 'text-[#22C55E]';
  } else if (state === 'wrong') {
    containerCls = 'border border-[#EF4444] bg-[#EF4444]/10 animate-shake';
    badgeCls = 'border border-[#EF4444] text-[#EF4444] bg-[#EF4444]/20';
    textCls = 'text-[#EF4444]';
  } else if (state === 'dimmed') {
    containerCls = 'panel opacity-35';
    badgeCls = 'border border-[#2A2A2A] text-[#374151]';
    textCls = 'text-[#374151]';
  } else if (state === 'selected') {
    containerCls = 'border border-[#C9A84C] bg-[#C9A84C]/10';
    badgeCls = 'border border-[#C9A84C] text-[#C9A84C] bg-[#C9A84C]/20';
    textCls = 'text-[#F5F0E8]';
  }

  return (
    <button
      onClick={() => onClick(index)}
      disabled={disabled}
      style={{ animationDelay: `${animationDelay}s` }}
      className={`w-full flex items-center gap-4 px-4 py-4 transition-all duration-150 animate-rise-in focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#D4B565] disabled:cursor-default ${containerCls}`}
    >
      <span
        className={`w-8 h-8 flex-shrink-0 flex items-center justify-center text-sm font-display font-bold tabular-nums ${badgeCls}`}
      >
        {LABELS[index]}
      </span>
      <span className={`text-left text-sm font-medium leading-snug ${textCls}`}>
        {text}
      </span>
      {state === 'correct' && (
        <span className="ml-auto text-[#22C55E] font-bold text-base flex-shrink-0">✓</span>
      )}
      {state === 'wrong' && (
        <span className="ml-auto text-[#EF4444] font-bold text-base flex-shrink-0">✕</span>
      )}
    </button>
  );
}

/** Derive the AnswerState for a given option index from reveal/selection context. */
export function deriveAnswerState(opts: {
  index: number;
  selectedIndex: number | null;
  correctIndex: number | null;
  isReveal: boolean;
}): AnswerState {
  const { index, selectedIndex, correctIndex, isReveal } = opts;
  if (isReveal) {
    if (index === correctIndex) return 'correct';
    if (index === selectedIndex && index !== correctIndex) return 'wrong';
    return 'dimmed';
  }
  if (index === selectedIndex) return 'selected';
  return 'idle';
}
