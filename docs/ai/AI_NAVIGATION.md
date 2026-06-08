# AI Navigation Guide - LandyMaker

This document is the fastest onboarding tool for future AI models. It explains where major systems live without requiring a full codebase scan.

## 🧱 1. Where is the Builder?

The Builder is the heart of the platform.
- **Entry Point**: `lib/features/builder/screens/builder_workspace_screen.dart`
- **Main Logic**: `lib/features/builder/controllers/builder_cubit.dart`
- **The Canvas**: `lib/features/builder/widgets/organisms/builder_canvas.dart`
- **Section Library**: `lib/features/builder/widgets/modals/section_library_modal.dart`
- **Registries**: `lib/features/builder/registries/` (Maps types to renderers).

## 📄 2. Where are Landing Page Sections?

Sections are the visual blocks added by users.
- **Section Renderer**: `lib/features/public_viewer/widgets/section_renderer.dart`
- **Section Widgets**: `lib/features/public_viewer/widgets/` (Look for `custom_*_widget.dart`).
- **Section Editors**: `lib/features/builder/widgets/editors/blocks/` (Look for `*_editor.dart`).
- **Block Definitions**: `lib/features/builder/registries/block_registry.dart`.

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

## 🛠 Common Development Tasks

### "I want to add a new section"
1. Create a `SectionWidget` in `lib/features/public_viewer/widgets/`.
2. Create a `SectionEditor` in `lib/features/builder/widgets/editors/blocks/`.
3. Register the mapping in `lib/features/builder/registries/block_registry.dart`.
4. Add the default JSON to `lib/features/builder/registries/template_registry.dart`.

### "I want to modify the builder"
1. Start at `lib/features/builder/controllers/builder_cubit.dart` for state changes.
2. Check `lib/features/builder/widgets/organisms/builder_sidebar.dart` for UI changes.

### "I want to modify SEO"
1. For app-wide tags, edit `lib/core/seo/app_seo.dart`.
2. For bot-specific HTML, edit `middleware.js`.

### "I want to edit translations"
1. Go to `lib/core/localization/translations_ar.dart` and `translations_en.dart`.
