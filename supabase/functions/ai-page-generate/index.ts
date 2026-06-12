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
const PIXABAY_API_KEY = Deno.env.get('PIXABAY_API_KEY') || ''

// =========== PROVIDER WRAPPERS ===========
async function tryGroqProvider(prompt: string): Promise<ModelResult | null> {
  return tryOpenAICompatibleProvider(
    'groq', GROQ_API_KEY, 'https://api.groq.com',
    ['llama-3.3-70b-versatile', 'mixtral-8x7b-32768', 'gemma2-9b-it'],
    prompt
  );
}

async function tryOpenRouterProvider(prompt: string): Promise<ModelResult | null> {
  return tryOpenAICompatibleProvider(
    'openrouter', OPENROUTER_API_KEY, 'https://openrouter.ai/api',
    ['meta-llama/llama-3.1-8b-instruct', 'mistralai/mistral-7b-instruct', 'cognitivecomputations/dolphin-mixtral-8x7b'],
    prompt
  );
}

async function tryDeepSeekProvider(prompt: string): Promise<ModelResult | null> {
  return tryOpenAICompatibleProvider(
    'deepseek', DEEPSEEK_API_KEY, 'https://api.deepseek.com',
    ['deepseek-chat'],
    prompt
  );
}

// =========== PIXABAY ===========
const BLOCK_IMAGE_TYPE_MAP: Record<string, { recommendedType: string; recommendedOrientation: string; category?: string; description: string }> = {
  'hero':               { recommendedType: 'photo',        recommendedOrientation: 'horizontal', description: 'عرض خلفية عريض' },
  'hero_saas':          { recommendedType: 'illustration', recommendedOrientation: 'horizontal', description: 'رسم توضيحي تقني للواجهة' },
  'features':           { recommendedType: 'illustration', recommendedOrientation: 'square',    description: 'أيقونات / صور توضيحية للميزات' },
  'products':           { recommendedType: 'photo',        recommendedOrientation: 'square',    description: 'صور منتجات' },
  'testimonials':       { recommendedType: 'photo',        recommendedOrientation: 'portrait',  category: 'people', description: 'صور أشخاص / آراء العملاء' },
  'gallery':            { recommendedType: 'photo',        recommendedOrientation: 'horizontal', description: 'معرض صور' },
  'team_members':       { recommendedType: 'photo',        recommendedOrientation: 'square',    category: 'people', description: 'صور فريق العمل' },
  'lead_magnet':        { recommendedType: 'illustration', recommendedOrientation: 'horizontal', description: 'صورة جانبية للمحتوى الحصري' },
  'bg_image_url':       { recommendedType: 'photo',        recommendedOrientation: 'horizontal', description: 'خلفية واسعة للقسم' },
  'logo_header':        { recommendedType: 'vector',       recommendedOrientation: 'square',    description: 'شعار الموقع' },
  'cta_banner':         { recommendedType: 'photo',        recommendedOrientation: 'horizontal', description: 'خلفية لدعوة المستخدم للإجراء' },
  'service_steps':      { recommendedType: 'illustration', recommendedOrientation: 'square',    description: 'صور توضيحية لخطوات الخدمة' },
  'animated_counter':   { recommendedType: 'illustration', recommendedOrientation: 'square',    description: 'أيقونات خلفية للعدادات' },
  'statistics_grid':    { recommendedType: 'illustration', recommendedOrientation: 'square',    description: 'أيقونات إحصائية' },
  'comparison_table':   { recommendedType: 'illustration', recommendedOrientation: 'square',    description: 'صورة توضيحية للمقارنة' },
};

interface PixabayCacheEntry { urls: string[]; timestamp: number; }

