# Project Structure - LandyMaker

This document provides a high-level overview of the LandyMaker repository structure, folder hierarchy, and architectural boundaries. It is designed to help AI models understand the project organization within minutes.

## 📂 Folder Hierarchy

```text
/
├── api/                    # Vercel Serverless Functions (JS/Node)
├── assets/                 # Global assets (images, logos)
├── blog-frontend/          # Next.js 16 Blog Application (Headless)
├── docs/                   # Platform documentation
│   └── ai/                 # 👈 AI-specific navigation & guidebooks
├── lib/                    # Main Flutter Application Source
│   ├── core/               # Shared logic, theme, routing, and generic widgets
│   ├── features/           # Domain-driven feature modules (The "Meat" of the app)
│   ├── services/           # Global singleton services (Supabase, Auth, etc.)
│   └── main.dart           # App Entry Point
├── supabase/               # Backend-as-a-Service configuration
│   ├── functions/          # Deno Edge Functions
│   └── migrations/         # SQL Schema and RLS Policies
├── web/                    # Flutter Web-specific build artifacts & SEO files
├── AI_CONTEXT.md           # Core project memory & rules (Single Source of Truth)
└── middleware.js           # Vercel Edge Middleware (SEO, Routing, Bot Detection)
```

## 🏗️ Architectural Boundaries

LandyMaker follows a **Feature-Driven Architecture**.

### 1. Core Layer (`lib/core/`)
Contains cross-cutting concerns that don't belong to a specific feature:
- **Router**: Centralized navigation using `go_router`.
- **Forms**: Centralized `ValidationEngine` and `FieldRenderer`.
- **Localization**: Arabic (RTL) and English translations.
- **Theme**: Centralized colors and typography.
- **Widgets**: Atomic and Molecular reusable UI components.

### 2. Feature Layer (`lib/features/`)
Each feature is an isolated module:
- `auth`: Login, Register, Password Reset.
- `builder`: The Editor workspace, block property editors, and registries.
- `dashboard`: User management panel, analytics, leads, and domain settings.
- `public_viewer`: High-performance renderer for live landing pages.
- `blog_admin`: Admin interface for managing the headless blog.
- `super_admin`: Platform-level metrics and global configuration.

### 3. Service Layer (`lib/services/`)
Contains global singleton classes that wrap external infrastructure:
- `SupabaseService`: Direct interaction with Supabase SDK.
- `DatabaseService`: High-level data persistence operations.
- `AuthService`: Wrapper for authentication logic.
- `TenantRoutingService`: Logic for resolving subdomains and custom domains.

### 4. Infrastructure Layer
- **Vercel Edge**: `middleware.js` handles requests before they hit the app, managing SEO and proxies.
- **Supabase Edge Functions**: Handles sensitive operations (Lead submission, Captcha verification).

## 🚀 Main Entry Points

- **Flutter App**: `lib/main.dart`
- **Routing**: `lib/core/router/app_router.dart`
- **Backend API**: `supabase/functions/`
- **Blog**: `blog-frontend/app/page.tsx`
- **Request Proxy**: `middleware.js`

## 🔑 Important Dependencies

- **State Management**: `flutter_bloc` (Cubit).
- **Navigation**: `go_router`.
- **Backend**: `supabase_flutter`.
- **HTTP Client**: `dio` (with `pretty_dio_logger`).
- **Icons**: `iconsax_flutter`.
- **SEO**: `meta_seo` (and custom Edge Middleware).
