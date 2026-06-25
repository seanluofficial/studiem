# Studiem — Technical Debt Register

Catalogued from a full repository audit. Each item has a severity, a location, and a clear description of the problem and fix.

Severity: **CRITICAL** (exploitable/data loss) → **HIGH** (user-visible bug or serious security gap) → **MEDIUM** (maintainability, silent incorrect behavior) → **LOW** (polish, minor inefficiency)

---

## Security

### TD-S1 — No authentication on HTTP challenge endpoints [CRITICAL]
**File:** [server/index.js:718-797](server/index.js#L718-L797)

`POST /challenge` and `POST /challenge/:id/submit` accept `challengerId` and `userId` from the request body with no JWT verification. Any HTTP client can submit a challenge result as any user, granting arbitrary ELO changes.

**Fix:** Read the `Authorization: Bearer <token>` header, verify with `supabase.auth.getUser(token)`, and reject if the token's `user.id` doesn't match the `userId` or `challengerId` in the body.

---

### TD-S2 — `answerIndex` not validated as 0–3 [HIGH]
**File:** [server/index.js:542-544](server/index.js#L542-L544)

`submit_answer` passes `answerIndex` directly to `handleAnswer` without checking that it's an integer in [0, 3]. A client sending `answerIndex: -1` or `answerIndex: 999` will never match `correct_index`, so it won't grant points, but it's untrusted data touching server state.

**Fix:** Add `if (!Number.isInteger(answerIndex) || answerIndex < 0 || answerIndex > 3) return;` at the top of `handleAnswer`.

---

### TD-S3 — CORS `origin: '*'` in production [HIGH]
**File:** [server/index.js:22](server/index.js#L22)

The Socket.io server accepts connections from any origin. Any website can proxy the battle server.

**Fix:** Set `cors: { origin: process.env.ALLOWED_ORIGIN ?? 'http://localhost:3000' }` and configure `ALLOWED_ORIGIN=https://studiem.gg` in Railway.

---

### TD-S4 — `new Function()` eval for formula evaluation [HIGH]
**File:** [server/questions.js:91](server/questions.js#L91)

`evalFormula` uses `new Function(...keys, \`return (${formula})\`)` where `formula` comes from source card JSON. If source JSON is ever writable by external parties or the import pipeline is compromised, this is remote code execution on the server.

Currently low-risk (local dev only, authored content), but the right fix is using `mathjs` for safe expression evaluation — it's already recommended in `CARD_SCHEMA.md` but not used.

---

### TD-S5 — Rate limiting absent on all socket events [HIGH]
**File:** [server/index.js](server/index.js) (all `socket.on` handlers)

A client can spam `join_queue`, `submit_answer`, or `send_message` without any throttle. `send_message` in particular triggers two Supabase queries per call.

**Fix:** Add per-socket rate limiting. A simple approach: track last-emit timestamp per event type per socket; reject events that arrive too quickly (e.g., `send_message` max once per 200ms).

---

### TD-S6 — `question_reports` RLS blocks reports from JSON fallback mode [MEDIUM]
**File:** [web/components/BattleRoom.tsx:44-54](web/components/BattleRoom.tsx#L44-L54)

When the server uses the JSON fallback (local dev, no `SUPABASE_URL`), question IDs are fake strings (`stem.slice(0, 32)` or `formula_params`), not real UUIDs. The `question_reports` table has a FK on `question_variant_id` pointing to `question_variants(id)`. Inserts with fake IDs fail silently — the user sees "Reported" but nothing is recorded.

**Fix:** Either don't render the Report button when `question.id` is not a UUID-shaped string, or handle the error and show a failure state.

---

## Correctness Bugs

### TD-B1 — Win/Loss stats on profile page are "last 10", not "all-time" [HIGH]
**File:** [web/app/profile/page.tsx:93-97](web/app/profile/page.tsx#L93-L97)

The profile page queries battles with `.limit(10)` for the history display, then counts wins and losses from those same 10 rows. The "Wins" and "Losses" stat blocks display these as if they are career totals.

**Fix:** Query total wins/losses separately with no limit, using a COUNT query or a Supabase RPC. The recent battles list can keep its limit.

```typescript
// Add to Promise.all:
supabase
  .from('battles')
  .select('winner_id', { count: 'exact' })
  .eq('player1_id', profileUserId)  // need to handle both player1 and player2
```
Or use a Postgres function/view that returns the counts directly.

---

### TD-B2 — Double ELO fetch on initial page mount [MEDIUM]
**File:** [web/app/page.tsx:156-191](web/app/page.tsx#L156-L191)

Two `useEffect` hooks both fetch ELO. The first (`[router, subject]`) fetches inside `getUser()` on mount. The second (`[userId, subject]`) also fetches after `userId` state is set. Both fire within milliseconds of each other on first load, producing two identical Supabase queries.

**Fix:** Remove the ELO fetch from the first effect. Let the second effect (`[userId, subject]`) be the single source of ELO data.

---

### TD-B3 — JSON fallback ignores `subject` parameter [MEDIUM]
**File:** [server/questions.js:7](server/questions.js#L7)

`CONTENT_DIR` is hardcoded to `content/apchem/`. `pickQuestionsFromJSON` serves AP Chemistry questions regardless of the `subject` argument. In local dev with multiple subjects, all battles serve chemistry questions.

**Fix:** Add a `SUBJECT_TO_DIR` map and use it in `loadAllCards`. If a directory doesn't exist, return an empty array with a clear warning.

---

### TD-B4 — `used_in_battle_count` never incremented [MEDIUM]
**File:** [server/questions.js:46-65](server/questions.js#L46-L65), [supabase/migrations/002_questions.sql](supabase/migrations/002_questions.sql)

`question_variants.used_in_battle_count` exists in the schema. `CARD_SCHEMA.md` documents it being used to deprioritize overused variants. `pickQuestionsFromDB` never reads or increments it.

**Fix:** Either remove the column (with a migration `DROP COLUMN used_in_battle_count`) or implement the increment after selecting variants:
```js
await supabase.from('question_variants').update({ used_in_battle_count: supabase.rpc('increment', ...) }).in('id', selectedIds);
```

---

### TD-B5 — Disconnect grace period marked done but not implemented [MEDIUM]
**File:** [server/index.js:400-447](server/index.js#L400-L447), [BACKLOG.md](BACKLOG.md) item #17

Backlog item #17 ("Disconnect: 30-second reconnect grace period") is checked `[x]` as complete. The actual `handleDisconnect` function calls `endBattle(roomId, socketId)` immediately on disconnect — there is no timer, no grace period, no reconnect path.

This is a feature gap, not just a bug. Either revert the backlog item to `[ ]`, or implement the grace period.

---

### TD-B6 — Message prune uses hardcoded `.range(50, 9999)` [LOW]
**File:** [server/index.js:585-593](server/index.js#L585-L593)

`.range(50, 9999)` assumes no conversation will ever exceed ~9999 messages. The correct implementation uses offset without an upper bound.

**Fix:**
```js
const { data: old } = await supabase
  .from('messages')
  .select('id')
  .or(...)
  .order('created_at', { ascending: false })
  .range(50, 999999); // or use a DELETE with a subquery
```

---

## Missing Migrations

### TD-M1 — `friendships` table has no migration file [HIGH]
The `friendships` table (`requester_id`, `addressee_id`, `status`, `id`) is queried throughout `server/index.js`, `web/components/FriendsPanel.tsx`, `web/app/leaderboard/page.tsx`, and `web/app/profile/page.tsx`. No migration file exists for it.

**Risk:** Recreating the DB from migrations produces a non-functional application. The migration is in the live Supabase DB but not in source control.

**Fix:** Write `supabase/migrations/010_friendships.sql` by introspecting the live DB schema.

---

### TD-M2 — `messages` table has no migration file [HIGH]
The `messages` table (`sender_id`, `receiver_id`, `content`, `read_at`, `created_at`) is used in `server/index.js` and `web/components/ChatBox.tsx`. No migration file exists.

**Fix:** Write `supabase/migrations/011_messages.sql`.

---

### TD-M3 — `profiles.invite_code` column has no migration file [MEDIUM]
`FriendsPanel.tsx` reads `invite_code` from `profiles`. No migration adding this column exists.

**Fix:** Add `ALTER TABLE public.profiles ADD COLUMN invite_code TEXT UNIQUE;` to a new migration, with a function that generates an 8-character alphanumeric code on profile insert.

---

## Code Duplication

### TD-D1 — Supabase client initialized 4 times [MEDIUM] — **RESOLVED**
**Fixed:** `server/supabase.js` created with shared `getSupabase()`. All four server modules (`index.js`, `elo.js`, `questions.js`, `streak.js`) now use `const { getSupabase } = require('./supabase')`.

~~**Files:** [server/index.js:29-38](server/index.js#L29-L38), [server/elo.js:1-14](server/elo.js#L1-L14), [server/questions.js:11-20](server/questions.js#L11-L20), [server/streak.js:1-14](server/streak.js#L1-L14)~~

**Original fix applied:**
```js
const { createClient } = require('@supabase/supabase-js');
const ws = require('ws');
let _supabase = null;
function getSupabase() {
  if (!_supabase) {
    _supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY,
      { realtime: { transport: ws } }
    );
  }
  return _supabase;
}
module.exports = { getSupabase };
```
Then `const { getSupabase } = require('./supabase')` in all four modules.

---

### TD-D2 — Answer button styling duplicated in BattleRoom and PracticeMode [LOW] — **RESOLVED**
**Fixed:** `web/components/AnswerButton.tsx` created. Exports `AnswerButton` component, `AnswerState` type (`'idle' | 'selected' | 'correct' | 'wrong' | 'dimmed'`), and `deriveAnswerState()` helper. Both `BattleRoom.tsx` and `PracticeMode.tsx` now use it.

---

### TD-D3 — `MVP_SUBJECTS` constant defined in 4 files [LOW]
**Files:** `web/app/page.tsx:68`, `web/app/profile/page.tsx:10`, `web/app/leaderboard/page.tsx:6`, `web/components/FriendsPanel.tsx` (implicitly via subject display)

**Fix:** Export from `web/lib/constants.ts`:
```ts
export const MVP_SUBJECTS = ['AP Biology', 'AP Chemistry', 'AP US History', 'AP Psychology', 'AP Calculus AB'] as const;
export type Subject = typeof MVP_SUBJECTS[number];
```

---

## Maintainability Risks

### TD-MA1 — `web/app/page.tsx` is a large god component [HIGH]
**Partial improvement:** Practice phases (`practice-select`, `practice`) extracted to `web/app/practice/page.tsx`. Page now handles lobby and battle phases only (~25 useState hooks, down from ~30). Remaining phases: lobby, queuing, countdown, battle, finished, complete. All socket event listeners, auth state, friends state, and ELO state still live in one component.

Every new feature adds more state and more socket listeners to an already-overloaded component. Any refactoring of one phase risks breaking others.

**Fix:** Split into focused components coordinated by a thin `Home` shell:
- `LobbyView.tsx` — idle subject selection, ELO display, join queue button
- `QueueView.tsx` — queuing, countdown states
- `BattleView.tsx` — delegates to existing BattleRoom + finished state
- `ResultView.tsx` — complete state with animated ELO
- Keep socket setup in a custom hook: `useSocket.ts`

---

### TD-MA2 — `server/index.js` is an 817-line monolith [HIGH]
The file mixes: matchmaking, battle execution, presence/social system, DM messaging, direct challenges, and HTTP REST endpoints. The messaging system alone has grown to ~100 lines of async Supabase calls embedded in socket handlers.

**Fix:** Extract modules:
- `server/matchmaking.js` — `queue`, `tryMatch`, `createBattle`
- `server/battle.js` — `startBattle`, `handleAnswer`, `tryAdvanceQuestion`, `finishPlayer`, `endBattle`
- `server/presence.js` — presence maps, friend events, direct challenges
- `server/messaging.js` — `send_message`, `mark_messages_read`
- `server/index.js` becomes the wiring layer only

---

### TD-MA3 — PRD and live code diverge on 5 significant behaviors [MEDIUM]
**File:** [PRD.md](PRD.md)

| PRD says | Code does |
|---|---|
| 10 questions per battle | 1 question (test mode) |
| 10s disconnect grace period | Immediate forfeit |
| Free tier: 3 battles/day | No limit (disabled) |
| "Rematch" + "New Opponent" buttons | "Play Again" + "Lobby" |
| NextAuth.js for auth | Supabase Auth |
| PostgreSQL via Railway | Supabase Postgres |

A new developer reading the PRD will build toward wrong targets. Update the PRD or add a "Current Implementation" section.

---

## Dead Code / Dead Schema

### TD-DC1 — `fr_static` and `fr_numeric` card types [LOW]
These types are allowed in the `source_cards` CHECK constraint and documented in `CARD_SCHEMA.md` (as "deprecated"). No free-response UI exists anywhere in the app. The generation pipeline never produces them. They are dead.

**Fix:** Remove from the CHECK constraint in a migration: `CHECK (type IN ('mc_static', 'mc_numeric'))`. Update CARD_SCHEMA.md.

### TD-DC2 — `data_chart` visual type [LOW]
Documented in CARD_SCHEMA.md as "reserved for future use." No code renders it. Remove from documentation.

### TD-DC3 — `used_in_battle_count` column [MEDIUM]
See TD-B4. Either implement or drop.

### TD-DC4 — `correct_value` column in `question_variants` [LOW]
`question_variants.correct_value` is defined for numeric types but never read by `pickQuestionsFromDB` or used in any server-side grading logic. Free response grading is not implemented. The column is dead for the current MC-only battle format.

---

## Performance

### TD-P1 — Practice mode uses two-round sampling [LOW]
**File:** [web/app/practice/page.tsx](web/app/practice/page.tsx) (`startDrill`)

The new practice page first selects up to 50 source cards via weighted JS sampling, then fetches their variants. This is more expensive than `ORDER BY random()` but is necessary for accuracy-weighted selection. The two-step query avoids joining user stats in Postgres, keeping queries simple and Supabase-plannable. Acceptable for now; could be replaced with a Postgres function that embeds the weighting logic.

### TD-P2 — Friends leaderboard makes 3 sequential queries [LOW]
**File:** [web/app/leaderboard/page.tsx:44-77](web/app/leaderboard/page.tsx#L44-L77)

The friends tab fetches friendships, then ELO rows, then profile names in sequence. Could be parallelized or expressed as a single join query.
