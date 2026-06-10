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

    const {
      businessName,
      businessType,
      location,
      language,
      offer,
      intent,
      currentDesign,
      instruction,
      // NEW AGENT CONTEXT
      memory_summary,
      business_profile,
      builder_snapshot,
      recent_messages
    } = await req.json()

    let prompt = `You are an Omnipotent AI Agent Designer for LandyMaker.
    Task: ${intent === 'edit' ? 'Surgically modify the existing page' : 'Generate a full landing page'}.
    Language: ${language}.

    CONVERSATION CONTEXT:
    - Memory Summary: ${memory_summary || 'None'}
    - Business Profile: ${JSON.stringify(business_profile || {})}
    - Recent Messages: ${JSON.stringify(recent_messages || [])}

    BUILDER STATE (SNAPSHOT):
    - Current Sections: ${JSON.stringify(builder_snapshot?.sections || [])}
    - Current Theme: ${JSON.stringify(builder_snapshot?.theme || {})}

    ${intent === 'edit' ? `User Instruction: ${instruction}` : ''}
    ${intent === 'edit' && currentDesign ? `Relevant Design Context: ${JSON.stringify(currentDesign)}` : ''}

    AGENTIC RULES:
    1. If critical information (Business Name, Industry, Offer) is missing:
       - DO NOT FAIL.
       - Use placeholders like "[Business Name]".
       - Use "ask_question" action only if generation is absolutely impossible.
    2. If intent is "edit", you might receive only RELEVANT blocks with "_index" property.
       - Always return the FULL updated block if you modify it.
       - Keep the "_index" property in the output if it was provided, so the frontend can map it back.
    3. Respond with a JSON object containing:
       - "designJson": The updated design (if applicable).
       - "memory_summary_update": A new concise summary of what you learned about the user.
       - "business_profile_update": Any new details for the profile.
       - "action": "pixabay_selection" | "ask_question" | "none".
       - "assistant_message": What to say to the user in chat.

    BLOCKS (Schema Reference):
    - global_theme: {primary, secondary, background, textPrimary, textSecondary, font_family, button_text_color}
    - hero / hero_saas: {title, subtitle, button_text, button_url, image_url, variant: 0-2, animation}
    - features: {title, items: [{title, description, image_url, link_url}], variant: 0-2}
    - lead_form / lead_magnet: {title, subtitle, button_text, image_url, whatsapp_auto_open, whatsapp_number}
    - pricing: {title, items: [{name, prices: {monthly, yearly}, currency, features, button_text, is_popular}], variant: 0-2}
    - faq, testimonials, whatsapp, trust_logos, animated_counter, etc.

    PIXABAY API RULES:
    - For images, use: { "pixabay_search": { "query": "...", "type": "photo"|"illustration"|"vector" } }.
    - If user asks "choose for me" or "replace with doctors", you can also trigger:
      { "action": "pixabay_selection", "query": "doctors", "type": "photo", "sectionIndex": X, "elementId": "...", "property": "image_url" }
    `;

    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GOOGLE_AI_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt + "\n\nCRITICAL: Output ONLY a single valid JSON object. No markdown, no triple backticks. Start with { and end with }." }] }],
        generationConfig: {
          temperature: 0.7,
          topP: 0.8,
          topK: 40
        }
      }),
    })

    const result = await response.json()
    if (!result.candidates || result.candidates.length === 0) {
      console.error('Gemini API Error details:', result);
      throw new Error(result.error?.message || 'The AI model failed to generate a response. Please try again.');
    }

    let rawText = result.candidates[0].content.parts[0].text;

    // Safety: Strip potential markdown backticks if AI ignores prompt instructions
    rawText = rawText.replace(/```json/g, '').replace(/```/g, '').trim();

    let aiResponse;
    try {
      aiResponse = JSON.parse(rawText);
    } catch (parseError) {
      console.error('JSON Parse Error. Raw Text:', rawText);
      throw new Error('AI returned an invalid design format. Please try rephrasing your request.');
    }

    // Resolve Pixabay Searches (Automatic)
    if (aiResponse.designJson?.blocks) {
      aiResponse.designJson = await resolvePixabayRequests(aiResponse.designJson);
    }

    // 4. Log Usage
    const clientIp = req.headers.get('x-real-ip') || 'unknown'
    await supabase.from('ai_usage_log').insert({
      user_id: userId,
      ip_address: clientIp,
      feature_type: 'page_generation'
    })

    return new Response(JSON.stringify(aiResponse), {
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
