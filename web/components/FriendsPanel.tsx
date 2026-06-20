'use client';

import { useState, useEffect, useCallback } from 'react';
import { createClient } from '@/lib/supabase/client';
import { getSocket } from '@/lib/socket';
import RankBadge from '@/components/RankBadge';
import ChatBox from '@/components/ChatBox';
import FriendContextMenu from '@/components/FriendContextMenu';

type Tab = 'friends' | 'requests' | 'invite';

interface FriendEntry {
  userId: string;
  displayName: string;
  friendshipId: string;
  eloBySubject: Record<string, number>;
}

interface PendingEntry {
  friendshipId: string;
  userId: string;
  displayName: string;
  direction: 'incoming' | 'outgoing';
}

export interface IncomingChallenge {
  challengeId: string;
  fromUserId: string;
  fromDisplayName: string;
  subject: string;
  receivedAt: number;
}

interface ContextMenuState {
  friend: FriendEntry;
  top: number;
  right: number;
}

interface Props {
  isOpen: boolean;
  onClose: () => void;
  userId: string;
  viewerSubject: string;
  onlineUserIds: Set<string>;
  friendActivity: Record<string, { subject: string; phase: string } | null>;
  incomingChallenge: IncomingChallenge | null;
  onChallengeAccept: (challengeId: string) => void;
  onChallengeDecline: (challengeId: string) => void;
  onPendingCount: (n: number) => void;
}

