# LandyMaker 🚀 (لاندي ميكر) - AI Assistant Deep Context Guide

Welcome, AI Assistant! You are looking at the comprehensive, deep project context for **LandyMaker**, a professional, high-performance SaaS Landing Page and E-commerce Builder engineered for the MENA region with native Right-to-Left (RTL) and Arabic-first support.

This document serves as your **core project memory**. Please read it carefully before suggesting any code changes, architectural decisions, or debugging steps.

---

## 🎯 1. Project Overview & Architecture

LandyMaker enables users to build, manage, and host multi-page SaaS landing pages and e-commerce stores without writing code. It uses a **Clean Feature-Driven Architecture** influenced by the **SPEC-KIT** methodology, separating concerns into presentation, business logic (States), and infrastructure services.

### Core Data Flow
The platform relies on a strict unidirectional data pipeline to ensure 1:1 visual parity between the editor and the live site:
**`Builder Workspace` → `JSON Schema` → `Parser` → `SectionRenderer` → `ActionHandlerService`**

1. **JSON Schema**: The absolute source of truth. Every layout, style, list, and form configuration is stored as a JSON dictionary in the `designMap`.
2. **Parser**: Translates raw JSON arrays and maps into typed Dart objects (e.g., `PricingParser` generating `PricingPlanModel`).
3. **Renderer**: `SectionRenderer` delegates the rendering to the appropriate feature widget (e.g., `CustomPricingWidget`).
4. **ActionHandler**: Intercepts CTA interactions globally, supporting routing, external links, WhatsApp generation, and form submissions.

### Directory Structure & Layout
```text
lib/
├── core/                   # Shared utilities, themes, routing, and forms
│   ├── forms/              # Validation Engine and Field Renderer
│   ├── localization/       # Translations dictionaries (ar/en)
│   └── widgets/            # Generic shared UI atoms/molecules
├── features/               # Isolated domain-specific feature modules
│   ├── auth/               # Auth state machine
│   ├── builder/            # Flex-Editor workspace, registries, block properties editors
│   ├── dashboard/          # Shell, analytics, leads charts, custom domain configuration
│   ├── public_viewer/      # High-performance section renderer for published pages
│   ├── subscription/       # Payment modals, tier limits
│   └── super_admin/        # Platform-level metrics and configurations
├── services/               # Infrastructure Client Adaptors
└── main.dart               # App entry point
```

---

## 🛠 2. Core Systems Architecture

LandyMaker is divided into clear boundaries: Builder System (Editor), Runtime System (Public Viewer), and Global UI Systems.

### A. Builder System (Editor)
- **Block Registry**: Defines default JSON schemas for every supported block type.
- **Dynamic Blocks System**: Utilizes `DynamicListEditor` to handle array-based properties safely. It ensures safe `null` handling (`as List? ?? []`) preventing runtime crashes during missing states.
- **Dual Rendering**: The builder workspace uses the exact same `SectionRenderer` as the public page.

### B. Runtime System (Public Viewer)
- **Pricing System V2**: Split into modular components: `PricingParser` (extracts prices/features), `PricingCalculator` (handles dynamic discount calculations), `PricingModels` (types), and `CustomPricingWidget` (handles UI and Monthly/Yearly toggle state locally).
- **Validation Engine & Field Renderer**: A centralized form validation system. `ValidationEngine` handles Regex and schema checks, while `FieldRenderer` generates correct inputs (Text, Email, Textarea, Select, etc.). Used by `CustomLeadFormWidget` and `CustomLeadMagnetWidget` to provide inline error/success feedback without silent failures.

### C. Global UI Systems
- **Sticky CTA System**: A global, fixed overlay (`StickyCtaBar`) that conditionally appears based on scroll threshold (e.g., `> 30%`). It manages its own loading state, prevents double submissions, and interacts with global components (like `FloatingCartWidget`) to prevent layout overlaps.

---

## 🧱 3. Supported Block Types (Registry)

