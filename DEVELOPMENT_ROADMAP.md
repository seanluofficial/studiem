# Studiem — Development Roadmap

Top 20 highest-ROI improvements, in priority order, before shipping new features. Each item maps to a TECH_DEBT.md entry.

ROI = (Impact if fixed) / (Effort to implement). Security exploits and user-visible bugs outrank maintainability wins regardless of effort.

---

## Priority 1 — Must fix before any real users

### #1 — Add JWT auth to HTTP challenge endpoints
**Debt:** TD-S1 | **Effort:** ~1 hour | **Risk:** Low

Any person can claim any userId in a POST body and earn ELO. This is actively exploitable.

**What to do:** In `server/index.js`, read `Authorization: Bearer <token>` header in both `/challenge` and `/challenge/:id/submit`. Call `getSupabase().auth.getUser(token)` to verify it. Reject if `user.id` doesn't match the `userId` / `challengerId` in the body.

```js
async function verifyToken(req) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return null;
  const { data: { user } } = await getSupabase().auth.getUser(token);
  return user ?? null;
}
```

---

### #2 — Extract shared `server/supabase.js` — **DONE**
**Debt:** TD-D1 | Created `server/supabase.js`; all four server modules updated. `node --check` passes on all server files.

---

### #3 — Write missing migration files for `friendships`, `messages`, `invite_code`
**Debt:** TD-M1, TD-M2, TD-M3 | **Effort:** ~1 hour | **Risk:** Low

These tables exist in production but not in source control. If the DB is ever recreated, the app will be non-functional and it won't be obvious why.

**What to do:** Introspect the live Supabase DB for the exact column types and constraints. Write:
- `supabase/migrations/010_friendships.sql`
- `supabase/migrations/011_messages.sql`
- `supabase/migrations/012_invite_code.sql`

Include RLS policies. These are documentation commits, not applied migrations.

---

### #4 — Fix Win/Loss stats showing last-10 as all-time totals
**Debt:** TD-B1 | **Effort:** 30 minutes | **Risk:** Low

Users see "Wins: 2" on their profile thinking it's their career record, but it's only the last 10 battles. This erodes trust in the product.

**What to do:** In `web/app/profile/page.tsx`, add a separate count query:
```ts
supabase
  .from('battles')
  .select('winner_id', { count: 'exact', head: true })
  .or(`player1_id.eq.${profileUserId},player2_id.eq.${profileUserId}`)
  .eq('winner_id', profileUserId)
```
Run two count queries (wins, losses) in parallel with the existing `Promise.all`. Remove the win/loss counting from the 10-battle loop.

---

### #5 — Validate `answerIndex` in `submit_answer`
**Debt:** TD-S2 | **Effort:** 5 minutes | **Risk:** Near zero

Unvalidated client input touching server state. Add one guard line.

**What to do:** In `handleAnswer` in `server/index.js`, add after the existing early-returns:
```js
if (!Number.isInteger(answerIndex) || answerIndex < 0 || answerIndex > 3) return;
```

---

### #6 — Lock CORS to production origin
**Debt:** TD-S3 | **Effort:** 10 minutes | **Risk:** Near zero

A public `origin: '*'` means any site can open a Socket.io connection to the battle server.

**What to do:** In `server/index.js`:
```js
const io = new Server(server, {
  cors: { origin: process.env.ALLOWED_ORIGIN ?? 'http://localhost:3000' },
  ...
});
```
Set `ALLOWED_ORIGIN=https://studiem.gg` (or whatever the Vercel domain is) in Railway environment variables.

---

## Priority 2 — Fix before feature growth compounds the problem

### #7 — Replace `new Function()` eval with mathjs
**Debt:** TD-S4 | **Effort:** 1–2 hours | **Risk:** Low

Code injection risk in formula evaluation, plus mathjs is already the intended solution per CARD_SCHEMA.md.

**What to do:**
```
cd server && npm install mathjs
```
In `server/questions.js`, replace `evalFormula`:
```js
const { evaluate } = require('mathjs');
function evalFormula(formula, params) {
  return evaluate(formula, params);
}
```
`mathjs.evaluate` is sandboxed — it cannot access `process`, `require`, or any JS globals. Test with both `mc_static` and `mc_numeric` card types.

---

### #8 — Fix double ELO fetch on page mount
**Debt:** TD-B2 | **Effort:** 15 minutes | **Risk:** Low

Two Supabase queries fire within milliseconds of each other for the same data on first load.

**What to do:** In `web/app/page.tsx`, remove the ELO fetch from the first `useEffect` (lines 171–178). The second effect (`[userId, subject]` at line 181) already handles it. The first effect only needs to handle `getUser()`, set `userId`, and call `register_presence`.