export default function FriendsPanel({
  isOpen,
  onClose,
  userId,
  viewerSubject,
  onlineUserIds,
  friendActivity,
  incomingChallenge,
  onChallengeAccept,
  onChallengeDecline,
  onPendingCount,
}: Props) {
  const [tab, setTab] = useState<Tab>('friends');
  const [friends, setFriends] = useState<FriendEntry[]>([]);
  const [pending, setPending] = useState<PendingEntry[]>([]);
  const [inviteCode, setInviteCode] = useState('');
  const [codeInput, setCodeInput] = useState('');
  const [addStatus, setAddStatus] = useState<'idle' | 'loading' | 'sent' | 'error'>('idle');
  const [addError, setAddError] = useState('');
  const [copied, setCopied] = useState(false);
  const [unread, setUnread] = useState<Record<string, number>>({});
  const [activeChatUserId, setActiveChatUserId] = useState<string | null>(null);
  const [contextMenu, setContextMenu] = useState<ContextMenuState | null>(null);
  const [challengeTimer, setChallengeTimer] = useState<number | null>(null);

  const fetchData = useCallback(async () => {
    if (!userId) return;
    const supabase = createClient();

    const [{ data: friendships }, { data: myProfile }] = await Promise.all([
      supabase
        .from('friendships')
        .select('id, status, requester_id, addressee_id')
        .or(`requester_id.eq.${userId},addressee_id.eq.${userId}`),
      supabase
        .from('profiles')
        .select('invite_code')
        .eq('id', userId)
        .single(),
    ]);

    if (myProfile?.invite_code) setInviteCode(myProfile.invite_code);

    const rows = friendships ?? [];
    const accepted = rows.filter(r => r.status === 'accepted');
    const pendingRows = rows.filter(r => r.status === 'pending');
    const incomingCount = pendingRows.filter(r => r.addressee_id === userId).length;
    onPendingCount(incomingCount);

    const friendIds = accepted.map(r =>
      r.requester_id === userId ? r.addressee_id : r.requester_id
    );
    const pendingIds = pendingRows.map(r =>
      r.requester_id === userId ? r.addressee_id : r.requester_id
    );
    const allIds = [...new Set([...friendIds, ...pendingIds])];

    if (allIds.length === 0) {
      setFriends([]);
      setPending([]);
      return;
    }

    const [{ data: profiles }, { data: eloRows }] = await Promise.all([
      supabase.from('profiles').select('id, display_name').in('id', allIds),
      supabase.from('elo_ratings').select('user_id, subject, rating').in('user_id', friendIds),
    ]);

    const profileMap: Record<string, string> = Object.fromEntries(
      (profiles ?? []).map(p => [p.id, p.display_name])
    );
    const eloMap: Record<string, Record<string, number>> = {};
    for (const row of eloRows ?? []) {
      if (!eloMap[row.user_id]) eloMap[row.user_id] = {};
      eloMap[row.user_id][row.subject] = row.rating;
    }

    setFriends(accepted.map(r => {
      const fid = r.requester_id === userId ? r.addressee_id : r.requester_id;
      return { userId: fid, displayName: profileMap[fid] ?? 'Unknown', friendshipId: r.id, eloBySubject: eloMap[fid] ?? {} };
    }));

    setPending(pendingRows.map(r => {
      const fid = r.requester_id === userId ? r.addressee_id : r.requester_id;
      return {
        friendshipId: r.id,
        userId: fid,
        displayName: profileMap[fid] ?? 'Unknown',
        direction: r.requester_id === userId ? 'outgoing' : 'incoming',
      };
    }));
  }, [userId, onPendingCount]);

  useEffect(() => {
    if (isOpen) fetchData();
  }, [isOpen, fetchData]);

  // Unread message count
  useEffect(() => {
    const socket = getSocket();
    function onMsg({ fromUserId }: { messageId: string; fromUserId: string; content: string; sentAt: string }) {
      if (fromUserId === activeChatUserId) return;
      setUnread(prev => ({ ...prev, [fromUserId]: (prev[fromUserId] ?? 0) + 1 }));
    }
    socket.on('new_message', onMsg);
    return () => { socket.off('new_message', onMsg); };
  }, [activeChatUserId]);

  // Challenge countdown
  useEffect(() => {
    if (!incomingChallenge) { setChallengeTimer(null); return; }
    const elapsed = Date.now() - incomingChallenge.receivedAt;
    const secs = Math.max(0, Math.ceil((300_000 - elapsed) / 1000));
    setChallengeTimer(secs);
    const interval = setInterval(() => setChallengeTimer(t => (t !== null && t > 0 ? t - 1 : 0)), 1000);
    return () => clearInterval(interval);
  }, [incomingChallenge]);

  function getDisplayElo(friend: FriendEntry): number {
    const act = friendActivity[friend.userId];
    if (act) return friend.eloBySubject[act.subject] ?? 1000;
    return friend.eloBySubject[viewerSubject] ?? 1000;
  }

  const sortedFriends = [...friends].sort((a, b) => {
    const aAct = !!friendActivity[a.userId];
    const bAct = !!friendActivity[b.userId];
    const aOn = onlineUserIds.has(a.userId);
    const bOn = onlineUserIds.has(b.userId);
    if (aAct !== bAct) return bAct ? 1 : -1;
    if (aOn !== bOn) return bOn ? 1 : -1;
    return a.displayName.localeCompare(b.displayName);
  });

  async function acceptRequest(friendshipId: string) {
    await createClient().from('friendships').update({ status: 'accepted' }).eq('id', friendshipId);
    fetchData();
  }

  async function removeRow(friendshipId: string) {
    await createClient().from('friendships').delete().eq('id', friendshipId);
    setPending(prev => prev.filter(p => p.friendshipId !== friendshipId));
    setFriends(prev => prev.filter(f => f.friendshipId !== friendshipId));
    onPendingCount(Math.max(0, pending.filter(p => p.direction === 'incoming' && p.friendshipId !== friendshipId).length));
  }

  async function handleAdd() {
    if (codeInput.length !== 8) return;
    setAddStatus('loading');
    setAddError('');
    try {
      const res = await fetch(`/api/invite/${codeInput.trim().toUpperCase()}`);
      if (!res.ok) {
        setAddStatus('error');
        setAddError('No user found with that code.');
        return;
      }
      const { userId: targetId } = await res.json() as { userId: string; displayName: string };
      if (targetId === userId) {
        setAddStatus('error');
        setAddError("That's your own code.");
        return;
      }
      const { error } = await createClient()
        .from('friendships')
        .insert({ requester_id: userId, addressee_id: targetId, status: 'pending' });
      if (error) {
        setAddStatus('error');
        setAddError(error.message.includes('unique') ? 'Request already sent or you are already friends.' : 'Could not send request.');
        return;
      }
      setAddStatus('sent');
      setCodeInput('');
      fetchData();
    } catch {
      setAddStatus('error');
      setAddError('Network error. Try again.');
    }
  }

  function openContextMenu(e: React.MouseEvent, friend: FriendEntry) {
    e.stopPropagation();
    const rect = (e.currentTarget as HTMLElement).getBoundingClientRect();
    setContextMenu({ friend, top: rect.bottom + 4, right: window.innerWidth - rect.right });
  }

  function openChat(friend: FriendEntry) {
    setActiveChatUserId(friend.userId);
    setUnread(prev => { const next = { ...prev }; delete next[friend.userId]; return next; });
  }

  const incomingCount = pending.filter(p => p.direction === 'incoming').length;
  const onlineCount = [...friends].filter(f => onlineUserIds.has(f.userId)).length;

  if (!isOpen) return null;

  return (
    <>
      {/* Backdrop */}
      <div className="fixed inset-0 z-30 bg-black/40" onClick={onClose} aria-hidden="true" />

      {/* Incoming challenge toast — always visible when challenge exists */}
      {incomingChallenge && (
        <div className="fixed top-16 right-[calc(320px+16px)] z-50 w-68 panel-raised border border-[#C9A84C]/50 p-4 flex flex-col gap-3 animate-rise-in shadow-xl">
          <p className="text-[9px] text-[#C9A84C]/70 uppercase tracking-[0.3em]">Incoming Challenge</p>
          <div>
            <p className="text-sm font-display font-bold uppercase tracking-[0.12em] text-[#F5F0E8]">
              {incomingChallenge.fromDisplayName}
            </p>
            <p className="text-[10px] text-[#F5F0E8]/40 uppercase tracking-[0.15em] mt-0.5">
              {incomingChallenge.subject.replace('AP ', '')} · {challengeTimer ?? '—'}s
            </p>
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => onChallengeAccept(incomingChallenge.challengeId)}
              className="flex-1 btn-gold font-display font-bold text-[10px] uppercase tracking-[0.15em] py-2"
            >
              Accept
            </button>
            <button
              onClick={() => onChallengeDecline(incomingChallenge.challengeId)}
              className="flex-1 btn-ghost font-display font-bold text-[10px] uppercase tracking-[0.15em] py-2"
            >
              Decline
            </button>
          </div>
        </div>
      )}

      {/* Panel drawer */}
      <div className="fixed top-0 right-0 bottom-0 w-80 z-40 flex flex-col panel border-l border-[#2A2A2A] shadow-2xl">

        {/* Header */}
        <div className="flex items-center justify-between px-5 py-4 border-b border-[#2A2A2A] flex-shrink-0">
          <p className="font-display font-black text-sm uppercase tracking-[0.2em] text-[#F5F0E8]/70">
            Friends
          </p>
          <button
            onClick={onClose}
            className="text-[#F5F0E8]/30 hover:text-[#F5F0E8]/60 text-2xl leading-none transition-colors"
            aria-label="Close panel"
          >
            ×
          </button>
        </div>

        {/* Tabs */}
        <div className="flex border-b border-[#2A2A2A] flex-shrink-0">
          {(['friends', 'requests', 'invite'] as const).map(t => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`relative flex-1 py-2.5 text-[10px] font-display font-bold uppercase tracking-[0.18em] transition-colors ${
                tab === t ? 'text-[#C9A84C]' : 'text-[#F5F0E8]/30 hover:text-[#F5F0E8]/55'
              }`}
            >
              {t}
              {t === 'requests' && incomingCount > 0 && (
                <span className="absolute top-1.5 right-2 w-1.5 h-1.5 bg-[#EF4444]" />
              )}
              {tab === t && (
                <span className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#C9A84C]" />
              )}
            </button>
          ))}
        </div>

        {/* Scrollable content */}
        <div className="flex-1 overflow-y-auto">

          {/* ── Friends tab ── */}
          {tab === 'friends' && (
            sortedFriends.length === 0 ? (
              <div className="py-16 text-center">
                <p className="text-[#F5F0E8]/15 text-[10px] uppercase tracking-[0.25em]">No friends yet</p>
                <p className="text-[#F5F0E8]/10 text-[9px] uppercase tracking-[0.2em] mt-1">Use the Invite tab to add friends</p>
              </div>
            ) : (
              sortedFriends.map(friend => {
                const online = onlineUserIds.has(friend.userId);
                const act = friendActivity[friend.userId] ?? null;
                const elo = getDisplayElo(friend);
                const unreadCount = unread[friend.userId] ?? 0;

                return (
                  <div
                    key={friend.userId}
                    onClick={() => openChat(friend)}
                    className="flex items-center gap-3 px-4 py-3 hover:bg-[#1C1C1C] transition-colors cursor-pointer group border-b border-[#2A2A2A]/40 relative"
                  >
                    {/* Avatar + status dot */}
                    <div className="relative flex-shrink-0">
                      <div className={`w-8 h-8 flex items-center justify-center text-[10px] font-display font-black ${
                        online
                          ? 'bg-[#1C1C1C] border border-[#C9A84C]/25 text-[#C9A84C]'
                          : 'bg-[#141414] border border-[#2A2A2A] text-[#F5F0E8]/20'
                      }`}>
                        {friend.displayName.slice(0, 2).toUpperCase()}
                      </div>
                      <span className={`absolute -bottom-0.5 -right-0.5 w-2.5 h-2.5 border-2 border-[#141414] ${
                        unreadCount > 0
                          ? 'bg-[#EF4444] animate-pulse'
                          : act ? 'bg-[#C9A84C]' : online ? 'bg-[#22C55E]' : 'bg-[#374151]'
                      }`} />
                    </div>

                    {/* Name + activity */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-1.5">
                        <p className="text-xs font-display font-bold uppercase tracking-[0.1em] text-[#F5F0E8]/80 truncate">
                          {friend.displayName}
                        </p>
                        {unreadCount > 0 && (
                          <span className="flex-shrink-0 inline-flex items-center justify-center w-4 h-4 text-[9px] bg-[#EF4444] text-white font-display font-black">
                            {unreadCount > 9 ? '9+' : unreadCount}
                          </span>
                        )}
                      </div>
                      {act ? (
                        <p className="text-[10px] text-[#C9A84C]/65 uppercase tracking-[0.1em] truncate">
                          {act.phase === 'battle' ? 'In Battle' : 'Searching'} · {act.subject.replace('AP ', '')}
                        </p>
                      ) : (
                        <p className={`text-[10px] uppercase tracking-[0.1em] ${online ? 'text-[#22C55E]/50' : 'text-[#F5F0E8]/18'}`}>
                          {online ? 'Online' : 'Offline'}
                        </p>
                      )}
                    </div>

                    {/* ELO */}
                    <RankBadge elo={elo} size="sm" className="flex-shrink-0 opacity-60 group-hover:opacity-100 transition-opacity" />

                    {/* Three-dots menu */}
                    <button
                      onClick={e => openContextMenu(e, friend)}
                      className="w-6 h-6 flex items-center justify-center text-[#F5F0E8]/20 hover:text-[#F5F0E8]/55 opacity-0 group-hover:opacity-100 transition-all flex-shrink-0 font-bold text-sm"
                      aria-label="Friend options"
                    >
                      ⋯
                    </button>
                  </div>
                );
              })
            )
          )}

          {/* ── Requests tab ── */}
          {tab === 'requests' && (
            <div className="p-4 flex flex-col gap-3">
              {pending.length === 0 ? (
                <p className="text-[#F5F0E8]/15 text-[10px] uppercase tracking-[0.25em] text-center py-10">
                  No pending requests
                </p>
              ) : (
                pending.map(req => (
                  <div key={req.friendshipId} className="flex items-center gap-3 panel p-3">
                    <div className="w-8 h-8 flex-shrink-0 flex items-center justify-center text-[10px] font-display font-black bg-[#141414] border border-[#2A2A2A] text-[#F5F0E8]/30">
                      {req.displayName.slice(0, 2).toUpperCase()}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-xs font-display font-bold uppercase tracking-[0.1em] text-[#F5F0E8]/75 truncate">
                        {req.displayName}
                      </p>
                      <p className={`text-[9px] uppercase tracking-[0.15em] ${
                        req.direction === 'incoming' ? 'text-[#C9A84C]/55' : 'text-[#F5F0E8]/22'
                      }`}>
                        {req.direction === 'incoming' ? 'Wants to be friends' : 'Request sent'}
                      </p>
                    </div>
                    {req.direction === 'incoming' ? (
                      <div className="flex gap-1.5 flex-shrink-0">
                        <button
                          onClick={() => acceptRequest(req.friendshipId)}
                          className="btn-gold text-[9px] font-display font-bold uppercase tracking-[0.12em] px-2.5 py-1.5"
                        >
                          Accept
                        </button>
                        <button
                          onClick={() => removeRow(req.friendshipId)}
                          className="btn-ghost text-[9px] font-display font-bold uppercase tracking-[0.12em] px-2.5 py-1.5"
                        >
                          Decline
                        </button>
                      </div>
                    ) : (
                      <button
                        onClick={() => removeRow(req.friendshipId)}
                        className="text-[9px] font-display uppercase tracking-[0.12em] text-[#F5F0E8]/20 hover:text-[#EF4444]/60 transition-colors"
                      >
                        Cancel
                      </button>
                    )}
                  </div>
                ))
              )}
            </div>
          )}

          {/* ── Invite tab ── */}
          {tab === 'invite' && (
            <div className="p-5 flex flex-col gap-6">
              {/* Own code */}
              <div>
                <p className="text-[10px] text-[#F5F0E8]/30 uppercase tracking-[0.25em] mb-2.5">Your Code</p>
                <div className="flex gap-2">
                  <div className="flex-1 panel px-4 py-3 font-display font-black text-lg tracking-[0.3em] text-[#C9A84C] text-center select-all">
                    {inviteCode || '—————'}
                  </div>
                  <button
                    onClick={() => { navigator.clipboard.writeText(inviteCode); setCopied(true); setTimeout(() => setCopied(false), 2000); }}
                    className="btn-ghost px-3 py-2 text-[10px] font-display font-bold uppercase tracking-[0.15em]"
                  >
                    {copied ? 'Copied' : 'Copy'}
                  </button>
                </div>
                <p className="text-[9px] text-[#F5F0E8]/18 mt-1.5">
                  Share this code so others can add you.
                </p>
              </div>

              <div className="rule-gold" />

              {/* Add by code */}
              <div>
                <p className="text-[10px] text-[#F5F0E8]/30 uppercase tracking-[0.25em] mb-2.5">Add Friend</p>
                <div className="flex gap-2">
                  <input
                    value={codeInput}
                    onChange={e => { setCodeInput(e.target.value.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 8)); setAddStatus('idle'); }}
                    placeholder="ENTER CODE"
                    className="flex-1 bg-[#141414] border border-[#2A2A2A] text-[#F5F0E8] font-display font-bold text-sm tracking-[0.25em] px-3 py-2.5 outline-none placeholder:text-[#F5F0E8]/12 focus:border-[#C9A84C]/40 transition-colors"
                    maxLength={8}
                  />
                  <button
                    onClick={handleAdd}
                    disabled={codeInput.length !== 8 || addStatus === 'loading'}
                    className="btn-gold px-4 py-2 text-xs font-display font-bold uppercase tracking-[0.15em] disabled:opacity-30"
                  >
                    {addStatus === 'loading' ? '…' : 'Add'}
                  </button>
                </div>
                {addStatus === 'sent' && (
                  <p className="text-[10px] text-[#22C55E] mt-1.5 uppercase tracking-[0.15em]">
                    Friend request sent!
                  </p>
                )}
                {addStatus === 'error' && (
                  <p className="text-[10px] text-[#EF4444]/80 mt-1.5">{addError}</p>
                )}
              </div>
            </div>
          )}

        </div>

        {/* Footer: online count */}
        <div className="px-5 py-3 border-t border-[#2A2A2A] flex-shrink-0">
          <p className="text-[9px] text-[#F5F0E8]/18 uppercase tracking-[0.2em]">
            {onlineCount} of {friends.length} friend{friends.length !== 1 ? 's' : ''} online
          </p>
        </div>
      </div>

      {/* Context menu (rendered at fixed position to escape overflow clip) */}
      {contextMenu && (
        <div style={{ position: 'fixed', top: contextMenu.top, right: contextMenu.right, zIndex: 60 }}>
          <FriendContextMenu
            friend={contextMenu.friend}
            onBlock={() => {
              setFriends(prev => prev.filter(f => f.userId !== contextMenu.friend.userId));
              setContextMenu(null);
            }}
            onClose={() => setContextMenu(null)}
          />
        </div>
      )}

      {/* Chat window */}
      {activeChatUserId && (() => {
        const friend = friends.find(f => f.userId === activeChatUserId);
        if (!friend) return null;
        return (
          <ChatBox
            key={activeChatUserId}
            friendUserId={activeChatUserId}
            friendDisplayName={friend.displayName}
            myUserId={userId}
            onClose={() => setActiveChatUserId(null)}
          />
        );
      })()}
    </>
  );
}
