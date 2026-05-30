// Matte layered surface with a lit top edge + 1px border. Square corners.
// Server-safe (no hooks). Thin wrapper over the .panel / .panel-raised CSS
// utilities so screens don't re-declare elevation styling.
import type { ReactNode } from 'react';

interface PanelProps {
  children: ReactNode;
  /** 'base' → .panel (#141414). 'raised' → .panel-raised (#1C1C1C + shadow). */
  variant?: 'base' | 'raised';
  /** Add a hairline gold top-accent rule. */
  accent?: boolean;
  className?: string;
}

export default function Panel({
  children,
  variant = 'base',
  accent = false,
  className = '',
}: PanelProps) {
  const base = variant === 'raised' ? 'panel-raised' : 'panel';
  return (
    <div className={`${base} ${accent ? 'panel-accent-top' : ''} ${className}`}>
      {children}
    </div>
  );
}
