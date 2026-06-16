# FULL THEME AND UI OVERHAUL PROTOCOL

## 1. The Core Problem
The previous AI implementation failed drastically. It hardcoded `AppColors.darkSurface` and `AppColors.darkBackground` in several widgets (like `dashboard_shell.dart`, `home_template_strip.dart`) and completely ignored over 1,200 instances of `AppColors.background`, `AppColors.textPrimary`, etc., spread across the codebase, particularly in `lib/features/builder/`. 
This means the Builder and Dashboard screens are permanently stuck in an incomplete Dark Mode and will completely break in Light Mode.

## 2. Objective
To completely eradicate all hardcoded `AppColors` across the ENTIRE application, ensuring 100% compatibility with `Theme.of(context).colorScheme`, and to elevate the UI density and professionalism across all screens to a premium level. Every single page must support dynamic Light/Dark mode flawlessly.

## 3. Strict Execution Protocol for AI

> [!WARNING]
> **CRITICAL RULE**: Do NOT modify, delete, or "refactor" any business logic, `Cubit` states, routing, or database calls. Only touch the visual layer (`build` methods, `Color` assignments, `Padding`, `BoxDecoration`).

### Phase 1: Eradicate Hardcoded Colors
You must do a systematic search-and-replace across the UI files. Replace static `AppColors` with their dynamic equivalents using `Theme.of(context)`:
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
*   `AppColors.darkSurface` / `darkBackground` ➔ `Theme.of(context).colorScheme.surface`

**Primary Target Directories**:
1. `lib/features/builder/widgets/organisms/`
2. `lib/features/builder/widgets/modals/`
3. `lib/features/dashboard/screens/`
4. `lib/features/home/`

### Phase 2: Fixing Context and Stateless Widgets
Because `Theme.of(context)` requires a `BuildContext`, you will encounter variables declared outside the `build` method. 
*   **Fix**: Move color declarations inside the `build` method.
*   Do not try to pass colors into widget constructors if the widget can just call `Theme.of(context)` itself.

### Phase 3: Premium UX & Density Polish (The "Wow" Factor)
*   **Paddings & Spacing**: The app currently suffers from "empty space syndrome" on desktop. Reduce massive `EdgeInsets.all(32+)` to `16` or `20`. 
*   **Max Widths**: Use `ConstrainedBox` with a `maxWidth` of `1200` for main dashboard content and `800` for reading/form content so things don't stretch indefinitely on large monitors.
*   **Card Styling**: Ensure all cards use `Theme.of(context).cardTheme`. Standardize the corner radii to `16px`. Add very subtle drop shadows in Light Mode, and sharp 1px borders in Dark Mode.
*   **Typography**: Ensure `Theme.of(context).textTheme` is used everywhere instead of manually declaring `TextStyle(color: ...)` unless adding a specific weight.

## 4. Verification Check
After updating a file, you must verify that `AppColors` is no longer imported or used in that file. Your job is not done until a global search for `AppColors.` yields ZERO results in the `lib/features` directory.
