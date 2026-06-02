# LandyMaker 🚀 - AI Assistant Context Guide

Welcome, AI Assistant! You are looking at the comprehensive project context for **LandyMaker**, a professional, high-performance SaaS Landing Page Builder engineered for speed, conversion, and effortless customization.

This document serves as your "Brain" for this project. Please read it carefully before suggesting any code changes, architectural decisions, or debugging steps.

## 🎯 Project Overview
LandyMaker transforms the complex process of web design into a simple, block-based experience. It allows users to build, manage, and host multi-page SaaS landing pages. 
It supports tier-based limits (Free, Pro, Enterprise), a unified dashboard, and deep analytics.

## 🛠 Technical Stack
- **Frontend Framework:** Flutter Web
- **Backend as a Service (BaaS):** Supabase (Authentication, PostgreSQL Database, Storage, Real-time RPCs, Triggers)
- **Hosting / Edge:** Vercel (Edge Functions for SEO & Routing middleware `seo-middleware.js`)
- **Architecture Methodology:** **SPEC-KIT** Framework for robust, scalable software engineering.
- **State Management:** `flutter_bloc` (Cubit approach is used exclusively).
- **Dependency Injection (DI):** `get_it` (Service Locator `sl`).
- **Routing:** `go_router` (Path URLs enabled via `url_strategy`).
- **Networking:** `dio` for custom HTTP client adapters (`lib/core/dio_http_client_adapter.dart`).
- **Logging:** `logging`, `pretty_dio_logger`, and custom API logging (`API_LOGGING_GUIDE.md`).

## 📁 Directory Structure & Architecture
The project follows a **Feature-Driven Architecture**:

```text
lib/
├── core/                   # Core utilities, theme, routing, localization, responsive helpers
│   ├── constants/          # App-wide constants
│   ├── localization/       # LocalizationCubit, RTL/LTR support (Arabic & English)
│   ├── responsive/         # Responsive layouts handling
│   ├── router/             # go_router configuration (app_router.dart)
│   ├── theme/              # App colors, styles, ThemeData
│   ├── utils/              # Shared utilities
│   └── widgets/            # Generic shared widgets (Never build from scratch if it's here!)
├── features/               # Isolated feature modules
│   ├── auth/               # Authentication flows (AuthCubit)
│   ├── builder/            # Drag & Drop Editor, Block Properties (BuilderCubit)
│   ├── dashboard/          # User Dashboard, Pages List, Analytics (LeadsAnalyticsCubit)
│   ├── home/               # Landing page / Home UI
│   ├── public_viewer/      # Renderer for published sites (PublicPageCubit & SectionRenderer)
│   ├── subscription/       # Tier limits, quotas, and payment flows
│   └── super_admin/        # Global admin dashboard (SuperAdminCubit)
├── injection_container.dart # get_it setup
└── main.dart               # Entry point
```

## 🧠 AI Assistant Rules & Guidelines (CRITICAL)

When writing code or suggesting changes for this project, you **MUST** adhere to the following rules:

1. **Do NOT reinvent the wheel:** NEVER build a widget from scratch if a custom widget already exists. Always check `lib/core/widgets/` or `lib/features/public_viewer/widgets/` first.
2. **State Management (Source of Truth):** ALWAYS maintain the "Source of Truth" in the Bloc/Cubit states. UI should only rebuild based on `BlocBuilder` or `BlocConsumer`. Do not use `setState` for global business logic.
3. **Builder Consistency:** Always use `SectionRenderer` for any block-based preview to ensure 1:1 consistency between the builder and the public viewer.
4. **Mobile-First Design:** Mobile-first design for the Builder Workspace is mandatory. Use the provided responsive utilities in `lib/core/responsive/`.
5. **Localization:** The app is **Arabic-First** (Native RTL support) but supports English. Ensure all strings are localizable or account for RTL layouts. Do not hardcode LTR margins/paddings if it breaks RTL.
6. **Font Management:** Real-time dynamic typography is handled via `google_fonts`. Do not embed heavy TTF files unless absolutely necessary.
7. **Error Handling & Logging:** Use the established Dio client for API calls and log properly using the project's logging utility.

## 🚀 Running the App

To run the application locally with the necessary environment variables:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=YOUR_PROJECT_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Dependencies must be installed first via `flutter pub get`.

## 📦 Key Dependencies
- `supabase_flutter`: Backend connectivity.
- `flutter_bloc`: State management.
- `get_it`: Dependency injection.
- `go_router`: Navigation.
- `dio` & `http`: Networking.
- `toastification`: In-app toast notifications.
- `google_fonts`: Dynamic fonts.

---
*Built with ❤️ for creators by LandyMaker Team.*
