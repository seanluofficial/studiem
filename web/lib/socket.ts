import { io, Socket } from 'socket.io-client';

let socket: Socket | null = null;

export function getSocket(): Socket {
  if (!socket) {
    const rawUrl = process.env.NEXT_PUBLIC_SOCKET_URL ?? 'http://localhost:4000';
    const isDev = rawUrl.includes('localhost');
    // Dev: connect directly to local server.
    // Prod: connect to same Vercel origin — next.config.ts rewrites /socket.io/* to Railway.
    const url = isDev ? rawUrl : window.location.origin;
    console.log('[socket] init →', url);
    socket = io(url, { autoConnect: false });
  }
  return socket;
}