The platform supports the following blocks, each with a dedicated Editor and Renderer:

- `hero`: Primary header with title, subtitle, buttons, and image.
- `hero_saas`: SaaS-specific header with tech logos and badge.
- `features`: Grid of feature cards with icons.
- `products`: E-commerce grid displaying physical or digital items.
- `pricing`: Monthly/Yearly pricing plans with feature inclusion toggles.
- `testimonials`: Customer reviews and ratings.
- `faq`: Accordion-based Frequently Asked Questions.
- `gallery`: Image grid/masonry display.
- `contact_info`: Contact details grid.
- `video_embed`: External video player integration.
- `logo_header`: Simple header containing the brand logo.
- `lead_form`: Full-width lead generation form block.
- `lead_magnet`: Split layout (Image + Form) lead generation block.
- `working_hours`: Store or business opening hours display.
- `location_map`: Google Maps / Map embed block.
- `trust_logos`: Horizontal row of trusted brand logos.
- `animated_counter`: Animated numbers representing statistics or milestones.
- `social_qr`: Display of social media links alongside a QR code.
- `whatsapp`: WhatsApp direct chat CTA block.
- `basic_section`: Empty rich-text section.

---

## 🛡️ 4. Security & Antispam Framework (CRITICAL)

To protect the platform from automated abuse and ensure data integrity, all user-submitted data (especially leads) MUST pass through the Security Layer:

### A. Client-Side Protection
- **Turnstile Captcha**: All form-based blocks (`lead_form`, `lead_magnet`, `multi_step_form`) MUST render the Cloudflare Turnstile widget via `TurnstileService`.
- **Device Fingerprinting**: Every submission MUST include an anonymous SHA-256 fingerprint generated via `FingerprintUtils.getFingerprint()`.

### B. Secure Data Pipeline (Mandatory)
- **NO Direct DB Inserts**: NEVER perform direct `supabase.from('leads').insert()` from the client.
- **Edge Function Proxy**: All lead submissions MUST be routed through the `lead-submit` Edge Function. This function enforces:
    1. Turnstile token verification with Cloudflare.
    2. IP-based rate limiting (10/hr).
    3. Fingerprint-based rate limiting (5/10min).

---

## 📈 5. Advanced Analytics & Visitor Tracking

LandyMaker tracks high-fidelity analytics to provide users with accurate conversion data:
- **Unique Visitor Tracking**: Accomplished via `visitor_fingerprint` in the `analytics` table.
- **Enhanced Metrics**: The `get_enhanced_page_stats` RPC calculates Total Views, Unique Visitors, and Conversions. 
- **Accurate Conversion Rate**: Calculated as `(Total Conversions / Unique Visitors) * 100`.

---

## 🔔 6. Real-Time Notification Ecosystem

The platform features a multi-channel notification system:
- **In-App Inbox**: Managed by `NotificationCubit` using Supabase Realtime (broadcast) for instant updates.
- **Web Push (FCM)**: Background notifications via Firebase Cloud Messaging. 
- **Webhook Protection**: The `lead-notify` Edge Function is protected by `WEBHOOK_SECRET`. Any manual call without a valid Bearer token MUST be rejected.

---

## 🌍 7. Multi-Tenant Domain & Path Routing

LandyMaker supports four methods of routing resolved by `TenantRoutingService` at startup:
1. **Path-Based Slugs**: `landymaker.com/restaurant-x`
2. **Subdomains**: `restaurant-x.landymaker.com`
3. **Custom Domains**: `restaurant-x.com`
4. **Local Query Params**: `localhost:xxxx/?tenant=restaurant-x`

### ⚠️ Reserved Paths Constraint
To prevent landing pages from hijacking core app paths, `TenantRoutingService.reservedPaths` contains blocked slugs (`login`, `dashboard`, `api`, `blog`, etc.).

---

## 📈 5. Vercel SEO Edge Middleware

