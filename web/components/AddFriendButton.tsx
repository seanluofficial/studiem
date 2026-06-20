'use client';

import { useState } from 'react';
import { createClient } from '@/lib/supabase/client';

type Status = 'none' | 'pending_sent' | 'pending_received' | 'accepted';

interface Props {
  viewerId: string;
  targetId: string;
  initialStatus: Status;
  friendshipId: string | null;
}

export default function AddFriendButton({ viewerId, targetId, initialStatus, friendshipId }: Props) {
  const [status, setStatus] = useState<Status>(initialStatus);
  const [fsId, setFsId] = useState<string | null>(friendshipId);
  const [loading, setLoading] = useState(false);

  async function handleAdd() {
    setLoading(true);
    const supabase = createClient();
    const { data, error } = await supabase
      .from('friendships')
      .insert({ requester_id: viewerId, addressee_id: targetId, status: 'pending' })
      .select('id')
      .single();
    if (!error && data) { setFsId(data.id); setStatus('pending_sent'); }
    setLoading(false);
  }

  async function handleAccept() {
    if (!fsId) return;
    setLoading(true);
    await createClient().from('friendships').update({ status: 'accepted' }).eq('id', fsId);
    setStatus('accepted');
    setLoading(false);
  }

  async function handleRemove() {
    if (!fsId) return;
    setLoading(true);
    await createClient().from('friendships').delete().eq('id', fsId);
    setStatus('none');
    setFsId(null);
    setLoading(false);
  }

  if (status === 'accepted') {
    return (
      <button
        onClick={handleRemove}
        disabled={loading}
        className="btn-ghost text-[10px] font-display font-bold uppercase tracking-[0.15em] px-3 py-1.5 disabled:opacity-40"
      >
        Friends ✓
      </button>
    );
  }

  if (status === 'pending_sent') {
    return (
      <button
        onClick={handleRemove}
        disabled={loading}
        className="btn-ghost text-[10px] font-display font-bold uppercase tracking-[0.15em] px-3 py-1.5 disabled:opacity-40 text-[#F5F0E8]/40"
      >
        Request Sent
      </button>
    );
  }

  if (status === 'pending_received') {
    return (
      <div className="flex gap-1.5">
        <button
          onClick={handleAccept}
          disabled={loading}
          className="btn-gold text-[10px] font-display font-bold uppercase tracking-[0.15em] px-3 py-1.5 disabled:opacity-40"
        >
          Accept
        </button>
        <button
          onClick={handleRemove}
          disabled={loading}
          className="btn-ghost text-[10px] font-display font-bold uppercase tracking-[0.15em] px-3 py-1.5 disabled:opacity-40"
        >
          Decline
        </button>
      </div>
    );
  }

  return (
    <button
      onClick={handleAdd}
      disabled={loading}
      className="btn-gold text-[10px] font-display font-bold uppercase tracking-[0.15em] px-3 py-1.5 disabled:opacity-40"
    >
      {loading ? '…' : 'Add Friend'}
    </button>
  );
}
