# Implementation Plan - AI-Friendly Project Restructuring

Transform the Landymaker codebase into an AI-optimized environment by creating a comprehensive documentation layer, improving discoverability, and standardizing naming conventions.

## User Review Required

> [!NOTE]
> This plan focuses on documentation and non-breaking structural improvements. No business logic or UI behavior will be changed.

- **Naming Standardization**: I plan to rename some widgets to be more consistent (e.g., removing redundant "Custom" prefix where appropriate). I will ensure imports are updated correctly.
- **Dead Code**: I've noticed `/dashboard/products` is a placeholder. I will document this as a "Future Feature" rather than removing it, unless instructed otherwise.

## Proposed Changes

### AI Documentation System (`/docs/ai/`)

#### [NEW] [PROJECT_STRUCTURE.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/PROJECT_STRUCTURE.md)
- High-level overview of the folder hierarchy and architectural boundaries.

#### [NEW] [AI_NAVIGATION.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/AI_NAVIGATION.md)
- Fast-onboarding guide for locating systems (Builder, SEO, Leads, etc.).

#### [NEW] [FEATURE_INDEX.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/FEATURE_INDEX.md)
- Map of features to their business purpose and main files.

#### [NEW] [SCREEN_INDEX.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/SCREEN_INDEX.md)
- Index of all screens with their paths and routes.

#### [NEW] [SERVICE_INDEX.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/SERVICE_INDEX.md)
- Index of all services and their responsibilities.

#### [NEW] [ROUTE_INDEX.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/ROUTE_INDEX.md)
- Comprehensive map of app routes.

#### [NEW] [BUILDER_ARCHITECTURE.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/BUILDER_ARCHITECTURE.md)
- Detailed breakdown of the builder's JSON-driven rendering pipeline.

#### [NEW] [DEPENDENCY_MAPS.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/DEPENDENCY_MAPS.md)
- Visual/textual mapping of inter-service and inter-feature dependencies.

#### [NEW] [AI_ONBOARDING.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/AI_ONBOARDING.md)
- The primary "Read Me First" for future AI models.

---

### Folder Documentation (README.md)

- [NEW] `lib/core/README.md`
- [NEW] `lib/features/README.md`
- [NEW] `lib/services/README.md`
- [NEW] `lib/features/builder/README.md`
- [NEW] `lib/features/dashboard/README.md`
- [NEW] `lib/features/public_viewer/README.md`
- [NEW] `supabase/README.md`

---

### File Discoverability (Headers)

Add standardized headers to:
- `lib/main.dart`
- `lib/core/router/app_router.dart`
- `lib/features/builder/controllers/builder_cubit.dart`
- `lib/features/public_viewer/widgets/section_renderer.dart`
- `lib/services/supabase_service.dart`
- `middleware.js`

---

### Naming & Cleanup

- Rename `CustomHeroWidget` to `HeroSection` (if safe).
- Rename `CustomPricingWidget` to `PricingSection` (if safe).
- Consistently use `Section` suffix for block-level widgets in `public_viewer`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no broken imports after renames.
- Command: `flutter analyze`

### Manual Verification
- Verify that all newly created `.md` files are accessible and correctly linked.
- Verify that the `docs/ai/AI_ONBOARDING.md` provides a clear path to understanding the project.