`middleware.js` acts as an Edge Routing, Domain/Tenant Resolution, and Bot-Detection Proxy:
- Proxies Next.js Headless Blog traffic on core domains (`/blog`).
- Serves dynamic `/robots.txt` and `/sitemap.xml` for custom domains.
- Detects crawlers and maps full block arrays (`hero`, `pricing`, etc.) into raw Semantic HTML5 strings with JSON-LD for Search Engines, bypassing Flutter Canvas constraints.

---

## 🔐 6. Authentication & Account Management

Auth is controlled by `AuthCubit` via Supabase:
- Registration auto-logs users in to the dashboard.
- Password resets utilize query tokens parsed securely in `ResetPasswordScreen`.
- `AuthCubit` tracks session restoration reactively to avoid startup race conditions.

---

## ⚙️ 7. API Logging & Telemetry

- **`logger` Wrapper**: `lib/core/logger.dart`.
- **`SupabaseLoggingMixin`**: Intercepts DB queries and Auth changes.
- **EventAnalyticsService**: Dedicated to structured logging of business events (views, conversions, form submissions). 

---

## 🌍 8. Localization & RTL Patterns

LandyMaker is bilingual (Arabic & English) and **Arabic-First** (native RTL):
- `context.translate('key')` maps to translations dictionary.
- `context.isRtl` determines alignment logic.
- Always use `EdgeInsetsDirectional` instead of hardcoded `EdgeInsets.only(left/right)`.

---

## 🧠 9. Strict AI Assistant Rules (MUST FOLLOW)

1. **Reusability First**: Do not build redundant code. Check `lib/core/widgets/` first.
2. **State-Management Cleanliness**: UI widgets must rebuild reactively. Local state (`setState`) is permitted for strictly internal component UI logic (e.g. form validation, loading spinners).
3. **Build-Phase Redirect Guard**: Wrap route changes in `WidgetsBinding.instance.addPostFrameCallback`.
4. **Bilingual Arabic-First Support**: Always add keys to both `translations_ar` and `translations_en`.
5. **Slug Validation**: Validate subdomains against reserved paths.
6. **Layout & Responsivity Rules (CRITICAL)**: 
   - 80px desktop vertical padding, 40px mobile. Do not hardcode heights for containers wrapping text.
   - **Never** use `MediaQuery.of(context).size` inside block widgets (`public_viewer/widgets`) to determine `isMobile` or column counts. This breaks the Builder Preview where components render in small simulated containers on large desktop screens.
   - **Always** wrap the widget in `LayoutBuilder` and use `constraints.maxWidth` (e.g., `final bool isMobile = constraints.maxWidth < 600;`).
   - For grids and layout utils, explicitly pass `width: constraints.maxWidth` to `ResponsiveUtils` methods (like `getGridCrossAxisCount(width: constraints.maxWidth)`) and `ResponsiveLayout.getScreenType(context, width: constraints.maxWidth)`.
   - Protect text from `RenderFlex Overflow` in nested columns by using `Expanded`/`Flexible` and adding `maxLines` and `overflow: TextOverflow.ellipsis`.
   - When animating with `Interval`, always clamp the bounds to prevent `Assertion failed end <= 1.0`: `Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0))`.
   - Never use scrollable physics inside block components (`ListView` or `GridView` inside `public_viewer`). Always use `shrinkWrap: true` and `physics: const NeverScrollableScrollPhysics()` to let the parent `SectionRenderer` handle global scrolling.
7. **Widget State & Animation Rules**:
   - Use `TickerProviderStateMixin` instead of `SingleTickerProviderStateMixin` if a widget instantiates multiple animation controllers or generates them dynamically inside a loop.
   - Always combine `type`, `index`, and `hashCode` (e.g., `ValueKey("${type}_${index}_${block.hashCode}")`) when generating unique `Key`s or `GlobalKey`s inside dynamically built lists to avoid "Duplicate GlobalKey" crashes.
   - Never wrap `AnimatedSwitcher` or `PageView` inside a `SingleChildScrollView` if its children might instantiate conflicting scroll controllers. Keep scroll contexts completely isolated.
