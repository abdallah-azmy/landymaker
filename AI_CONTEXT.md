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
│   ├── constants/          # Application constants
│   ├── forms/              # Validation Engine and Field Renderer
│   ├── localization/       # Translations dictionaries (ar/en)
│   ├── responsive/         # Layout breakpoints and responsive builder widgets
│   ├── router/             # GoRouter routing rules (app_router.dart)
│   ├── services/           # Low-level core services (Analytics, Turnstile)
│   ├── theme/              # Styles, palettes, and light/dark theme schemes
│   ├── utils/              # Utility helpers
│   └── widgets/            # Generic shared UI atoms/molecules
├── features/               # Isolated domain-specific feature modules
│   ├── auth/               # Auth state machine
│   ├── blog_admin/         # Blog article publishing & synchronizer UI
│   ├── builder/            # Flex-Editor workspace, registries, block properties editors
│   ├── dashboard/          # Shell, analytics, leads charts, custom domain configuration
│   ├── home/               # SaaS marketing website UI, template picker
│   ├── public_viewer/      # High-performance section renderer for published pages
│   ├── subscription/       # Payment modals, tier limits
│   └── super_admin/        # Platform-level metrics and configurations
├── services/               # Infrastructure Client Adaptors
├── injection_container.dart # Dependency Injection Container (GetIt locator)
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
- `multi_step_lead_form`: Step-based lead qualification form for complex quotes, bookings, and eligibility flows.
- `working_hours`: Store or business opening hours display.
- `location_map`: Google Maps / Map embed block.
- `trust_logos`: Horizontal row of trusted brand logos.
- `animated_counter`: Animated numbers representing statistics or milestones.
- `social_qr`: Display of social media links alongside a QR code.
- `whatsapp`: WhatsApp direct chat CTA block.
- `basic_section`: Empty rich-text section.

### Template & AI-Agent Preparation Notes
- `TemplateRegistry.availableTemplates` is the authoritative template catalog for the dashboard and template picker.
- Template block JSON may include non-rendering helper keys such as `ai_intent`, `ai_slots`, and metadata hints. Renderers must ignore unknown keys and continue reading only their supported schema fields.
- Future AI Agent tools should choose from registered block `type` values only. Do not generate a new type unless a renderer, editor, builder default, and documentation entry exist.
- Section selection should prefer specialized blocks first (`products`, `pricing`, `multi_step_lead_form`, `location_map`) and fall back to `basic_section` only for custom layouts that do not match an existing section.

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
- **AI Security**: All AI generation calls MUST be routed through `ai-page-generate` or `ai-copywrite` Edge Functions. These functions enforce tier-based quotas via the `ai_usage_log` table and `check_ai_quota` RPC.

---

## 📈 5. Advanced Analytics & Visitor Tracking

LandyMaker tracks high-fidelity analytics to provide users with accurate conversion data:
- **Unique Visitor Tracking**: Accomplished via `visitor_fingerprint` in the `analytics` table.
- **Enhanced Metrics**: The `record_page_event` RPC records granular events (`view`, `conversion`, `cta_click`, `whatsapp_open`, `funnel_start`, `funnel_complete`).
- **Metadata Support**: New events capture `metadata` (JSONB) such as button text, target URLs, and form IDs.
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

## 📈 8. Vercel SEO Edge Middleware

`middleware.js` acts as an Edge Routing, Domain/Tenant Resolution, and Bot-Detection Proxy:
- Proxies Next.js Headless Blog traffic on core domains (`/blog`).
- Serves dynamic `/robots.txt` and `/sitemap.xml` for custom domains.
- Detects crawlers and maps full block arrays (`hero`, `pricing`, etc.) into raw Semantic HTML5 strings with JSON-LD for Search Engines, bypassing Flutter Canvas constraints.

---

## 🔐 9. Authentication & Account Management

Auth is controlled by `AuthCubit` via Supabase:
- Registration auto-logs users in to the dashboard.
- Password resets utilize query tokens parsed securely in `ResetPasswordScreen`.
- `AuthCubit` tracks session restoration reactively to avoid startup race conditions.

---

## ⚙️ 10. API Logging & Telemetry

