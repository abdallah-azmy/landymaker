# AI Onboarding Guide - LandyMaker

Welcome to LandyMaker! This is your entry point to understanding and modifying the LandyMaker codebase efficiently.

## 🎯 1. Project Purpose
LandyMaker is a JSON-driven landing page and e-commerce builder specialized for the MENA region (Arabic-First, RTL).

## 🚀 2. Core Architecture Overview
LandyMaker follows a **Clean Feature-Driven Architecture**:
- **Features**: Isolated modules (auth, builder, dashboard, public_viewer).
- **Core**: Shared infrastructure (theme, router, responsive utils).
- **Services**: Global singletons wrapping infrastructure (Supabase, Auth).

## 🛡️ 3. Safety Rules (DO NOT BREAK)
1.  **Strict RTL**: Always use `EdgeInsetsDirectional`.
2.  **No Direct Inserts**: User data (Leads) **must** go through Edge Functions.
3.  **Source of Truth**: The `designMap` (JSON) is the absolute authority for visual rendering.
4.  **Responsive**: Never use `MediaQuery.of(context).size` inside block widgets; use `LayoutBuilder` and `constraints.maxWidth`.
5.  **Safe Sizing & Numeric Parsing**: Always parse numbers via `NumericParser` when reading style overrides or JSON designs from AI. Never call `.toDouble()` directly on dynamic values because AI may output strings with units (e.g. `"18px"`).
6.  **Unconstrained Image Sizing Safety**: In `CustomNetworkImage`, do not set shimmer or loading layouts to `double.infinity` in unconstrained axes (like height in vertical lists) as it will crash Flutter layout. Leave unconstrained width as `null` and default unconstrained height to `200.0`.
7.  **AI Design Map Application Safety**: Merge design properties into the existing `designMap` rather than replacing the whole map. This preserves page-level settings (like `subdomain`).
8.  **Partial Edit Fault Tolerance**: If the AI returns a subset of blocks without specifying `_index` during an edit request, merge the incoming blocks into the existing ones by matching types sequentially instead of replacing the entire page, preventing blank page errors.
9.  **Responsive Layout Safety**: Never use `LayoutBuilder` inside an `IntrinsicHeight` widget (it crashes). Avoid `GridView` with fixed `childAspectRatio` for content cards; prefer `ResponsiveUtils.getContentColumns(width)` with auto-height layouts (`Row`/`Column`). Use `FittedBox(scaleDown)` for decorative mockups to prevent intermediate screen overflow.
10. **Edge Function AI Development**: Do not hardcode AI JSON schemas inside the edge function source code. The single source of truth is `supabase/functions/shared/schema_registry.json`. Use `SUPABASE_SERVICE_ROLE_KEY` to bypass RLS when writing usage logs from the server. Use Promise Memoization when caching third-party API calls (e.g. Pixabay) to prevent cache stampedes.
## 🧭 4. Navigation & Files
- Read [AI_NAVIGATION.md](./AI_NAVIGATION.md) to locate specific systems.
- Refer to [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md) for folder hierarchy.
- Use [SCREEN_INDEX.md](./SCREEN_INDEX.md) to find UI files by purpose.

## 🛠 5. Common Workflows

### Modifying a Section
1.  Find the renderer: `lib/features/public_viewer/widgets/custom_<name>_widget.dart`.
2.  Find the editor: `lib/features/builder/widgets/editors/blocks/<name>_editor.dart`.
3.  Update logic in both to maintain 1:1 parity.

### Adding a Service
1.  Define the class in `lib/services/`.
2.  Register it in `lib/injection_container.dart`.
3.  Inject it into relevant Cubits.

## 💾 6. Environment & Development
- **Secrets**: Handled via `--dart-define`. See [AI_CONTEXT.md](../AI_CONTEXT.md) Section 12.
- **Backend**: Supabase.
- **Frontend**: Flutter Web (Stable).

## 🆘 7. Where to start?
If you are new to this repo, your first task should be to explore `lib/features/builder/` and `lib/features/public_viewer/` as they represent the core value proposition of LandyMaker.
