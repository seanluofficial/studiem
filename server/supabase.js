const { createClient } = require('@supabase/supabase-js');
const ws = require('ws');

let _supabase = null;

function getSupabase() {
  if (!_supabase) {
    _supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_SERVICE_ROLE_KEY,
      { realtime: { transport: ws } }
    );
  }
  return _supabase;
}

module.exports = { getSupabase };