8. **Form Submission & Data Flow**:
   - Always manage an explicit `isLoading` state during async operations (especially form submissions) to disable buttons and prevent double-submits.
   - Provide inline success/error feedback inside the widget instead of relying on silent failures or generic snackbars alone.
9. **UI/UX Design Patterns (CRITICAL)**:
   - **Social Auth**: Always use the reusable `SocialSignInButton` for OAuth flows to ensure branding consistency.
   - **Tables & Lists**: Use `ResponsiveDataTable` for all dashboard data. It MUST implement a card-based fallback for mobile (`maxWidth < 600`) to prevent horizontal overflows.
   - **Modals**: For complex editors or large lists (SEO, Section Library, Image Picker), always use `DraggableModalSheet`. This allows users to expand the modal to full-screen on demand.
   - **Legal Compliance**: Every registration/auth flow must include a `RichText` notice linking to `/privacy-policy` and `/terms`.
10. **Workspace Cleanliness**:
   - Never create `.py`, `.sh`, or temporary markdown audit files in the project directory for debugging. Keep the repository strictly limited to production code and documentation.
11. **Complex Tasks**: Use SPEC-KIT methodology in `.specify/` when requested.
12. **Environment Variable Hygiene**: All sensitive keys (Firebase, Turnstile) read via `String.fromEnvironment` MUST be cleaned using the `_cleanEnv` helper logic or `EnvUtils.get()` to strip potential quotes (`"` or `'`) added in `.env.local`.
13. **Edge Function Development Rules**:
    - **Absolute URLs**: Always use full URLs for imports (e.g., `https://esm.sh/...`).
    - **Strict Typing**: Always define explicit types for Request/Response and catch blocks (`error: unknown`).
    - **CORS Handling**: Every function must handle `OPTIONS` requests and return proper `Access-Control-Allow-Origin` headers.
    - **IDE Support**: Use `tsconfig.json` and `deno-types.d.ts` for IDE support. Do not delete or ignore these files.
14. **Data Integrity**: Never perform arithmetic operations on potential zero values in the UI (e.g., conversion rate) without a safety check (`visitors > 0`).

---

## 🖼️ 10. Unified Image Management & Media Picker System

LandyMaker features a centralized, robust Image Media Picker and Background Upload system used across the Builder Workspace:
- **Sources Supported**: 
  - **Local Device**: Uploads compress instantly using `image_picker` (max 1920x1920, 88% quality) to ensure lightweight assets before uploading.
  - **Pixabay API**: Search and paginate through free stock images. To comply with Pixabay ToS (no hotlinking), images are downloaded into memory (`Uint8List`) and instantly proxied/uploaded to ImgBB without touching the local file system. Supports advanced filtering (`photo`, `illustration`, `vector`). Safely handles Rate Limiting (429 HTTP status).
  - **Direct URL**: Users can paste an external URL.
- **Upload Pipeline**: Powered by `ImageMediaService` via `Dio` and managed globally by `UploadManagerCubit`.
- **Background Upload Architecture**: When a user selects an image via `ImagePickerModal`, the UI optimistically renders a placeholder with the scheme `upload://{timestamp}`. The actual byte data is delegated to `UploadManagerCubit` which uploads in the background and eventually replaces the `upload://` scheme with the final `https://` ImgBB URL.

### 🚨 Strict Guidelines for Image Rendering (MUST FOLLOW)
- **Always use `CustomNetworkImage`**: Whenever you need to display an image from a URL, whether it's an uploaded asset, background image, or any internet link, you **MUST** use `CustomNetworkImage`. Do **NOT** use `Image.network` or `CachedNetworkImage` directly. 
- **Why?**: `CustomNetworkImage` natively resolves the internal `upload://...` scheme showing real-time upload progress, handles network shimmer loading, and crucially sets memory bounds (`memCacheWidth` and `maxWidthDiskCache: 1200`) to prevent Out-Of-Memory (OOM) app crashes when displaying many images inside grids or canvas blocks.

