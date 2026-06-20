'use client';

import { useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';

const MVP_SUBJECTS = [
  'AP Biology',
  'AP Chemistry',
  'AP US History',
  'AP Psychology',
  'AP Calculus AB',
];

interface Friend {
  userId: string;
  displayName: string;
  friendshipId: string;
}

interface Props {
  friend: Friend;
  onBlock: () => void;
  onClose: () => void;
}

export default function FriendContextMenu({ friend, onBlock, onClose }: Props) {
  const router = useRouter();
  const [showPicker, setShowPicker] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handle(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) onClose();
    }
    document.addEventListener('mousedown', handle);
    return () => document.removeEventListener('mousedown', handle);
  }, [onClose]);

  async function handleBlock() {
    const supabase = createClient();
    await supabase
      .from('friendships')
      .update({ status: 'blocked' })
      .eq('id', friend.friendshipId);
    onBlock();
    onClose();
  }

  function handleChallenge(subject: string) {
    // getSocket is imported lazily to avoid circular deps
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const { getSocket } = require('@/lib/socket');
    getSocket().emit('friend_challenge', { toUserId: friend.userId, subject });
    onClose();
  }

  if (showPicker) {
    return (
      <div ref={ref} className="w-44 panel-raised border border-[#2A2A2A] py-1">
        <p className="text-[9px] text-[#F5F0E8]/30 uppercase tracking-[0.2em] px-3 py-1.5">
          Pick Subject
        </p>
        {MVP_SUBJECTS.map(s => (
          <button
            key={s}
            onClick={() => handleChallenge(s)}
            className="w-full text-left px-3 py-2 text-xs text-[#F5F0E8]/70 hover:bg-[#2A2A2A] hover:text-[#C9A84C] font-display uppercase tracking-wide transition-colors"
          >
            {s.replace('AP ', '')}
          </button>
        ))}
      </div>
    );
  }

  return (
    <div ref={ref} className="w-40 panel-raised border border-[#2A2A2A] py-1">
      <button
        onClick={() => { router.push(`/profile?id=${friend.userId}`); onClose(); }}
        className="w-full text-left px-3 py-2.5 text-xs text-[#F5F0E8]/65 hover:bg-[#2A2A2A] hover:text-[#F5F0E8] font-display uppercase tracking-wide transition-colors"
      >
        View Profile
      </button>
      <button
        onClick={() => setShowPicker(true)}
        className="w-full text-left px-3 py-2.5 text-xs text-[#F5F0E8]/65 hover:bg-[#2A2A2A] hover:text-[#C9A84C] font-display uppercase tracking-wide transition-colors"
      >
        Challenge
      </button>
      <div className="h-px bg-[#2A2A2A] mx-3 my-1" />
      <button
        onClick={handleBlock}
        className="w-full text-left px-3 py-2.5 text-xs text-[#EF4444]/55 hover:bg-[#2A2A2A] hover:text-[#EF4444] font-display uppercase tracking-wide transition-colors"
      >
        Block
      </button>
    </div>
  );
}
