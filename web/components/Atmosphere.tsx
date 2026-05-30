// Ambient background: vignette + faint film-grain + soft gold glows.
// Mount ONCE globally in layout.tsx, behind all content. Server-safe (no
// hooks, no 'use client'). Purely decorative + non-interactive.
export default function Atmosphere() {
  return <div className="atmosphere" aria-hidden="true" />;
}
