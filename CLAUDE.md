# Studiem — Autonomous Loop Protocol

## Project Overview

Real-time 1v1 AP exam battle app. Two players face the same 10 questions simultaneously; faster + more accurate player wins. ELO ranking per subject.

- **Web:** Next.js 16 (App Router) — `web/`
- **Server:** Node.js + Express + Socket.io — `server/`
- **Database:** Supabase (Postgres + Auth)
- **Hosting:** Railway (server), Vercel (web)

## Repo Structure

```
web/                  Next.js frontend
  app/page.tsx        Main battle UI (lobby → battle → result)
  components/         BattleRoom.tsx and shared UI
  lib/socket.ts       Socket.io client singleton
  lib/supabase/       Supabase client helpers
server/
  index.js            Socket.io battle server (matchmaking + game loop)
  elo.js              ELO calculation + Supabase upsert
  questions.js        Question loader (reads from Supabase DB, JSON fallback for local dev)
  .env                SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
supabase/
  migrations/         SQL migrations (run in order)
scripts/
  pipeline.js         End-to-end content generation: generate → validate → clean (Groq)
  import.js           Bulk-upsert clean JSON cards into Supabase
  validator_agent.js  Standalone LLM validator for a single unit file
content/
  apchem/             unit1.json–unit9.json (source question JSON for local fallback)
BACKLOG.md            Task list — loop reads this each iteration
PRD.md                Full product spec
CARD_SCHEMA.md        question_variants / source_cards DB schema
```

## Validation Commands

Always run before committing. All must pass.

```powershell
# TypeScript check (web)
cd web; npx tsc --noEmit; cd ..

# Syntax check (server)
node --check server/index.js
node --check server/elo.js
node --check server/questions.js
```

Do NOT run `npm run build` in the loop — it's slow. TypeScript + syntax check is sufficient.

## Current State (as of last commit)

- Email/password auth + Google OAuth via Supabase works
- Matchmaking queue works (ELO-bracketed ±200, widens to ±400 after 30s)
- Battle sends **1 question per player** (set to 1 for testing — change `pickQuestions(state.subject, 1)` in server/index.js to increase)
- **Async per-player flow** — each player answers at their own pace, no lockstep waiting between questions. When a player finishes all questions they wait for the opponent to finish, then results are shown. Do NOT change this to a synchronized/lockstep flow.
- ELO updates after battle; subject selection flows through matchmaking, ELO, and battle records
- ~1009 AP Chemistry cards across Units 1–9 imported into `source_cards` / `question_variants`
- Full frontend redesign: gold/black Studiem theme, Barlow Condensed + Inter fonts
- Free tier limits removed — all users play unlimited battles
- Disconnect = immediate forfeit (no grace period dodge window)

## IMPORTANT — Do not revert these behaviors
The PRD describes aspirational features. The actual implemented behavior takes precedence:
- Battle flow is **async/independent per player**, not synchronized lockstep
- Question count is **1 for testing** — do not change it back to 10 unless explicitly asked
- Free tier battle limits are **disabled** — do not re-enable the battles_today check
- Result screen has **Play Again + Return to Lobby only** — no Rematch button

## Server Security Rules

Never take a lazy shortcut that shifts trust to the client. The server is the only authority.

### Input validation on every socket event

All data from `socket.on(...)` is untrusted. Always validate before use:

- **ELO**: clamp to `[ELO_MIN, ELO_MAX]`, reject `NaN`/`Infinity` (they pass `>` checks and break matchmaking)
- **Subject**: check against `KNOWN_SUBJECTS` set — unknown subjects break `pickQuestions` and ELO queries
- **Display name**: trim, enforce max length, reject empty string
- **roomId**: never trust the client's roomId for authorisation — always verify `state.players[socket.id]` exists
- **clientTimeTakenMs**: enforce `[CLIENT_TIME_MIN_MS, CLIENT_TIME_MAX_MS]` bounds — unvalidated, it lets any client win every tiebreak by sending `1`

