-- 004_streaks.sql
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS current_streak  INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS longest_streak  INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_battle_date DATE;
