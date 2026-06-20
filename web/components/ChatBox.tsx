'use client';

import { useState, useEffect, useRef } from 'react';
import { createClient } from '@/lib/supabase/client';
import { getSocket } from '@/lib/socket';

interface Message {
  id: string;
  sender_id: string;
  content: string;
  created_at: string;
}

interface Props {
  friendUserId: string;
  friendDisplayName: string;
  myUserId: string;
  onClose: () => void;
}

export default function ChatBox({ friendUserId, friendDisplayName, myUserId, onClose }: Props) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(true);
  const bottomRef = useRef<HTMLDivElement>(null);

  // Load history + mark read on open
  useEffect(() => {
    const supabase = createClient();
    supabase
      .from('messages')
      .select('id, sender_id, content, created_at')
      .or(
        `and(sender_id.eq.${myUserId},receiver_id.eq.${friendUserId}),` +
        `and(sender_id.eq.${friendUserId},receiver_id.eq.${myUserId})`
      )
      .order('created_at', { ascending: true })
      .limit(50)
      .then(({ data }) => {
        setMessages(data ?? []);
        setLoading(false);
      });

    getSocket().emit('mark_messages_read', { fromUserId: friendUserId });
  }, [myUserId, friendUserId]);

  // Scroll to bottom on new messages
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Real-time: append messages from this friend
  useEffect(() => {
    const socket = getSocket();
    function onNewMessage({
      messageId,
      fromUserId,
      content,
      sentAt,
    }: {
      messageId: string;
      fromUserId: string;
      content: string;
      sentAt: string;
    }) {
      if (fromUserId !== friendUserId) return;
      setMessages(prev => [...prev, {
        id: messageId,
        sender_id: fromUserId,
        content,
        created_at: sentAt,
      }]);
      socket.emit('mark_messages_read', { fromUserId: friendUserId });
    }
    socket.on('new_message', onNewMessage);
    return () => { socket.off('new_message', onNewMessage); };
  }, [friendUserId]);

  function send() {
    const text = input.trim();
    if (!text) return;
    setInput('');
    // Optimistic append
    setMessages(prev => [...prev, {
      id: `tmp_${Date.now()}`,
      sender_id: myUserId,
      content: text,
      created_at: new Date().toISOString(),
    }]);
    getSocket().emit('send_message', { toUserId: friendUserId, content: text });
  }

  return (
    <div className="fixed bottom-0 right-80 z-45 w-72 flex flex-col panel-raised border border-[#2A2A2A] border-b-0" style={{ maxHeight: '380px' }}>
      {/* Header */}
      <div className="flex items-center justify-between px-3 py-2.5 border-b border-[#2A2A2A] flex-shrink-0">
        <span className="text-xs font-display font-bold uppercase tracking-[0.15em] text-[#F5F0E8]/80 truncate">
          {friendDisplayName}
        </span>
        <button
          onClick={onClose}
          className="text-[#F5F0E8]/30 hover:text-[#F5F0E8]/60 text-xl leading-none transition-colors px-0.5"
          aria-label="Close chat"
        >
          ×
        </button>
      </div>

      {/* Message list */}
      <div className="flex-1 overflow-y-auto p-3 flex flex-col gap-2">
        {loading ? (
          <p className="text-[#F5F0E8]/20 text-[10px] text-center py-6 uppercase tracking-[0.2em]">
            Loading…
          </p>
        ) : messages.length === 0 ? (
          <p className="text-[#F5F0E8]/15 text-[10px] text-center py-6 uppercase tracking-[0.2em]">
            No messages yet
          </p>
        ) : (
          messages.map(msg => (
            <div
              key={msg.id}
              className={`flex ${msg.sender_id === myUserId ? 'justify-end' : 'justify-start'}`}
            >
              <span
                className={`px-2.5 py-1.5 text-xs max-w-[85%] leading-relaxed break-words ${
                  msg.sender_id === myUserId
                    ? 'bg-[#C9A84C]/15 text-[#F5F0E8] border border-[#C9A84C]/25'
                    : 'bg-[#141414] text-[#F5F0E8]/75 border border-[#2A2A2A]'
                }`}
              >
                {msg.content}
              </span>
            </div>
          ))
        )}
        <div ref={bottomRef} />
      </div>

      {/* Input */}
      <div className="flex border-t border-[#2A2A2A] flex-shrink-0">
        <input
          value={input}
          onChange={e => setInput(e.target.value.slice(0, 500))}
          onKeyDown={e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); send(); } }}
          placeholder="Message…"
          className="flex-1 bg-[#0A0A0A] text-[#F5F0E8] text-xs px-3 py-2.5 outline-none placeholder:text-[#F5F0E8]/20"
        />
        <button
          onClick={send}
          disabled={!input.trim()}
          className="px-3 text-[#C9A84C] hover:text-[#D4B565] disabled:text-[#F5F0E8]/15 text-[10px] font-display font-bold uppercase tracking-[0.15em] transition-colors flex-shrink-0"
        >
          Send
        </button>
      </div>
    </div>
  );
}
