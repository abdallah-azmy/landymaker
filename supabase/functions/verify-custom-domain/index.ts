import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) throw new Error('No authorization header')

    const body = await req.json()
    const page_id = body?.page_id
    const action = body?.action || 'verify'

    // Initialize Supabase Client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') || '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '',
    )

    // Verify User
    const { data: userData, error: userError } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''))
    if (userError || !userData.user) throw new Error('Invalid user session')

    // Fetch Page
    const { data: page, error: pageError } = await supabase
      .from('landing_pages')
      .select('*, profiles(tier, role)')
      .eq('id', page_id)
      .eq('user_id', userData.user.id)
      .single()

    if (pageError || !page) {
      throw new Error('Page not found or unauthorized')
    }

    const VERCEL_TOKEN = Deno.env.get('VERCEL_TOKEN') || ''
    const PROJECT_ID = Deno.env.get('VERCEL_PROJECT_ID') || ''
    const TEAM_ID = Deno.env.get('VERCEL_TEAM_ID') || ''

    const domain = page.custom_domain
    if (!domain && action !== 'delete') {
      throw new Error('No custom domain configured')
    }

    if (action === 'delete') {
      if (!domain) throw new Error('Domain required for deletion')

      const deleteUrl = `https://api.vercel.com/v9/projects/${PROJECT_ID}/domains/${domain}${TEAM_ID ? `?teamId=${TEAM_ID}` : ''}`
      await fetch(deleteUrl, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${VERCEL_TOKEN}` },
      })

      await supabase.from('landing_pages').update({
        custom_domain: null,
        domain_status: 'pending'
      }).eq('id', page_id)

      return new Response(JSON.stringify({ success: true, message: 'Domain removed' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Security check
    const profile = page.profiles as any
    const tier = profile?.tier || 'free'
    const role = profile?.role || 'user'

    if (role !== 'super_admin' && tier === 'free') {
      throw new Error('Premium tier required for custom domains')
    }

    // 1. Add domain to Vercel
    const addUrl = `https://api.vercel.com/v10/projects/${PROJECT_ID}/domains${TEAM_ID ? `?teamId=${TEAM_ID}` : ''}`
    await fetch(addUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${VERCEL_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ name: domain }),
    })

    // 2. Check Verification Status
    const verifyUrl = `https://api.vercel.com/v9/projects/${PROJECT_ID}/domains/${domain}/verify${TEAM_ID ? `?teamId=${TEAM_ID}` : ''}`
    const verifyRes = await fetch(verifyUrl, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${VERCEL_TOKEN}` },
    })

    const status = await verifyRes.json()
    const isVerified = status.verified === true

    // Update Supabase
    await supabase
      .from('landing_pages')
      .update({ domain_status: isVerified ? 'connected' : 'failed' })
      .eq('id', page_id)

    return new Response(JSON.stringify({
      success: true,
      verified: isVerified,
      status: isVerified ? 'connected' : 'pending_dns'
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error'
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
