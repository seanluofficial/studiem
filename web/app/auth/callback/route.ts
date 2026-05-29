import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get('code');
  const next = searchParams.get('next') ?? '/';

  if (code) {
    const supabase = await createClient();
    const { data, error } = await supabase.auth.exchangeCodeForSession(code);

    if (!error && data.user) {
      const rawName = (
        (data.user.user_metadata?.full_name as string | undefined) ??
        (data.user.user_metadata?.name as string | undefined) ??
        data.user.email?.split('@')[0] ??
        ''
      ).slice(0, 24).trim();

      await supabase
        .from('profiles')
        .upsert(
          { id: data.user.id, display_name: rawName.length >= 2 ? rawName : 'Player' },
          { onConflict: 'id', ignoreDuplicates: true }
        );

      return NextResponse.redirect(new URL(next, origin));
    }
  }

  return NextResponse.redirect(new URL('/login?error=oauth_failed', origin));
}
