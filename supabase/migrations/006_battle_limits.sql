-- 006_battle_limits.sql
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS battles_today      INT  NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS battles_reset_date DATE NOT NULL DEFAULT current_date;
