import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const GOOGLE_AI_KEY = Deno.env.get('GOOGLE_AI_KEY') || ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') || ''

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

    // 1. Auth & Limits Check
    const authHeader = req.headers.get('Authorization')
    let userId: string | null = null

    if (authHeader) {
      const { data: { user }, error: authError } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''))
      if (!authError && user) {
        userId = user.id
      }
    }

    if (userId) {
      const { data: hasQuota, error: quotaError } = await supabase.rpc('check_ai_quota', { p_user_id: userId })
      if (quotaError || !hasQuota) {
        return new Response(JSON.stringify({ error: 'AI generation limit reached for this month.' }), {
          status: 403,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
    } else {
      const clientIp = req.headers.get('x-real-ip') || 'unknown'
      const { count } = await supabase
        .from('ai_usage_log')
        .select('*', { count: 'exact', head: true })
        .eq('ip_address', clientIp)
        .gt('created_at', new Date(Date.now() - 3600000).toISOString())

      if (count && count >= 5) { // Increased to 5 for smoother testing
        return new Response(JSON.stringify({ error: 'Guest limit reached. Please log in for more.' }), {
          status: 429,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
    }

    const { businessName, businessType, location, language, offer, intent, currentDesign, instruction } = await req.json()

    // 2. Advanced Gemini Prompt (Conversational & Diverse)
    let prompt = `You are a Conversion Rate Optimization (CRO) and Web Architect expert for the Arabic market.
    Task: ${intent === 'edit' ? 'Modify the existing page' : 'Generate a new page'}.
    Context: ${businessName} (${businessType}) in ${location}.
    Language: ${language}. Target Offer: ${offer}.

    ${intent === 'edit' ? `Current Design: ${JSON.stringify(currentDesign)}\nUser Instruction: ${instruction}` : ''}

    BLOCKS (Schema Reference):
    - hero: {title, subtitle, button_text, button_url, image_url, variant: 0-2}
    - features: {title, items: [{title, description, icon}], variant: 0-9}
    - lead_form: {title, button_text, whatsapp_auto_open: bool, whatsapp_number, whatsapp_message_template}
    - pricing: {title, items: [{name, price, features: []}], variant: 0-9}
    - faq: {title, items: [{question, answer}]}
    - testimonials: {title, items: [{author, role, quote, image_url}]}
    - whatsapp: {title, phone_number, message, button_text}
    - trust_logos: {title, items: [url]}
    - animated_counter: {title, items: [{value, label, prefix, suffix}]}
    - cta_banner: {title, subtitle, button_text}
    - comparison_table: {title, plans: [{name, price}], features: [{name, values: []}]}

    RULES:
    1. Output strictly valid JSON with root key "blocks": [].
    2. Optimize for LEADS. High urgency, clear CTAs.
    3. Use PAS or AIDA frameworks.
    4. For images: https://images.unsplash.com/photo-[ID]?w=800&q=80.
    5. VARIETY: Use different variants (0-9) to avoid repetitive looks.
    `;

    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GOOGLE_AI_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt + "\nGenerate only JSON. Professional Arabic/English copy." }] }],
        generationConfig: { response_mime_type: "application/json" }
      }),
    })

    const result = await response.json()
    if (!result.candidates) throw new Error(result.error?.message || 'Gemini API Error')

    const rawText = result.candidates[0].content.parts[0].text
    const designJson = JSON.parse(rawText)

    // 3. Log Usage
    const clientIp = req.headers.get('x-real-ip') || 'unknown'
    await supabase.from('ai_usage_log').insert({
      user_id: userId,
      ip_address: clientIp,
      feature_type: 'page_generation'
    })

    return new Response(JSON.stringify({ designJson }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
