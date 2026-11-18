import { createClient } from "https://esm.sh/@supabase/supabase-js@2.57.0";

export const NOVA_SUPABASE_URL = "https://suirbghmnuxixktzkrze.supabase.co";
export const NOVA_SUPABASE_KEY = "sb_publishable_1ZmYJ5J-A8hGDIcUIOiY3g_dYOKdnIp";

export const supabase = createClient(NOVA_SUPABASE_URL, NOVA_SUPABASE_KEY, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
    flowType: "pkce"
  }
});

// Reuse exactly one browser client per page to avoid competing auth locks.
if (typeof window !== "undefined") window.NOVA_SUPABASE = supabase;
