# LandyMaker 🚀 (لاندي ميكر) — AI Context Entry Point

Welcome, AI Assistant. This is the **global entry point** for LandyMaker, a professional SaaS Landing Page and E-commerce Builder engineered for the MENA region with native RTL and Arabic-first support.

**⚠️ ALWAYS read the local `README.md` of any feature folder you modify before editing code.**

---

## 📚 Documentation Index

### ⚠️ Read These First (Core Architecture & Rules)
- **[AI Development Rules](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/AI_DOCUMENTATION_RULES.md)** — CRITICAL: all execution protocols, UI/UX patterns, state management rules.
- **[DevOps & Assets](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/DEVOPS_AND_ASSETS.md)** — CRITICAL: deployment, CI/CD, image handling, secrets.
- **[Unified System Map](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/SYSTEM_MAP.md)** — directory structures, features index, screens, routes, services, dependency flowcharts.

### 🧊 Cube Loading & Logo System (Read in Order)
- **[Cube Ecosystem](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/CUBE_ECOSYSTEM.md)** — Master reference for CubeLoader vs FloatingCubeBackground.
- **[Cube Loader](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/CUBE_LOADER.md)** — API, variants, states, performance.
- **[Floating Cube Background](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/FLOATING_CUBE_BACKGROUND.md)** — V2 particle system: 4 modes, physics engine, entity lifecycle.
- **[HTML Loading View](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/HTML_LOADING_VIEW.md)** — Pre-Flutter HTML loading screen, cross-fade to Flutter.
- **[Loading Logo System](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/LOADING_LOGO_SYSTEM.md)** — DEPRECATED: use CubeLoader.

### 🏗️ Builder & Feature Systems
- **[Builder Architecture](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/BUILDER_ARCHITECTURE.md)** — Editor workspace, BlockRegistry, Section Library, theme management, undo/redo, templates, mixin sharding, isolate offloading, back navigation, bottom sheets, Desktop/Mobile toolbar consistency, content tab dispatcher.
- **[Block Schema Registry](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/BLOCK_SCHEMA_REGISTRY.md)** — All 29 block types with schemas, layout_style values, editor paths, AI generation rules.
- **[Theme System](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/THEME_SYSTEM.md)** — Dynamic M3 light/dark theme, color mapping, Rule #30.

### 🔧 Debugging & Reference
- **[API Logging Guide](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/API_LOGGING_GUIDE.md)** — Structured logging, SupabaseLoggingMixin.
- **[Concurrent Modification Crash Fix](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/CONCURRENT_MODIFICATION_CRASH_FIX.md)** — Fix for `ConcurrentModificationError` in particle loops.

---

## 🧭 Topology Link Directory

Each feature module has a local `README.md` playbook. **Always read the relevant playbook before editing any code in that feature.**

