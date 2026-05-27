import { io, Socket } from 'socket.io-client';

let socket: Socket | null = null;

const SOCKET_URL = process.env.NEXT_PUBLIC_SOCKET_URL ?? 'http://localhost:4000';

export function getSocket(): Socket {
  if (!socket) {
    console.log('[socket] init →', SOCKET_URL);
    // Connect directly to Railway. WebSocket-first for low latency;
    // falls back to polling if WebSocket upgrade is blocked.
    socket = io(SOCKET_URL, { autoConnect: false, transports: ['websocket', 'polling'] });
  }
  return socket;
}
