import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY') || ''
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

    // 1. Auth check
    const authHeader = req.headers.get('Authorization')!
    const { data: { user }, error: authError } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''))
    if (authError || !user) throw new Error('Unauthorized')

    // Quota Check
    const { data: hasQuota, error: quotaError } = await supabase.rpc('check_ai_quota', { p_user_id: user.id })
    if (quotaError || !hasQuota) {
      return new Response(JSON.stringify({ error: 'AI credit limit reached.' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const { fieldType, context, tone, length } = await req.json()

    // 2. Construct Prompt
    const systemPrompt = `You are an expert Arabic conversion copywriter.
    Write 3 variations for a ${fieldType} for a business with the following context:
    ${JSON.stringify(context)}

    Tone: ${tone}
    Target Length: ${length}

    CRITICAL RULES:
    1. Output MUST be valid JSON: {"variations": ["...", "...", "..."]}
    2. Focus on high conversion and persuasive Arabic language.
    3. Respect the tone and length constraints.
    `;

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: 'Generate JSON variations.' }
        ],
        response_format: { type: 'json_object' }
      }),
    })

    const aiResult = await response.json()
    const variations = JSON.parse(aiResult.choices[0].message.content).variations

    // Log Usage
    await supabase.from('ai_usage_log').insert({
      user_id: user.id,
      feature_type: 'copywriting'
    })

    return new Response(JSON.stringify({ variations }), {
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