### Tiebreaker and display must agree

If you display value X to determine the winner, you must also use X in the tiebreaker. Using different values (e.g. display `clientTimeTakenMs`, decide by `finishedAt`) produces results that contradict what the player sees.

### No draws

Always resolve to a winner. A `null` winner causes ELO to skip the update silently and leaves the result screen showing DRAW. Add a deterministic fallback (`sids[0]`) after all time comparisons.

### Prevent state collisions

- `roomId` must include random entropy, not just `Date.now()` — two simultaneous matches get the same ID otherwise
- Check `battles.values()` before adding to queue — a socket already in a battle must not re-queue

---

## Autonomous Loop Protocol

Each iteration of `/loop`:

1. **Read `BACKLOG.md`** — find the first unchecked `[ ]` task that is not marked `[BLOCKED]` or `[NEEDS: ...]`
2. **Read all files relevant to that task** before writing any code
3. **Implement the task** — smallest correct change that satisfies the acceptance criteria
4. **Run validation commands** — fix any errors before proceeding
5. **Mark the task complete** in `BACKLOG.md`: change `[ ]` to `[x]`
6. **Commit** with message `feat: <task title>` (or `fix:` / `chore:` as appropriate)
7. **Report**: one sentence on what changed, one sentence on what's next

### Rules

- Complete exactly **one task per iteration** — do not bundle multiple tasks
- **Never break existing working features** — if a change risks breaking auth, ELO, or matchmaking, be conservative and describe the risk
- Tasks marked `[NEEDS: X]` require an environment variable or external credential not present — skip them and pick the next available task
- Tasks marked `[BLOCKED: #N]` cannot start until task #N is checked off — skip and pick next
- If a task requires a DB migration, write it as `supabase/migrations/NNN_description.sql` (increment the number from the last migration file)
- DB migrations are **not auto-applied** — after writing a migration file, note in the commit message that it must be run in the Supabase dashboard
- For UI changes: describe the change in the commit body since you cannot open a browser
- Keep TypeScript strict — no `any` types, no `@ts-ignore`

## Key Constraints from PRD

- Server must be persistent (not serverless) — Railway only
- ELO is per-subject — never mix subjects in elo_ratings queries
- Only `reviewed: true` source cards are served in battles
- Free tier: 3 battles/day (resets midnight UTC)
- Premium: $2.99/mo, unlimited battles
- Matchmaking: ±200 ELO bracket, widen to ±400 after 30s, offer async after 60s

---

## Question Generation Pipeline

This pipeline uses the `/loop` dynamic workflow. It runs autonomously — one iteration per loop wake — until the target question count is reached.

### Trigger

When the user says anything like **"Generate [N] questions for [subject]"** or **"Generate AP [subject] questions"**:

1. Parse the subject name → slug using this map:
   - AP Biology → `apbio`
   - AP Chemistry → `apchem`
   - AP Calculus AB → `apcalcab`
   - AP US History → `apush`
   - AP Computer Science A → `apcsa`
2. Parse the target count (default 1000 if not specified).
3. Read `content/ced/<slug>.json`. If the file has an empty `units` array, stop and tell the user to populate it from their CED PDF before running.
4. Read or initialize `content/questions/<slug>/progress.json`.
5. If `unit_targets` is empty, compute: `unit_target[n] = round(total × unit.exam_weight_pct / 100)` for each unit. Save to progress.json.
6. Invoke `/loop` (dynamic mode) to run the generation loop below.

### Generation Loop (one iteration per /loop wake)

Each iteration executes exactly one generate-then-validate cycle for one unit batch:

1. **Find the target unit:** pick the unit with the largest gap (`unit_target[n] - unit_count[n]`). If all units are at or above target, the loop is done — print the summary and stop.