- **`logger` Wrapper**: `lib/core/logger.dart`.
- **`SupabaseLoggingMixin`**: Intercepts DB queries and Auth changes.
- **EventAnalyticsService**: Dedicated to structured logging of business events (views, conversions, form submissions). 

---

## 🌍 11. Localization & RTL Patterns

LandyMaker is bilingual (Arabic & English) and **Arabic-First** (native RTL):
- `context.translate('key')` maps to translations dictionary.
- `context.isRtl` determines alignment logic.
- Always use `EdgeInsetsDirectional` instead of hardcoded `EdgeInsets.only(left/right)`.

---

## 🛡️ 12. PROTECTED CORE SYSTEMS

The following systems are considered mission-critical and must never be broken without explicit validation.

## Builder Engine

Includes:

- Builder Workspace
- Drag & Drop System
- Section Management
- Live Preview
- Auto Save
- Undo / Redo
- **Global Design & Animation System (V2)**: 10 Shapes (Variants) per section and performance-optimized `BlockAnimationWrapper`.
- **Theme Management**: `BuilderThemeCubit` owns `LandingPageTheme` (colors, fonts, backgrounds) separately from `LandingPageBuilderCubit`. The main cubit subscribes to the theme cubit's stream and syncs into `BuilderLoaded.theme` — keeping all existing widgets reading `state.theme` unchanged.

## Rendering Pipeline

Includes:

- JSON Schema
- Schema Validation
- Parser Layer
- SectionRenderer
- Dynamic Rendering
- **Style Wrapper Layer**: Handles Glassmorphism, Neumorphism, and Floating 3D global variants.

## Action System

Includes:

- ActionHandlerService: Central command center for CTAs.
- Navigation Actions: `link`, `scroll_to_section`.
- Form Actions: `submit`, `whatsapp_auto_open`.
- Button Actions: `checkout`, `open_modal`.
- **Smart WhatsApp**: Intercepts leads before opening WhatsApp via `ActionHandlerService.openWhatsApp`.

## Publishing System

Includes:

- **Draft / Publish Lifecycle**: New pages start as draft (`isPublished: false`). Explicit "Publish" in `BuilderAppBar` shows a confirmation dialog with the public URL. "Save Draft" saves without publishing. `BuilderOptionsModal` also exposes both actions.
- Site Generation
- SEO Metadata Generation
- Sitemap Generation
- OpenGraph Generation

## Lead Capture System

Includes:

- Lead Forms
- Supabase Submission Flow
- Turnstile Validation
- Rate Limiting
- Fingerprint Protection

## Security Layer

Includes:

- Environment Variables
- Secrets Management
- Edge Functions
- RLS Assumptions
- Authentication Flows

## SEO Layer

Includes:

- Metadata
- Structured Data
- Canonical URLs
- OpenGraph
- Twitter Cards
- Indexability

## AI Documentation Layer (CRITICAL)

Includes:

### Active Documentation (`/docs/ai/`)
- AI Navigation System: `AI_NAVIGATION.md`
- Feature and Screen Indexes: `FEATURE_INDEX.md`, `SCREEN_INDEX.md`, `ROUTE_INDEX.md`
- Service Index: `SERVICE_INDEX.md`
- Builder Architecture Guides: `BUILDER_ARCHITECTURE.md`, `BLOCK_SCHEMA_REGISTRY.md`
- Dependency Maps: `DEPENDENCY_MAPS.md`
- Project Structure: `PROJECT_STRUCTURE.md`
- Task Routing Guide: `TASK_ROUTING_GUIDE.md`
- AI Onboarding: `AI_ONBOARDING.md`
- Documentation Rules: `AI_DOCUMENTATION_RULES.md`

### Historical Reports (`/docs/archive/`)
- **Mission Execution Plan**: `MISSION_EXECUTION.md` (Tracks implemented Growth & AI features)
- **Security Audit**: `SECURITY_AUDIT_REPORT.md` (Mission verification)
- **AI Agent Specs**: `AI_AGENT_REPORT.md` (Agent cost & quality optimization)
- **Guest Flow**: `GUEST_FLOW_GUIDE.md` (Guest AI generation logic)
- **Continuation Prompt**: `AI_AGENT_CONTINUATION_PROMPT.md` (Master plan for future AI models)
- **Interactive AI Agent Reports**: Analysis, Architecture, and Final Report

Any task affecting one of these systems MUST:

