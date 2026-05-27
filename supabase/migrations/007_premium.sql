-- 007_premium.sql
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS is_premium        BOOLEAN     NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS premium_expires_at TIMESTAMPTZ;
