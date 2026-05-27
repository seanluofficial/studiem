-- 002_questions.sql
-- source_cards: authored question library
-- question_variants: pre-generated battle-ready question records

CREATE TABLE public.source_cards (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject               TEXT NOT NULL,
  unit                  TEXT NOT NULL,
  unit_exam_weight_pct  INTEGER NOT NULL,
  deck                  TEXT NOT NULL,
  type                  TEXT NOT NULL CHECK (type IN ('mc_static','mc_numeric','fr_static','fr_numeric')),
  difficulty            TEXT NOT NULL CHECK (difficulty IN ('easy','medium','hard')),
  tags                  TEXT[],
  source                TEXT NOT NULL DEFAULT 'ced_generated',
  reviewed              BOOLEAN NOT NULL DEFAULT false,
  visual                JSONB,
  content               JSONB NOT NULL,
  content_hash          TEXT UNIQUE NOT NULL,
  created_at            TIMESTAMPTZ DEFAULT now(),
  updated_at            TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.question_variants (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_card_id        UUID REFERENCES public.source_cards(id) ON DELETE CASCADE,
  rendered_stem         TEXT NOT NULL,
  rendered_options      TEXT[],
  correct_index         INTEGER,
  correct_value         NUMERIC,
  param_values          JSONB,
  used_in_battle_count  INTEGER DEFAULT 0,
  created_at            TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX question_variants_source_card_id_idx ON public.question_variants(source_card_id);
CREATE INDEX source_cards_subject_unit_idx ON public.source_cards(subject, unit);

-- RLS
ALTER TABLE public.source_cards       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_variants  ENABLE ROW LEVEL SECURITY;

-- Public SELECT on reviewed source_cards
CREATE POLICY "source_cards_read_reviewed"
  ON public.source_cards FOR SELECT
  USING (reviewed = true);

-- Service role handles all writes (no policy needed for INSERT/UPDATE with service key)
-- Public SELECT on question_variants joined with reviewed source cards
CREATE POLICY "question_variants_read_reviewed"
  ON public.question_variants FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.source_cards sc
      WHERE sc.id = source_card_id AND sc.reviewed = true
    )
  );