---

### #9 — Mark or implement the disconnect grace period
**Debt:** TD-B5 | **Effort:** 2 hours (implement) or 5 minutes (document) | **Risk:** Medium if implemented

Backlog item #17 is marked complete but the code does immediate forfeit. Users who lose connection mid-battle are penalized immediately with no recovery window.

**What to do (documentation path):** Revert backlog item #17 to `[ ]` and add a note that the code does immediate forfeit. This avoids misleading future developers.

**What to do (implementation path):** In `handleDisconnect`, start a 30-second timer instead of calling `endBattle` immediately. Store the timer ID on the battle state. If the player reconnects within 30s, clear the timer and restore their progress. After 30s, call `endBattle(roomId, socketId)`.

---

### #10 — Add rate limiting to socket events
**Debt:** TD-S5 | **Effort:** 1–2 hours | **Risk:** Low

No protection against event spam. `send_message` triggers 2 Supabase queries per call.

**What to do:** Add a per-socket rate limiter using a simple token bucket or timestamp check. A lightweight approach with no dependencies:
```js
const lastEmit = new Map(); // `${socketId}:${event}` → timestamp

function rateLimit(socketId, event, minIntervalMs) {
  const key = `${socketId}:${event}`;
  const last = lastEmit.get(key) ?? 0;
  if (Date.now() - last < minIntervalMs) return false;
  lastEmit.set(key, Date.now());
  return true;
}

// In socket.on('send_message', ...):
if (!rateLimit(socket.id, 'send_message', 500)) return;
```
Clean up `lastEmit` entries on disconnect.

---

### #11 — Extract `MVP_SUBJECTS` constant to shared lib
**Debt:** TD-D3 | **Effort:** 20 minutes | **Risk:** Near zero

The same array is defined in 4 files. Adding a new subject or renaming one requires 4 changes, and it's easy to miss one.

**What to do:** Create `web/lib/constants.ts`:
```ts
export const MVP_SUBJECTS = [
  'AP Biology', 'AP Chemistry', 'AP US History', 'AP Psychology', 'AP Calculus AB'
] as const;
export type Subject = typeof MVP_SUBJECTS[number];
```
Update imports in `page.tsx`, `profile/page.tsx`, `leaderboard/page.tsx`, and `server/index.js` (as a `KNOWN_SUBJECTS` array that feeds the `Set`).

---

### #12 — Fix JSON fallback to respect subject
**Debt:** TD-B3 | **Effort:** 30 minutes | **Risk:** Low

In local dev with multiple subjects, all battles return AP Chemistry questions. Debugging subject-specific issues is impossible locally.

**What to do:** In `server/questions.js`, map subjects to content directories:
```js
const SUBJECT_DIRS = {
  'AP Chemistry': 'apchem',
  'AP Biology': 'apbio',
};

function loadAllCards(subject) {
  const dir = SUBJECT_DIRS[subject];
  if (!dir) return [];
  const contentDir = path.join(__dirname, '..', 'content', dir);
  // ...existing logic...
}
```

---

### #13 — Split `page.tsx` into focused view components
**Debt:** TD-MA1 | **Effort:** 3–4 hours | **Risk:** Medium (large refactor, test each phase)

The god component already has 30+ useState hooks. Every new feature added here makes bugs harder to find and fixes riskier.

**What to do:** Extract in this order (each step is independently shippable):
1. `web/hooks/useSocket.ts` — pull out the entire `useEffect` socket setup (lines 221–365)
2. `web/views/ResultView.tsx` — pull out `appPhase === 'complete'` render (lines 482–579)
3. `web/views/LobbyView.tsx` — pull out `appPhase === 'idle'` render (lines 627–718)
4. `web/views/PracticeSelectView.tsx` — pull out `appPhase === 'practice-select'`

After each extraction, run `npx tsc --noEmit` before committing.

---

### #14 — Remove or implement `used_in_battle_count`
**Debt:** TD-B4, TD-DC3 | **Effort:** 30 minutes (remove) or 2 hours (implement) | **Risk:** Low

The column exists and is documented but never touched. It's dead schema that sets false expectations.

**What to do (simplest):** Write `supabase/migrations/013_drop_battle_count.sql`:
```sql
ALTER TABLE public.question_variants DROP COLUMN used_in_battle_count;
```

**What to do (implement):** After selecting variants in `pickQuestionsFromDB`, fire-and-forget an increment:
```js
supabase.from('question_variants')
  .rpc('increment_battle_count', { variant_ids: selectedIds })
  .then(() => {}).catch(() => {});
```

---

