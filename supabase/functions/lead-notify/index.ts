import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''
const WEBHOOK_SECRET = Deno.env.get('WEBHOOK_SECRET') || ''
const FIREBASE_SERVICE_ACCOUNT = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') || '{}')

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // SECURITY: Verify that the request comes from Supabase Webhook
  const authHeader = req.headers.get('Authorization')
  if (!WEBHOOK_SECRET || authHeader !== `Bearer ${WEBHOOK_SECRET}`) {
    return new Response(JSON.stringify({ error: 'Unauthorized: Invalid Webhook Secret' }), {
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  try {
    const payload = await req.json()
    const lead = payload.record
    if (!lead) throw new Error('No record found in payload')

    const landing_page_id = lead.landing_page_id

    // 1. Get Landing Page Info and Owner
    const { data: page } = await supabase
      .from('landing_pages')
      .select('subdomain, user_id')
      .eq('id', landing_page_id)
      .single()

    if (!page) throw new Error('Page not found')

    // 2. Get User's FCM Tokens
    const { data: tokens } = await supabase
      .from('user_fcm_tokens')
      .select('fcm_token')
      .eq('user_id', page.user_id)

    if (!tokens || tokens.length === 0) {
      return new Response(JSON.stringify({ message: 'No tokens found for user' }), { headers: corsHeaders })
    }

    const fcmTokens = tokens.map((t: any) => t.fcm_token)

    // 3. Logic to send FCM (Placeholder logic for JWT signing)
    console.log(`SECURE WEBHOOK: Verified and ready to notify user ${page.user_id} for page ${page.subdomain}`);

    return new Response(JSON.stringify({ success: true, message: 'Secure notification logic triggered' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error'
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