async function fetchPixabayImageWithCache(
  query: string, type: string, indexInSequence: number,
  searchCache: Record<string, PixabayCacheEntry>, limit: number,
  orientation?: string, quality?: string
): Promise<string | null> {
  if (!PIXABAY_API_KEY) return null;
  const cacheKey = `${query}_${type}_${orientation || 'all'}`;
  const PIXABAY_CACHE_TTL = 10 * 60 * 1000;
  try {
    const cached = searchCache[cacheKey];
    if (cached && (Date.now() - cached.timestamp < PIXABAY_CACHE_TTL)) {
      const urls = cached.urls;
      if (urls.length > 0) return urls[indexInSequence % urls.length];
    }

    const perPage = Math.max(3, Math.min(limit, 200));
    let url = `https://pixabay.com/api/?key=${PIXABAY_API_KEY}&q=${encodeURIComponent(query)}&image_type=${type}&per_page=${perPage}&safesearch=true`;
    if (orientation) url += `&orientation=${orientation}`;
    if (BLOCK_IMAGE_TYPE_MAP[query]?.category) url += `&category=${BLOCK_IMAGE_TYPE_MAP[query].category}`;

    const response = await fetch(url);
    const data = await response.json();

    const qualityField = quality === 'fullHDURL' ? 'fullHDURL'
                       : quality === 'largeImageURL' ? 'largeImageURL'
                       : 'webformatURL';

    let hits: string[] = data.hits?.length > 0
      ? data.hits.map((h: any) => h[qualityField] || h.webformatURL).filter(Boolean)
      : [];

    if (hits.length === 0 && orientation) {
      const fallbackUrl = `https://pixabay.com/api/?key=${PIXABAY_API_KEY}&q=${encodeURIComponent(query)}&image_type=${type}&per_page=${perPage}&safesearch=true`;
      const fallbackResponse = await fetch(fallbackUrl);
      const fallbackData = await fallbackResponse.json();
      hits = fallbackData.hits?.length > 0
        ? fallbackData.hits.map((h: any) => h[qualityField] || h.webformatURL).filter(Boolean)
        : [];

      if (hits.length === 0) {
        const genericKeywords = ['business', 'website', 'studio', 'office', 'professional'];
        for (const kw of genericKeywords) {
          const genericUrl = `https://pixabay.com/api/?key=${PIXABAY_API_KEY}&q=${encodeURIComponent(kw)}&image_type=${type}&per_page=3&safesearch=true`;
          const genericResponse = await fetch(genericUrl);
          const genericData = await genericResponse.json();
          if (genericData.hits?.length > 0) {
            hits = genericData.hits.map((h: any) => h[qualityField] || h.webformatURL).filter(Boolean);
            break;
          }
        }
      }
    }

    searchCache[cacheKey] = { urls: hits, timestamp: Date.now() };
    if (hits.length > 0) return hits[indexInSequence % hits.length];
  } catch (e) {
    console.error('Pixabay Error:', e);
  }
  return null;
}

function extractJson(text: string): any {
  try {
    const match = text.match(/```json\s*([\s\S]*?)\s*```/);
    const cleanedText = match ? match[1] : text;
    const start = cleanedText.indexOf('{');
    if (start === -1) return null;
    let balance = 0, end = -1;
    for (let i = start; i < cleanedText.length; i++) {
      if (cleanedText[i] === '{') balance++;
      if (cleanedText[i] === '}') {
        balance--;
        if (balance === 0) { end = i; break; }
      }
    }
    if (end === -1) return null;
    return JSON.parse(cleanedText.substring(start, end + 1));
  } catch (e) {
    console.error('JSON extraction error:', e);
    return null;
  }
}

function countQueryOccurrences(obj: any): Record<string, number> {
  const counts: Record<string, number> = {};
  function scan(node: any) {
    if (typeof node !== 'object' || node === null) return;
    if (Array.isArray(node)) { node.forEach(scan); return; }
    if (node.pixabay_search) {
      const { query, type } = node.pixabay_search;
      counts[`${query}_${type || 'photo'}`] = (counts[`${query}_${type || 'photo'}`] || 0) + 1;
    }
    Object.keys(node).forEach(key => scan(node[key]));
  }
  scan(obj);
  return counts;
}

async function resolvePixabayRequests(obj: any, sendEvent?: (data: any) => void): Promise<any> {
  const queryCounters: Record<string, number> = {};
  const searchCache: Record<string, PixabayCacheEntry> = {};
  const queryCounts = countQueryOccurrences(obj);

  async function resolveNode(node: any): Promise<any> {
    if (typeof node !== 'object' || node === null) return node;
    if (Array.isArray(node)) return Promise.all(node.map(resolveNode));

    const keys = Object.keys(node);
    const results = await Promise.all(keys.map(async (key) => {
      const val = node[key];
      if (val && typeof val === 'object' && val.pixabay_search) {
        const { query, type, orientation, quality } = val.pixabay_search;
        const searchType = type || 'photo';
        const counterKey = `${query}_${searchType}_${orientation || 'all'}`;
        const index = queryCounters[counterKey] || 0;
        queryCounters[counterKey] = index + 1;
        const limit = queryCounts[`${query}_${searchType}`] || 5;
        const resolvedUrl = await fetchPixabayImageWithCache(
          query, searchType, index, searchCache, limit, orientation, quality
        );
        return { key, val: resolvedUrl || "https://images.unsplash.com/photo-1497366216548-37526070297c?w=800" };
      }
      const resolved = await resolveNode(val);
      return { key, val: resolved };
    }));

    const newObj: any = {};
    results.forEach(({ key, val }) => { newObj[key] = val; });
    return newObj;
  }

  return resolveNode(obj);
}

