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
  /** If set and current < total, show placement UI instead of rank. */
  placement?: { current: number; total: number } | null;
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
  placement,
}: RankBadgeProps) {
  const rating = elo ?? 1000;
  const tier = eloToTier(rating);

  // Placement mode: show "Placement X/5" instead of rank
  if (placement && placement.current < placement.total) {
    return (
      <span
        className={`inline-flex items-center font-display font-bold uppercase tracking-[0.18em] tabular-nums ${SIZES[size]} ${className}`}
        style={{
          color: '#9CA3AF',
          backgroundColor: 'var(--surface)',
          border: '1px solid #374151',
          boxShadow: 'inset 0 1px 0 rgba(245,240,232,0.05)',
        }}
      >
        <span className="inline-block w-1.5 h-1.5 flex-shrink-0 bg-[#9CA3AF]" aria-hidden="true" />
        Placement
        <span className="text-[#F5F0E8]/40 font-sans font-medium tracking-normal">
          {placement.current}/{placement.total}
        </span>
      </span>
    );
  }

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
