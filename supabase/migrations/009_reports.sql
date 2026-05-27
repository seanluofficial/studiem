-- 009_reports.sql
CREATE TABLE public.question_reports (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_variant_id UUID REFERENCES public.question_variants(id) ON DELETE CASCADE,
  reporter_id         UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  reason              TEXT,
  created_at          TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX question_reports_variant_id_idx ON public.question_reports(question_variant_id);

ALTER TABLE public.question_reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "reports_insert_own" ON public.question_reports FOR INSERT WITH CHECK (reporter_id = auth.uid());
CREATE POLICY "reports_read_own" ON public.question_reports FOR SELECT USING (reporter_id = auth.uid());
