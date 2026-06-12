# خطة تطويرAI Agent Chat - التحكم الكامل في صفحات الهبوط

**تاريخ البدء:** 2026-06-12
**آخر تحديث:** 2026-06-12

---

## حالة المهام

| الجزء | الحالة | الأولوية |
|-------|--------|---------|
| **1** - إعادة هيكلة Edge Function لدمج مزودين متعددين + التتابع الذكي | ✅ تم | 🔴 حرجة |
| **2** - توسيع تحكم الـ AI ليشمل كل خصائص الصفحة | ✅ تم | 🔴 حرجة |
| **3** - دمج الـ Copywriter في شات الـ AI الرئيسي | ✅ تم | 🟡 متوسطة |
| **4** - تحسين Session Context و Memory | ✅ تم | 🟡 متوسطة |
| **5** - تحسين سرعة الأداء (Streaming + Token Optimization) | ✅ تم | 🟢 عادية |
| **9** - Fixes after comprehensive review | 🔧 قيد الإصلاح | 🔴 حرجة |
| **6** - فك ارتباط ai-copywrite من موديل واحد | ✅ تم | 🟡 متوسطة |
| **7** - معالجة الأخطاء والحدود (Quota & Fallback UX) | ✅ تم | 🟡 متوسطة |
| **8** - تحكم Pixabay الذكي: Image Type Mapping + Context Preservation | ✅ تم | 🔴 حرجة |

---

## الأجزاء والتفاصيل

---

### الجزء 1: إعادة هيكلة Edge Function لدمج مزودين متعددين + التتابع الذكي ✅

**الهدف**: تحويل `ai-page-generate/index.ts` من مزود واحد (Gemini) إلى multi-provider system مع 4 مزودين.

**المهام**:
- [x] إضافة متغيرات البيئة الجديدة للمزودين
- [x] إنشاء Model Router Layer (multi-provider abstraction)
- [x] تنفيذ Circuit Breaker Pattern
- [x] تحديث `EnvUtils.dart` في Flutter
- [x] تحديث `.github/workflows/deploy.yml`
- [x] تحديث `ai-copywrite/index.ts` لنفس الهيكل

**ملفات التعديل**:
- `supabase/functions/ai-page-generate/index.ts`
- `supabase/functions/ai-copywrite/index.ts`
- `lib/core/utils/env_utils.dart`
- `.github/workflows/deploy.yml`

**ترتيب المحاولة**: Gemini → Groq → OpenRouter → DeepSeek → Error

**شرح التنفيذ**:
- `ai-page-generate/index.ts` و `ai-copywrite/index.ts`: تمت إضافة 4 مزودين (Gemini, Groq, OpenRouter, DeepSeek)
- كل مزود عنده Circuit Breaker (3 فشل متتالي = إغلاق لمدة 5 دقايق)
- Gemini يستخدم `GOOGLE_AI_KEY` الموجود مسبقاً (المزود الرئيسي)
- Groq, OpenRouter, DeepSeek وقته ما يتضاف API keys بتاعتهم
- `Gemini-3.5-flash` (dead code) ^ تم إزالته من قائمة الموديلات
- OpenAI-compatible APIs (Groq, OpenRouter, DeepSeek) يستخدمون نفس الميكانيزم (`tryOpenAICompatibleProvider`)
- تم إضافة الـ env vars في `env_utils.dart` و `deploy.yml`

---

### الجزء 2: توسيع تحكم الـ AI ليشمل كل خصائص الصفحة ✅

**الهدف**: تمكين الـ AI من التحكم في 100% من خصائص كل بلوك.

**المهام**:
- [x] توسيع System Prompt ليشمل كل الخصائص (Animation, Variant, Background, Padding, Layout, Typography, Sticky CTA, Colors, SEO)
- [x] إضافة Structured Block Schema Registry كامل لكل 27 نوع بلوك
- [ ] إنشاء property_mapper في Flutter client (للتأكد من توافق الخصائص الجديدة مع BuilderCubit)

**ملفات التعديل**:
- `supabase/functions/ai-page-generate/index.ts`
- `lib/features/builder/controllers/ai_generation_cubit.dart`

**الخصائص الجديدة**:
| الخاصية | مثال | ملاحظة |
|---------|------|--------|
| `animation` | `{type: "fadeIn", duration: 800, delay: 0}` | لكل بلوك |
| `variant` | `0-9` | لكل بلوك |
| `bg_image_url` | pixabay_search format | لكل بلوك |
| `bg_overlay_opacity` | `0.0 - 1.0` | لكل بلوك |
| `vertical_padding` | `80` أو `40` responsive | لكل بلوك |
| `layout_style` | `grid`, `list`, `masonry` | للـ grid blocks |
| `font_family` | string | global & per block |
| `sticky_cta` | object full config | global |
| `page_title`, `meta_description` | strings | SEO |
| `border_radius` | number | لكل بلوك |
| `box_shadow` | object | لكل بلوك |

