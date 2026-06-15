# AI Agent Chat Improvement Plan

**Start Date:** 2026-06-12
**Last Updated:** 2026-06-14

---

## Task Status

| Part | Status | Priority |
|------|--------|----------|
| **1** - Edge Function Multi-Provider Restructure + Smart Failover | ✅ Done | 🔴 Critical |
| **2** - Expand AI Control to All Page Properties | ✅ Done | 🔴 Critical |
| **3** - Merge Copywriter into Main AI Chat | ✅ Done | 🟡 Medium |
| **4** - Improve Session Context & Memory | ✅ Done | 🟡 Medium |
| **5** - Performance Optimization (Streaming + Token Optimization) | ✅ Done | 🟢 Low |
| **6** - Decouple ai-copywrite from Single Model | ✅ Done | 🟡 Medium |
| **7** - Error Handling & Quota (Quota & Fallback UX) | ✅ Done | 🟡 Medium |
| **8** - Smart Pixabay Control: Image Type Mapping + Context Preservation | ✅ Done | 🔴 Critical |
| **9** - Comprehensive Review Fixes (SSE, Error Flow, Leaks, Timeouts) | ✅ Done | 🔴 Critical |

---

## Parts & Details

---

### Part 1: Edge Function Multi-Provider Restructure + Smart Failover ✅

**Goal:** Upgrade `ai-page-generate/index.ts` from a single provider (Gemini) to a 4-provider multi-provider system.

**Tasks:**
- [x] Add new environment variables for all providers
- [x] Create Model Router Layer (multi-provider abstraction)
- [x] Implement Circuit Breaker Pattern
- [x] Update `EnvUtils.dart` in Flutter
- [x] Update `.github/workflows/deploy.yml`
- [x] Update `ai-copywrite/index.ts` with the same structure

**Modified Files:**
- `supabase/functions/ai-page-generate/index.ts`
- `supabase/functions/ai-copywrite/index.ts`
- `lib/core/utils/env_utils.dart`
- `.github/workflows/deploy.yml`

**Provider Fallback Order:** Gemini → Groq → OpenRouter → DeepSeek → Error

**Implementation Notes:**
- `ai-page-generate/index.ts` and `ai-copywrite/index.ts`: 4 providers added (Gemini, Groq, OpenRouter, DeepSeek)
- Each provider has a Circuit Breaker (3 consecutive failures = 5-min cooldown)
- Gemini uses pre-existing `GOOGLE_AI_KEY` (primary provider)
- Groq, OpenRouter, DeepSeek work once their API keys are added
- `gemini-3.5-flash` (dead code) removed from model list
- OpenAI-compatible APIs (Groq, OpenRouter, DeepSeek) use the same `tryOpenAICompatibleProvider` mechanism

---

### Part 2: Expand AI Control to All Page Properties ✅

**Goal:** Enable the AI to control 100% of every block's properties.

**Tasks:**
- [x] Expand System Prompt to include all properties (Animation, Variant, Background, Padding, Layout, Typography, Sticky CTA, Colors, SEO)
- [x] Add complete Structured Block Schema Registry for all 27 block types
- [x] Create BlockPropertyMapper in Flutter (`block_schema.dart` + updated `ai_response_validator.dart`)

**Modified Files:**
- `supabase/functions/ai-page-generate/index.ts`
- `lib/features/builder/controllers/ai_generation_cubit.dart`
- `lib/features/builder/ai/block_schema.dart` (new)
- `lib/features/builder/ai/ai_response_validator.dart` (refactored)

**New Properties:**
| Property | Example | Notes |
|----------|---------|-------|
| `animation` | `{type: "fadeIn", duration: 800, delay: 0}` | Per block |
| `variant` | `0-9` | Per block |
| `bg_image_url` | pixabay_search format | Per block |
| `bg_overlay_opacity` | `0.0 - 1.0` | Per block |
| `vertical_padding` | `80` or `40` responsive | Per block |
| `layout_style` | `grid`, `list`, `masonry` | Grid blocks |
| `font_family` | string | Global & per block |
| `sticky_cta` | object full config | Global |
| `page_title`, `meta_description` | strings | SEO |
| `border_radius` | number | Per block |
| `box_shadow` | object | Per block |

---

### Part 3: Merge Copywriter into Main AI Chat ✅

**Goal:** User can say "improve the features section text" and the chat edits it directly.

**Tasks:**
- [x] Add `rewrite` intent in edge function prompt
- [x] Add `copy_update` action type with full `copy_updates` schema
- [x] Instruct the AI: for text-only edits, use `copy_update` instead of `designJson`
- [x] Add `AIGenerationCopyUpdate` state in Flutter
- [x] Add handler in `processUserMessage` to apply `copy_updates` via `updateBlockProperty`
- [x] Add listener in `ai_chat_modal` to show copy-update success message

