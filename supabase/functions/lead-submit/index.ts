import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') || ''
const TURNSTILE_SECRET_KEY = Deno.env.get('TURNSTILE_SECRET_KEY') || ''
const WEBHOOK_SECRET = Deno.env.get('WEBHOOK_SECRET') || ''

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

  try {
    const body = await req.json()
    const landing_page_id = body?.landing_page_id
    const form_data = body?.form_data

    if (!landing_page_id || !form_data) {
      return new Response(JSON.stringify({ error: 'Missing required data' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const metadata = form_data['__metadata'] || {}
    const turnstile_token = metadata['turnstile_token']
    const fingerprint = metadata['fingerprint']
    const client_ip = req.headers.get('x-real-ip') || req.headers.get('x-forwarded-for') || 'unknown'

    // 1. Verify Turnstile Token
    const verifyFormData = new FormData()
    verifyFormData.append('secret', TURNSTILE_SECRET_KEY)
    verifyFormData.append('response', turnstile_token || '')

    const turnstileResult = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
      body: verifyFormData,
      method: 'POST',
    })

    const turnstileOutcome = await turnstileResult.json()
    if (!turnstileOutcome.success) {
      return new Response(JSON.stringify({ error: 'Invalid captcha token' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 2. Rate Limiting Check
    const { count: ipCount } = await supabase
      .from('lead_submissions_log')
      .select('*', { count: 'exact', head: true })
      .eq('ip_address', client_ip)
      .gt('created_at', new Date(Date.now() - 3600000).toISOString())

    if (ipCount !== null && ipCount >= 10) {
      return new Response(JSON.stringify({ error: 'Too many requests from this IP' }), {
        status: 429,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    if (fingerprint) {
      const { count: fpCount } = await supabase
        .from('lead_submissions_log')
        .select('*', { count: 'exact', head: true })
        .eq('fingerprint', fingerprint)
        .gt('created_at', new Date(Date.now() - 600000).toISOString())

      if (fpCount !== null && fpCount >= 5) {
        return new Response(JSON.stringify({ error: 'Too many requests from this device' }), {
          status: 429,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
    }

    // 3. Log Submission Attempt
    await supabase.from('lead_submissions_log').insert({
      landing_page_id,
      ip_address: client_ip,
      fingerprint: fingerprint,
    })

    // 4. Insert Lead
    const finalFormData = { ...form_data }
    delete finalFormData['__metadata']

    const { data: lead, error: leadError } = await supabase
      .from('leads')
      .insert({
        landing_page_id,
        form_data: finalFormData,
      })
      .select()
      .single()

    if (leadError) throw leadError

    // 5. Trigger Analytics (Conversion)
    await supabase.rpc('increment_page_view', { page_id: landing_page_id, increment_purchase: true })

    // 6. Trigger Page Owner Notification (fire-and-forget)
    if (WEBHOOK_SECRET) {
      try {
        await fetch(`${SUPABASE_URL}/functions/v1/lead-notify`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${WEBHOOK_SECRET}`,
          },
          body: JSON.stringify({ record: lead }),
        })
      } catch (_) {
        // Notification failure should not block the lead submission response
      }
    }

    return new Response(JSON.stringify({ success: true, lead }), {
      status: 200,
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
