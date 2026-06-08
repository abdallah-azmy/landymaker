# AI Documentation Rules - LandyMaker

Keep AI-facing docs synchronized with implementation changes. Documentation is part of the architecture contract.

## Update Required When Changing
- Screens: update `SCREEN_INDEX.md`.
- Routes: update `ROUTE_INDEX.md`.
- Services or infrastructure flows: update `SERVICE_INDEX.md`.
- Business features: update `FEATURE_INDEX.md`.
- Builder sections, templates, registries, schema assumptions, or renderer/editor mappings: update `AI_CONTEXT.md`, `AI_NAVIGATION.md`, and `BUILDER_ARCHITECTURE.md`.
- Folder structure or ownership boundaries: update `PROJECT_STRUCTURE.md`.

## Builder Documentation Rules
- Every new section type must be listed in `AI_CONTEXT.md`.
- Every section exposed in `SectionLibraryModal` must have:
  - a matching `LandingPageBuilderCubit.addBlock` default,
  - a `BlockRegistry` renderer mapping,
  - an editor path or a clear generic editing path.
- Future AI-agent hints such as `ai_intent`, `ai_slots`, `ai_role`, and `ai_when_to_use` are advisory only. Renderers must not require them.

## Safety Notes
- Do not document behavior that is not implemented.
- Do not remove security notes for Turnstile, rate limiting, fingerprinting, Edge Functions, RLS, or webhook protection.
- Prefer short, navigational documentation over broad codebase summaries.