1. Identify impact.
2. Validate impact.
3. Explain impact.
4. Preserve backward compatibility.
5. Include manual verification steps.

---


## 🧠 13. **Strict AI Assistant Rules (MUST FOLLOW)**:

1. **Professional Builder Standards**: Every section editor MUST follow the strict tabbed structure: **[Content, Actions, Design]**.
   - **Content**: Pure text, images, and list data.
   - **Actions**: Buttons, links, WhatsApp numbers, and form success redirects.
   - **Design**: Section Variants (0-9), Animations, Fonts, Backgrounds, and Opacity.
2. **Animation Performance**: All block animations must utilize `BlockAnimationWrapper` with `RepaintBoundary` to prevent global repaints. Additionally, any widget with continuous or expensive per-frame animations (AnimatedBuilder, staggered entrance sequences, hover-driven AnimatedSlide/AnimatedContainer changes) MUST be wrapped in `RepaintBoundary` to isolate repaint cycles. Apply this especially to: section-level scroll-triggered entrance animations, card hover effects inside grids (bento, stats, testimonials), and background gradient pulsers.
3. **RTL Responsiveness**: Always use `EdgeInsetsDirectional` and ensure `Transform` animations respect the text direction (LTR/RTL).
4. **Image Management**: Use `CustomImageField` for all image properties.
5. **Deprecated API Prohibition**: Always use `withValues(alpha:)` instead of the deprecated `withOpacity()` method for color opacity. `withValues()` is the Dart 3.9+ standard and avoids the implicit `Color` → `Color` conversion that `withOpacity()` performs internally.
3. **Visual Safety**: Every section with a background image MUST include a `bg_overlay_opacity` slider (0.0 to 1.0) to ensure text remains readable.
4. **Reusability First**: Do not build redundant code. Check `lib/core/widgets/` first. Use `CustomTextField` for all inputs to maintain the slate-dark theme.
5. **State-Management Cleanliness**: UI widgets must rebuild reactively. Local state (`setState`) is permitted for strictly internal component UI logic (e.g. form validation, loading spinners).
6. **Build-Phase Redirect Guard**: Wrap route changes in `WidgetsBinding.instance.addPostFrameCallback`.
7. **Bilingual Arabic-First Support**: Always add keys to both `translations_ar` and `translations_en`.
8. **Slug Validation**: Validate subdomains against reserved paths.
9. **Layout & Responsivity Rules (CRITICAL)**: 
   - Standard sections: 80px desktop vertical padding, 40px mobile. Content container constrained to `BoxConstraints(maxWidth: 1200)` and centered. Edge-to-edge full-width layouts (like `HeroLayout.fullWidthImage` or `CtaLayout.fullWidthImage`): the outermost container has ZERO padding, the image uses `Positioned.fill` with a dark overlay (alpha ≥ 0.55), and the content wraps inside a centered container with `BoxConstraints(maxWidth: 1200)` and `EdgeInsetsDirectional.symmetric(horizontal: 24)`.
   - Do not hardcode heights for containers wrapping text. Use `minHeight` and `ConstrainedBox` where flexible sizing is needed.
   - **Never** use `MediaQuery.of(context).size` inside block widgets to determine `isMobile`.
   - **Always** wrap the widget in `LayoutBuilder` and use `constraints.maxWidth` (e.g., `final bool isMobile = constraints.maxWidth < 600;`).
   - **Strict `EdgeInsetsDirectional` rule**: Never use `EdgeInsets.only(left: ...)` or `EdgeInsets.only(right: ...)`. Always prefer `EdgeInsetsDirectional.only(start: ...)` / `EdgeInsetsDirectional.only(end: ...)` for RTL/LTR support. `EdgeInsets.symmetric(horizontal: ...)` is acceptable where the padding is equal on both sides.
   - **Never** use `GridView` with `SliverGridDelegateWithFixedCrossAxisCount` and a fixed `childAspectRatio` for text-heavy content cards, as this causes overflow or excessive white space. Use `Row`/`Column` loops with `ResponsiveUtils.getContentColumns` and auto-height instead.
   - **Never** use a `LayoutBuilder` inside the children of an `IntrinsicHeight` widget. `LayoutBuilder` cannot return intrinsic dimensions and will cause an immediate crash. Pre-calculate layout decisions at the parent level.
   - For complex presentation mockups or rigid decorative elements (like Hero Phone Previews), wrap them in `FittedBox(fit: BoxFit.scaleDown)` to prevent `RenderFlex overflow` on intermediate screen widths.
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
   - **PROTECTION RULE**: Never delete files inside `/docs/ai/` as they are essential for AI-assisted development and context reduction.