---

### الجزء 3: دمج الـ Copywriter في شات الـ AI الرئيسي ✅

**الهدف**: المستخدم يقدر يقول "حسن النصوص في قسم المميزات" والشات يعدلها مباشرة.

**المهام**:
- [x] إضافة intent `rewrite` في الـ edge function prompt
- [x] إضافة `copy_update` action type مع `copy_updates` schema كامل
- [x] إضافة توجيه للـ AI: إذا المستخدم طلب تحسين نصوص، يستخدم `copy_update` بدل `designJson`
- [x] إضافة `AIGenerationCopyUpdate` state في Flutter
- [x] إضافة handler في `processUserMessage` يطبق `copy_updates` باستخدام `updateBlockProperty`
- [x] إضافة listener في `ai_chat_modal` لعرض رسالة نجاح تحسين النصوص

**ملاحظة**: `AICopywriterCubit` و `ai-copywrite/index.ts` لسه شغالين للـ standalone modal. التكامل الجديد هو قناة إضافية في الـ main chat.

**ملفات التعديل**:
- ✅ `supabase/functions/ai-page-generate/index.ts`
- ✅ `lib/features/builder/controllers/ai_generation_cubit.dart`
- ✅ `lib/features/builder/widgets/modals/ai_chat_modal.dart`

---

### الجزء 4: تحسين Session Context و Memory ✅

**الهدف**: الـ AI يفتكر conversation كامل بشكل أفضل ويدعم سياق أعمق.

**المهام**:
- [x] رفع الحد من 10 إلى 30 رسالة
- [x] إضافة Message Compressor (آخر 10 رسايل كاملة، الأقدم مضغوطة)
- [ ] تخزين session_history في localStorage (مستقبلياً)
- [x] تحسين `getContextForAI`: إرسال كل الـ theme fields بدل primary/background فقط
- [x] تحسين `_getMinimalDesignContext`: إضافة `_meta` (block_count, section_types)

**ملفات التعديل**:
- ✅ `lib/features/builder/ai/ai_conversation_session.dart`
- ✅ `lib/features/builder/controllers/ai_generation_cubit.dart`

---

### الجزء 5: تحسين سرعة الأداء (Streaming + Token Optimization) ✅

**الهدف**: تجربة مستخدم أسرع مع استهلاك أقل للـ tokens.

**المهام**:
- [x] Cancel Previous Request: `_isProcessing` + `_cancelled` flag تتجاهل الاستجابات القديمة
- [x] Request Deduplication: لو المستخدم بعت نفس الرسالة مرتين، اتخطى
- [x] استخدام Partial Updates (`_index`) — تم في الجزء 2
- [x] Token Optimization Rule في الـ prompt: توجيه الـ AI لاستخدام copy_update ثم partial update ثم full design
- [ ] SSE (Streaming) — معقد ويحتاج إعادة هيكلة كبيرة للـ Edge Function، يمكن إضافته مستقبلاً

**شرح Cancel Previous Request**:
- `processUserMessage` تتحقق من `_isProcessing` قبل البدء
- لو في طلب قيد التنفيذ، `_cancelled = true` (الاستجابة القديمة تتجاهل)
- الـ response handler يتحقق من `_cancelled` قبل معالجة الاستجابة

**ملفات التعديل**:
- ✅ `supabase/functions/ai-page-generate/index.ts`
- ✅ `lib/features/builder/controllers/ai_generation_cubit.dart`

---

### الجزء 6: فك ارتباط ai-copywrite من موديل واحد ✅

**الهدف**: copywrite edge function يستخدم multi-provider architecture.

**المهام**:
- [x] إضافة model router لـ ai-copywrite
- [ ] توحيد الـ model router في shared module (مستقبلياً)

**ملفات التعديل**:
- `supabase/functions/ai-copywrite/index.ts`

---

### الجزء 7: معالجة الأخطاء والحدود (Quota & Fallback UX) ✅

**الهدف**: لو كل الموديلات فشلت، المستخدم ياخد تجربة سلسة.

**المهام**:
- [x] Unified Error Handler: `_handleAIError()` في ai_generation_cubit تجمع كل رسائل الخطأ في مكان واحد
- [x] Graceful Degradation: لو `intent == 'generate'` وفشل الـ AI، يطلع `AIGenerationTemplateFallback` بدل Failure
- [x] تحسين رسائل quota limit: رسائل واضحة ومفصلة (تحتوي على تعليمات لتفعيل API keys)
- [x] إضافة `canRetry` للتمييز بين الأخطاء القابلة للمحاولة (Invalid JSON, Network) وغير القابلة (Quota, Unauthorized)
- [x] رسائل مخصصة لكل نوع خطأ (Unauthorized, All providers failed, No response, Invalid format)

