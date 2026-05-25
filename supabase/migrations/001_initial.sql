-- Profiles: one row per auth user
create table public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 2 and 24),
  created_at timestamptz default now()
);

-- ELO per user per subject
create table public.elo_ratings (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  subject    text not null default 'apchem',
  rating     int  not null default 1000,
  updated_at timestamptz default now(),
  unique (user_id, subject)
);

-- Battle history
create table public.battles (
  id          uuid primary key default gen_random_uuid(),
  player1_id  uuid references public.profiles(id) on delete set null,
  player2_id  uuid references public.profiles(id) on delete set null,
  winner_id   uuid references public.profiles(id) on delete set null,
  subject     text not null default 'apchem',
  scores      jsonb,
  created_at  timestamptz default now()
);

-- Row-level security
alter table public.profiles    enable row level security;
alter table public.elo_ratings enable row level security;
alter table public.battles     enable row level security;

-- Profiles: anyone can read; only owner can insert/update their own row
create policy "profiles_read_all"   on public.profiles for select using (true);
create policy "profiles_insert_own" on public.profiles for insert with check (id = auth.uid());
create policy "profiles_update_own" on public.profiles for update using (id = auth.uid());

-- ELO: anyone can read; service role handles writes (via API route)
create policy "elo_read_all" on public.elo_ratings for select using (true);

-- Battles: anyone can read
create policy "battles_read_all" on public.battles for select using (true);
