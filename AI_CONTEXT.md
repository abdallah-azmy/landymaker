# LandyMaker 🚀 (لاندي ميكر) - AI Assistant Deep Context Guide

Welcome, AI Assistant! You are looking at the comprehensive, deep project context for **LandyMaker**, a professional, high-performance SaaS Landing Page and E-commerce Builder engineered for the MENA region with native Right-to-Left (RTL) and Arabic-first support.

This document serves as your **core project memory** and **Master Entry Point**. Please read it carefully to understand the state, architecture, implemented features, decisions, and constraints of the project.

---

## 📚 Table of Contents & AI Navigation

For deep-dives into specific systems, refer to the dedicated documentation files in the `docs/ai/` directory:

- **[AI Development Rules](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/AI_DOCUMENTATION_RULES.md)**: CRITICAL. Contains all strict execution protocols, UI/UX patterns, state management rules, and development guidelines.
- **[DevOps & Assets](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/DEVOPS_AND_ASSETS.md)**: CRITICAL. Read before any deployment, CI/CD, image handling, or secrets modification.
- **[AI Navigation](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/AI_NAVIGATION.md)**: The map of all files, including feature indexes, screen indexes, and architecture boundaries.

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

## 📋 Implementation Knowledge (Post-Plan Learnings)

### ✏️ Lead Form Defaults Location
The default `fields` arrays for `lead_form` and `lead_magnet` blocks are defined in `builder_cubit.dart:addBlock()`, NOT in `block_registry.dart`. When modifying default form fields, edit the `fields` list inside `addBlock()` for each respective block type. The Edge Function `lead-submit` handles Turnstile verification, rate limiting, fingerprinting, and invokes `lead-notify` fire-and-forget with `WEBHOOK_SECRET` auth — never insert leads directly from the client.

### 🤖 AI Chat Session Scoping
AI chat sessions are scoped per landing page. `AIGenerationCubit` uses `'ai_session_$pageId'` as the `SharedPreferences` key. Each page has its own independent chat history.

### 🖥️ Guest Preview Screen
`GuestPreviewScreen` (route `/guest-preview`) uses `PreviewMode.desktop` with a `LayoutBuilder` wrapper. When the window is desktop width (>= 768px), two toggle icons (`Icons.phone_android_rounded` and `Icons.desktop_windows_rounded`) appear in the AppBar to switch between mobile and desktop preview. The `initState` includes a fallback `cubit.initializeNewPage()` if the cubit state is not `BuilderLoaded`.

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
- **Global Design & Animation System**: Performance-optimized `BlockAnimationWrapper`. *(Note: The 10 shape variants from `StyleRegistry` were removed in Phase 11. `lib/features/builder/registries/style_registry.dart` is kept as deprecated reference only — do not restore or import it.)*
- **Theme Management**: `BuilderThemeCubit` owns `LandingPageTheme` (colors, fonts, backgrounds) separately from `LandingPageBuilderCubit`. The main cubit subscribes to the theme cubit's stream and syncs into `BuilderLoaded.theme` — keeping all existing widgets reading `state.theme` unchanged.
- **Font Picker Binding**: The global font picker (`DesignFontsTab` in `builder_sidebar_tabs.dart`) MUST listen to `BuilderThemeCubit` directly — NOT `LandingPageBuilderCubit`. See Rule 34.

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


## 🧠 13. **Strict AI Assistant Rules (MUST FOLLOW)**

> **[MOVED]**: These execution rules, UI/UX design patterns, and coding constraints have been extracted to a dedicated file to keep this context focused on architecture.
> 👉 **Read them here:** [AI_DOCUMENTATION_RULES.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/AI_DOCUMENTATION_RULES.md)

---

## 🖼️ 14. Unified Image Management & 🚀 15. CI/CD Pipeline

