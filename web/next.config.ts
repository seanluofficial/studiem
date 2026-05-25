import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async rewrites() {
    const socketUrl = process.env.NEXT_PUBLIC_SOCKET_URL;
    // Only proxy when pointing at a real remote server (not localhost dev)
    if (!socketUrl || socketUrl.includes('localhost')) return [];
    return [
      {
        source: '/socket.io/:path*',
        destination: `${socketUrl}/socket.io/:path*`,
      },
    ];
  },
};

export default nextConfig;