---

## 🚀 11. CI/CD Pipeline & Deployment Architecture (CRITICAL — READ BEFORE ANY DEPLOY)

This section documents how LandyMaker is built and deployed. **Every AI assistant MUST read this before touching anything related to deployment, assets, icons, or secrets.**

### 11.1 — Project Layout on Vercel (Two Separate Projects)

| Vercel Project | Project ID | URL | Source |
|---|---|---|---|
| `landymaker` | `prj_dDwATAOXwcnKLc7nh0wVRIqDjqjV` | `landymaker.com` | Main Flutter Web App |
| `landymaker-blog` | `prj_ONp0ZC8l6Udq8o13iXXjmAWWD7vc` | `landymaker-blog.vercel.app` | Next.js Blog (`blog-frontend/`) |

Both are in the **same GitHub repository**: `abdallah-azmy/landymaker`

- The **main app** (`landymaker`) is a Flutter Web app. Its Vercel Output Directory is `build/web`.
- The **blog** (`landymaker-blog`) is a Next.js 16 app located in `blog-frontend/`. It deploys via its own Vercel auto-deployment triggered from the repo root.

### 11.2 — Main App (Flutter) CI/CD Pipeline

**⚠️ CRITICAL WARNING**: The `public/` and `/build/` directories are both in `.gitignore`. They are **NEVER committed to Git**. Do NOT try to commit them.

**The ONLY correct way to deploy the main app** is via GitHub Actions:

```
.github/workflows/deploy.yml
```

**Pipeline Flow (MUST match this exactly):**
```
1. Checkout code from GitHub
2. Setup Node.js 24
3. Setup Flutter 3.35.3 (stable) using subosito/flutter-action@v2
4. flutter pub get
5. flutter build web --release \
     --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
     --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }} \
     --dart-define=IMGBB_API_KEY=${{ secrets.IMGBB_API_KEY }}
   → Output goes to: build/web/
6. Create .vercel/project.json (link to projectId)
7. npm install -g vercel@latest
8. vercel pull --yes --environment=production --token=${{ secrets.VERCEL_TOKEN }}
9. vercel build --prod  (reads from build/web via Output Directory setting)
10. vercel deploy --prebuilt --prod
```

**⚠️ KNOWN ISSUE — Vercel Auto-Deploy Race Condition:**
Vercel also triggers its own auto-deploy when a push happens to `main` (separate from GitHub Actions). This Vercel auto-deploy has NO Flutter build — it just finds an empty `build/web` and deploys nothing useful. It finishes in ~8 seconds. The GitHub Actions build finishes in ~2-3 minutes and then deploys the correct Flutter-built output. If the Vercel auto-deploy runs AFTER GitHub Actions, it will overwrite the correct deploy with an empty one.

**Permanent Fix (TODO):** Disable Vercel's Git auto-deployment in the Vercel Dashboard:
- Go to: `vercel.com/azmy-s-projects/landymaker/settings/git`
- Disable "Auto-Deploy on Push"
- Leave GitHub Actions as the **only** deploy trigger

### 11.3 — Blog (Next.js) CI/CD Pipeline

The blog in `blog-frontend/` is auto-deployed by Vercel directly when changes are pushed to `main`.

**Blog Vercel Project Settings:**
- Output Directory: `.next` (auto-detected by Next.js preset)
- Environment Variables must be set in the Vercel Dashboard for `landymaker-blog` project:
  - `NEXT_PUBLIC_SUPABASE_URL`
  - `NEXT_PUBLIC_SUPABASE_ANON_KEY`