11. **Complex Tasks**: Use SPEC-KIT methodology in `.specify/` when requested.
12. **Environment Variable Hygiene & CI/CD (CRITICAL)**:
   - **Pattern**: NEVER use dynamic retrieval for environment variables. `String.fromEnvironment` MUST be used as a `const` constructor with a string literal key.
   - **Centralization**: All environment variables MUST be defined as static getters in `lib/core/utils/env_utils.dart`.
   - **Cleaning**: Always wrap the `const String.fromEnvironment` call with `cleanEnv()` to strip potential quotes added by CI/CD or `.env` files.
   - **Deployment**: When adding a new environment variable, you **MUST** update the `Build Flutter Web` step in `.github/workflows/deploy.yml` to include the new `--dart-define` flag.
   - **GitHub Secrets**: Remind the user to add the corresponding secret to GitHub Repository Secrets. Failure to do this will result in empty values in production.
   - **Example**:
     ```dart
     static String get myNewKey => cleanEnv(const String.fromEnvironment('MY_NEW_KEY'));
     ```
 13. **Edge Function Development Rules (CRITICAL)**:
    - **Absolute URLs**: Always use full URLs for imports (e.g., `https://esm.sh/...`).
    - **Strict Typing**: Always define explicit types for Request/Response and catch blocks (`error: unknown`).
    - **CORS Handling**: Every function must handle `OPTIONS` requests and return proper `Access-Control-Allow-Origin` headers.
    - **IDE Support**: Use `tsconfig.json` and `deno-types.d.ts` for IDE support. Do not delete or ignore these files. Ensure `"resolveJsonModule": true` and `"allowSyntheticDefaultImports": true` are present when working with JSON schemas.
    - **RLS & Security Bypass**: Whenever an Edge Function needs to write to internal logging/quota tables (e.g. `ai_usage_log`) that are hidden behind RLS, it MUST instantiate a separate `adminSupabase` client using `SUPABASE_SERVICE_ROLE_KEY`. Never use the `ANON_KEY` for background service operations to avoid exposing tables to the public.
    - **Information Disclosure**: Never pass raw backend database error strings (e.g., PostgreSQL errors) directly to the client. Always wrap unknown errors in a generic fallback message and log the real error server-side (`console.error`).
    - **Cache Stampede Prevention**: When implementing in-memory caching for third-party APIs (like Pixabay) inside edge functions, always store the **Promise** in the cache rather than the resolved value. This prevents concurrent identical requests from firing multiple HTTP calls before the first one resolves.
14. **Data Integrity**: Never perform arithmetic operations on potential zero values in the UI (e.g., conversion rate) without a safety check (`visitors > 0`).
15. **Safe Sizing & Numeric Parsing (CRITICAL)**:
    - Always use `NumericParser` to parse and coerce font sizes, spacing, padding, margins, or image width/height from dynamic design maps or style overrides.
    - Never call `.toDouble()` or `.toInt()` directly on dynamic lookups without checking the type or using `NumericParser`. AI models or web configurations might return strings with CSS units (e.g. `"18px"`, `"100%"`), which will cause runtime exceptions when cast directly.
16. **Unconstrained Image Sizing Safety (CRITICAL)**:
    - Never set the placeholder/shimmer width or height of network images (such as in `CustomNetworkImage`) to `double.infinity` by default if they can be placed inside unconstrained layout axes.
    - For example, setting `height` to `double.infinity` when rendering inside a vertical scrollable (like a `ListView` or `SingleChildScrollView`) will trigger a "BoxConstraints forces an infinite height" crash. Always leave unconstrained width as `null` and fallback unconstrained height to a default finite size (e.g., `200.0`).
17. **AI Design Map Application Safety (CRITICAL)**:
    - In `LandingPageBuilderCubit.applyDesignJson`, always merge updated design fields (such as `blocks`, `theme`, `sticky_cta`, `business_name`, etc.) into the existing `designMap` rather than replacing the entire map with the AI payload. This preserves vital page settings (e.g. `subdomain`) when they are omitted in the AI's response.
