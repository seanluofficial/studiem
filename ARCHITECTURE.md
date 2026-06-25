# Studiem — Architecture

---

## 1. System Overview

```
┌─────────────────────────────────────────────────────────────┐
│  Browser                                                    │
│  Next.js 16 (React 19) — Vercel                            │
│                                                             │
│  app/page.tsx          ← 891-line SPA shell                │
│  components/           ← BattleRoom, FriendsPanel, ...     │
│  lib/socket.ts         ← Socket.io singleton               │
│  lib/supabase/         ← Client + Server helpers           │
│  middleware.ts         ← Auth guard (every route)          │
└──────────┬──────────────────────┬───────────────────────────┘
           │ Socket.io (WS/poll)  │ Supabase JS (REST + auth)
           ▼                      ▼
┌──────────────────┐    ┌─────────────────────────────────────┐
│  Battle Server   │    │  Supabase (Postgres + Auth)         │
│  Node.js 22      │◄───│                                     │
│  Express 5       │    │  profiles          elo_ratings      │
│  Socket.io 4     │    │  battles           source_cards     │
│  Railway         │    │  question_variants friendships      │
│                  │────►  messages          challenges       │
│  index.js        │    │  question_reports  leaderboard(view)│
│  elo.js          │    │  user_card_stats                    │
│  questions.js    │    │                                     │
│  streak.js       │    │  Auth: Supabase Auth                │
│  supabase.js     │    │  (email/password + Google OAuth)    │
│  stats.js        │    │                                     │
└──────────────────┘    └─────────────────────────────────────┘
```

**Two separate services.** The battle server is a persistent Node.js process on Railway. The web app is statically rendered + SSR on Vercel. They never call each other over HTTP — all real-time communication goes through Socket.io, and both read/write Supabase directly with different keys.

---

## 2. Authentication Architecture

### Session management
Supabase Auth manages sessions via cookies. `@supabase/ssr` handles cookie refresh in `middleware.ts` on every request.

### Auth guard
`web/middleware.ts` runs on every non-static route. If no valid session: redirect to `/login`. Auth routes (`/login`, `/signup`, `/auth/*`) are excluded.

### Two Supabase client types
| Client | File | Key | Used for |
|---|---|---|---|
| Browser client | `lib/supabase/client.ts` | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Auth, profile reads, RLS-gated writes |
| Server client | `lib/supabase/server.ts` | `NEXT_PUBLIC_SUPABASE_ANON_KEY` + session | SSR data fetching (profile, leaderboard) |
| Battle server | `server/*.js` | `SUPABASE_SERVICE_ROLE_KEY` | ELO writes, battle records, streak updates — bypasses RLS |

### Google OAuth flow
```
/login → signInWithOAuth → Supabase → Google → /auth/callback
/auth/callback → exchangeCodeForSession → upsert profile row → redirect /
```

---

## 3. Battle Flow

### State machine
```
idle → queuing → countdown (3s) → battle → finished → complete
```

### Matchmaking
1. Client emits `join_queue` with `{ userId, displayName, elo, subject }`.
2. Server validates all fields and appends to `queue[]`.
3. `tryMatch()` runs immediately and on a 5-second interval.
4. Match criteria: same subject, ELO within ±200 (±400 after 30s), timeout and emit `queue_timeout` after 60s.
5. `createBattle(p1, p2)` assigns a random roomId, joins both sockets to the room, emits `match_found` to each.

### Battle execution
```
createBattle()
  └─ setTimeout(startBattle, 3000)           ← 3-second countdown in UI
       └─ pickQuestions(subject, 1)           ← currently 1 question for testing
       └─ sendNextQuestion() for each player  ← emits 'question' event

client: submit_answer → server: handleAnswer()
  ├─ validates: not done, not already answered, answerIndex (NOT CURRENTLY VALIDATED 0-3)
  ├─ scores the answer
  ├─ emits 'question_result' to answerer
  ├─ emits 'opponent_progress' to other player
  └─ setTimeout(tryAdvanceQuestion, 1500)     ← reveal window

tryAdvanceQuestion():
  ├─ if both ready → advance all players to next question
  └─ if one waiting → emit 'waiting_for_opponent' to faster player

finishPlayer() → if both done → endBattle()
  ├─ determines winner: score comparison → time comparison → sids[0] fallback
  ├─ updateElo(state, winner)               ← writes elo_ratings + battles
  ├─ updateStreak(userId) for each player   ← writes profiles
  └─ emit 'battle_complete' to room
```