**⚠️ KNOWN ISSUE — Blog 404 Caching:**
Next.js blog post pages were previously set to `revalidate = 60`, which caused Vercel to cache 404 responses for 60 seconds. When a page was first hit before Supabase responded, the 404 was cached. Fix applied: `export const dynamic = 'force-dynamic'` + `revalidate = 0` in `blog-frontend/app/blog/[slug]/page.tsx`. **Do NOT revert this.**

### 11.4 — Secrets & Environment Variables

**🔐 SECURITY RULES — MUST FOLLOW:**
1. **NEVER hardcode secrets** in any source file.
2. **NEVER commit `.env.local`** or any `.env*` file (already in `.gitignore`).
3. Flutter reads secrets via `--dart-define` at **build time** — not at runtime.
4. The Edge middleware (`middleware.js`) reads `process.env.SUPABASE_URL` and `process.env.SUPABASE_ANON_KEY` from Vercel environment variables.

**Required GitHub Repository Secrets** (`Settings → Secrets → Actions`):

| Secret Name | Used By | Description |
|---|---|---|
| `SUPABASE_URL` | Flutter build + middleware.js | Supabase project URL |
| `SUPABASE_ANON_KEY` | Flutter build + middleware.js | Supabase anonymous/public API key |
| `IMGBB_API_KEY` | Flutter build | ImgBB image hosting API key |
| `VERCEL_TOKEN` | GitHub Actions deploy step | Vercel CLI authentication token |

**Required Vercel Environment Variables** (set in Vercel Dashboard for `landymaker` project):

| Variable | Used By |
|---|---|
| `SUPABASE_URL` | `middleware.js` (Edge Runtime) |
| `SUPABASE_ANON_KEY` | `middleware.js` (Edge Runtime) |
| `PIXABAY_API_KEY` | `middleware.js` or API routes (if any) |
| `IMGBB_API_KEY` | `middleware.js` or API routes (if any) |

**Required Vercel Environment Variables** (set in Vercel Dashboard for `landymaker-blog` project):

| Variable | Used By |
|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | `blog-frontend/lib/supabase.ts` (Next.js client) |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `blog-frontend/lib/supabase.ts` (Next.js client) |

**Local Development** (`.env.local` — never committed):
```
PIXABAY_API_KEY=...
IMGBB_API_KEY=...
SUPABASE_URL=https://zajcnkpcdsvswfmsmqpt.supabase.co
SUPABASE_ANON_KEY=eyJ...
```
Run Flutter locally with:
```bash
flutter run -d chrome \
  --dart-define-from-file=.env.local
```

### 11.5 — App Icons & Assets

**⚠️ CRITICAL — Where Icons Live (Two Places):**

The project has **two sets** of icon/asset files. Both must be updated when changing the logo:

| Location | Purpose | What Deploys It |
|---|---|---|
| `web/favicon.png` | Browser tab icon (Flutter source) | Copied to `build/web/` by `flutter build web` |
| `web/icons/Icon-*.png` | PWA icons (Flutter source) | Copied to `build/web/icons/` by `flutter build web` |
| `web/logo_social.webp` | Social share OG image (Flutter source) | Copied to `build/web/` by `flutter build web` |
| `assets/images/logo.webp` | In-app logo (large, Flutter asset) | Bundled inside Flutter app |
| `assets/images/logo_small.webp` | In-app logo (small, Flutter asset) | Bundled inside Flutter app |
| `public/` *(gitignored)* | ⛔ LOCAL ONLY — never deployed via git | Used only for local `vercel dev` testing |

**When changing the logo, you MUST update all 5 files in `web/` and `assets/images/`. The files in `public/` are local artifacts and will be overwritten by `flutter build web` anyway.**