18. **Partial Edit Fault Tolerance & Subset Heuristic (CRITICAL)**:
    - In `applyDesignJson`, if `isPartial` is false but the incoming blocks list is a smaller subset of the current page blocks, use the subset edit heuristic to automatically match and merge the incoming block(s) by type into the existing blocks list. Never replace the entire page with a partial list, as this wipes out the page.
19. **Partial Edit Validation Safety (CRITICAL)**:
    - In `AIResponseValidator.validate`, if `isEdit` is true, the validator must resolve the block `type` from the existing blocks list (`currentBlocks`) if the AI omitted it in partial edits.
    - Also, do not discard list blocks (like `features`, `pricing`, `faq`, `testimonials`) during edits just because they lack the `items` key (which is normally omitted when the AI edits other properties like backgrounds).
20. **Theme Editing Merge Principle (CRITICAL)**:
    - In `applyDesignJson`, always merge incoming theme/global_theme modifications with the current theme map instead of replacing it. This prevents other unspecified colors and fonts from resetting to default values.
21. **Section Image Updates (CRITICAL)**:
    - In `AIGenerationCubit`, when Pixabay selection completes, check if `elementId` is null. If it is null (block-level property like background image), use `_builderCubit.updateBlockProperty` rather than `updateElementProperty` to correctly apply the image to the block.
22. **Merge Safety (CRITICAL)**:
    - Before merging incoming block map properties (via `existing.addAll` / `merged.addAll`), recursively strip any keys whose value is `null` or `""` (empty string) using the `_cleanIncomingMap` helper. This prevents lazy AI responses from overwriting existing valid content and breaking images.
23. **Non-Destructive Blocks Merge (CRITICAL)**:
    - If the AI returns block updates that are not subset edits, merge them block-by-block sequentially using type-matching, but preserve all remaining unmodified blocks rather than truncating/discarding the list.
24. **Proper Pivot Detection Timing (CRITICAL)**:
    - Capture the `oldIndustry` value at the absolute start of processing AI responses (before calling `_session.updateProfileFromAI`), ensuring business pivot detection correctly identifies industry changes.

---

## 🖼️ 14. Unified Image Management & Media Picker System

LandyMaker features a centralized, robust Image Media Picker and Background Upload system used across the Builder Workspace:
- **Sources Supported**: 
  - **Local Device**: Uploads compress instantly using `image_picker` (max 1920x1920, 88% quality) to ensure lightweight assets before uploading.
  - **Pixabay API**: Search and paginate through free stock images. To comply with Pixabay ToS (no hotlinking), images are downloaded into memory (`Uint8List`) and instantly proxied/uploaded to ImgBB and Supabase. Supports advanced filtering (`photo`, `illustration`, `vector`). Safely handles Rate Limiting (429 HTTP status).
  - **Direct URL**: Users can paste an external URL.

### 📥 Double-Upload & Asset Importing
To ensure high performance and user ownership, LandyMaker employs a "Double-Upload" strategy for all external assets (Pixabay templates):
1. **ImgBB**: Primary host for the design's `image_url`. Optimized for global CDN delivery.
2. **Supabase Storage**: Secondary host used to "Import" the asset into the user's personal gallery.
3. **Workflow**: Triggered automatically via `importTemplateAssets` when applying templates or `magicReplaceImages` when using the Magic Swapper.

### ✨ Magic Image Swapper
A specialized engine in `LandingPageBuilderCubit` that bulk-replaces page visuals based on a search category.
- **Intelligent Categorization**:
    - `Hero SaaS`: Uses `illustration` image type.
    - `Testimonials / Team`: Uses `portrait` photo search keyword.
    - `Other Blocks`: Uses general `photo` image type.
- **Async Safety**: Prevents saving the page (`savePage`) if any `upload://` placeholders are active in the `designMap`.