2. **Spawn the Writer agent** using the Agent tool:
   - `model: "sonnet"` — Sonnet 4.6 for AP-quality generation
   - Prompt: fill in `scripts/prompts/writer_agent.md` with the target unit's data (`subject`, `unit_name`, `exam_weight_pct`, `decks`, `objectives`, `existing_count`, `batch_size = 25`)
   - Save the raw output JSON array to `content/questions/<slug>/raw/unit{N}_batch_{timestamp}.json`
   - If the output cannot be parsed as a JSON array, log the error, skip validation, and schedule the next iteration

3. **Schema filter (no AI needed):** check each generated question for:
   - Required fields: `stem`, `options` (array of 4), `correct_index` (0–3), `correct_explanation`, `distractor_explanations` (array of 3), `type` is `mc_static` or `mc_numeric`
   - For `mc_numeric`: `params`, `answer_formula`, `distractors` (array of 3) all present; all `{{var}}` in stem match param keys
   - For `visual.type === "latex"`: `value` is non-empty string with balanced braces
   - Remove any question that fails schema. Log count of schema failures.

4. **Spawn the Validator agent** using the Agent tool:
   - `model: "haiku"` — Haiku 4.5 for fast answer-first validation
   - Prompt: fill in `scripts/prompts/validator_agent.md` with `subject`, `unit_name`, `objectives`, and the schema-passing questions as JSON
   - Send questions in sub-batches of 10 if more than 10 passed schema (spawn one Validator per 10-question sub-batch, run in parallel if context allows)
   - Collect results: extract all questions with `verdict === "PASS"`

5. **Handle auto-correct (optional):** For questions with `verdict === "FLAG"` and `auto_correct_eligible === true`:
   - Spawn one Writer agent call per eligible question with the fix instruction
   - Re-validate the corrected question with the Validator agent
   - If the corrected question PASS → add to clean list

6. **Save clean questions:** append all PASS questions to `content/questions/<slug>/unit{N}_clean.json`

7. **Update progress.json:**
   - Increment `unit_counts[N]` by the number of questions added
   - Update `total_clean`
   - Set `last_updated` to current ISO timestamp

8. **Report progress:** print one line: `[Unit N] +{added} added → {unit_counts[N]}/{unit_targets[N]} | Total: {total_clean}/{target_total}`

9. **Loop control:**
   - If `total_clean < target_total`: call `ScheduleWakeup(60)` to continue
   - If `total_clean >= target_total`: print final summary and stop

### Model assignment

| Role | Model | Reason |
|---|---|---|
| Writer | Sonnet 4.6 (`sonnet`) | AP exam questions require strong domain accuracy. Sonnet reduces the rate of factually wrong questions, lowering wasted validation cycles. |
| Validator | Haiku 4.5 (`haiku`) | Answering AP MCQ and checking JSON quality is well within Haiku's capabilities at much lower cost per question. |

### Batch sizes

- Writer: 25 questions per call (larger batches cause JSON truncation)
- Validator: 10 questions per call (larger batches cause answer-index confusion)

### File locations

| File | Purpose |
|---|---|
| `content/ced/<slug>.json` | CED data: units, weights, decks, objectives |
| `content/questions/<slug>/progress.json` | Running totals per unit |
| `content/questions/<slug>/unit{N}_clean.json` | Validated questions, appended each iteration |
| `content/questions/<slug>/raw/unit{N}_batch_{ts}.json` | Raw Writer output (kept for debugging) |
| `scripts/prompts/writer_agent.md` | Writer agent prompt template |
| `scripts/prompts/validator_agent.md` | Validator agent prompt template |

### Rules

- Never mix units in one Writer call
- Validator ALWAYS answers questions blind (Phase 1) before checking `correct_index`
- A question where the validator's independent answer mismatches `correct_index` is discarded immediately — no quality scoring
- If a CED file has empty `units`, stop and prompt the user to populate it
- The Groq-based scripts (`scripts/pipeline.js`, `scripts/validator_agent.js`) remain as a fallback for bulk offline generation but are not the primary pipeline