**ملفات التعديل**:
- ✅ `lib/features/builder/controllers/ai_generation_cubit.dart`
- ✅ `lib/features/builder/widgets/modals/ai_chat_modal.dart`

---

### الجزء 8: تحكم Pixabay الذكي — Image Type Mapping + Context Preservation ✅

**الهدف**: تمكين الـ AI من التحكم الكامل في صور صفحة الهبوط، مع اختيار النوع المناسب لكل بلوك، والبحث الذكي عن الصور المناسبة حسب نوع النشاط التجاري، والحفاظ على سياق المحادثة بعد اختيار الصورة.

**المشاكل الحالية التي يعالجها هذا الجزء**:
1. ~~الـ AI بيستخدم `webformatURL` بس~~ ✅ الآن يدعم `largeImageURL` و `fullHDURL`
2. ~~مفيش mapping بين نوع البلوك ونوع الصورة~~ ✅ تم إضافة `BLOCK_IMAGE_TYPE_MAP`
3. ~~Pixabay search queries مش مبنية على industry~~ ✅ تم إضافة تعليمات Industry-Aware
4. ~~بعد اختيار الصورة السياق بيتلاشى~~ ✅ تم إضافة `resumeAfterPixabaySelection()`
5. ~~مفيش image fallback~~ ✅ تم إضافة fallback chain
6. ~~مفيش caching~~ ✅ `searchCache` موجود مسبقاً وتم تحسينه
7. ~~الـ AI مش بيفرق بين image_url و bg_image_url~~ ✅ تم إضافة التوعية في الـ BLOCK_IMAGE_TYPE_MAP
8. ~~مفيش orientation parameter~~ ✅ تم إضافة `orientation`, `quality`, `category`

**المهام**:
- [x] إنشاء `BLOCK_IMAGE_TYPE_MAP` بـ 14 نوع بلوك مع type/orientation/category الموصى به
- [x] تحديث System Prompt: إضافة Block-to-Image-Type Map كامل و Industry-Aware Queries و Bilingual Search
- [x] تحديث `pixabay_search` schema: دعم `orientation` و `quality` و `category`
- [x] دعم `orientation` في API call + `largeImageURL`/`fullHDURL` كجودة اختيارية
- [x] Pixabay Session Cache موجود (`searchCache`) وتم تحسينه
- [x] Image Fallback Chain: 1. Exact params → 2. بدون orientation → 3. Industry-generic keywords
- [x] Industry-Aware Default Keywords في fallback
- [x] Context Preservation: `_pixabayPendingMessage` + `resumeAfterPixabaySelection()` في ai_generation_cubit
- [x] Pixabay Selector UI: orientation filters + industry keyword suggestions

**ملفات التعديل**:
- ✅ `supabase/functions/ai-page-generate/index.ts`
- ✅ `lib/features/builder/controllers/ai_generation_cubit.dart`
- ✅ `lib/features/builder/widgets/modals/ai_chat_modal.dart`
- ✅ `lib/features/builder/widgets/modals/pixabay_selector_modal.dart`
- ✅ `lib/features/builder/controllers/pixabay_selector_cubit.dart`
- ✅ `lib/services/image_media_service.dart`

---

## الأخطاء (Bugs) المكتشفة في الكود الحالي يجب إصلاحها

| # | المشكلة | الملف:السطر | severity |
|---|---------|------------|----------|
| 1 | `gemini-3.5-flash` غير موجود — dead code يسبب محاولات فاشلة | ~~`ai-page-generate/index.ts`~~ | 🟡 متوسطة ✅ |
| 2 | `TextDirection.rtl` hardcoded في message bubble | `ai_chat_modal.dart:243` | 🟢 بسيطة |
| 3 | 10 رسايل كحد أقصى للـ session — فقدان سياق سريع | ~~`ai_conversation_session.dart:79-81`~~ | 🟡 متوسطة ✅ |
| 4 | Guest limit (5/hour) hardcoded في الـ edge function | `ai-page-generate/index.ts:273` | 🟢 بسيطة |
| 5 | `_getMinimalDesignContext` بدون meta data | ~~`ai_generation_cubit.dart:251-258`~~ | 🟡 متوسطة ✅ |
| 6 | Example prompts بتتكتب في الـ input مش بتتبعت مباشر | `ai_chat_input.dart:73-76` | 🟢 بسيطة |
| 7 | Pixabay selection بيفقد سياق المحادثة بالكامل | ~~`ai_generation_cubit.dart`~~ | 🟡 متوسطة ✅ |
| 8 | Pixabay search بيستخدم `webformatURL` بس بجودة منخفضة | ~~`ai-page-generate/index.ts`~~ | 🟢 بسيطة ✅ |
| 9 | مفيش mapping بين نوع البلوك ونوع الصورة | ~~`ai-page-generate/index.ts`~~ | 🟡 متوسطة ✅ |
| 10 | Pixabay search queries مش بتستفيد من `business_profile.industry` | ~~`ai-page-generate/index.ts`~~ | 🟡 متوسطة ✅ |