### Disconnect handling
- Player disconnects → `handleDisconnect()` → `endBattle(roomId, socketId)` immediately.
- No reconnect grace period (backlog #17 was marked done but is not implemented in code).
- Remaining player receives `opponent_disconnected` then `battle_complete`.

---

## 4. Presence & Social Architecture

All presence state is in-memory on the server:

```
userSockets      Map<userId, Set<socketId>>   // all active sockets per user
socketToUser     Map<socketId, userId>         // reverse lookup
userActivity     Map<userId, {subject, phase}> // current activity
userProfiles     Map<userId, {displayName, elo}> // cache for challenge display
directChallenges Map<challengeId, {...}>        // pending friend challenges with timers
```

On `register_presence`: server loads accepted friends from DB, emits `presence_init` with online friend IDs, notifies those friends of the new connection.

On `disconnect`: cleans all four maps, cancels pending direct challenges, emits `friend_offline` to friends.

**Messaging** is persisted to Supabase (`messages` table) and relayed in real-time via Socket.io. Conversations are pruned to last 50 messages after each send.

---

## 5. Question Serving Architecture

### Production path (Supabase)
```
pickQuestions(subject, n)
  └─ SELECT source_cards WHERE subject = ? AND reviewed = true
  └─ shuffle IDs in JS, sample n*4
  └─ SELECT question_variants WHERE source_card_id IN (sample)
  └─ shuffle variants, return n
```

The two-step query avoids a single ORDER BY random() on a large join. The card shuffle happens in JS; the variant shuffle is also in JS.

### Local dev fallback (JSON)
When `SUPABASE_URL` is not set, loads all `content/apchem/unit*.json` files. **Does not respect the `subject` parameter** — always returns AP Chemistry questions regardless of what subject is requested.

### Question structure (served to client via battle)
```typescript
{ id: string, stem: string, options: string[], correct_index: number, source_card_id: string, unit: string | null }
```

`id` is a real UUID from `question_variants` when using DB, or a fake string in JSON fallback mode. `source_card_id` and `unit` are used server-side for stat recording; they are also sent to the client but not displayed.

### Question structure (served to client via practice)
```typescript
// PracticeQuestion — built by web/app/practice/page.tsx
{ id: string, sourceCardId: string, stem: string, options: string[], correctIndex: number, correctExplanation: string | null, unit: string }
```

Practice questions are fetched directly by the client from Supabase (browser → Supabase), weighted by per-user accuracy from `user_card_stats`. Stat recording calls `upsert_card_stat` RPC from the client.

---

## 6. Database Schema

### Tables with migration files

| Table | Key Columns | Notes |
|---|---|---|
| `profiles` | `id`, `display_name`, `current_streak`, `longest_streak`, `last_battle_date`, `battles_today`, `is_premium`, `premium_expires_at` | Columns added across migrations 001, 004, 006, 007 |
| `elo_ratings` | `user_id`, `subject`, `rating` | UNIQUE(user_id, subject); starts at 1000 |
| `battles` | `player1_id`, `player2_id`, `winner_id`, `subject`, `scores` (JSONB) | scores keyed by userId |
| `source_cards` | `subject`, `unit`, `type`, `reviewed`, `content` (JSONB), `content_hash` | content_hash UNIQUE prevents duplicate cards |
| `question_variants` | `source_card_id`, `rendered_stem`, `rendered_options`, `correct_index` | FK cascade from source_cards |
| `challenges` | `challenger_id`, `opponent_id`, `questions_json`, `status` | async challenge flow |
| `question_reports` | `question_variant_id`, `reporter_id`, `reason` | user-flagged bad questions |
| `user_card_stats` | `user_id`, `source_card_id`, `subject`, `unit`, `correct_count`, `total_count`, `last_seen_at` | per-user per-card accuracy; UNIQUE(user_id, source_card_id); `upsert_card_stat` RPC writes atomically |

### Tables in live DB but missing migration files
These exist in production code but have no migration file in `supabase/migrations/`:

| Table / Column | Used by |
|---|---|
| `friendships` (`requester_id`, `addressee_id`, `status`) | FriendsPanel, leaderboard friends tab, server presence |
| `messages` (`sender_id`, `receiver_id`, `content`, `read_at`) | ChatBox, server messaging |
| `profiles.invite_code` | FriendsPanel invite tab, `/api/invite/[code]` route |

**If the database ever needs to be recreated from migrations, these must be added manually.**

### Views
`leaderboard` — created in migration 005. Joins `elo_ratings` with `profiles`, returns `rank, display_name, rating, user_id` ordered by rating DESC partitioned by subject.

### RLS Summary
| Table | SELECT | INSERT | UPDATE | DELETE |
|---|---|---|---|---|
| `profiles` | public | own (id = auth.uid()) | own | — |
| `elo_ratings` | public | service role only | service role only | — |
| `battles` | public | service role only | — | — |
| `source_cards` | reviewed=true only | service role only | — | — |
| `question_variants` | joined reviewed cards | service role only | — | — |
| `question_reports` | own only | own (reporter_id = auth.uid()) | — | — |
| `challenges` | public | service role (via HTTP endpoint) | service role | — |
| `friendships` | ? (not in migration file) | ? | ? | ? |
| `messages` | ? (not in migration file) | ? | ? | ? |

---

## 7. Frontend Component Map

```
app/page.tsx (lobby — battle phases only)
  ├─ NavBar (with onPracticeClick queue-leave guard)
  ├─ FriendsPanel
  │    ├─ ChatBox
  │    └─ FriendContextMenu
  └─ BattleRoom
       └─ RankBadge

app/practice/page.tsx (full practice drill — new route)
  ├─ NavBar
  └─ PracticeMode
       └─ AnswerButton

app/profile/page.tsx (SSR)
  ├─ NavBar
  ├─ Panel
  ├─ RankBadge
  └─ AddFriendButton

app/leaderboard/page.tsx (SSR)
  ├─ NavBar
  └─ RankBadge

app/challenge/[id]/page.tsx (CSR — fetches from battle server REST)
app/challenge/create/page.tsx
app/login/page.tsx
app/signup/page.tsx
app/auth/callback/route.ts
```

### State architecture (page.tsx)
All game state (lobby → queuing → countdown → battle → result) and socket listeners live in a single `Home` component with ~25 `useState` hooks. Practice phases were extracted to `/practice`. There is no global state manager (no Zustand, no Context). TD-MA1 remains open for further decomposition.

### Practice mode architecture
`/practice` is a standalone `'use client'` page with three phases: `select → drill → summary`. Phase data flows downward only — `PracticeMode` receives pre-loaded `PracticeQuestion[]` and calls `onStop(results)` when done. The parent page owns all Supabase queries and weighted sampling logic (`lib/practice.ts`). In-queue practice (lightweight) lives in `page.tsx`'s queuing phase and does not record stats.

---

## 8. Deployment

### Battle server (Railway)
- `nixpacks.toml` installs `server/` dependencies and runs `node server/index.js`
- Single process, single instance — in-memory state (battles, queue, presence) is not shared across instances
- Required env vars: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `PORT` (set by Railway)

### Web app (Vercel)
- Standard Next.js deployment — `web/` directory
- Required env vars: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `NEXT_PUBLIC_SOCKET_URL`
- `middleware.ts` runs on edge — auth guard on every request

### Scaling constraint
The battle server cannot scale horizontally. In-memory `battles`, `queue`, and presence maps are process-local. Adding a second Railway instance would split socket connections and break matchmaking. A Redis adapter for Socket.io would be required before horizontal scaling is possible.

---

## 9. Key Design Decisions

| Decision | Reason |
|---|---|
| Socket.io over WebSocket directly | Auto-reconnect, fallback to polling, room management built-in |
| Supabase over self-hosted Postgres | Managed auth (OAuth, sessions, JWTs), built-in RLS, no ops burden for MVP |
| Railway over Vercel for server | Vercel is serverless — Socket.io requires a persistent process |
| Server-side question selection | Prevents clients from pre-loading answers; reviewed gate enforced server-side |
| In-memory battle state | Zero latency for game events; acceptable for single-instance MVP |
| Service role key only on server | Client never gets write access to ELO or battle records |
| ELO K-factor = 32 | Standard for online games; produces ~16-point swings for evenly matched players |
