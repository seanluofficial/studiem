-- 008_challenges.sql
CREATE TABLE public.challenges (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenger_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  opponent_id       UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  subject           TEXT NOT NULL,
  question_ids      TEXT[] NOT NULL,
  questions_json    JSONB NOT NULL,
  challenger_answers JSONB,
  challenger_score  INTEGER,
  challenger_time_ms BIGINT,
  opponent_answers  JSONB,
  opponent_score    INTEGER,
  opponent_time_ms  BIGINT,
  winner_id         UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  status            TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','completed','expired')),
  expires_at        TIMESTAMPTZ NOT NULL DEFAULT (now() + INTERVAL '24 hours'),
  created_at        TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX challenges_challenger_id_idx ON public.challenges(challenger_id);
CREATE INDEX challenges_status_idx ON public.challenges(status);

ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "challenges_read_all" ON public.challenges FOR SELECT USING (true);
