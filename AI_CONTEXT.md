# LandyMaker 🚀 (لاندي ميكر) - AI Assistant Deep Context Guide

Welcome, AI Assistant! You are looking at the comprehensive, deep project context for **LandyMaker**, a professional, high-performance SaaS Landing Page and E-commerce Builder engineered for the MENA region with native Right-to-Left (RTL) and Arabic-first support.

This document serves as your **core project memory**. Please read it carefully before suggesting any code changes, architectural decisions, or debugging steps.

---

## 🎯 1. Project Overview & Architecture

LandyMaker enables users to build, manage, and host multi-page SaaS landing pages and e-commerce stores without writing code. It uses a **Clean Feature-Driven Architecture** influenced by the **SPEC-KIT** methodology, separating concerns into presentation, business logic (States), and infrastructure services.

### Directory Structure & Layout
```text
lib/
├── core/                   # Shared utilities, themes, routing, and localization
│   ├── constants/          # Application-wide constants
│   ├── localization/       # LocalizationCubit, translations dictionaries (ar/en)
│   ├── responsive/         # Responsive layouts handling (ResponsiveLayout, ResponsiveUtils)
│   ├── router/             # GoRouter configuration (app_router.dart)
│   ├── theme/              # Typography, HSL-based colors, light/dark ThemeData
│   └── widgets/            # Generic shared UI atoms/molecules (custom fields, buttons)
├── features/               # Isolated domain-specific feature modules
│   ├── auth/               # Auth state machine, Login, Signup, Reset & Forgot Password screens
│   ├── blog_admin/         # Flutter Admin UI for synchronizing Next.js blog posts
│   ├── builder/            # Flex-Editor workspace, registries, blocks properties panels
│   ├── dashboard/          # Shell, analytics, leads charts, custom domain configuration
│   ├── home/               # Platform marketing site, Bento layouts, Hero animations
│   ├── public_viewer/      # High-performance section renderer for published pages
│   ├── subscription/       # Payment modals (WhatsApp confirmation flow), tier limits
│   └── super_admin/        # Platform-level metrics and custom Platform SEO configurations
├── services/               # Infrastructure Client Adaptors (injectable via GetIt)
│   ├── auth_service.dart   # Email, password, and recovery handlers
│   ├── database_service.dart # CRUD operations for pages, leads, and SEO settings
│   ├── storage_service.dart# Supabase Storage asset uploads
│   ├── subscription_service.dart # SaaS quotas and active payments verification
│   ├── tenant_routing_service.dart # Domain, subdomain, and path-based routing parser
│   └── supabase_service.dart # Controller class implementing SupabaseLoggingMixin
├── injection_container.dart# Dependency Injection Container (GetIt `sl` configuration)
└── main.dart               # App entry point (attaches URL strategy, handles initial route)
```

---

## 🛠 2. Technical Stack & Integrations

- **Frontend Core:** Flutter Web (HTML, CanvasKit, CSS styling, Javascript bootstrap hooks).
- **Headless Blog:** Next.js & React (hosted separately at `https://landymaker-blog.vercel.app`), serving `/blog` and Next.js assets.
- **State Management:** `flutter_bloc` (Cubit approach is used exclusively).
- **Routing:** `go_router` supporting deep linking and path-based URLs via `url_strategy`.
- **Dependency Injection:** `get_it` (Service Locator `sl`).
- **Database / BaaS:** PostgreSQL on Supabase (Auth, RLS Policies, Real-Time RPCs, Triggers).
- **Edge Layer:** Vercel Serverless Edge Functions (`middleware.js`) for routing, Next.js blog proxying, and Crawler SEO.

---

## 🌍 3. Multi-Tenant Domain & Path Routing