**Note:** `AICopywriterCubit` and `ai-copywrite/index.ts` still work for the standalone modal. The integration is an additional channel in the main chat.

**Modified Files:**
- ✅ `supabase/functions/ai-page-generate/index.ts`
- ✅ `lib/features/builder/controllers/ai_generation_cubit.dart`
- ✅ `lib/features/builder/widgets/modals/ai_chat_modal.dart`

---

### Part 4: Improve Session Context & Memory ✅

**Goal:** The AI remembers the full conversation more effectively with deeper context.

**Tasks:**
- [x] Raise message limit from 10 to 30
- [x] Add Message Compressor (last 10 full, older compressed)
- [ ] Store session_history in localStorage (future)
- [x] Improve `getContextForAI`: send all theme fields instead of just primary/background
- [x] Improve `_getMinimalDesignContext`: add `_meta` (block_count, section_types)

**Modified Files:**
- ✅ `lib/features/builder/ai/ai_conversation_session.dart`
- ✅ `lib/features/builder/controllers/ai_generation_cubit.dart`

---

### Part 5: Performance Optimization (Streaming + Token Optimization) ✅

**Goal:** Faster user experience with lower token consumption.

**Tasks:**
- [x] Cancel Previous Request: `_isProcessing` + request ID counter ignores stale responses
- [x] Request Deduplication: skip if user sends the same message twice
- [x] Partial Updates (`_index`) — done in Part 2
- [x] Token Optimization Rule in prompt: instruct AI to prefer copy_update → partial update → full design
- [x] **SSE Streaming**: fully implemented — `ReadableStream` in edge function, SSE line buffer (`StringBuffer`) in Flutter client to handle TCP fragmentation, real-time progress events (`status`/`result`/`error`)

**Cancel Previous Request Flow:**
- `processUserMessage` sets `_activeRequestId` before each request
- Stale responses are detected via `myRequestId != _activeRequestId` and discarded
- No more boolean `_cancelled` flag (replaced with incrementing counter)

**Modified Files:**
- ✅ `supabase/functions/ai-page-generate/index.ts`
- ✅ `lib/features/builder/controllers/ai_generation_cubit.dart`

---

### Part 6: Decouple ai-copywrite from Single Model ✅

**Goal:** Copywrite edge function uses multi-provider architecture.

**Tasks:**
- [x] Add model router to ai-copywrite
- [ ] Unify model router in shared module (done — `shared/model_router.ts` created)

**Modified Files:**
- `supabase/functions/ai-copywrite/index.ts`
- `supabase/functions/shared/model_router.ts`

---

### Part 7: Error Handling & Quota (Quota & Fallback UX) ✅

**Goal:** When all models fail, the user gets a smooth experience.

**Tasks:**
- [x] Unified Error Handler: `_handleAIError()` in ai_generation_cubit collects all error messages in one place
- [x] Graceful Degradation: if `intent == 'generate'` and AI fails, show `AIGenerationTemplateFallback` instead of Failure
- [x] Improved quota error messages: clear, detailed (includes API key activation instructions)
- [x] `canRetry` flag to distinguish retriable errors (Invalid JSON, Network) vs non-retriable (Quota, Unauthorized)
- [x] Specific messages per error type (Unauthorized, All providers failed, No response, Invalid format)

**Modified Files:**
- ✅ `lib/features/builder/controllers/ai_generation_cubit.dart`
- ✅ `lib/features/builder/widgets/modals/ai_chat_modal.dart`

---

### Part 8: Smart Pixabay Control — Image Type Mapping + Context Preservation ✅

**Goal:** Enable the AI to fully control landing page images, select appropriate types per block, search intelligently based on business type, and preserve conversation context after image selection.

**Problems this part addresses:**
1. ~~AI only used `webformatURL`~~ ✅ Now supports `largeImageURL` and `fullHDURL`
2. ~~No mapping between block type and image type~~ ✅ `BLOCK_IMAGE_TYPE_MAP` added
3. ~~Pixabay search queries not industry-aware~~ ✅ Industry-Aware instructions added
4. ~~Context lost after image selection~~ ✅ `resumeAfterPixabaySelection()` added
5. ~~No image fallback~~ ✅ Fallback chain added
6. ~~No caching~~ ✅ `searchCache` improved with TTL
7. ~~AI doesn't distinguish image_url vs bg_image_url~~ ✅ Awareness added in `BLOCK_IMAGE_TYPE_MAP`
8. ~~No orientation parameter~~ ✅ `orientation`, `quality`, `category` added

