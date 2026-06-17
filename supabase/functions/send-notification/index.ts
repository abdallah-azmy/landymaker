import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"
import { initializeApp, cert, getApps } from "npm:firebase-admin@11.11.0/app"
import { getMessaging } from "npm:firebase-admin@11.11.0/messaging"

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''
const FIREBASE_SERVICE_ACCOUNT = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') || '{}')

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

if (getApps().length === 0) {
  initializeApp({ credential: cert(FIREBASE_SERVICE_ACCOUNT) })
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface SendNotificationPayload {
  user_ids: string[] | null // null = all users
  title: string
  message: string
  type: string
  redirect_to: string | null
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Verify caller is authenticated super_admin
    const authHeader = req.headers.get('Authorization') || ''
    const jwt = authHeader.replace('Bearer ', '')
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(jwt)

    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (!profile || profile.role !== 'super_admin') {
      return new Response(JSON.stringify({ error: 'Forbidden: super_admin role required' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const payload: SendNotificationPayload = await req.json()
    const { user_ids, title, message, type, redirect_to } = payload

    if (!title || !message) {
      return new Response(JSON.stringify({ error: 'title and message are required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 1. Fetch target FCM tokens
    let query = supabase.from('user_fcm_tokens').select('fcm_token')

    if (user_ids && user_ids.length > 0) {
      query = query.in('user_id', user_ids)
    }

    const { data: tokens, error: tokenError } = await query

    if (tokenError) {
      throw new Error(`Failed to fetch FCM tokens: ${tokenError.message}`)
    }

    if (!tokens || tokens.length === 0) {
      return new Response(JSON.stringify({ message: 'No FCM tokens found', sent: 0 }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // 2. Deduplicate tokens (a user may have multiple devices with same token)
    const uniqueTokens = [...new Set(tokens.map((t: any) => t.fcm_token))]

    // 3. Build FCM data payload
    const data: Record<string, string> = { type }
    if (redirect_to) {
      data['redirect_to'] = redirect_to
      data['click_action'] = redirect_to
    }

    // 4. Send in batches of 500 (FCM limit)
    const BATCH_SIZE = 500
    let sent = 0
    let failed = 0

    for (let i = 0; i < uniqueTokens.length; i += BATCH_SIZE) {
      const batch = uniqueTokens.slice(i, i + BATCH_SIZE)
      try {
        const result = await getMessaging().sendEachForMulticast({
          tokens: batch,
          notification: { title, body: message },
          data,
        })
        sent += result.successCount
        failed += result.failureCount
      } catch (e) {
        failed += batch.length
        console.error(`Batch failed at offset ${i}:`, e)
      }
    }

    return new Response(JSON.stringify({
      success: true,
      sent,
      failed,
      total_tokens: uniqueTokens.length,
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error'
    console.error('send-notification error:', errorMessage)
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
