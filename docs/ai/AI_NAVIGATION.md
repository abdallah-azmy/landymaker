# AI Navigation Guide - LandyMaker

This document is the fastest onboarding tool for future AI models. It explains where major systems live without requiring a full codebase scan.

## 🧭 0. Primary Sources of Truth & Documentation Ownership

| Document | Purpose |
|----------|---------|
| **AI_CONTEXT.md** | Master Entry Point — Project state, architecture, implemented features, decisions. |
| **docs/ai/AI_DOCUMENTATION_RULES.md** | AI Execution Rules — Rules for keeping docs synchronized, builder standards, UI/UX patterns. |
| **docs/ai/DEVOPS_AND_ASSETS.md** | Deployment Rules — CI/CD, ImgBB, Vercel edge middleware, image management. |
| **docs/ai/PROJECT_STRUCTURE.md** | Folder hierarchy and architecture boundaries. |
| **docs/ai/BUILDER_ARCHITECTURE.md** | Builder system data flow. |
| **docs/ai/BLOCK_SCHEMA_REGISTRY.md** | JSON schema for AI-agent editing. |
| **docs/ai/API_LOGGING_GUIDE.md** | Developer guide and cheat sheet for structured logging. |
| **docs/ai/FEATURE_INDEX.md** | Feature-to-file mapping. |
| **docs/ai/SCREEN_INDEX.md** | Screen-to-file-and-route mapping. |
| **docs/ai/SERVICE_INDEX.md** | Global service directory with dependencies. |
| **docs/ai/ROUTE_INDEX.md** | Route definitions with guards. |
| **docs/ai/DEPENDENCY_MAPS.md** | System relationship diagrams. |

*(Note: All historical artifacts and execution logs have been removed to keep context clean.)*

---

## 🧱 1. Where is the Builder?

The Builder is the heart of the platform.
- **Entry Point**: `lib/features/builder/screens/builder_workspace_screen.dart`
- **Main Logic**: `lib/features/builder/controllers/builder_cubit.dart`
- **The Canvas**: `lib/features/builder/widgets/organisms/builder_canvas.dart`
- **Section Library**: `lib/features/builder/widgets/modals/section_library_modal.dart`
- **Registries**: `lib/features/builder/registries/` (Maps types to renderers).
- **Template Catalog**: `lib/features/builder/registries/template_registry.dart` (Template metadata, recommended sections, and initial JSON blocks).

## 📄 2. Where are Landing Page Sections?

Sections are the visual blocks added by users.
- **Section Renderer**: `lib/features/public_viewer/widgets/section_renderer.dart`
- **Section Widgets**: `lib/features/public_viewer/widgets/` (Look for `custom_*_widget.dart`).
- **Section Editors**: `lib/features/builder/widgets/editors/blocks/` (Look for `*_editor.dart`).
- **Block Definitions**: `lib/features/builder/registries/block_registry.dart`.
- **Section Picker Metadata**: `lib/features/builder/widgets/modals/section_library_modal.dart` contains the user-facing section catalog plus silent `ai_role` / `ai_when_to_use` hints for future AI-assisted building.

## ⚙️ 3. Where is JSON Processing?

Everything is JSON-driven.
- **Schema & Parsing**: Handled within the specific widgets or specialized parsers in `lib/features/public_viewer/utils/`.
- **Validation**: `lib/core/forms/validation_engine.dart`.
- **Localization Parsing**: `lib/core/utils/localized_text_parser.dart`.

## 🚀 4. Where is Publishing?

Publishing is a status flag in the database.
- **Save/Publish Logic**: `lib/features/builder/controllers/builder_cubit.dart` (Method: `savePage`).
- **Database Op**: `lib/services/database_service.dart` (Method: `updatePagePublishStatus`).

## 🔍 5. Where is SEO?

SEO is multi-layered.
- **App Metadata**: `lib/core/seo/app_seo.dart`.
- **Builder SEO Settings**: `lib/features/builder/widgets/modals/seo_settings_modal.dart`.
- **Crawler SEO**: `middleware.js` (Renders Semantic HTML for bots).
- **Platform SEO**: `lib/features/super_admin/screens/platform_seo_screen.dart`.

## 📥 6. Where are Leads?

Lead management and form submission.
- **Submission Flow**: `lib/services/database_service.dart` (Method: `submitLead`).
- **Lead Tracker UI**: `lib/features/dashboard/screens/leads_tracker_screen.dart`.
- **Edge Function Proxy**: `supabase/functions/lead-submit/`.

## 🔐 7. Where is Authentication?

User identity management.
- **Auth Service**: `lib/services/auth_service.dart`.
- **Auth Cubit**: `lib/features/auth/controllers/auth_cubit.dart`.
- **Screens**: `lib/features/auth/screens/`.

## 📊 8. Where is Dashboard Logic?

The user management panel.
- **Shell Layout**: `lib/features/dashboard/screens/dashboard_shell.dart`.
- **Website Context**: `lib/features/dashboard/controllers/active_website_cubit.dart`.
- **Tabs**: `lib/features/dashboard/screens/`.

## 📡 9. Where is Supabase?

Backend configuration.
- **Client Wrapper**: `lib/services/supabase_service.dart`.
- **Migrations**: `supabase/migrations/`.
- **Edge Functions**: `supabase/functions/`.

## 🤖 10. Where is the AI?

AI is handled via Edge Functions and specific frontend Cubits.
- **AI Brain (Edge)**: `supabase/functions/ai-page-generate/`
- **Copywriter (Edge)**: `supabase/functions/ai-copywrite/`
- **Page Logic**: `lib/features/builder/controllers/ai_generation_cubit.dart`
- **Copy Logic**: `lib/features/builder/controllers/ai_copywriter_cubit.dart`
- **Quota Logic**: `check_ai_quota` (SQL RPC) and `ai_usage_log` (Table).

## 📈 11. Where are the New Analytics?

Granular event tracking.
- **Service**: `lib/core/services/event_analytics_service.dart`.
- **Database Op**: `record_page_event` (SQL RPC).
- **Triggers**: Handled in `ActionHandlerService` and specific block widgets.

## 🛠 Common Development Tasks

### "I want to add a new section"
1. Create a `SectionWidget` in `lib/features/public_viewer/widgets/`.
2. Create a `SectionEditor` in `lib/features/builder/widgets/editors/blocks/`.
3. Register the mapping in `lib/features/builder/registries/block_registry.dart`.
4. Add the default JSON to `lib/features/builder/registries/template_registry.dart`.
5. Add the section to `SectionLibraryModal` with a category and AI selection hints.
6. Update `AI_CONTEXT.md` and any affected docs under `docs/ai/`.

### "I want to modify the builder"
1. Start at `lib/features/builder/controllers/builder_cubit.dart` for state changes.
2. Check `lib/features/builder/widgets/organisms/builder_sidebar.dart` for UI changes.

### "I want to modify SEO"
1. For app-wide tags, edit `lib/core/seo/app_seo.dart`.
2. For bot-specific HTML, edit `middleware.js`.

### "I want to edit translations"
1. Go to `lib/core/localization/translations_ar.dart` and `translations_en.dart`.
