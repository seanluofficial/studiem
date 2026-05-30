// Pure ELO → rank-tier mapping. No deps. Source of truth for tier identity.
// Six tiers across realistic competitive ELO bands. Gold maps near the 1000
// default rating so a fresh player sits in the brand's hero tier.

export interface Tier {
  /** Display name, e.g. "Gold". */
  name: string;
  /** Tier accent color (matches --tier-* vars in globals.css). */
  color: string;
  /** Inclusive lower ELO bound for this tier. */
  min: number;
}

const TIERS: Tier[] = [
  { name: 'Bronze',   color: '#A06A3C', min: 0 },
  { name: 'Silver',   color: '#B8BCC4', min: 800 },
  { name: 'Gold',     color: '#C9A84C', min: 1000 },
  { name: 'Platinum', color: '#5FD3C4', min: 1300 },
  { name: 'Diamond',  color: '#6EA8FF', min: 1600 },
  { name: 'Master',   color: '#C96AE0', min: 1900 },
];

/**
 * Map an ELO rating to its tier. Always returns a tier (clamps below Bronze
 * to Bronze). Null/undefined-safe callers should default to 1000 before call.
 */
export function eloToTier(elo: number): Tier {
  let tier = TIERS[0];
  for (const t of TIERS) {
    if (elo >= t.min) tier = t;
  }
  return tier;
}