**Tasks:**
- [x] Create `BLOCK_IMAGE_TYPE_MAP` with 14 block types + recommended type/orientation/category
- [x] Update System Prompt: add Block-to-Image-Type Map, Industry-Aware Queries, Bilingual Search
- [x] Update `pixabay_search` schema: support `orientation`, `quality`, `category`
- [x] Add `orientation` to API call + `largeImageURL`/`fullHDURL` as optional quality
- [x] Pixabay Session Cache (`searchCache`) improved
- [x] Image Fallback Chain: 1. Exact params → 2. Without orientation → 3. Industry-generic keywords
- [x] Industry-Aware Default Keywords in fallback
- [x] Context Preservation: `_pixabayPendingMessage` + `resumeAfterPixabaySelection()` in ai_generation_cubit
- [x] Pixabay Selector UI: orientation filters + industry keyword suggestions

**Modified Files:**
- ✅ `supabase/functions/ai-page-generate/index.ts`
- ✅ `lib/features/builder/controllers/ai_generation_cubit.dart`
- ✅ `lib/features/builder/widgets/modals/ai_chat_modal.dart`
- ✅ `lib/features/builder/widgets/modals/pixabay_selector_modal.dart`
- ✅ `lib/features/builder/controllers/pixabay_selector_cubit.dart`
- ✅ `lib/services/image_media_service.dart`

---

### Part 9: Comprehensive Review Fixes — SSE, Error Flow, Leaks, Timeouts ✅

**Goal:** Fix architectural issues discovered during a full code review of the SSE streaming implementation.

**Tasks:**
- [x] **Fix 1 — SSE TCP Fragmentation**: Add `StringBuffer` line buffer in the Dart parser so SSE events split across TCP chunks are correctly reassembled
- [x] **Fix 2 — Error Flow Bypass**: SSE error events from the edge function (Arabic messages like "لقد استهلكت رصيدك...") were being processed by `_handleAIError()` which checks `contains('quota')` before displaying — but Arabic text doesn't match. Fixed by emitting `AIGenerationFailure` directly with `canRetry` from the SSE stream handler
- [x] **Fix 3 — Resource Leak**: `httpClient.close()` was not called if the stream threw an exception. Wrapped stream reading in `try/finally` to guarantee cleanup
- [x] **Fix 4 — Completer Hang**: `_resolvePixabayUrlsInDesign` in `builder_cubit.dart` used a `Completer` that never completes if `persistExternalImage` fails. Added `.timeout(30s)` with fallback to original URL
- [x] **Fix 5 — Guest Auth Header**: Raw HTTP request (for SSE) only sent `Authorization` header when `currentSession?.accessToken` was non-null. Supabase gateway rejects requests without auth. Fixed by always sending `Authorization: Bearer <token>` with `anonKey` as fallback, matching `functions.invoke()` behavior

**Files Modified:**
- ✅ `lib/features/builder/controllers/ai_generation_cubit.dart`
- ✅ `lib/features/builder/controllers/builder_cubit.dart`
- ✅ `lib/features/builder/ai/block_schema.dart`
- ✅ `lib/features/builder/ai/ai_response_validator.dart`
- ✅ `lib/services/image_media_service.dart` (dead code removed)

**BlockPropertyMapper (`block_schema.dart`):**
- Created schema registry with all 27 block types + 11 shared properties
- Type coercion, range clamping, stale property stripping
- `ai_response_validator.dart` now uses `BlockPropertyMapper.sanitize()` instead of manual validation

**Pixabay Upload at Publish:**
- `_resolvePixabayUrlsInDesign()` in `savePage()` scans for `pixabay.com` URLs and uploads to ImgBB before saving
- Pixabay cache TTL: 10 minutes for `searchCache`

**Race Condition Fix:**
- Replaced `_cancelled` boolean with `_activeRequestId` counter in `ai_generation_cubit`

---

## Known Bugs in Current Code

