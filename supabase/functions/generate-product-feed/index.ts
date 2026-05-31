import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const url = new URL(req.url)
    const websiteId = url.searchParams.get('website_id')
    const token = url.searchParams.get('token')

    if (!websiteId || !token) {
      return new Response(JSON.stringify({ error: 'Missing parameters' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Initialize Supabase Client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Validate Website, Token & Tier (Premium Only)
    const { data: page, error: fetchError } = await supabase
      .from('landing_pages')
      .select('subdomain, design_json, feed_token, user_id, profiles(tier, role)')
      .eq('id', websiteId)
      .single()

    if (fetchError || !page || page.feed_token !== token) {
      return new Response(JSON.stringify({ error: 'Unauthorized or not found' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Security Check: Only Pro/Enterprise or Super Admin
    const role = (page.profiles as any)?.role || 'user'
    const tier = (page.profiles as any)?.tier || 'free'
    if (role !== 'super_admin' && tier === 'free') {
      return new Response(JSON.stringify({ error: 'Premium subscription required for product feeds' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Extract Products
    const design = typeof page.design_json === 'string' ? JSON.parse(page.design_json) : page.design_json
    const productsBlock = (design.blocks || []).find((b: any) => b.type === 'products')
    const products = productsBlock?.items || []

    // Generate RSS XML
    const domain = page.subdomain + '.landymaker.com' // Fallback to subdomain
    const xml = `<?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:g="http://base.google.com/ns/1.0" version="2.0">
  <channel>
    <title>${page.subdomain} - Product Feed</title>
    <link>https://${domain}</link>
    <description>Dynamic product feed for ${page.subdomain}</description>
    ${products.map((p: any) => `
    <item>
      <g:id>${p.id || 'p_' + Math.random().toString(36).substr(2, 9)}</g:id>
      <g:title><![CDATA[${p.name}]]></g:title>
      <g:description><![CDATA[${p.description || p.name}]]></g:description>
      <g:link>https://${domain}/#product-${p.id}</g:link>
      <g:image_link>${p.image_url}</g:image_link>
      <g:condition>new</g:condition>
      <g:availability>in stock</g:availability>
      <g:price>${p.price.replace(/[^\d.]/g, '')} EGP</g:price>
      <g:brand>${page.subdomain}</g:brand>
    </item>`).join('')}
  </channel>
</rss>`

    return new Response(xml, {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/xml; charset=utf-8',
      },
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