function buildPrompt(params: {
  intent: string; language: string; memory_summary: any; business_profile: any;
  recent_messages: any; builder_snapshot: any; instruction: string; currentDesign: any
}): string {
  const {
    intent, language, memory_summary, business_profile,
    recent_messages, builder_snapshot, instruction, currentDesign
  } = params;

  return `You are an Omnipotent AI Agent Designer for LandyMaker.
Task: ${intent === 'edit' ? 'Surgically modify the existing page' : intent === 'rewrite' ? 'Rewrite copy/text on the existing page' : 'Generate a full landing page'}.
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
0. TOKEN EFFICIENCY: Always prefer the most token-efficient response. Use copy_update for text-only changes, _index partial updates for small design edits, and full designJson only for major structural changes. Keep memory_summary_update concise.
1. If critical information (Business Name, Industry, Offer) is missing:
   - DO NOT FAIL.
   - Use placeholders like "[Business Name]".
   - Use "ask_question" action only if generation is absolutely impossible.
2. If intent is "edit" or "generate", you MUST ALWAYS return a non-null, valid "designJson" JSON Object. Leaving "designJson" out or null, or returning it as a JSON Array of blocks instead of a JSON Object with "global_theme" and "blocks" keys, is strictly forbidden.
3. If intent is "rewrite" or the user asks to improve/change text, prefer returning "copy_update" action (with "copy_updates" array) instead of full "designJson". Only fall back to full designJson if the rewrite requires structural changes.
4. If intent is "edit", you MUST perform SURGICAL EDITS:
   - You MAY use PARTIAL UPDATES via "_index" on each block: {"_index": 2, "title": "New Title"} to update only block at index 2 without resending all blocks.
   - If using _index, ONLY include changed blocks with their _index. Do NOT include unchanged blocks.
   - You can also add NEW blocks by setting _index equal to the current blocks length.
    - If NOT using partial updates, return the FULL design with ALL blocks preserved.
5. RESPONSE FORMAT: Respond with a JSON object containing:
   - "designJson": The full/paginated design JSON Object.
   - "memory_summary_update": A new concise summary of what you learned about the user.
   - "business_profile_update": Any new details for the profile.
    - "action": "pixabay_selection" | "copy_update" | "ask_question" | "none".
    - Use "copy_update" when user asks to rewrite/improve specific text (e.g. "حسن النصوص", "غير العنوان", "اكتب وصف أفضل").
    - When action is "copy_update", provide "copy_updates" array instead of "designJson".
   - "assistant_message": What to say to the user in chat.

PAGE-LEVEL CONFIG:
- "sticky_cta": {is_enabled: bool, text: string, button_text: string, button_action_type: "link"|"checkout", button_action_value: string}
- "page_title": string (SEO title)
- "meta_description": string (SEO description)

COPY UPDATE ACTION (when action="copy_update"):
- "copy_updates": [
    {"sectionIndex": <int>, "field": "<block_property>", "value": "<new_text>"}
  ]
- For nested items within a block:
    {"sectionIndex": <int>, "itemIndex": <int>, "field": "<item_property>", "value": "<new_text>"}
- Examples:
  • Update hero title:  {"sectionIndex": 0, "field": "title", "value": "عنوان جديد"}
  • Update feature item: {"sectionIndex": 1, "itemIndex": 0, "field": "description", "value": "وصف جديد"}
  • Update testimonial quote: {"sectionIndex": 2, "itemIndex": 1, "field": "quote", "value": "اقتباس جديد"}

GLOBAL THEME (designJson.global_theme):
{primary: hex, secondary: hex, background: hex, textPrimary: hex, textSecondary: hex, font_family: string, button_text_color: hex, globalBgColorHex: hex, globalBgImageUrl: string}

GLOBAL BLOCK PROPERTIES (every block type supports these):
- type: string (required - block type identifier)
- title: string (section heading)
- variant: int 0-9 (layout variant, default 0)
- animation: {type: "fadeIn"|"slideUp"|"slideLeft"|"zoomIn"|"flip", duration: int ms, delay: int ms}
- fontFamily: string (override font for this block)
- bg_image_url: string (background image, use pixabay_search format)
- bg_overlay_opacity: float 0.0-1.0 (overlay on bg image, default 0.4)
- bg_overlay_color: string hex (overlay color)
- bg_blur: float (background blur)
- is_visible: bool (default true)

PIXABAY BLOCK-TO-IMAGE-TYPE MAP (reference for choosing type/orientation per block):
- hero:         type=photo,        orientation=horizontal  // خلفية عرضية
- hero_saas:    type=illustration,  orientation=horizontal  // رسم توضيحي تقني
- features:     type=illustration,  orientation=square      // أيقونات توضيحية
- products:     type=photo,         orientation=square      // صور منتجات
- testimonials: type=photo,         orientation=portrait    // صور أشخاص (portrait/face)
- gallery:      type=photo,         orientation=horizontal  // معرض صور
- team_members: type=photo,         orientation=square      // صور فريق عمل
- lead_magnet:  type=illustration,  orientation=horizontal  // صورة جانبية
- bg_image_url: type=photo,         orientation=horizontal  // خلفية واسعة
- logo_header:  type=vector,        orientation=square      // شعار
- cta_banner:   type=photo,         orientation=horizontal  // خلفية CTA
- service_steps: type=illustration, orientation=square      // خطوات الخدمة
- comparison_table: type=illustration, orientation=square   // صورة مقارنة

COMPLETE BLOCK SCHEMA REFERENCE:

=== hero ===
{title, subtitle, button_text, button_url, image_url, vertical_padding: 0-300, variant: 0-2}

=== hero_saas ===
{title, subtitle, button_text, button_url, image_url, vertical_padding: 0-300}

=== features ===
{title, layout_style: "grid"|"bento", variant: 0-2,
 items: [{title, description, image_url, link_url}]}

=== products ===
{title, layout_style: "grid_2"|"grid_3", whatsapp_number, show_category_filter: bool, categories: [string],
 items: [{id, name, price, description, image_url, button_text, purchase_url, category}]}

=== pricing (v1 - legacy) ===
{title, schema_version: 1, variant: 0-2,
 items: [{name, price, features: [string], is_popular: bool}]}

=== pricing (v2 - toggle) ===
{title, subtitle, schema_version: 2, has_toggle: true, variant: 0-2,
 toggle_labels: {monthly: "شهري", yearly: "سنوي"},
 items: [{plan_id, name, prices: {monthly: num, yearly: num}, currency, periods: {monthly, yearly},
          discount_mode: "hidden"|"auto"|"manual", manual_discount_text, features: [string],
          button_text, button_action_type: "link"|"checkout", button_action_value, is_popular}]}

=== testimonials ===
{title, items: [{author, role, quote, image_url}]}

=== faq ===
{title, items: [{question, answer, image_url}]}

=== gallery ===
{title, display_mode: "grid"|"carousel"|"masonry", grid_columns: 1-6,
 items: [image_url_string], gallery_links: [url_string]}

=== contact_info ===
{title, email, phone, location, phone_icon, email_icon, location_icon}

=== video_embed ===
{title, subtitle, video_url, aspect_ratio: "16:9"|"4:3"|"1:1"|"9:16", max_width, use_thumbnail: bool, thumbnail_url, autoplay: bool, show_controls: bool}

=== logo_header ===
{title, logo_url, logo_height: num, alignment: "left"|"center"|"right"}

=== lead_form ===
{title, button_text, whatsapp_auto_open: bool, whatsapp_number, whatsapp_message_template,
 fields: [{field_id, field_type: "text"|"email"|"phone"|"textarea"|"select", label, placeholder, is_required: bool, options: [{value, label}], validation: {min_length}}]}

=== lead_magnet ===
{title, subtitle, button_text, image_url, whatsapp_auto_open: bool, whatsapp_number, whatsapp_message_template,
 fields: [same as lead_form fields]}

=== multi_step_lead_form ===
{title, subtitle, success_message, enable_local_save: bool, schema_version, whatsapp_auto_open, whatsapp_number, whatsapp_message_template,
 steps: [{step_id, step_title, fields: [same as lead_form fields]}]}

=== working_hours ===
{title, schedule: {day_label: "time_range"}}

=== location_map ===
{title, address, map_iframe_url}

=== trust_logos ===
{title, items: [logo_image_url_string]}

=== animated_counter ===
{title, items: [{value, label, prefix, suffix}]}

=== social_qr ===
{title, subtitle, links: [{platform: "website"|"instagram"|"facebook"|"twitter"|"linkedin"|"whatsapp", url, image_url}]}

=== qr_code ===
{title, subtitle, qr_payload, qr_size: 100-350}

=== whatsapp ===
{title, phone_number, message, button_text}

=== basic_section ===
{title, layout_direction: "column"|"row", spacing: 0-100, vertical_padding, main_axis_alignment: "start"|"center"|"end"|"spaceBetween", cross_axis_alignment: "start"|"center"|"end"|"stretch",
 elements: [{id, type: "text"|"image", content, url, width, height, fit, style_overrides: {}}]}

=== statistics_grid ===
{title, subtitle, items: [{value, label, icon: "people"|"star"|"check"|"trending"|"business"|"thumb_up"|"public"|"speed"|"favorite"}]}

=== team_members ===
{title, subtitle, items: [{name, role, bio, image_url, socials: [{platform: "linkedin"|"instagram"|"twitter"|"facebook", url}]}]}

=== service_steps ===
{title, subtitle, items: [{title, description}]}

=== cta_banner ===
{title, subtitle, button_text, button_url, secondary_button_text, secondary_button_url}

=== comparison_table ===
{title, subtitle, plans: [{name, price}], features: [{name, values: [bool_per_plan]}]}

PIXABAY API RULES (STRICTLY REQUIRED):
1. You are FORBIDDEN from generating raw string URLs for image properties. Use pixabay_search format ALWAYS.
2. ENHANCED pixabay_search format:
   { "pixabay_search": {
       "query": "<search keyword>",
       "type": "photo"|"illustration"|"vector",
       "orientation": "horizontal"|"vertical"|"square"|"portrait",
       "quality": "webformatURL"|"largeImageURL"|"fullHDURL",
       "category": "nature"|"people"|"business"|"technology"|"health"|"education"|"food"|"travel"
     }
   }
3. Choose "type" and "orientation" per the BLOCK-TO-IMAGE-TYPE MAP above.
4. INDUSTRY-AWARE QUERIES: Always combine the block context with the user's industry/offer.
5. BILINGUAL QUERIES: Use the prompt's language. For Arabic prompts, search in Arabic keywords.
6. For lists with multiple items (products, team, features), write a distinct specific query per item.
7. QUALITY: Use "largeImageURL" as default quality for hero and bg_image blocks, "webformatURL" for thumbnails.
8. If user asks "choose for me" or "replace with <topic>", you can trigger:
   { "action": "pixabay_selection", "query": "<topic>", "type": "photo", "orientation": "...",
     "sectionIndex": X, "elementId": "...", "property": "image_url" }

CRITICAL: Output ONLY a single valid JSON object. No markdown, no triple backticks. Start with { and end with }.`;
}

