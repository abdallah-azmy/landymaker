import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const GOOGLE_AI_KEY = Deno.env.get('GOOGLE_AI_KEY') || ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') || ''
const PIXABAY_API_KEY = Deno.env.get('PIXABAY_API_KEY') || ''

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

async function fetchPixabayImage(query: string, type: string = 'photo'): Promise<string | null> {
  if (!PIXABAY_API_KEY) return null;
  try {
    const response = await fetch(`https://pixabay.com/api/?key=${PIXABAY_API_KEY}&q=${encodeURIComponent(query)}&image_type=${type}&per_page=5&safesearch=true`);
    const data = await response.json();
    if (data.hits && data.hits.length > 0) {
      const index = Math.floor(Math.random() * Math.min(data.hits.length, 5));
      return data.hits[index].webformatURL;
    }
  } catch (e) {
    console.error('Pixabay Error:', e);
  }
  return null;
}

async function resolvePixabayRequests(obj: any): Promise<any> {
  if (typeof obj !== 'object' || obj === null) return obj;

  if (Array.isArray(obj)) {
    for (let i = 0; i < obj.length; i++) {
      if (obj[i] && typeof obj[i] === 'object' && obj[i].pixabay_search) {
        const { query, type } = obj[i].pixabay_search;
        obj[i] = await fetchPixabayImage(query, type) || "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800";
      } else {
        obj[i] = await resolvePixabayRequests(obj[i]);
      }
    }
  } else {
    for (const key in obj) {
      const val = obj[key];
      if (val && typeof val === 'object' && val.pixabay_search) {
        const { query, type } = val.pixabay_search;
        const resolvedUrl = await fetchPixabayImage(query, type);
        if (resolvedUrl) {
          obj[key] = resolvedUrl;
        } else {
          obj[key] = "https://images.unsplash.com/photo-1497366216548-37526070297c?w=800";
        }
      } else {
        obj[key] = await resolvePixabayRequests(val);
      }
    }
  }
  return obj;
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

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

      if (count && count >= 5) {
        return new Response(JSON.stringify({ error: 'Guest limit reached. Please log in for more.' }), {
          status: 429,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        })
      }
    }

    const { businessName, businessType, location, language, offer, intent, currentDesign, instruction } = await req.json()

    let prompt = `You are an Omnipotent AI Designer for LandyMaker.
    Task: ${intent === 'edit' ? 'Surgically modify the existing page' : 'Generate a full landing page'}.
    Language: ${language}. Business: ${businessName} (${businessType}) in ${location}. Offer: ${offer}.

    ${intent === 'edit' ? `Current Design: ${JSON.stringify(currentDesign)}\nUser Instruction: ${instruction}` : ''}

    BLOCKS (Schema Reference):
    - global_theme: {primary, secondary, background, textPrimary, textSecondary, font_family, button_text_color}
    - hero / hero_saas: {title, subtitle, button_text, button_url, image_url, variant: 0-2 (0:Std, 1:Split, 2:Centered), animation}
    - features: {title, items: [{title, description, image_url, link_url}], variant: 0-2 (0:Grid, 1:Bento, 2:List)}
    - lead_form / lead_magnet: {title, subtitle, button_text, image_url, whatsapp_auto_open, whatsapp_number, whatsapp_message_template}
    - pricing: {title, items: [{name, prices: {monthly, yearly}, currency, features, button_text, is_popular}], variant: 0-2 (0:Grid, 1:Row, 2:Table)}
    - products: {title, items: [{id, name, description, price, image_url, button_text, category}], layout_style: "grid_2"|"grid_3"|"list"}
    - faq: {title, items: [{question, answer}]}
    - testimonials: {title, items: [{author, role, quote, image_url}]}
    - whatsapp: {title, phone_number, message, button_text}
    - trust_logos: {title, items: [url]}
    - animated_counter: {title, items: [{value, label, prefix, suffix}]}
    - statistics_grid: {title, subtitle, items: [{value, label, icon}]}
    - team_members: {title, subtitle, items: [{name, role, bio, image_url, socials: [{platform, url}]}]}
    - service_steps: {title, subtitle, items: [{title, description}]}
    - cta_banner: {title, subtitle, button_text, button_url}
    - comparison_table: {title, subtitle, plans, features}
    - video_embed: {title, video_url}
    - gallery: {title, items: [url], display_mode: "grid"|"slider", grid_columns: 1-4}
    - contact_info: {title, email, phone, location}

    PIXABAY API RULES:
    1. For any NEW image or if user asks for specific images (e.g., "change chips image"), you MUST NOT guess a URL.
    2. Instead, use: { "pixabay_search": { "query": "specific search terms", "type": "photo"|"illustration"|"vector" } }.
    3. For Avatars: use type="illustration" or type="photo" with query "avatar person".
    4. For Backgrounds: use specific textures or high-quality photos.

    CONVERSATIONAL FLOW:
    - If user asks to "change image of product X", find the block, identify the item, and use "pixabay_search" for its image_url.
    - If user says "make it an avatar", update the search type to "illustration" or "photo" with "avatar" keywords.

    SPECIAL ACTION: PIXABAY SELECTOR
    - If user asks to "choose a new image for X", and you want to give them multiple options, output:
      { "action": "pixabay_selection", "query": "search query", "type": "photo", "sectionIndex": number, "elementId": "item_id", "property": "image_url" }
      This will open a 9-choice grid for the user to pick from.

    RULES:
    1. Output strictly valid JSON.
    2. Optimize for LEADS. High urgency.
    3. Contrast: Ensure button_text_color works with secondary.
    4. VARIETY: Use variant (0-9).
    `;

    const response = await fetch(`https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=${GOOGLE_AI_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt + "\nGenerate JSON. Professional Arabic/English." }] }],
        generationConfig: {
          response_mime_type: "application/json",
          temperature: 0.7,
          topP: 0.8,
          topK: 40
        }
      }),
    })

    const result = await response.json()
    if (!result.candidates) throw new Error(result.error?.message || 'Gemini API Error')

    const rawText = result.candidates[0].content.parts[0].text
    let designJson = JSON.parse(rawText)

    // Resolve Pixabay Searches (Automatic)
    if (designJson.blocks) {
      designJson = await resolvePixabayRequests(designJson);
    }

    // 4. Log Usage
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
