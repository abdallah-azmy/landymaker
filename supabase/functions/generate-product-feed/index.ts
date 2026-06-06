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
    const url = new URL(req.url)
    const websiteId = url.searchParams.get('website_id')
    const token = url.searchParams.get('token')

    if (!websiteId || !token) {
      return new Response(JSON.stringify({ error: 'Missing parameters' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') || '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''
    )

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

    const profile = page.profiles as any
    const role = profile?.role || 'user'
    const tier = profile?.tier || 'free'
    if (role !== 'super_admin' && tier === 'free') {
      return new Response(JSON.stringify({ error: 'Premium subscription required for product feeds' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const design = typeof page.design_json === 'string' ? JSON.parse(page.design_json) : page.design_json
    const blocks = (design?.blocks || []) as any[]
    const productsBlock = blocks.find((b: any) => b.type === 'products')
    const products = (productsBlock?.items || []) as any[]

    const domain = page.subdomain + '.landymaker.com'
    const itemsXml = products.map((p: any) => {
      const pId = p.id || 'p_' + Math.random().toString(36).substring(2, 9)
      const pPrice = p.price ? p.price.replace(/[^\d.]/g, '') : '0'
      return `
    <item>
      <g:id>${pId}</g:id>
      <g:title><![CDATA[${p.name}]]></g:title>
      <g:description><![CDATA[${p.description || p.name}]]></g:description>
      <g:link>https://${domain}/#product-${pId}</g:link>
      <g:image_link>${p.image_url}</g:image_link>
      <g:condition>new</g:condition>
      <g:availability>in stock</g:availability>
      <g:price>${pPrice} EGP</g:price>
      <g:brand>${page.subdomain}</g:brand>
    </item>`
    }).join('')

    const xml = `<?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:g="http://base.google.com/ns/1.0" version="2.0">
  <channel>
    <title>${page.subdomain} - Product Feed</title>
    <link>https://${domain}</link>
    <description>Dynamic product feed for ${page.subdomain}</description>
    ${itemsXml}
  </channel>
</rss>`

    return new Response(xml, {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/xml; charset=utf-8',
      },
    })

  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error'
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