| # | Issue | File:Line | Severity | Status |
|---|-------|-----------|----------|--------|
| 1 | `gemini-3.5-flash` does not exist — dead code causing failed attempts | ~~`ai-page-generate/index.ts`~~ | 🟡 Medium | ✅ Fixed |
| 2 | `TextDirection.rtl` hardcoded in message bubble | `ai_chat_modal.dart:243` | 🟢 Low | ⬜ Open |
| 3 | 10 message session limit — rapid context loss | ~~`ai_conversation_session.dart:79-81`~~ | 🟡 Medium | ✅ Fixed |
| 4 | Guest limit (5/hour) hardcoded in edge function | `ai-page-generate/index.ts:448-460` | 🟢 Low | ⬜ Open |
| 5 | `_getMinimalDesignContext` without meta data | ~~`ai_generation_cubit.dart:251-258`~~ | 🟡 Medium | ✅ Fixed |
| 6 | Example prompts written to input field instead of sent directly | `ai_chat_input.dart:73-76` | 🟢 Low | ⬜ Open |
| 7 | Pixabay selection loses conversation context entirely | ~~`ai_generation_cubit.dart`~~ | 🟡 Medium | ✅ Fixed |
| 8 | Pixabay search only used low-quality `webformatURL` | ~~`ai-page-generate/index.ts`~~ | 🟢 Low | ✅ Fixed |
| 9 | No mapping between block type and image type | ~~`ai-page-generate/index.ts`~~ | 🟡 Medium | ✅ Fixed |
| 10 | Pixabay search queries not using `business_profile.industry` | ~~`ai-page-generate/index.ts`~~ | 🟡 Medium | ✅ Fixed |

---

## API Key Requirements

To enable the multi-provider fallback, create API keys at the following providers:

### 1. **Google Gemini API** ✅ (Already active)
- **Variable:** `GOOGLE_AI_KEY`
- **Models:** `gemini-2.5-flash`, `gemini-2.0-flash`, `gemini-1.5-flash-latest`
- **Link:** https://aistudio.google.com/apikey
- **Location:** Already in GitHub Secrets as `GOOGLE_AI_KEY`

### 2. **Groq API** ⬜ (Needs creation)
- **Variable:** `GROQ_API_KEY`
- **Models:** `llama-3.3-70b-versatile`, `mixtral-8x7b-32768`
- **Link:** https://console.groq.com/keys
- **Features:** Fastest inference, completely free (30 request/min)
- **Add to:**
  - GitHub Secrets: `GROQ_API_KEY`
  - Vercel Dashboard → landymaker → Environment Variables: `GROQ_API_KEY`
  - `.env.local` (local development)

### 3. **OpenRouter API** ⬜ (Needs creation - optional)
- **Variable:** `OPENROUTER_API_KEY`
- **Models:** `meta-llama/llama-3.1-8b-instruct`, `mistralai/mistral-7b-instruct`
- **Link:** https://openrouter.ai/keys
- **Features:** 200+ models, $1 free credit
- **Add to:**
  - GitHub Secrets: `OPENROUTER_API_KEY`
  - Vercel Dashboard → landymaker → Environment Variables: `OPENROUTER_API_KEY`
  - `.env.local` (local development)

### 4. **DeepSeek API** ⬜ (Needs creation - optional)
- **Variable:** `DEEPSEEK_API_KEY`
- **Models:** `deepseek-chat`
- **Link:** https://platform.deepseek.com/api_keys
- **Features:** Very cheap ($0.14/M input tokens), good Arabic support
- **Add to:**
  - GitHub Secrets: `DEEPSEEK_API_KEY`
  - Vercel Dashboard → landymaker → Environment Variables: `DEEPSEEK_API_KEY`
  - `.env.local` (local development)

### ⚠️ Most Important: Supabase Dashboard (Edge Functions)

Since `ai-page-generate` and `ai-copywrite` run as **Supabase Edge Functions (Deno)**, they read env vars from **Supabase Dashboard Environment Variables** — NOT from Flutter or Vercel.

Go to: **Supabase Dashboard → Edge Functions → (select function) → Environment Variables**

Add the following variables to each function:
```
GOOGLE_AI_KEY=AIza...  ✅ (Already set)
GROQ_API_KEY=gsk_...   ⬜ (Needs creation)
OPENROUTER_API_KEY=sk-or-... ⬜ (Needs creation - optional)
DEEPSEEK_API_KEY=sk-... ⬜ (Needs creation - optional)
PIXABAY_API_KEY=...    ⬜ (Needs creation - optional, for image search)
```

### Other Locations

**1. GitHub Secrets** (Settings → Secrets and variables → Actions):
```
GOOGLE_AI_KEY=AIza...  ✅ (Already set)
GROQ_API_KEY=gsk_...   ⬜
OPENROUTER_API_KEY=sk-or-... ⬜
DEEPSEEK_API_KEY=sk-... ⬜
```

**2. `.env.local` (local development):**
```
GOOGLE_AI_KEY=AIza...
GROQ_API_KEY=gsk_...
OPENROUTER_API_KEY=sk-or-...
DEEPSEEK_API_KEY=sk-...
```

**3. Vercel Dashboard Environment Variables** (for `landymaker` project):
Same variable names as above (for future Flutter use cases)

**4. GitHub Actions `.github/workflows/deploy.yml`** — updated in Part 1 with `--dart-define` for each new key.