### 📊 Storage Quotas & Tier Enforcement
Image uploads to Supabase Storage are strictly governed by user tier and role to prevent resource abuse while supporting power users:
- **Free Tier**: **50 images** maximum.
- **Pro Tier**: **200 images** maximum.
- **Super Admin**: **Unlimited** (999,999) images.
- **Enforcement Logic**: Handled in `SupabaseService.uploadImageBytes` using cached `_currentUserRole` and `_currentUserTier` for maximum performance during bulk operations.
- **User Feedback**: Displays clear Arabic error messages explaining why an upload failed and how to increase limits.

### 🚨 Strict Guidelines for Image Rendering (MUST FOLLOW)
- **Always use `CustomNetworkImage`**: Whenever you need to display an image from a URL, whether it's an uploaded asset, background image, or any internet link, you **MUST** use `CustomNetworkImage`. Do **NOT** use `Image.network` or `CachedNetworkImage` directly. 
- **Why?**: `CustomNetworkImage` natively resolves the internal `upload://...` scheme showing real-time upload progress, handles network shimmer loading, and crucially sets memory bounds (`memCacheWidth` and `maxWidthDiskCache: 1200`) to prevent Out-Of-Memory (OOM) app crashes when displaying many images inside grids or canvas blocks.

---

## 🚀 15. CI/CD Pipeline & Deployment Architecture (CRITICAL — READ BEFORE ANY DEPLOY)

This section documents how LandyMaker is built and deployed. **Every AI assistant MUST read this before touching anything related to deployment, assets, icons, or secrets.**

### 15.1 — Project Layout on Vercel (Two Separate Projects)

| Vercel Project | Project ID | URL | Source |
|---|---|---|---|
| `landymaker` | `prj_dDwATAOXwcnKLc7nh0wVRIqDjqjV` | `landymaker.com` | Main Flutter Web App |
| `landymaker-blog` | `prj_ONp0ZC8l6Udq8o13iXXjmAWWD7vc` | `landymaker-blog.vercel.app` | Next.js Blog (`blog-frontend/`) |

Both are in the **same GitHub repository**: `abdallah-azmy/landymaker`

- The **main app** (`landymaker`) is a Flutter Web app. Its Vercel Output Directory is `build/web`.
- The **blog** (`landymaker-blog`) is a Next.js 16 app located in `blog-frontend/`. It deploys via its own Vercel auto-deployment triggered from the repo root.

### 15.2 — Main App (Flutter) CI/CD Pipeline

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

### 15.3 — Blog (Next.js) CI/CD Pipeline

The blog in `blog-frontend/` is auto-deployed by Vercel directly when changes are pushed to `main`.

**Blog Vercel Project Settings:**
- Output Directory: `.next` (auto-detected by Next.js preset)
- Environment Variables must be set in the Vercel Dashboard for `landymaker-blog` project:
  - `NEXT_PUBLIC_SUPABASE_URL`
  - `NEXT_PUBLIC_SUPABASE_ANON_KEY`

**⚠️ KNOWN ISSUE — Blog 404 Caching:**
Next.js blog post pages were previously set to `revalidate = 60`, which caused Vercel to cache 404 responses for 60 seconds. When a page was first hit before Supabase responded, the 404 was cached. Fix applied: `export const dynamic = 'force-dynamic'` + `revalidate = 0` in `blog-frontend/app/blog/[slug]/page.tsx`. **Do NOT revert this.**

### 15.4 — Secrets & Environment Variables

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

### 15.5 — App Icons & Assets

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

### 15.6 — Blog URL Routing

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

### 15.7 — Troubleshooting Common CI/CD Problems

