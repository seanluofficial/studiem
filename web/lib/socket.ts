import { io, Socket } from 'socket.io-client';

let socket: Socket | null = null;

export function getSocket(): Socket {
  if (!socket) {
    // In development, hit the local server directly.
    // In production, connect to the same Vercel origin — next.config.ts rewrites
    // /socket.io/* to Railway server-to-server, avoiding CORS entirely.
    const isDev = process.env.NODE_ENV === 'development';
    const url = isDev
      ? (process.env.NEXT_PUBLIC_SOCKET_URL ?? 'http://localhost:4000')
      : undefined; // undefined → socket.io uses window.location (same origin)
    socket = io(url as string, { autoConnect: false });
  }
  return socket;
}
