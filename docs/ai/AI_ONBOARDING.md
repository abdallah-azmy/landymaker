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