**Logo Generation (if needed — use Python Pillow):**
```python
from PIL import Image
src = Image.open("new_logo_1024x1024.png")

# Required outputs:
src.resize((32, 32)).save("web/favicon.png", "PNG")
src.resize((192, 192)).save("web/icons/Icon-192.png", "PNG")
src.resize((512, 512)).save("web/icons/Icon-512.png", "PNG")
# Maskable (safe zone = 80% inner area):
m192 = Image.new("RGB", (192,192), (0,0,0)); m192.paste(src.resize((150,150)), (21,21)); m192.save("web/icons/Icon-maskable-192.png")
m512 = Image.new("RGB", (512,512), (0,0,0)); m512.paste(src.resize((400,400)), (56,56)); m512.save("web/icons/Icon-maskable-512.png")
# Social share (1200x630):
social = Image.new("RGB",(1200,630),(0,0,0)); social.paste(src.resize((500,500)),(350,65)); social.save("web/logo_social.webp","WEBP",quality=90)
# In-app assets:
src.resize((500,500)).save("assets/images/logo.webp","WEBP",quality=90)
src.resize((128,128)).save("assets/images/logo_small.webp","WEBP",quality=90)
```

### 11.6 — Blog URL Routing

The blog lives at `landymaker.com/blog/...` but is served from a **separate Vercel project** (`landymaker-blog`). The routing is handled by `middleware.js` (Edge Middleware) in the root project:

```
User visits landymaker.com/blog/post-slug
       ↓
middleware.js detects /blog path
       ↓
Rewrites request to landymaker-blog.vercel.app/blog/post-slug
       ↓
Next.js serves the blog post from Supabase blog_posts table
```

**⚠️ Do NOT add `blog` as a Flutter route** — it will conflict with the middleware proxy.

**⚠️ CRITICAL MIDDLEWARE & VERCEL.JSON ROUTING RULES (MUST FOLLOW):**
1. **Middleware Precedence**: The Blog & Next.js assets routing logic (`/blog` and `/_next`) **MUST** reside at the very top of `middleware.js`. If it is placed below static asset verification (`staticExtensions`), Next.js chunk and script files (like `_next/static/chunks/...js`) will trigger the early-exit check and return the Flutter app index, causing the blog layout to fail and return **404 (This page could not be found)** errors on Next.js resources.
2. **vercel.json Blanket Rewrite Bypass**: The `vercel.json` file controls routing at the Vercel server level. The default Flutter rewrite rule **MUST** exclude blog routes and assets:
   ```json
   "source": "/((?!blog|_next|sitemap\\.xml|robots\\.txt|llms\\.txt).*)"
   ```
   If it is set to a catch-all `/(.*)` without exclusions, Vercel will rewrite Next.js/blog assets back to `/index.html`, leading to persistent black screens and 404 errors on blog posts.

### 11.7 — Troubleshooting Common CI/CD Problems

| Symptom | Cause | Fix |
|---|---|---|
| Icons/favicon didn't update after push | Vercel auto-deploy (not GitHub Actions) ran last | Disable Vercel Git auto-deploy; push a new commit to trigger GitHub Actions |
| Blog posts show 404 | `dynamic` not set; Vercel cached the 404 | Ensure `export const dynamic = 'force-dynamic'` is in `[slug]/page.tsx` |
| Blog posts show 404 / Black screen | Blog assets (`/_next/static/..`) intercepted by Flutter's static checker | Ensure Blog rewrite logic is at the absolute top of `middleware.js` before `staticExtensions` test |
| Blog posts show 404 / Catch-all rewrite | `vercel.json` overrides middleware and rewrites `/blog` to `/index.html` | Ensure the regex in `vercel.json` excludes `blog`, `_next`, and SEO assets |
| Flutter app shows blank/broken | `--dart-define` secrets missing from GitHub Secrets | Add `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `IMGBB_API_KEY` to GitHub repo secrets |
| `vercel deploy` fails with "path not found" | Running `vercel deploy` from inside `blog-frontend/` with Vercel root dir mismatch | Never run `vercel deploy` manually — always use GitHub Actions |
| Middleware returns 500 errors | Missing Vercel environment variables for `middleware.js` | Add `SUPABASE_URL` + `SUPABASE_ANON_KEY` to Vercel Dashboard for `landymaker` project |