LandyMaker supports four methods of routing resolved by [TenantRoutingService](file:///Users/abdallahazmy/Projects/mylandy/lib/services/tenant_routing_service.dart) at startup:

1. **Path-Based Slugs:** `landymaker.com/restaurant-x` loads page with subdomain/slug `restaurant-x` via [PublicLandingPage](file:///Users/abdallahazmy/Projects/mylandy/lib/features/public_viewer/screens/public_landing_page.dart).
2. **Subdomains:** `restaurant-x.landymaker.com` loads the page.
3. **Custom Domains:** `restaurant-x.com` maps directly to the page.
4. **Local Query Params:** `localhost:xxxx/?tenant=restaurant-x` simulates tenant page loads in local development.

### ⚠️ Reserved Paths Constraint
To prevent landing pages from hijacking core app paths, `TenantRoutingService.reservedPaths` contains a static set of blocked slugs (`login`, `register`, `forgot-password`, `reset-password`, `dashboard`, `builder`, `api`, `blog`, `_next`, `robots.txt`, `sitemap`, etc.). 

*   **Rule:** When creating a landing page, you **must** run validation check against `reservedPaths` and already-taken subdomains before allowing the user to save.

---

## 📈 4. Vercel SEO Edge Middleware

To ensure client-side Flutter applications rank on search engines, [middleware.js](file:///Users/abdallahazmy/Projects/mylandy/middleware.js) acts as an Edge Routing and Bot-Detection Proxy:

1. **Next.js Blog Proxying:** Intercepts path prefixes `/blog`, `/_next`, `/sitemap.xml`, `/robots.txt`, and `/llms.txt`. It rewrites them to the Next.js blog project and appends a header `x-blog-proxied: 1` to prevent infinite loops.
2. **Static Assets Pass-Through:** Ignores static files matching extension regular expressions (e.g. `.js`, `.wasm`, `.png`, `.css`) to let Vercel serve them directly.
3. **Bot/Crawler Interception:** Detects User-Agents containing `bot`, `crawler`, `spider`, `ai`, `gptbot`, `perplexity`, etc.
   - **For Platform Routes:** Fetches config from the `public.platform_seo_settings` table (managed via `PlatformSeoScreen`) and returns a static HTML page containing relevant title, meta description, and social OG tags.
   - **For User Pages:** Fetches from `public.landing_pages` by subdomain slug. It parses `design_json`, filters visible blocks, and outputs semantic HTML (e.g., `<header>`, `<section>`, `<h1>`) alongside a structured JSON-LD schema.
4. **Human Traffic:** Passes through, allowing GoRouter in Flutter to resolve views natively.

---

## 🔐 5. Authentication & Account Management

Auth is controlled by `AuthCubit` using email/password:
- **Registration & Auto-Login:** When a user registers successfully, the system automatically authenticates them and routes them to the dashboard without requiring an extra sign-in step.
- **Forgot Password:** Users trigger a reset link email via `/forgot-password` route.
- **Reset Password:** The reset email routes users back to `/reset-password` with query tokens, where they can input and save a new password.
- **Auto-Sync:** The auth state is reactively tracked. If a session expires or a user logs out, the app redirects to `/login`.
- **API Credentials Fallback:** Production builds run with default fallback Supabase credentials embedded in the codebase if environment variables are not supplied.

---

## 🎨 6. Builder Engine (Flex-Editor)

- **Block Registry:** Blocks are defined as JSON templates and registered in [BlockRegistry](file:///Users/abdallahazmy/Projects/mylandy/lib/features/builder/registries/block_registry.dart).
- **Dual Rendering (SectionRenderer):** Every block (e.g. `hero`, `products`, `leads`, `faq`) must use the exact same `SectionRenderer` in both the workspace editor ([BuilderWorkspaceScreen](file:///Users/abdallahazmy/Projects/mylandy/lib/features/builder/screens/builder_workspace_screen.dart)) and live published viewer ([PublicLandingPage](file:///Users/abdallahazmy/Projects/mylandy/lib/features/public_viewer/screens/public_landing_page.dart)) to ensure 1:1 visual match.
- **Bento Grid & Hero Cycling:** The main landing page utilizes complex entry effects and animated mobile previews cycling inside the hero to display layout capabilities.

---

## ⚙️ 7. API Logging & Telemetry

LandyMaker has a structured, professional logging suite:
- **`logger` Wrapper:** Located in `lib/core/logger.dart`.
- **`SupabaseLoggingMixin`:** Located in `lib/core/supabase_logging_mixin.dart` and implemented by `SupabaseService`. It intercepts operations to log database queries, uploads, and auth changes.
- **Log Outputs:** Outputs structured boxes containing operation parameters, query durations in milliseconds, and status codes.
- **Privacy Policy:** Automatically filters out passwords, credit cards, or key credentials.
- **Performance:** Logging is fully active in **Debug mode** and disabled in **Release mode** (`kDebugMode` checks).

---

## 🌍 8. Localization & RTL Patterns

LandyMaker is bilingual (Arabic & English) and **Arabic-First** (native RTL):
- **Locale Cubit:** Holds `Locale` state.
- **Context Extensions:**
  - `context.translate('key')` maps to translations dictionary.
  - `context.isRtl` returns `true` if current locale is Arabic.
- **Layout Rule:** Never hardcode LTR padding (`EdgeInsets.only(left: 10)`) where layout symmetry is expected. Always use `EdgeInsetsDirectional` (e.g. `EdgeInsetsDirectional.only(start: 10)`) or adjust alignment depending on `context.isRtl`.

---

## 🧠 9. Strict AI Assistant Rules (MUST FOLLOW)

When working on this project, you **MUST** follow these rules:

### 1. Reusability First
Before creating any custom button, card, input field, or layout, check [lib/core/widgets/](file:///Users/abdallahazmy/Projects/mylandy/lib/core/widgets/) and existing feature widgets. **Do not write redundant UI widgets.**

### 2. State-Management Cleanliness
Maintain the "Source of Truth" in the respective Bloc/Cubit state. Do **NOT** use `setState` in screen layouts to manage global variables, database entries, or authentication states. UI widgets should rebuild reactively using `BlocBuilder` or `BlocConsumer`.

### 3. Build-Phase Redirect Guard
When routing or executing navigational side-effects (e.g., redirecting to login or dashboard) in response to a Cubit state change, you **MUST** wrap the navigator call in a post-frame callback:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  context.go('/target-route');
});
```
Failing to do this will cause Flutter framework exceptions due to navigation calls triggered during the widget build phase.

### 4. Localization Synchronization
When adding strings/keys to UI screens, you **must** add translation pairs to both:
- `lib/core/localization/translations_ar.dart`
- `lib/core/localization/translations_en.dart`
Use `context.translate('your_key_here')` to display them.

### 5. Multi-Tenant Safety & Slug Validation
When developing features related to creating or updating landing pages, validate that the requested subdomain or slug does not conflict with `TenantRoutingService.reservedPaths` or match existing rows.

### 6. Logging Standards
Use `Logger.info()`, `Logger.debug()`, or `Logger.error()` for diagnostic outputs. If writing database code, utilize `SupabaseLoggingMixin` methods or follow the logging syntax in `API_LOGGING_GUIDE.md` to track query execution duration and errors safely.

---
*Built with ❤️ for creators by LandyMaker Team.*
