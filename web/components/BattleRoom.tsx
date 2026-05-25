'use client';

interface Question {
  id: string;
  stem: string;
  options: string[];
  correct_index: number;
}

interface BattleState {
  phase: 'question' | 'reveal';
  question: Question | null;
  qIndex: number;
  qTotal: number;
  selectedIndex: number | null;
  correctIndex: number | null;
  lastCorrect: boolean | null;
  myScore: number;
  oppScore: number;
  oppQIndex: number;
}

interface Props {
  battle: BattleState;
  opponent: { displayName: string };
  mySocketId: string;
  onSubmit: (index: number) => void;
}

export default function BattleRoom({ battle, opponent, onSubmit }: Props) {
  const { phase, question, qIndex, qTotal, selectedIndex, correctIndex, lastCorrect, myScore, oppScore, oppQIndex } = battle;

  if (!question) {
    return (
      <main className="min-h-screen bg-gray-950 text-white flex items-center justify-center">
        <p className="text-gray-400 animate-pulse">Loading question…</p>
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-gray-950 text-white flex flex-col items-center justify-center gap-6 px-4">
      {/* Score header */}
      <div className="flex justify-between w-full max-w-xl text-sm text-gray-400">
        <span>You: <strong className="text-white">{myScore}</strong></span>
        <span>Q {qIndex}/{qTotal}</span>
        <span>
          {opponent.displayName}: <strong className="text-white">{oppScore}</strong>
          <span className="ml-1 text-gray-600">(Q{Math.min(oppQIndex + 1, qTotal)}/{qTotal})</span>
        </span>
      </div>

      <div className="w-full max-w-xl flex flex-col gap-4">
        <p className="text-lg font-medium leading-relaxed">{question.stem}</p>

        <div className="flex flex-col gap-3">
          {question.options.map((opt, i) => {
            let cls = 'bg-gray-800 hover:bg-gray-700 border-gray-700';
            if (phase === 'reveal') {
              if (i === correctIndex) cls = 'bg-green-700 border-green-500';
              else if (i === selectedIndex) cls = 'bg-red-800 border-red-600';
              else cls = 'bg-gray-800 border-gray-700 opacity-40';
            } else if (i === selectedIndex) {
              cls = 'bg-indigo-700 border-indigo-500';
            }
            return (
              <button
                key={i}
                onClick={() => onSubmit(i)}
                disabled={selectedIndex !== null || phase === 'reveal'}
                className={`w-full text-left px-4 py-3 rounded-lg border transition ${cls}`}
              >
                <span className="font-semibold mr-2">{String.fromCharCode(65 + i)}.</span>
                {opt}
              </button>
            );
          })}
        </div>

        {/* Result feedback — shown briefly before next question loads */}
        {phase === 'reveal' && lastCorrect !== null && (
          <p className={`text-center text-sm font-semibold animate-pulse ${lastCorrect ? 'text-green-400' : 'text-red-400'}`}>
            {lastCorrect ? '✓ Correct!' : '✗ Wrong'}
          </p>
        )}
        {phase === 'reveal' && lastCorrect === null && (
          <p className="text-center text-sm text-gray-500 animate-pulse">Time's up — next question coming…</p>
        )}
      </div>
    </main>
  );
}
