import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3"

const GOOGLE_AI_KEY = Deno.env.get('GOOGLE_AI_KEY') || ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') || ''
const PIXABAY_API_KEY = Deno.env.get('PIXABAY_API_KEY') || ''
let cachedModel: string | null = null;
let lastFetchTime = 0;
const CACHE_TTL = 30 * 60 * 1000; // 30 minutes cache

async function getBestActiveModel(apiKey: string): Promise<string> {
  const now = Date.now();
  if (cachedModel && (now - lastFetchTime < CACHE_TTL)) {
    console.log(`Using cached active model: ${cachedModel}`);
    return cachedModel;
  }

  try {
    console.log("Fetching supported models from Gemini ModelService...");
    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`);
    if (!response.ok) {
      throw new Error(`Failed to list models: ${response.statusText}`);
    }
    const data = await response.json();
    const modelsList = data.models || [];

    // Preference ranking for flash models
    const preferenceOrder = [
      'gemini-2.5-flash',
      'gemini-1.5-flash-latest',
      'gemini-1.5-flash',
      'gemini-2.0-flash-exp',
      'gemini-2.0-flash'
    ];

    // Filter models that support generateContent and are gemini models
    const activeModels = modelsList
      .filter((m: any) =>
        m.supportedGenerationMethods?.includes('generateContent') &&
        m.name?.startsWith('models/gemini-')
      )
      .map((m: any) => m.name.replace('models/', ''));

    console.log("Active Gemini models found:", activeModels);

    let bestModel = '';
    for (const pref of preferenceOrder) {
      if (activeModels.includes(pref)) {
        bestModel = pref;
        break;
      }
    }

    if (!bestModel && activeModels.length > 0) {
      const flashModel = activeModels.find((name: string) => name.includes('flash'));
      bestModel = flashModel || activeModels[0];
    }

    if (!bestModel) {
      bestModel = 'gemini-1.5-flash-latest';
    }

    cachedModel = bestModel;
    lastFetchTime = now;
    console.log(`Selected and cached best active model: ${bestModel}`);
    return bestModel;
  } catch (e) {
    console.error("Failed to query ModelService, falling back to gemini-1.5-flash-latest", e);
    return 'gemini-1.5-flash-latest';
  }
}

async function fetchWithRetry(url: string, options: RequestInit, retries = 2, delay = 1000): Promise<Response> {
  for (let i = 0; i < retries; i++) {
    const res = await fetch(url, options);
    
    // Check for HTTP rate limit (429) or service unavailable (503)
    if (res.status === 429 || res.status === 503) {
      console.warn(`Attempt ${i + 1} returned status ${res.status}. Retrying in ${delay}ms...`);
      await new Promise(resolve => setTimeout(resolve, delay));
      delay *= 1.5;
      continue;
    }

    // Check for transient API error in response body
    const clone = res.clone();
    try {
      const json = await clone.json();
      if (json.error?.message?.includes("high demand") || json.error?.message?.includes("quota") || json.error?.message?.includes("Quota exceeded")) {
        console.warn(`Attempt ${i + 1} failed with transient API error: ${json.error.message}. Retrying in ${delay}ms...`);
        await new Promise(resolve => setTimeout(resolve, delay));
        delay *= 1.5;
        continue;
      }
    } catch (e) {
      // Ignore non-json or parsing errors
    }

    return res;
  }
  return await fetch(url, options);
}

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

/**
 * SMARTEST JSON EXTRACTOR
 * Finds the first '{' and balances braces to extract a valid JSON object
 * from a string that might contain markdown or conversational text.
 */
function extractJson(text: string): any {
  try {
    // Check for markdown code blocks first
    const match = text.match(/```json\s*([\s\S]*?)\s*```/);
    const cleanedText = match ? match[1] : text;

    const start = cleanedText.indexOf('{');
    if (start === -1) return null;

    let balance = 0;
    let end = -1;
    for (let i = start; i < cleanedText.length; i++) {
      if (cleanedText[i] === '{') balance++;
      if (cleanedText[i] === '}') {
        balance--;
        if (balance === 0) {
          end = i;
          break;
        }
      }
    }

    if (end === -1) return null;

    const jsonString = cleanedText.substring(start, end + 1);
    return JSON.parse(jsonString);
  } catch (e) {
    console.error('Extraction Error:', e);
    return null;
  }
}

async function resolvePixabayRequests(obj: any): Promise<any> {
  if (typeof obj !== 'object' || obj === null) return obj;

  if (Array.isArray(obj)) {
    const promises = obj.map(async (item) => {
      if (item && typeof item === 'object' && item.pixabay_search) {
        const { query, type } = item.pixabay_search;
        return await fetchPixabayImage(query, type) || "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800";
      }
      return await resolvePixabayRequests(item);
    });
    return await Promise.all(promises);
  } else {
    const keys = Object.keys(obj);
    const promises = keys.map(async (key) => {
      const val = obj[key];
      if (val && typeof val === 'object' && val.pixabay_search) {
        const { query, type } = val.pixabay_search;
        const resolvedUrl = await fetchPixabayImage(query, type);
        return { key, val: resolvedUrl || "https://images.unsplash.com/photo-1497366216548-37526070297c?w=800" };
      }
      const resolved = await resolvePixabayRequests(val);
      return { key, val: resolved };
    });

    const results = await Promise.all(promises);
    const newObj: any = {};
    results.forEach(({ key, val }) => {
      newObj[key] = val;
    });
    return newObj;
  }
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

    const bestModel = await getBestActiveModel(GOOGLE_AI_KEY);
    const candidateModels = [
      bestModel,
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-3.5-flash',
      'gemini-1.5-flash-latest',
      'gemini-1.5-flash',
      'gemini-2.0-flash-exp'
    ].filter((value, index, self) => self.indexOf(value) === index);

    let result: any = null;
    const modelErrors: Record<string, string> = {};
    let selectedModel = '';

    for (const model of candidateModels) {
      try {
        console.log(`Trying Gemini model: ${model}`);
        const res = await fetchWithRetry(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GOOGLE_AI_KEY}`, {
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
        });

        const resJson = await res.json();

        if (resJson.error) {
          console.warn(`Model ${model} failed:`, resJson.error.message);
          modelErrors[model] = resJson.error.message;
          continue;
        }

        if (resJson.candidates && resJson.candidates.length > 0) {
          result = resJson;
          selectedModel = model;
          console.log(`Successfully generated content using model: ${selectedModel}`);
          break;
        } else {
          console.warn(`Model ${model} returned empty candidates:`, resJson);
          modelErrors[model] = 'No candidates returned';
        }
      } catch (e: any) {
        console.warn(`Fetch with model ${model} threw exception:`, e);
        modelErrors[model] = e.message || String(e);
      }
    }

    if (!result) {
      const keyPrefix = GOOGLE_AI_KEY ? GOOGLE_AI_KEY.substring(0, 10) : 'EMPTY';
      const keySuffix = GOOGLE_AI_KEY && GOOGLE_AI_KEY.length > 4 ? GOOGLE_AI_KEY.substring(GOOGLE_AI_KEY.length - 4) : 'EMPTY';
      const keyLen = GOOGLE_AI_KEY ? GOOGLE_AI_KEY.length : 0;
      throw new Error(`AI_GENERATION_FAILED: All models failed. Key fingerprint: ${keyPrefix}...${keySuffix} (Len: ${keyLen}). Details: ${JSON.stringify(modelErrors)}`);
    }

    const rawText = result.candidates[0].content.parts[0].text;
    const aiResponse = extractJson(rawText);

    if (!aiResponse) {
      console.error('JSON Parse Error. Raw Text:', rawText);
      throw new Error('AI_INVALID_FORMAT');
    }

    // Normalize and Resolve Pixabay Searches (Automatic)
    if (aiResponse.designJson) {
      if (aiResponse.designJson.sections && !aiResponse.designJson.blocks) {
        aiResponse.designJson.blocks = aiResponse.designJson.sections;
        delete aiResponse.designJson.sections;
      }
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
    // UNIFIED ERROR RESPONSE
    const errorMap: Record<string, string> = {
      'AI_LIMIT_REACHED': 'لقد استهلكت رصيدك المتاح لهذا الشهر.',
      'AI_GENERATION_FAILED': 'فشل المساعد في توليد الرد. حاول صياغة الطلب بشكل أبسط.',
      'AI_INVALID_FORMAT': 'حدث خطأ في تنسيق البيانات الواردة من الـ AI. يرجى المحاولة مرة أخرى.',
    };

    let userFriendlyError = errorMap[error.message] || error.message || 'حدث خطأ غير متوقع';
    if (error.message && error.message.startsWith('AI_GENERATION_FAILED:')) {
      userFriendlyError = `فشل توليد الرد من Gemini: ${error.message.replace('AI_GENERATION_FAILED: ', '')}`;
    }

    return new Response(JSON.stringify({
      error: userFriendlyError
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  }
})