### #15 — Split `server/index.js` into modules
**Debt:** TD-MA2 | **Effort:** 3–4 hours | **Risk:** Medium (requires careful module boundary design)

817 lines mixing battle logic, social presence, messaging, and HTTP routes. The messaging system has grown to ~100 lines of async Supabase calls inside socket handlers.

**What to do:** Extract in this order:
1. `server/presence.js` — `userSockets`, `socketToUser`, `userActivity`, `userProfiles`, `directChallenges`, `getAcceptedFriendIds`, `emitToOnlineFriends`, and all friend challenge socket handlers
2. `server/messaging.js` — `send_message`, `mark_messages_read` handlers
3. `server/battle.js` — `startBattle`, `sendNextQuestion`, `handleAnswer`, `tryAdvanceQuestion`, `finishPlayer`, `endBattle`, `handleDisconnect`
4. `server/matchmaking.js` — `queue`, `tryMatch`, `createBattle`

Each module exports the handler functions; `index.js` registers them with the socket instance.

---

### #16 — Extract `AnswerButton` shared component — **DONE**
**Debt:** TD-D2 | Created `web/components/AnswerButton.tsx` with `AnswerState = 'idle' | 'selected' | 'correct' | 'wrong' | 'dimmed'` and `deriveAnswerState()` helper. Used by both `BattleRoom.tsx` and `PracticeMode.tsx`.

---

### #17 — Fix message prune hardcoded upper bound
**Debt:** TD-B6 | **Effort:** 10 minutes | **Risk:** Near zero

`.range(50, 9999)` will silently fail to prune conversations over ~9999 messages.

**What to do:** In `server/index.js` messaging handler, replace the prune query with a DELETE using a subquery:
```js
const { data: old } = await supabase
  .from('messages')
  .select('id')
  .or(`and(sender_id.eq.${fromUserId},receiver_id.eq.${toUserId}),and(sender_id.eq.${toUserId},receiver_id.eq.${fromUserId})`)
  .order('created_at', { ascending: false })
  .range(50, 1000000);
```

---

### #18 — Drop dead card types from CHECK constraint
**Debt:** TD-DC1 | **Effort:** 20 minutes | **Risk:** Low

`fr_static` and `fr_numeric` types are deprecated, never generated, and have no UI. The CHECK constraint allows them, which misrepresents the system.

**What to do:** Write `supabase/migrations/014_drop_dead_types.sql`:
```sql
ALTER TABLE public.source_cards
  DROP CONSTRAINT source_cards_type_check,
  ADD CONSTRAINT source_cards_type_check
    CHECK (type IN ('mc_static', 'mc_numeric'));
```
If any rows with the old types exist, migrate them first or exclude them.

---

### #19 — Increase battle question count from 1 to 10
**Debt:** Not a debt item — this is restoring the core feature | **Effort:** 5 minutes | **Risk:** Medium (requires enough content in DB for the subject)

The game's entire value proposition is a 10-question battle. Battles currently have 1 question, which makes the product feel broken to any real user. This was set for development testing.

**What to do:** In `server/index.js`, line 189:
```js
state.questions = await pickQuestions(state.subject, 10);
```
Verify that `question_variants` has at least 10 rows for AP Chemistry and AP Biology before changing. The DB should have ~1009 AP Chemistry cards with variants.

---

### #20 — Restrict `/health` endpoint to internal use
**Debt:** Minor security hardening | **Effort:** 15 minutes | **Risk:** Near zero

`GET /health` exposes `queue.length` and `battles.size` to any HTTP client. This is operational intelligence that could be used to time attacks or infer user activity.

**What to do:** Either remove the metrics from the response (return just `{ ok: true }`) or require an `X-Internal-Key` header matched against a `HEALTH_SECRET` environment variable:
```js
app.get('/health', (req, res) => {
  if (req.headers['x-internal-key'] !== process.env.HEALTH_SECRET) {
    return res.json({ ok: true });
  }
  res.json({ ok: true, queue: queue.length, battles: battles.size });
});
```

---

## After these 20 items

Once the above are addressed, the codebase will be:
- Secure enough for real users (no impersonation exploits)
- Correctly reporting user stats (profile Win/Loss)
- Maintainable enough to add features without constant regression risk
- Architecturally honest (migrations match live DB, PRD matches implementation)

The recommended order for new features after this cleanup:
1. Increase question count to 10 (already in list as #19)
2. Reconnect grace period (30s timer in `handleDisconnect`)
3. Free tier battle limits (re-enable `battles_today` check — migration 006 exists)
4. Stripe integration (migration 007 exists; payment flow needs implementing)
5. Async challenge improvements (ELO uses hardcoded 1000 starting rating instead of actual player ELO)