// =========== MAIN HANDLER ===========
serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  const encoder = new TextEncoder()
  let cancelled = false
  req.signal.addEventListener('abort', () => { cancelled = true })

  const stream = new ReadableStream({
    async start(controller) {
      const send = (data: any) => {
        if (cancelled) return
        controller.enqueue(encoder.encode(`data: ${JSON.stringify(data)}\n\n`))
      }

      try {
        // ---- Auth & Quota ----
        send({ type: 'status', message: 'جاري التحقق من حسابك...' })

        const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

        const authHeader = req.headers.get('Authorization')
        let userId: string | null = null

        if (authHeader) {
          const { data: { user }, error: authError } = await supabase.auth.getUser(authHeader.replace('Bearer ', ''))
          if (!authError && user) userId = user.id
        }

        if (userId) {
          const { data: hasQuota } = await supabase.rpc('check_ai_quota', { p_user_id: userId })
          if (!hasQuota) {
            send({ type: 'error', message: 'لقد استهلكت رصيدك المتاح لهذا الشهر.', canRetry: false })
            controller.close()
            return
          }
        } else {
          const clientIp = req.headers.get('x-real-ip') || 'unknown'
          const { count } = await supabase
            .from('ai_usage_log')
            .select('*', { count: 'exact', head: true })
            .eq('ip_address', clientIp)
            .gt('created_at', new Date(Date.now() - 3600000).toISOString())

          if (count && count >= 5) {
            send({ type: 'error', message: 'وصلت للحد الأقصى للزوار (5) لهذه الساعة. سجل الدخول لاستخدام غير محدود.', canRetry: false })
            controller.close()
            return
          }
        }

        // ---- Parse Payload ----
        send({ type: 'status', message: 'جاري تحليل طلبك...' })

        const {
          language, intent, currentDesign, instruction,
          memory_summary, business_profile, builder_snapshot, recent_messages
        } = await req.json()

        const prompt = buildPrompt({
          intent: intent || 'generate',
          language: language || 'ar',
          memory_summary,
          business_profile,
          recent_messages,
          builder_snapshot,
          instruction: instruction || '',
          currentDesign
        })

        // ---- Multi-Provider Fallback ----
        const tryGemini = (p: string) => tryGeminiProvider(p, GOOGLE_AI_KEY)

        const providers: Array<{ name: string; tryFn: (p: string) => Promise<ModelResult | null> }> = [
          { name: 'gemini', tryFn: tryGemini },
          { name: 'groq', tryFn: tryGroqProvider },
          { name: 'openrouter', tryFn: tryOpenRouterProvider },
          { name: 'deepseek', tryFn: tryDeepSeekProvider },
        ]

        let result: ModelResult | null = null
        const providerErrors: string[] = []

        for (const provider of providers) {
          send({ type: 'status', message: `جاري الاتصال بـ ${provider.name}...` })
          const res = await provider.tryFn(prompt)
          if (res) {
            result = res
            send({ type: 'status', message: `تم الرد من ${res.provider} ✓` })
            break
          }
          const msg = `${provider.name} لم يستجب`
          providerErrors.push(msg)
          send({ type: 'status', message: `${provider.name} غير متاح، جرب下一个...` })
        }

        if (!result) {
          const allMsg = `تعذر توليد الرد من جميع مزودي الذكاء الاصطناعي.`
          send({ type: 'error', message: allMsg, canRetry: true })
          controller.close()
          return
        }

        // ---- Parse AI Response ----
        send({ type: 'status', message: 'جاري معالجة رد الذكاء الاصطناعي...' })

        const rawText = result.text
        const aiResponse = extractJson(rawText)

        if (!aiResponse) {
          console.error(`JSON Parse Error from ${result.provider} (${result.model}). Raw:`, rawText.substring(0, 500))
          send({ type: 'error', message: 'استجاب الذكاء الاصطناعي بتنسيق غير صالح. حاول مرة أخرى.', canRetry: true })
          controller.close()
          return
        }

        // ---- Resolve Pixabay ----
        if (aiResponse.designJson) {
          if (aiResponse.designJson.sections && !aiResponse.designJson.blocks) {
            aiResponse.designJson.blocks = aiResponse.designJson.sections
            delete aiResponse.designJson.sections
          }

          send({ type: 'status', message: 'جاري تجهيز الصور المناسبة...' })
          aiResponse.designJson = await resolvePixabayRequests(aiResponse.designJson, send)
        }

        // ---- Log Usage ----
        const clientIp = req.headers.get('x-real-ip') || 'unknown'
        await supabase.from('ai_usage_log').insert({
          user_id: userId,
          ip_address: clientIp,
          feature_type: 'page_generation'
        })

        // ---- Final Result ----
        aiResponse._provider = result.provider
        aiResponse._model = result.model

        send({ type: 'result', data: aiResponse })
        controller.close()

      } catch (error: any) {
        if (cancelled) return
        console.error('Unhandled error in SSE stream:', error)

        const errorMap: Record<string, string> = {
          'AI_LIMIT_REACHED': 'لقد استهلكت رصيدك المتاح لهذا الشهر.',
          'AI_GENERATION_FAILED': 'فشل المساعد في توليد الرد. حاول صياغة الطلب بشكل أبسط.',
          'AI_INVALID_FORMAT': 'حدث خطأ في تنسيق البيانات الواردة من الـ AI. يرجى المحاولة مرة أخرى.',
        }

        let userFriendlyError = errorMap[error.message] || error.message || 'حدث خطأ غير متوقع'
        if (error.message?.startsWith('AI_GENERATION_FAILED:')) {
          userFriendlyError = `تعذر توليد الرد من جميع مزودي الذكاء الاصطناعي.`
        }

        send({ type: 'error', message: userFriendlyError, canRetry: true })
        controller.close()
      }
    }
  })

  return new Response(stream, {
    headers: {
      ...corsHeaders,
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  })
})
