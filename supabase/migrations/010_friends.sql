-- ── Friendships ──────────────────────────────────────────────────────────────
-- Covers pending requests, accepted friends, and blocked users.
-- One row per directional pair: requester → addressee.

CREATE TABLE public.friendships (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  addressee_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status       TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'blocked')),
  created_at   TIMESTAMPTZ DEFAULT now(),
  UNIQUE (requester_id, addressee_id)
);

CREATE INDEX friendships_addressee_idx ON public.friendships (addressee_id);
CREATE INDEX friendships_status_idx    ON public.friendships (status);

ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;

-- Participants can read their own friendship rows
CREATE POLICY "friendships_select" ON public.friendships FOR SELECT
  USING (requester_id = auth.uid() OR addressee_id = auth.uid());

-- Only the requester can insert
CREATE POLICY "friendships_insert" ON public.friendships FOR INSERT
  WITH CHECK (requester_id = auth.uid());

-- Either party can update (accept/decline/block)
CREATE POLICY "friendships_update" ON public.friendships FOR UPDATE
  USING (requester_id = auth.uid() OR addressee_id = auth.uid());

-- Either party can delete (unfriend / cancel request)
CREATE POLICY "friendships_delete" ON public.friendships FOR DELETE
  USING (requester_id = auth.uid() OR addressee_id = auth.uid());


-- ── Direct Messages ───────────────────────────────────────────────────────────
-- Last 50 per conversation enforced server-side after each insert.

CREATE TABLE public.messages (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content     TEXT NOT NULL CHECK (char_length(content) BETWEEN 1 AND 500),
  read_at     TIMESTAMPTZ,
  created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX messages_conversation_idx ON public.messages (
  LEAST(sender_id, receiver_id),
  GREATEST(sender_id, receiver_id),
  created_at DESC
);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "messages_select" ON public.messages FOR SELECT
  USING (sender_id = auth.uid() OR receiver_id = auth.uid());

CREATE POLICY "messages_insert" ON public.messages FOR INSERT
  WITH CHECK (sender_id = auth.uid());

-- Receiver can mark messages as read
CREATE POLICY "messages_update_read" ON public.messages FOR UPDATE
  USING (receiver_id = auth.uid());


-- ── Invite Code on Profiles ───────────────────────────────────────────────────

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS invite_code TEXT UNIQUE;

-- Backfill existing profiles with a unique code
UPDATE public.profiles
  SET invite_code = upper(substring(md5(id::text || random()::text), 1, 8))
  WHERE invite_code IS NULL;

-- Set default for new profiles
ALTER TABLE public.profiles
  ALTER COLUMN invite_code
    SET DEFAULT upper(substring(md5(gen_random_uuid()::text), 1, 8));
