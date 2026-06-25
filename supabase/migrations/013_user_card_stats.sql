-- 013_user_card_stats.sql
-- Per-user per-card accuracy tracking for weighted practice and unit recommendations
-- APPLY MANUALLY in Supabase dashboard

CREATE TABLE public.user_card_stats (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  source_card_id UUID NOT NULL REFERENCES public.source_cards(id) ON DELETE CASCADE,
  subject        TEXT NOT NULL,
  unit           TEXT NOT NULL,
  correct_count  INTEGER NOT NULL DEFAULT 0,
  total_count    INTEGER NOT NULL DEFAULT 0,
  last_seen_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, source_card_id)
);

CREATE INDEX idx_user_card_stats_user_subject
  ON public.user_card_stats(user_id, subject);

CREATE INDEX idx_user_card_stats_user_subject_unit
  ON public.user_card_stats(user_id, subject, unit);

ALTER TABLE public.user_card_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_card_stats_select_own"
  ON public.user_card_stats FOR SELECT
  USING (user_id = auth.uid());

-- Atomic increment RPC callable from both client (authenticated) and server (service role).
-- SECURITY DEFINER runs as postgres role (bypasses RLS).
-- Client calls: auth.uid() is checked — user can only update their own rows.
-- Server calls (service role): auth.uid() is NULL — check is skipped.
CREATE OR REPLACE FUNCTION public.upsert_card_stat(
  p_user_id        UUID,
  p_source_card_id UUID,
  p_subject        TEXT,
  p_unit           TEXT,
  p_correct        BOOLEAN
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NOT NULL AND auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Cannot update another user''s stats';
  END IF;

  INSERT INTO public.user_card_stats
    (user_id, source_card_id, subject, unit, correct_count, total_count, last_seen_at)
  VALUES
    (p_user_id, p_source_card_id, p_subject, p_unit,
     CASE WHEN p_correct THEN 1 ELSE 0 END, 1, now())
  ON CONFLICT (user_id, source_card_id) DO UPDATE SET
    correct_count = user_card_stats.correct_count + CASE WHEN p_correct THEN 1 ELSE 0 END,
    total_count   = user_card_stats.total_count + 1,
    last_seen_at  = now();
END;
$$;

GRANT EXECUTE ON FUNCTION public.upsert_card_stat TO authenticated;
GRANT EXECUTE ON FUNCTION public.upsert_card_stat TO service_role;