| Symptom | Cause | Fix |
|---|---|---|
| Icons/favicon didn't update after push | Vercel auto-deploy (not GitHub Actions) ran last | Disable Vercel Git auto-deploy; push a new commit to trigger GitHub Actions |
| Blog posts show 404 | `dynamic` not set; Vercel cached the 404 | Ensure `export const dynamic = 'force-dynamic'` is in `[slug]/page.tsx` |
| Blog posts show 404 / Black screen | Blog assets (`/_next/static/..`) intercepted by Flutter's static checker | Ensure Blog rewrite logic is at the absolute top of `middleware.js` before `staticExtensions` test |
| Blog posts show 404 / Catch-all rewrite | `vercel.json` overrides middleware and rewrites `/blog` to `/index.html` | Ensure the regex in `vercel.json` excludes `blog`, `_next`, and SEO assets |
| Flutter app shows blank/broken | `--dart-define` secrets missing from GitHub Secrets | Add `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `IMGBB_API_KEY` to GitHub repo secrets |
| `vercel deploy` fails with "path not found" | Running `vercel deploy` from inside `blog-frontend/` with Vercel root dir mismatch | Never run `vercel deploy` manually — always use GitHub Actions |
### 🛡️ Professional Error Handling & Fault Tolerance (NEW)
LandyMaker employs a multi-layered error recovery strategy to ensure 100% uptime of the generation flow:
1. **Edge Function Fallbacks**: If Pixabay API fails, the engine automatically injects high-quality placeholders (Pixabay static fallback links) instead of returning an error.
2. **Safe Color Parsing**: `LandingPageTheme.parseColor` includes a try-catch sanitize loop. It handles malformed Hex codes from AI and reverts to theme defaults without crashing the UI.
3. **Optimistic Asset Registration**: Image deduplication (SHA-256) is non-blocking. If a hash lookup fails, the system defaults to a new upload to ensure the user is never stuck.

## 🧠 16. AI Agent & Conversion Mission (Omnipotent Control)

LandyMaker has evolved into an AI-powered conversion platform with "Omnipotent Control" over design and assets:

### A. AI Page Generator & Conversational Editor
- **Location**: `supabase/functions/ai-page-generate/`
- **Logic**: Uses a multi-provider fallback (Gemini → Groq → OpenRouter → DeepSeek) to generate or surgically edit JSON landing pages. Must rely on Regex-based JSON extraction instead of native JSON Mode to preserve compatibility across all LLMs.
- **Intent: 'edit'**: Supports precise updates based on current design context. AI understands relative references ("top", "last section", "change second block background").
- **Unified Decoupled Schema**: Every editable property is mapped in a decoupled JSON file located at `supabase/functions/shared/schema_registry.json`. This serves as the absolute Source of Truth for the LLM prompt. Any new sections added to the Flutter `BlockRegistry` must also be declared in this JSON registry to be available to the AI.

### B. Visual Intelligence & Pixabay Integration
- **Direct Search**: AI uses `{ "pixabay_search": { "query", "type" } }` for automated image fulfillment.
- **Image Types**: AI understands and uses `photo`, `illustration`, and `vector` filters for appropriate section feel (e.g., Avatars vs Backgrounds).
- **Pixabay Selector**: AI can trigger a multi-choice UI grid via `{ "action": "pixabay_selection" }` to let users pick from 9+ options.

### C. Advanced Asset Management (Deduplication)
- **ImgBB Exclusive**: All production design URLs flow through ImgBB to optimize Supabase Storage costs.
- **SHA-256 Deduplication**: Every image is hashed before upload. If a hash exists in `user_assets`, the URL is reused, preventing redundant uploads.
- **User Gallery**: External links (ImgBB) are registered in the `user_assets` table to ensure they appear in the user's Media Library for reuse.

### D. Smart WhatsApp Leads & Gating
- **Conversion Goal**: Converts clicks into identified leads.
- **Logic**: Forms can auto-open WhatsApp with pre-filled user data after submission.
- **Enforcement**: Managed via `SubscriptionService`, `FeatureGateWrapper`, and `ai_usage_log`.

## 🏗️ 17. Phase 2 Architecture & UX Patterns

This section documents the UI/UX patterns introduced during Phase 2 enhancements.

### A. Layout Picker System (Builder Feature)
- **Location**: `lib/features/builder/widgets/layout_picker/`
- **Components**: `LayoutPickerPanel`, `LayoutOptionCard`, `LayoutSlotGrid`
- **Pattern**: Each block type maps to a list of available layouts via `_getLayoutsForType(type)`. Each layout entry contains `layoutStyle`, `name`, `description`, and `slots`.
- **State Flow**: `LayoutPickerPanel` reads `BuilderState` to determine current layout, writes updates via `builder_cubit.updateBlockProperty()` (property keys: `layout_style`, `slot_widgets`).
- **Mini Preview**: `LayoutOptionCard` renders a small schematic preview using `_LayoutMiniPreview`, which matches the `layoutStyle` string to a visual representation.
- **Fallback**: If a block type has no registered layouts, the panel shows a centered message "هذا القسم لا يدعم تغيير التخطيط".
- **Rule**: When adding a new layout variant to any home section (Hero, CTA, etc.), register its corresponding entry in both the `_getLayoutsForType()` function and the `layout_option_card.dart` switch cases.

### B. Mobile Bottom Sheet Pattern (Template Picker)
- **Pattern**: Desktop >= 900px renders an inline sidebar. Below 900px, a filter button opens a `DraggableScrollableSheet` as a modal bottom sheet.
- **Implementation**: `template_picker_screen.dart` — uses `showModalBottomSheet` with `DraggableScrollableSheet(initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 0.8)`.
- **Selection Flow**: Tapping a sheet item calls `setState` to update the selection, then `Navigator.pop(context)` to dismiss the sheet.
- **Rule**: Always use `DraggableScrollableSheet` (not a fixed `Container`) for mobile filter/sidebar panels to support small screens (320px). Never hardcode a `ListView` outside a scrollable container in bottom sheets.

### C. CustomNetworkImage Patterns
- **Location**: `lib/core/widgets/custom_network_image.dart`
- **Loading State**: Uses `Shimmer.fromColors` (shimmer/skeleton) while the image loads. Default fallback height is `200.0` when no explicit height is given.
- **Error State**: Displays a grey container with a `broken_image_rounded` icon.
- **URL Validation**: Empty and malformed URLs (`Uri.tryParse` returning null or non-absolute) show the error widget instead of crashing.
- **Platform Split**: Web uses `Image.network` with `loadingBuilder`/`errorBuilder`. Native uses `CachedNetworkImage` with `placeholder`/`errorWidget`.
- **Upload Handling**: URLs starting with `upload://` are managed via `UploadManagerCubit` with progress overlay, cancel button, and error display.
- **Rule**: Always wrap `CustomNetworkImage` in a `ClipRRect` (or ensure it's within a clipped parent) for consistent border rounding. Do NOT specify explicit `width`/`height` when the parent provides tight constraints (e.g., inside `Positioned.fill`).

### D. Home Section Layout Enums
- **Location**: `lib/features/home/models/home_layouts.dart`
- **Enums**: `HeroLayout`, `FeatureLayout`, `StatsLayout`, `CtaLayout`, `TemplateSliderLayout`
- **Rule**: Every layout variant must support both Desktop (>= 900px) and Mobile (< 900px) via `LayoutBuilder`. Every layout must respect RTL via `EdgeInsetsDirectional`. Do NOT use `MediaQuery.of(context).size` for layout decisions inside section widgets — use the `constraints` from `LayoutBuilder` or `HomeBreakpoint`.
- **Rule**: When adding a new layout, add its enum entry, implement the rendering method in the section widget (e.g., `_buildFullWidthImageLayout`), and register the mini preview in `layout_option_card.dart`.

### E. Scroll-Triggered Visibility
- **Pattern**: Use `VisibilityObserver` (in `lib/core/widgets/visibility_observer.dart`) instead of `GlobalKey` + `_checkAndReveal`.
- **Behavior**: Observes its ancestor `Scrollable` via `Scrollable.maybeOf(context)`, listens for scroll position changes, and fires `onVisible` once the widget enters the viewport.
- **Rule**: Use `ScrollPosition.viewportDimension` instead of `MediaQuery.of(context).size.height` for viewport calculations. Remove the scroll listener after the widget becomes visible to avoid wasted work.

### F. Entrance Animation Mixin
- **Location**: `lib/core/animations/entrance_animation_mixin.dart`
- **Pattern**: `EntranceAnimationMixin` provides `entranceFade`, `entranceSlide`, `entranceDuration`, `entranceSlideBegin`, `startEntrance()`, and `buildEntranceAnimation()`.
- **Rule**: Any widget that needs a fade + slide entrance animation on visibility should mix in `EntranceAnimationMixin` and respond to `widget.isVisible` in `didUpdateWidget` by calling `startEntrance()`.

### G. Responsive Breakpoint
- **Location**: `lib/core/responsive/responsive_utils.dart`
- **Utility**: `HomeBreakpoint.isMobile(width)` returns `true` for `width < 700`.
- **Rule**: Use `LayoutBuilder` + `HomeBreakpoint.isMobile(constraints.maxWidth)` for responsive decisions in home section widgets. Keep `isMobile` local to the builder function; do NOT store it in state.