> **[MOVED]**: All DevOps, CI/CD pipeline instructions, Vercel routing, and image/asset management constraints have been extracted to a dedicated file.
> 👉 **Read them here:** [DEVOPS_AND_ASSETS.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/DEVOPS_AND_ASSETS.md)

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

## 🏛️ 18. Phase 3: Clean Responsive Architecture

This section documents the massive architectural refactoring executed to eliminate inline `if (isMobile)` spaghetti code and improve AI readability and render performance.

### A. Factory Pattern & Layout Splitting
- **Pattern**: Core components (e.g., `HomeNavbar`, `HomeFooter`, `dashboard_shell`) and Builder Sections (e.g., `CustomCtaBannerWidget`, `CustomComparisonTableWidget`) act as **Factory Widgets**. 
- **Behavior**: The main factory widget reads the `layout_style` and utilizes a `LayoutBuilder`. It then delegates the actual rendering to independent `_DesktopLayout` and `_MobileLayout` classes.
- **Rule**: Never nest complex `if (isMobile)` blocks deeply inside rows and columns. Split them at the root of the component.

### B. State Preservation (Hoisting)
- **Pattern**: When transitioning between `_DesktopLayout` and `_MobileLayout` upon window resize, the Render Tree destroys and recreates the widgets.
- **Rule**: All stateful data (e.g., `ScrollController`, `TextEditingController`, `GlobalKey`, async playback flags) MUST be hoisted into the parent `StatefulWidget` (the Factory). The delegated layout classes should be `StatelessWidget`s that receive this data via constructor properties (`_Props` class).

### C. AI-Friendly "Sweet Spot" File Sizing
- **Pattern**: To optimize token context windows for future AI models, all related classes (Factory, Props, Desktop Layout, Mobile Layout, Shared Sub-widgets) are kept in a **single file** as long as the file is under ~800 lines.
- **Formatting**: Files utilizing this pattern are strictly segmented using large visual comments (`/// ==========================`) to delineate the Factory, Props, Layouts, and Shared sections, preventing AI hallucination during complex reads.

---

## 🏛️ 19. Phase 4: UI/UX Theme Compliance & Global Controls

This section documents the comprehensive modernization of LandyMaker's user-facing screens to achieve full Light/Dark mode compliance and visual polish.

### A. Shared Layout Wrapper for Auth
- **Widget**: `AuthLayoutWrapper` (`lib/features/auth/widgets/auth_layout_wrapper.dart`)
- **Usage**: Encapsulates the centered two-column brand-and-form layout on desktop and single-column on mobile. Includes built-in theme and language switcher toggles in the top-right corner. Used across all four auth screens (`LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen`, `ResetPasswordScreen`).

### B. Standardized Language Switcher
- **Widget**: `LanguageSwitcherButton` (`lib/core/widgets/atoms/language_switcher_button.dart`)
- **Variants**:
  - `LanguageSwitcherVariant.iconOnly`: Compact icon button for header zones (e.g. mobile navbar, auth top bar).
  - `LanguageSwitcherVariant.iconAndText`: TextButton with icon and "العربية" / "English" text label (e.g. desktop navbar).

### C. UX Control Placement Guidelines (Strict Rules)
1. **Language Switching**: Inside the dashboard, the language toggle resides **strictly in the Settings screen** (Language section). It must **never** be shown in the dashboard top bar or the sidebar footer to avoid cognitive load.
2. **Theme Toggle**: The `AnimatedThemeToggle` is displayed in:
   - Marketing homepage navbar (desktop & mobile).
   - Auth screens (via `AuthLayoutWrapper`).
   - Dashboard Shell top bar (desktop & mobile).
   - Settings screen (Appearance section).
3. **Sidebar Architecture**: Redesigned to support a `260px` desktop width, a 2px top brand accent bar, clean uppercase headers with spacing, and reactive sidebar items highlighting selected states with tinted backgrounds and left borders. Includes a `_PlanBadge` ("Free Plan"/"Pro Plan") and a dynamic usage indicator.


