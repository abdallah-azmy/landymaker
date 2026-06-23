<div align="center">
  <img src="assets/images/logo.webp" alt="LandyMaker Logo" width="120" />
  <h1>LandyMaker 🚀 (لاندي ميكر)</h1>
  <p><strong>Professional, High-Performance AI Landing Page & E-commerce Builder</strong></p>

  [![Flutter Web](https://img.shields.io/badge/Flutter-Web-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com/)
  [![Vercel](https://img.shields.io/badge/Vercel-Edge_SEO-000000?logo=vercel&logoColor=white)](https://vercel.com/)
  [![Next.js](https://img.shields.io/badge/Next.js-Blog-000000?logo=nextdotjs&logoColor=white)](https://nextjs.org/)
  [![SPEC-KIT](https://img.shields.io/badge/Architecture-SPEC--KIT-FF6B6B)](https://github.com/github/spec-kit)
</div>

<br />

> **LandyMaker** is an AI-powered, high-performance Landing Page and E-commerce Store Builder engineered specifically for the MENA region with native Right-to-Left (RTL) and Arabic-first support. It empowers startups, SaaS founders, small businesses, and freelancers to build, manage, host, and optimize conversion-driven pages and stores without writing any code.

> 🤖 **AI Assistants & New Developers:** Please read [AI_CONTEXT.md](./AI_CONTEXT.md) as the single source of truth for project architecture, rules, and documentation before contributing.

---

## 📑 Table of Contents
- [🌟 Core Features](#-core-features)
- [🛠 Technical Stack](#-technical-stack)
- [🌍 Multi-Tenant Hosting & Routing](#-multi-tenant-hosting--routing)
- [📈 Edge SEO & Bot Middleware](#-edge-seo--bot-middleware)
- [📁 Project Structure](#-project-structure)
- [⚙️ Developer Logging & Telemetry](#%EF%B8%8F-developer-logging--telemetry)
- [🚀 Getting Started](#-getting-started)
- [💻 Environment Variables](#-environment-variables)

---

## 🌟 Core Features

### 🎨 Professional Builder Engine (Flex-Editor)
- **Modular Block System**: 15+ industry-specific sections including `Hero`, `Products`, `Lead Forms`, `Basic Layouts`, and interactive `Q&A` / `Pricing`.
- **Atomic Styling**: Fine-grained customization of individual text, buttons, images, and alignments via long-press contextual menus.
- **Dynamic Google Fonts**: Real-time typography updates via Google Fonts API without application bloat.
- **Responsive Workspace**: Clean mobile-first simulator, tablet, and desktop real-time viewports.
- **Entrance & Cycling Effects**: Animated mobile preview cycling and scroll entrance animations on the marketing landing page hero.
- **Optimized Performance & Gestures**: Symmetrical desktop Bento grid alignment, state-isolated high-frequency animations (typewriter, mockups) to prevent screen-wide rebuilds, and scroll-hijacking prevention inside interactive mobile previews using overscroll propagation.

### 🏪 E-commerce & Shopping Carts
- **Integrated Catalog**: Add products, configure descriptions, set prices, and list item feeds.
- **Shopping Cart**: Real-time floating cart with item counts and price summation.
- **Local Payment Checkout**: Offline/Manual Payment workflows, including direct confirmation via WhatsApp.

### 🏢 Multi-Tenant SaaS Infrastructure
- **Tier-Based Limits**: Auto-enforcement of landing page quotas for Free (1), Pro (5), and Enterprise (Unlimited) users.
- **Custom Domains**: Seamless custom domain matching (`myrestaurant.com`) and subdomains (`restaurant.landymaker.com`) mapping.
- **Slug Validation**: Safe slug-creation validation checking against reserved paths (`/login`, `/dashboard`, `/builder`, etc.) to prevent routing conflicts.
- **Reactive Auth**: Bulletproof auth state synchronization and automatic login immediately after user registration.
- **Account Operations**: Comprehensive sign-in, signup, forgot password, and reset password flows.

### 📝 Integrated Next.js Blog
- **Next.js Frontend**: High-performance headless blog located under the `blog-frontend/` subdirectory.
- **Admin Management Panel**: Core Flutter Dashboard screen allowing admins to manage blog posts and synchronize data.
- **Monorepo Build Configuration**: The blog project specifies `outputFileTracingRoot: __dirname` in its `next.config.ts`. This configuration restricts file tracing scope to the subproject folder, avoiding Next.js monorepo workspace mismatch warnings and preventing dynamic route resolution errors (404 pages) on Vercel.

---

## 🛠 Technical Stack

### Frontend
- **App Framework**: Flutter Web (compiles to web targets)
- **State Management**: `flutter_bloc` (exclusively following the Cubit approach)
- **Navigation Routing**: `go_router` (configured with path URL strategy)
- **Dependency Injection**: `get_it` (Service Locator registry)
- **HTTP Client**: `dio` (with request interceptors and performance tracking) & `http`

### Headless Blog
- **Framework**: Next.js & React (hosted separately at `https://landymaker-blog.vercel.app`)
- **Integration**: Transparently proxied under the `/blog` and `/_next` routes via Vercel Edge Middleware.

### Backend (BaaS)
- **Database & Hosting**: PostgreSQL & Supabase
- **Features**: Real-time PostgreSQL RPCs, triggers, Row Level Security (RLS) policies, and Supabase Storage.
- **SQL Schema**: `create_platform_seo.sql` configures the schema for global admin SEO controls.

### Hosting & Routing Edge
- **Provider**: Vercel
- **Edge Middleware**: Custom `middleware.js` intercepting all traffic to manage subdomains, custom domains, proxying Next.js blog assets, and returning SEO-optimized pages for crawlers.

---

## 🌍 Multi-Tenant Hosting & Routing

The system supports multiple modes of routing parsed by `TenantRoutingService` at startup:

1. **Path-Based Slugs**: `landymaker.com/restaurant-x` loading page with subdomain = `restaurant-x`.
2. **Subdomains**: `restaurant-x.landymaker.com` resolving page.
3. **Custom Domains**: `restaurant-x.com` mapping directly to the page.
4. **Local Development**: Query parameters like `?tenant=restaurant-x` or `?subdomain=restaurant-x` to simulate tenant pages on localhost.

---

## 🌍 Localization & RTL

LandyMaker is designed to be **Arabic-First** but fully bilingual:
- **Native RTL Layouts**: Auto-mirrored UI, custom layouts, and right-to-left paddings.
- **Bilingual Keys**: Fully translated resource maps in `translations_ar.dart` and `translations_en.dart`.
- **Easy Toggle**: Real-time UI language switching via `LocalizationCubit`.

---

---

## 🎨 Design System & Spacing Constitution

LandyMaker features a strict design standard managed under the project's specification tools:
- **Visual Theme**: Uses a default **Slate-based dark theme** (`AppColors`) with high-contrast accent colors (such as cyan and amber) to emphasize primary interactive components.
- **Fluid Layouts**: UI widgets avoid hardcoded heights and utilize `LayoutBuilder` and `AspectRatio` to scale dynamically without layout overflows.
- **Visual Spacing**: Enforces standard vertical spacing margins of **80px on desktop** and **40px on mobile** to maintain breathing room and design balance.
- **Arabic-First Default**: While bilingual (AR/EN), Arabic Cairo styling is the primary design target.
- **Reusability Guard**: All developers (and AI assistants) must search `lib/core/widgets/` for existing elements before creating any new components, helper methods, or styling blocks to prevent duplication.
- **Task Structuring via SPEC-KIT**: Complex features and architecture modifications must strictly adhere to **SPEC-KIT** guidelines documented under the [.specify/](./.specify/) directory.

---


## 📈 Edge SEO & Bot Middleware

To circumvent the SEO limitations of client-side single-page Flutter apps, Vercel Edge Middleware (`middleware.js`) operates a domain-aware bot-detection and routing proxy:

- **Crawler Detection**: Identifies search bots and AI crawlers (Googlebot, GPTBot, Perplexitybot, Applebot, etc.) using User-Agent headers.
- **Dynamic Crawler HTML**: 
  - For **Platform Routes** (on Core Domains like `landymaker.com`): Queries the `public.platform_seo_settings` database table (e.g. `/` or `/login`) and returns lightweight, rich meta-tagged static HTML.
  - For **Tenant Landing Pages**:
    - **Path-Based Slugs** (on Core Domains): Queries `landing_pages` where `subdomain = slug` (e.g. `/azmy`).
    - **Custom Domains** (on Custom Domains): Queries `landing_pages` where `custom_domain = host`.
    - **Tier Validation**: For custom domains, checks the user profile tier and throws 404 for `free` tier pages.
    - **Semantic Generation**: Parses all blocks in the page design (`hero_saas`, `pricing`, `testimonials`, `contact_info`, `products`, `lead_magnet`, `basic_section`, etc.) to produce complete semantic HTML (using `<header>`, `<section>`, `<ul>`, `<blockquote>`, etc.) and structured JSON-LD schema metadata for maximum crawler indexing.
- **Next.js Blog Proxy**: Rewrites requests for `/blog`, `/_next`, `/sitemap.xml`, `/robots.txt`, and `/llms.txt` to the Next.js blog project **only on core domains** (to avoid hijacking custom domain sitemaps).
- **Dynamic Custom Domain SEO files**: For custom domains, intercepting `/robots.txt` and `/sitemap.xml` returns dynamic, self-referential plain text and XML sitemaps pointing exclusively to the custom domain home route with the database last modified timestamp.

---

## ⚙️ Developer Logging & Telemetry

LandyMaker features a professional logging suite based on the `logger` package:

- **Auto-Filtering**: Logs are fully detailed in **Debug mode** and automatically stripped in **Release mode** to protect performance.
- **Logging Mixin**: `SupabaseLoggingMixin` wraps database queries, authentication flows, and storage uploads to output detailed structured logs including request bodies, response payloads, query duration, and full stack traces for errors.
- **Developer Guides**:
  - Refer to [API_LOGGING_GUIDE.md](./docs/ai/API_LOGGING_GUIDE.md) for full developer documentation.

---

## 📁 Project Structure

```text
lib/
├── core/                   # Shared utilities, themes, routing, and localization
│   ├── constants/          # Application constants
│   ├── localization/       # LocalizationCubit, translations dictionaries (ar/en)
│   ├── responsive/         # Layout breakpoints and responsive builder widgets
│   ├── router/             # GoRouter routing rules (app_router.dart)
│   ├── theme/              # Styles, palettes, and light/dark theme schemes
│   └── widgets/            # Core UI atoms/molecules (custom text fields, cards)
├── features/               # Isolated domain-specific feature modules
│   ├── auth/               # SignIn, Register, Forgot & Reset Password screens, Cubit
│   ├── blog_admin/         # Blog article publishing & synchronizer UI
│   ├── builder/            # Flex-Editor workspace, Sidebar, properties editors
│   ├── dashboard/          # Project list, analytics charts, leads tables, domains config
│   ├── home/               # SaaS marketing website UI, Benton Grid, Home Hero
│   ├── public_viewer/      # High-performance engine for rendering published landing pages
│   ├── subscription/       # Limits, payments, and checkout modals
│   └── super_admin/        # Platform SEO management screen, platform metrics
├── services/               # Infrastructure client wrappers
│   ├── auth_service.dart   # Sign-in/up, OTP and session operations
│   ├── database_service.dart # Basic CRUD for pages and settings
│   ├── storage_service.dart# Image bucket operations
│   ├── subscription_service.dart # Payment & tier checks
│   ├── tenant_routing_service.dart # Domain/subdomain/slug resolver & reserved paths
│   └── supabase_service.dart # High-level controller implementing SupabaseLoggingMixin
├── injection_container.dart# Dependency Injection Container (GetIt locator)
└── main.dart               # App initialization entry point
```

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Environment Variables
You need a Supabase backend to run the application. Copy `.env.local` or provide your keys directly.

### 3. Run Locally (Chrome)
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=YOUR_PROJECT_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

---

## 💻 Environment Variables

For production Vercel builds or local releases, compile with:

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Your Supabase project REST API endpoint |
| `SUPABASE_ANON_KEY` | Your Supabase project public anon key |

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=YOUR_PROJECT_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

---
<div align="center">
  <i>Built with ❤️ for creators by the LandyMaker Team.</i>
</div>
