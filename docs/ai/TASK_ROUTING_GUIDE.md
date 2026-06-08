# Task Routing Guide - LandyMaker

Use this guide after reading `AI_CONTEXT.md`, `AI_ONBOARDING.md`, and `AI_NAVIGATION.md`.

## Builder / Sections / Templates
- Read `docs/ai/BUILDER_ARCHITECTURE.md`.
- Inspect only:
  - `lib/features/builder/registries/block_registry.dart`
  - `lib/features/builder/registries/template_registry.dart`
  - `lib/features/builder/widgets/modals/section_library_modal.dart`
  - relevant editor under `lib/features/builder/widgets/editors/blocks/`
  - relevant renderer under `lib/features/public_viewer/widgets/`
- Keep `designMap` JSON backward compatible.

## Screens
- Read `docs/ai/SCREEN_INDEX.md`.
- Modify only the screen and directly related widgets/controllers.

## Routes
- Read `docs/ai/ROUTE_INDEX.md`.
- Verify reserved paths and tenant routing assumptions before changing catch-all routes.

## Services
- Read `docs/ai/SERVICE_INDEX.md`.
- Preserve Supabase, rate limiting, Turnstile, and Edge Function proxy assumptions.

## Features
- Read `docs/ai/FEATURE_INDEX.md`.
- Follow feature boundaries before introducing shared code.

## Dependencies
- Read `docs/ai/DEPENDENCY_MAPS.md`.
- Prefer existing dependencies and patterns before adding packages.