| Feature | Path | Purpose |
|---------|------|---------|
| **Super Admin** | [`lib/features/super_admin/README.md`](file:///Users/abdallahazmy/Projects/landymaker/lib/features/super_admin/README.md) | Platform admin panel, user management, plan config, broadcast, SEO |
| **Blog Admin** | [`lib/features/blog_admin/README.md`](file:///Users/abdallahazmy/Projects/landymaker/lib/features/blog_admin/README.md) | Blog CRUD, categories, slug enforcement |
| **Subscription** | [`lib/features/subscription/README.md`](file:///Users/abdallahazmy/Projects/landymaker/lib/features/subscription/README.md) | Upgrade modals, payment UI (no cubit) |
| **Public Viewer** | [`lib/features/public_viewer/README.md`](file:///Users/abdallahazmy/Projects/landymaker/lib/features/public_viewer/README.md) | Landing page rendering, SectionRenderer, 33+ widgets |
| **Builder** | [`lib/features/builder/README.md`](file:///Users/abdallahazmy/Projects/landymaker/lib/features/builder/README.md) | Editor workspace, registries, block editors, cubit mixins |
| **Dashboard** | [`lib/features/dashboard/README.md`](file:///Users/abdallahazmy/Projects/landymaker/lib/features/dashboard/README.md) | User hub — site management, analytics, leads, media gallery, domain config |
| **Auth** | [`lib/features/auth/README.md`](file:///Users/abdallahazmy/Projects/landymaker/lib/features/auth/README.md) | Login, register, password reset, Google OAuth, session restoration |
| **Home** | [`lib/features/home/README.md`](file:///Users/abdallahazmy/Projects/landymaker/lib/features/home/README.md) | SaaS marketing site, cube ecosystem, template picker, cross-fade transition |
| **Services** | [`lib/services/README.md`](file:///Users/abdallahazmy/Projects/landymaker/lib/services/README.md) | Sharded infrastructure adaptors — Supabase, Auth, Storage, Database, Tenant, Subscription |

---

## 🎯 Project Overview

LandyMaker: **Builder Workspace → JSON Schema → SectionRenderer → ActionHandlerService**.

- **`lib/` structure**: `core/` (shared), `features/` (domain modules), `services/` (infrastructure adaptors)
- **State management**: BLoC/Cubit (`flutter_bloc`)
- **DI**: GetIt (`injection_container.dart`)
- **Routing**: GoRouter (`lib/core/router/app_router.dart`)
- **Backend**: Supabase (auth, DB, storage, Edge Functions)
- **Languages**: Arabic (primary) + English — `context.translate('key')`, `EdgeInsetsDirectional`

---

## 🛡️ Critical Security Rules

1. **NO direct DB inserts** from client — always route through Edge Functions (`lead-submit`, `ai-page-generate`, `ai-copywrite`).
2. **Turnstile Captcha** required on all form blocks (`lead_form`, `lead_magnet`, `multi_step_lead_form`).
3. **Fingerprint** every submission via `FingerprintUtils.getFingerprint()`.
4. **Edge Function auth**: `lead-notify` requires `WEBHOOK_SECRET` Bearer token.
5. **No secrets in client code** — use `EnvUtils` for env vars.

---

## 🤖 AI Agent Instructions

1. **Read the local README.md** of the feature you are editing before making any changes.
2. **Never guess** block type strings — use the 29 registered types from `BLOCK_SCHEMA_REGISTRY.md`.
3. **Never inline `jsonDecode`/`jsonEncode`** — use `parseJsonDesign()` from `core/utils/json_utils.dart` or the cubit's isolate-based helpers.
4. **Never merge sharded files** — the `part`/`part of` and mixin splits are deliberate for AI readability.
5. **All links in this file must resolve** — if you add a new feature playbook, add its link here.
6. **Documentation updates** are tracked in `docs/reports/audit_execution_log.md`.

### 🏗️ Builder-Specific Rules (from Comprehensive Audit)

7. **Section Data Variant Key Rule (CRITICAL)**: In `section_data.dart`, hero and hero_saas variants MUST use the `layout_style` key (NOT `variant_style`) to match the renderer's `_effectiveVariant` mapping. Using `variant_style` causes the variant selection to fall through to the default layout (index 0). Hero variants must map to layout_style values: `split`, `centered`, `glass`, `fullWidthBg`, `reverse`, `gradientOnly`, `fullWidthImage`, `minimal`. Hero_SaaS variants: `dashboardSplit`, `launchCenter`, `darkSaas`.

8. **Back Navigation Save-and-Exit Rule (CRITICAL)**: Both `BuilderAppBar._handleBack()` (desktop) and `BuilderMobileToolbar._handleBack()` (mobile) MUST offer 3 options: Cancel, Exit (discard changes), and **Save and Exit**. The `_onWillPop()` handler in `builder_workspace_screen.dart` must also offer save-and-exit when the user presses system back. Never offer only Cancel/Exit.

9. **Dynamic Color Theme Rule (CRITICAL — Builder)**: All `AppColors.activeGreen` and `Colors.green` references in builder files MUST use `Theme.of(context).colorScheme.primary` instead. This has been fully applied to `builder_app_bar.dart` (11+ places), `builder_workspace_screen.dart`, `builder_mobile_toolbar.dart` (5 places), and `builder_options_modal.dart`. Do NOT reintroduce hardcoded green in these files.

10. **Section Library Completeness Rule**: The `SectionLibraryModal` must expose all 29 block types. Library `section_data.dart` entries must have matching `BlockRegistry` renderer, `LandingPageBuilderCubit.addBlock()` default, and an editor path. The `_DualMiniPreview` widget uses abstract geometric patterns only — never real section content. Category filter chips scroll horizontally.

11. **Bottom Sheets Consistency Rule**: All modals in the builder must use `DraggableModalSheet.show()` with `isScrollControlled: true`, `CubeLoader`/`CubeProgress` (never `CircularProgressIndicator`), and meaningful titles. All 7 builder modals now comply as of Phase 16. Default sizes: `initialChildSize=0.6`, `minChildSize=0.4`, `maxChildSize=0.95`. For AI chat modals, use `initialChildSize=0.85`.

12. **DynamicFontService After AI Rule**: After every `applyDesignJson()` call (from AI generation, template load, page load, or custom design apply), `DynamicFontService.loadFontsFromDesign()` MUST be called with the design JSON to load the theme's `defaultFont`. This applies in 4 persistence methods: `_handleLoadedPage`, `applyTemplate`, `applyCustomDesign`, and `applyDesignJson`. Missing this call causes the font picker to have no visible effect on the canvas.

13. **Large File Awareness (Phase 16 Clean)**: All 4 previously oversized builder files are now under 800 lines after Phase 16 splits. One file remains large:
    - `builder_cubit_blocks.dart` (702 lines ✅) — was 1054; items CRUD extracted to `builder_cubit_blocks_items.dart` (361 lines)
    - `builder_cubit_persistence.dart` (656 lines ✅) — was 1045; design/image methods extracted to `builder_cubit_persistence_design.dart` (263 lines) and `builder_cubit_persistence_images.dart` (219 lines)
    - `section_data.dart` (738 lines ✅) — was 812; base types extracted to `section_data_base.dart` (77 lines)
    - `builder_workspace_screen.dart` (555 lines ✅) — was 811; 6 widgets extracted to `screens/workspace/`
    - `block_properties_editor.dart` (1500+ lines) — full split deferred

14. **Back Button Cancel/Exit Fallback**: Always use `context.safePop()` for back navigation with `Icons.arrow_back_ios_new_rounded` as static back icon. Never hardcode routing paths in back buttons.

15. **Cubit Mixin Shard Rule (Phase 16)**: `LandingPageBuilderCubit` now mixes in 5 mixins: `BuilderCubitBlocks` (blocks.dart), `BuilderCubitBlocksItems` (blocks_items.dart), `BuilderCubitPersistence` (persistence.dart), `BuilderCubitPersistenceDesign` (persistence_design.dart), `BuilderCubitPersistenceImages` (persistence_images.dart). When adding new cubit methods, add them to the appropriate existing mixin or create a new one if the target mixin would exceed 800 lines.

16. **CustomTextField maxLength Rule**: `CustomTextField` now accepts a `maxLength` int parameter. Always pass sensible field-type limits: title=100, subtitle/description=300, quote=500, URL=2000, phone=20, email=254, price=30, button_text=50. 33 constraints applied across 18 editor files as of Phase 16.

17. **Preview Toggle Rule**: `BuilderAppBar` has 4 preview modes: mobile, tablet (added Phase 16), desktop, fullscreen. On mobile screens, `builder_workspace_screen.dart` defaults `_previewMode` to `PreviewMode.mobile` via post-frame callback. Tablet toggle uses `Icons.tablet_rounded`.

18. **Unsaved Changes Indicator Rule**: `BuilderAppBar` shows a small red dot (`error.withValues(alpha: 0.8)`) next to the page title when `state.hasUnsavedChanges` is true. The dot uses `error` (not `primary`) so it clearly signals a problem.
