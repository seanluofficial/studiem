import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

export async function GET(
  _req: Request,
  { params }: { params: Promise<{ code: string }> }
) {
  const { code } = await params;
  const supabase = await createClient();
  const { data } = await supabase
    .from('profiles')
    .select('id, display_name')
    .eq('invite_code', code.toUpperCase())
    .maybeSingle();

  if (!data) return NextResponse.json({ error: 'Not found' }, { status: 404 });
  return NextResponse.json({ userId: data.id, displayName: data.display_name });
}
