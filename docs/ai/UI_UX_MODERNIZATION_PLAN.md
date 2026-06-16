# FULL THEME AND UI OVERHAUL PROTOCOL (PHASED EXECUTION)

## 1. The Core Problem & Current Status
The app contains nearly 900 remaining instances of hardcoded `AppColors.*` (e.g., `AppColors.background`, `AppColors.textPrimary`), mostly concentrated in the Builder editors. This breaks dynamic Light/Dark mode.
Because this is a massive operation, attempting to fix all files at once will hit rate limits. Therefore, this protocol is split into **bite-sized stages**.

## 2. Objective
To completely eradicate all hardcoded `AppColors` across the ENTIRE application, ensuring 100% compatibility with `Theme.of(context).colorScheme`, and to elevate the UI density and professionalism to a premium level without hitting AI usage limits.

## 3. Strict Execution Rules for AI
> [!WARNING]
> **CRITICAL RULE**: Do NOT modify, delete, or "refactor" any business logic, `Cubit` states, routing, or database calls. Only touch the visual layer (`build` methods, `Color` assignments, `Padding`, `BoxDecoration`).

When you are asked to execute a stage, you must replace static `AppColors` with their dynamic equivalents using `Theme.of(context)`:
*   `AppColors.background` ➔ `Theme.of(context).colorScheme.surface`
*   `AppColors.cardBg` ➔ `Theme.of(context).colorScheme.surfaceContainer` (or `surface`)
*   `AppColors.border` ➔ `Theme.of(context).colorScheme.outline`
*   `AppColors.textPrimary` ➔ `Theme.of(context).colorScheme.onSurface`
*   `AppColors.textSecondary` ➔ `Theme.of(context).colorScheme.onSurfaceVariant`
*   `AppColors.textMuted` ➔ `Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)`
*   `AppColors.secondary` ➔ `Theme.of(context).colorScheme.secondary`
*   `AppColors.primary` ➔ `Theme.of(context).colorScheme.primary`
*   `AppColors.dangerRed` ➔ `Theme.of(context).colorScheme.error`
*   `AppColors.activeGreen` ➔ `Colors.green`

*Note: If the widget is stateless or extracts colors outside the `build` method, move the color assignments inside `build` to access `context`.*

---

## 4. Execution Stages (Run One Stage Per Prompt)

### Stage 1: Layout Picker & Global Editors
**Target Directories:**
- `lib/features/builder/widgets/layout_picker/` (e.g., `layout_slot_grid.dart`, `slot_widget_selector.dart`)
- `lib/features/builder/widgets/editors/global/` (e.g., `sticky_cta_editor.dart`)

**Goal:** Clean these specific directories entirely. Improve padding (reduce from 32 to 16/24 where appropriate) and ensure cards don't look empty.

### Stage 2: Main Block Properties & Sub-Editors
**Target Directories:**
- `lib/features/builder/widgets/editors/block_properties_editor.dart` (This file is huge and has dozens of `AppColors`. Focus heavily here).
- `lib/features/builder/widgets/editors/` (Any other remaining `*_editor.dart` or tabs).

**Goal:** This is the heaviest UI part of the builder. Be extremely careful not to break the callbacks. Only swap the colors and tighten the layout density.

### Stage 3: Public Viewer & Builder Core
**Target Directories:**
- `lib/features/public_viewer/` (If any `AppColors` exist here)
- `lib/features/builder/widgets/modals/` (Clean up any remaining modals that were missed)
- `lib/features/builder/widgets/organisms/` (Clean up anything missed like bottom bars)

### Stage 4: Core, Auth, and Home Polish
**Target Directories:**
- `lib/core/` (e.g., `app_router.dart`, `atoms`, `molecules`)
- `lib/features/auth/`
- `lib/features/home/`

**Goal:** The final sweep. Ensure all login screens, routing error screens, and homepage sections are flawless and 100% dynamic. At the end of Stage 4, a grep for `AppColors.` in `lib/` (excluding `app_colors.dart`) should yield ZERO results.