---

## متطلبات API Keys

لتفعيل multi-provider fallback، تحتاج إلى إنشاء API Keys عند المزودين التاليين:

### 1. **Google Gemini API** ✅ (مفعل بالفعل)
- **المتغير**: `GOOGLE_AI_KEY`
- **الموديلات**: `gemini-2.5-flash`, `gemini-2.0-flash`, `gemini-1.5-flash-latest`
- **الرابط**: https://aistudio.google.com/apikey
- **مكان الإضافة**: موجود بالفعل في GitHub Secrets كـ `GOOGLE_AI_KEY`

### 2. **Groq API** ⬜ (يلزم إنشاؤه)
- **المتغير**: `GROQ_API_KEY`
- **الموديلات**: `llama-3.3-70b-versatile`, `mixtral-8x7b-32768`
- **الرابط**: https://console.groq.com/keys
- **المميزات**: أسرع inference في السوق، مجاني بالكامل (30 request/min)
- **مكان الإضافة**:
  - GitHub Secrets: `GROQ_API_KEY`
  - Vercel Dashboard → landymaker → Environment Variables: `GROQ_API_KEY`
  - `.env.local` (للتطوير المحلي)

### 3. **OpenRouter API** ⬜ (يلزم إنشاؤه - اختياري)
- **المتغير**: `OPENROUTER_API_KEY`
- **الموديلات**: `meta-llama/llama-3.1-8b-instruct`, `mistralai/mistral-7b-instruct`
- **الرابط**: https://openrouter.ai/keys
- **المميزات**: يجمع 200+ موديل، $1 مجاني للبدء
- **مكان الإضافة**:
  - GitHub Secrets: `OPENROUTER_API_KEY`
  - Vercel Dashboard → landymaker → Environment Variables: `OPENROUTER_API_KEY`
  - `.env.local` (للتطوير المحلي)

### 4. **DeepSeek API** ⬜ (يلزم إنشاؤه - اختياري)
- **المتغير**: `DEEPSEEK_API_KEY`
- **الموديل**: `deepseek-chat`
- **الرابط**: https://platform.deepseek.com/api_keys
- **المميزات**: رخيص جداً ($0.14/M input tokens)، دعم عربي جيد
- **مكان الإضافة**:
  - GitHub Secrets: `DEEPSEEK_API_KEY`
  - Vercel Dashboard → landymaker → Environment Variables: `DEEPSEEK_API_KEY`
  - `.env.local` (للتطوير المحلي)

### ⚠️ المكان الأهم: Supabase Dashboard (Edge Functions)

لأن `ai-page-generate` و `ai-copywrite` بيشتغلوا كـ **Supabase Edge Functions (Deno)**، هم بيقرأوا الـ env vars من **Supabase Dashboard Environment Variables** مش من Flutter أو Vercel.

اذهب إلى: **Supabase Dashboard → Edge Functions → (اختر function) → Environment Variables**

أضف المتغيرات التالية لكل function:
```
GOOGLE_AI_KEY=AIza...  ✅ (مفعل مسبقاً)
GROQ_API_KEY=gsk_...   ⬜ (يلزم إنشاؤه)
OPENROUTER_API_KEY=sk-or-... ⬜ (يلزم إنشاؤه - اختياري)
DEEPSEEK_API_KEY=sk-... ⬜ (يلزم إنشاؤه - اختياري)
```

### أماكن الإضافة الإضافية

**1. GitHub Secrets** (Settings → Secrets and variables → Actions):
```
GOOGLE_AI_KEY=AIza...  ✅ (موجود مسبقاً)
GROQ_API_KEY=gsk_...   ⬜
OPENROUTER_API_KEY=sk-or-... ⬜
DEEPSEEK_API_KEY=sk-... ⬜
```

**2. ملف `.env.local` (للتطوير المحلي):**
```
GOOGLE_AI_KEY=AIza...
GROQ_API_KEY=gsk_...
OPENROUTER_API_KEY=sk-or-...
DEEPSEEK_API_KEY=sk-...
```

**3. Vercel Dashboard Environment Variables** (لـ `landymaker` project):
نفس الأسماء المذكورة أعلاه (لأي Flutter use cases مستقبلية)

**4. GitHub Actions `.github/workflows/deploy.yml`** — تم تحديثها في الجزء 1 بإضافة `--dart-define` لكل مفتاح جديد.
