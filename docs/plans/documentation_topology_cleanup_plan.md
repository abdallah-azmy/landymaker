# Plan: Documentation Topology Refactoring & Workspace Cleanup

This plan establishes a high-fidelity **Hierarchical Context Topology** (Parent-Child layout) to optimize AI readability and context window efficiency. It also cleans up outdated documentation artifacts to ensure future AI agents do not get confused by stale designs.

---

## 📋 Pillars of the Plan

### Pillar 1: Workspace Cleanup & Archiving
*   **Goal**: Clean up stale plans and templates that describe pre-refactored states, freeing up directory scanning overhead.
*   **Actions**:
    1.  Create the archive directory: `docs/plans/archive/`.
    2.  Move all completed/stale plans from `docs/plans/` into the archive:
        *   `ai_docs_audit_plan.md`
        *   `cube_explosion_3d_enhancement_plan.md`
        *   `cube_transition_refinement.md`
        *   `home_page_enhancements_plan.md`
        *   `homepage_and_templates_plan.md`
        *   `homepage_preview_plan.md`
        *   `splash_logo_animation_plan.md`
        *   `unified_brick_building_plan.md`
    3.  Delete obsolete utility files:
        *   `docs/tasks/TASK_TEMPLATE.md`

---

### Pillar 2: Global Documentation Updates
*   **Goal**: Align global architecture assets with the post-modularized codebase.
*   **Actions**:
    1.  **Update [SYSTEM_MAP.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/SYSTEM_MAP.md)**:
        *   Document the sharded parts model of `SupabaseService` (`supabase_auth.dart`, `supabase_pages.dart`, `supabase_storage.dart`) using the Dart `part/part of` mixin pattern.
        *   Document the sharded structure of `LandingPageBuilderCubit` (`builder_cubit_blocks.dart`, `builder_cubit_persistence.dart`).
        *   Document extracted widget folders for `navbar/`, `hero/`, and the newly extracted `logo_test_dialog.dart`.
    2.  **Update [BUILDER_ARCHITECTURE.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/BUILDER_ARCHITECTURE.md)**:
        *   Detail the mixin-based sharding strategy used to split Cubits.
        *   Add a section explaining Isolate-based asynchronous offloading (`Isolate.run()` / `compute()`) for both `jsonEncode` (saving) and `jsonDecode` (loading/history) cycles.
    3.  **Update [BLOCK_SCHEMA_REGISTRY.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/BLOCK_SCHEMA_REGISTRY.md)**:
        *   Verify block key names correspond exactly to current presets to prevent agents from writing legacy block contracts.

---

### Pillar 3: Hierarchical Topology & Local Feature Playbooks
*   **Goal**: Direct AI agents to local context nodes to prevent context pollution and memory bloat.
*   **Actions**:
    1.  **Refactor [AI_CONTEXT.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/AI_CONTEXT.md)**:
        *   Convert it into a clean global Entry Point file.
        *   Remove nested class details for sub-features.
        *   Add a **Topology Link Directory** pointing to each feature's local `README.md` (e.g. `lib/features/super_admin/README.md`).
        *   Add instructions telling agents to *always* read the local `README.md` of their target feature folder before editing.
    2.  **Verify & Standardize Feature `README.md` Playbooks**:
        *   Ensure the following files exist and match the local playbook format:
            *   `lib/features/super_admin/README.md`
            *   `lib/features/blog_admin/README.md`
            *   `lib/features/subscription/README.md`
            *   `lib/features/public_viewer/README.md`
            *   `lib/features/builder/README.md`
        *   Each playbook must define:
            *   **Purpose**: Local module responsibilities.
            *   **File Map**: Key UI screens, dialogs, widgets, and state/cubits.
            *   **State & Services**: Local state flows and active dependencies.
            *   **AI Warnings**: Explicit warnings to prevent legacy anti-patterns (e.g., in `super_admin/` do not merge sharded tab widgets; in `public_viewer/` do not break responsive columns).

---

## 🏁 Verification Plan
*   **Dry Run Scan**: Ensure all markdown links in `AI_CONTEXT.md` resolve to existing, active `README.md` paths.
*   **No Code Interruption**: Verify no source code files are touched, modified, or deleted during this documentation cleanup.
