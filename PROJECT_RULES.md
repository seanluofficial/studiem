# Studiem — Project Rules

Engineering standards and invariants for this codebase. Read before writing any code.

---

## 1. Repository Layout

```
server/         Node.js + Express + Socket.io battle server (Railway)
  index.js      Battle engine, matchmaking, presence, messaging, HTTP routes
  elo.js        ELO calculation + Supabase upsert
  questions.js  Question loader: Supabase DB primary, JSON fallback for local dev
  streak.js     Daily streak tracking
  .env          SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, PORT

web/            Next.js 16 App Router frontend (Vercel)
  app/          Routes: page.tsx (lobby+battle), profile/, leaderboard/, challenge/
  components/   BattleRoom, FriendsPanel, NavBar, PracticeMode, RankBadge, ...
  lib/          socket.ts (singleton), supabase/client.ts, supabase/server.ts, rank.ts
  middleware.ts Auth guard — redirects unauthenticated requests to /login

supabase/
  migrations/   SQL migrations numbered 001–009 (run manually in Supabase dashboard)

content/
  apchem/       unit1–9.json source cards (local dev fallback only)
  ced/          Course and Exam Description JSON for each subject
  questions/    Generated question banks per subject
```

---

## 2. Architecture Invariants

These must never be violated without an explicit decision recorded in a commit message.

### Server is the single source of truth
- All game state (scores, question index, timers) lives in server memory.
- The client is a dumb renderer — it displays what the server sends, nothing more.
- Never trust a score, roomId, or game-state field from the client.

### Async per-player battle flow
- Each player answers at their own pace. Do NOT change to synchronized lockstep.
- The server waits for both players to answer before advancing to the next question (`tryAdvanceQuestion`).
- A player who finishes all questions sees a "waiting" screen until the opponent finishes.

### ELO is always per-subject
- Every ELO read or write must include a `subject` filter on `elo_ratings`.
- Never aggregate or compare ELO across subjects.

### Only `reviewed: true` source cards are served in battles
- The DB query in `questions.js` filters `reviewed = true` on `source_cards`.
- Do not remove or relax this filter.

### No draws in battle resolution
- `endBattle` must always resolve to a winner. After score comparison and time comparison, fall back to `sids[0]` as the deterministic tiebreaker.
- A `null` winner silently skips the ELO update and leaves the result screen showing DRAW.

### Server auth: service role key only
- The server uses `SUPABASE_SERVICE_ROLE_KEY` which bypasses RLS.
- This key must never be exposed to the client.
- The web app uses `NEXT_PUBLIC_SUPABASE_ANON_KEY` (public) + session cookies.

---

## 3. Input Validation Rules (Server)

All `socket.on(...)` data is untrusted. Follow these rules for every event:

| Field | Validation |
|---|---|
| `elo` | `isFinite(elo)`, clamp to `[ELO_MIN=100, ELO_MAX=3000]`, default to 1000 |
| `subject` | Check against `KNOWN_SUBJECTS` Set — reject unknown subjects |
| `displayName` | `typeof string`, `.trim()`, `.slice(0, DISPLAY_NAME_MAX=32)`, reject empty |
| `roomId` | Never trust for authorization — always verify `state.players[socket.id]` exists |
| `clientTimeTakenMs` | `typeof number`, `isFinite`, clamp to `[CLIENT_TIME_MIN_MS=500, CLIENT_TIME_MAX_MS=300000]` |
| `answerIndex` | Must be validated as integer in `[0, 3]` |
| `userId` | Check against `socketToUser` map — never trust raw userId from client for auth decisions |

---

## 4. Security Rules

- HTTP endpoints (`/challenge`, `/challenge/:id/submit`) must verify a Supabase JWT before acting. Currently they don't — this is the top-priority security fix.
- Never use `new Function()` or `eval()` with untrusted data. The JSON fallback `evalFormula` is the only current exception; it must be replaced with a safe math evaluator (mathjs).
- CORS `origin: '*'` is a local dev setting. In production it must be locked to `NEXT_PUBLIC_APP_URL`.
- Never commit `.env` files. Server secrets live in Railway environment variables.
- `question_reports` are inserted client-side — the FK on `question_variant_id` is the only guard against garbage inserts. In JSON-fallback mode, question IDs are fake strings, not UUIDs, and inserts will silently fail.

---

## 5. Database Rules

- All schema changes require a migration file in `supabase/migrations/` with the next sequential number.
- Migrations are run manually in the Supabase dashboard — they are NOT auto-applied.
- When writing a migration, note in the commit message that it must be applied.
- RLS must be enabled on every new table.
- The server writes ELO, battles, streaks, and questions via service role — no client-side writes for these.
- Three tables exist in the live DB but have no migration files in this repo: `friendships`, `messages`, and the `invite_code` column on `profiles`. If recreating the DB from migrations, these must be added manually.

---

## 6. TypeScript Rules (web/)

- No `any` types. No `@ts-ignore`.
- All socket event payloads must have typed interfaces at the callsite.
- Keep TypeScript strict — `tsconfig.json` already enforces this.
- Validate with `cd web && npx tsc --noEmit` before every commit.

---

## 7. Code Style

- No comments explaining what the code does. Only add a comment when the WHY is non-obvious.
- No docstrings. No JSDoc on trivial functions.
- No feature flags or backwards-compatibility shims when you can just change the code.
- Design system lives in `web/app/globals.css`. All visual token decisions go there. Do not add one-off magic colors in components — use the CSS variables or the defined utility classes.
- `LABELS = ['A','B','C','D']` and the answer-button styling pattern are duplicated in `BattleRoom.tsx` and `PracticeMode.tsx`. Consolidate before adding a third caller.

---

## 8. Validation Commands

Run before every commit. All must pass.

```powershell
# TypeScript check (web)
cd web; npx tsc --noEmit; cd ..

# Syntax check (server)
node --check server/index.js
node --check server/elo.js
node --check server/questions.js
node --check server/streak.js
```

---

## 9. Preserved Behaviors (Do Not Revert)

| Behavior | Detail |
|---|---|
| Async per-player battle flow | Players advance independently — no lockstep |
| Question count = 1 | Set for testing; see `startBattle` in `server/index.js` |
| No free-tier battle limits | `battles_today` check is disabled |
| Immediate disconnect forfeit | No reconnect grace period despite backlog item #17 being marked done |
| Result screen: Play Again + Lobby only | No Rematch button |
| AP Chemistry + AP Biology are the only live subjects | Others show "Coming Soon" |
