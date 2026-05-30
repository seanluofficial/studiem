// Presentational rank-tier chip. Square-cornered, tier-tinted hairline +
// matte fill. Server-safe (no hooks). Pass an ELO; tier is derived.
import { eloToTier } from '@/lib/rank';

interface RankBadgeProps {
  /** Player ELO. Defaults to 1000 (Gold) if null/undefined. */
  elo: number | null | undefined;
  /** Visual scale. Default 'md'. */
  size?: 'sm' | 'md' | 'lg';
  /** Show the numeric ELO alongside the tier name. Default true. */
  showElo?: boolean;
  className?: string;
}

const SIZES = {
  sm: 'text-[10px] px-2 py-0.5 gap-1.5',
  md: 'text-xs px-2.5 py-1 gap-2',
  lg: 'text-sm px-3 py-1.5 gap-2.5',
} as const;

export default function RankBadge({
  elo,
  size = 'md',
  showElo = true,
  className = '',
}: RankBadgeProps) {
  const rating = elo ?? 1000;
  const tier = eloToTier(rating);

  return (
    <span
      className={`inline-flex items-center font-display font-bold uppercase tracking-[0.18em] tabular-nums ${SIZES[size]} ${className}`}
      style={{
        color: tier.color,
        backgroundColor: 'var(--surface)',
        border: `1px solid ${tier.color}`,
        boxShadow: 'inset 0 1px 0 rgba(245,240,232,0.05)',
      }}
    >
      {/* Tier pip */}
      <span
        className="inline-block w-1.5 h-1.5 flex-shrink-0"
        style={{ backgroundColor: tier.color }}
        aria-hidden="true"
      />
      {tier.name}
      {showElo && (
        <span className="text-[#F5F0E8]/55 font-sans font-medium tracking-normal">
          {rating}
        </span>
      )}
    </span>
  );
}
