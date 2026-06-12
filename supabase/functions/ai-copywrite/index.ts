import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"
import {
  corsHeaders,
  type ModelResult,
  tryGeminiProvider,
  tryOpenAICompatibleProvider,
} from "../shared/model_router.ts"

const GOOGLE_AI_KEY = Deno.env.get('GOOGLE_AI_KEY') || ''
const GROQ_API_KEY = Deno.env.get('GROQ_API_KEY') || ''
const OPENROUTER_API_KEY = Deno.env.get('OPENROUTER_API_KEY') || ''
const DEEPSEEK_API_KEY = Deno.env.get('DEEPSEEK_API_KEY') || ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') || ''

async function tryGroq(p: string) {
  return tryOpenAICompatibleProvider('groq', GROQ_API_KEY, 'https://api.groq.com', ['llama-3.3-70b-versatile', 'mixtral-8x7b-32768'], p, { maxTokens: 4096, temperature: 0.7 });
}
async function tryOpenRouter(p: string) {
  return tryOpenAICompatibleProvider('openrouter', OPENROUTER_API_KEY, 'https://openrouter.ai/api', ['meta-llama/llama-3.1-8b-instruct', 'mistralai/mistral-7b-instruct'], p, { maxTokens: 4096, temperature: 0.7 });
}
async function tryDeepSeek(p: string) {
  return tryOpenAICompatibleProvider('deepseek', DEEPSEEK_API_KEY, 'https://api.deepseek.com', ['deepseek-chat'], p, { maxTokens: 4096, temperature: 0.7 });
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
    const authHeader = req.headers.get('Authorization')!
    const { data: { user }, error: authError } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''))
    if (authError || !user) throw new Error('Unauthorized')

    const { data: hasQuota, error: quotaError } = await supabase.rpc('check_ai_quota', { p_user_id: user.id })
    if (quotaError || !hasQuota) {
      return new Response(JSON.stringify({ error: 'AI credit limit reached.' }), {
        status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const { fieldType, context, tone, length } = await req.json()

    const prompt = `You are an expert Arabic conversion copywriter.
Write 3 variations for a ${fieldType} for a business with the following context:
${JSON.stringify(context)}

Tone: ${tone}
Target Length: ${length}

CRITICAL RULES:
1. Output MUST be valid JSON: {"variations": ["...", "...", "..."]}
2. Focus on high conversion and persuasive Arabic language.
3. Output ONLY the JSON, no other text.`

    // =========== MULTI-PROVIDER FALLBACK ===========
    const providers = [
      { name: 'gemini', fn: () => tryGeminiProvider(prompt, GOOGLE_AI_KEY, "application/json") },
      { name: 'groq', fn: () => tryGroq(prompt) },
      { name: 'openrouter', fn: () => tryOpenRouter(prompt) },
      { name: 'deepseek', fn: () => tryDeepSeek(prompt) },
    ];

    let result: ModelResult | null = null;
    for (const p of providers) {
      console.log(`Copywrite: trying ${p.name}`);
      result = await p.fn();
      if (result) break;
    }

    if (!result) throw new Error('All AI providers failed for copywriting.');

    const rawText = result.text;
    const match = rawText.match(/\{[\s\S]*\}/);
    const jsonStr = match ? match[0] : rawText;
    const parsed = JSON.parse(jsonStr);
    const variations = parsed.variations;

    if (!Array.isArray(variations) || variations.length === 0) {
      throw new Error('AI returned invalid variations format');
    }

    await supabase.from('ai_usage_log').insert({
      user_id: user.id,
      feature_type: 'copywriting'
    })

    return new Response(JSON.stringify({ variations, _provider: result.provider, _model: result.model }), {
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
