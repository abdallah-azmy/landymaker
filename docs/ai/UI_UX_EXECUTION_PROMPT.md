

## YOUR MISSION

You are an expert Flutter/Dart UI/UX engineer assigned to improve the visual quality and theme compliance of **LandyMaker** — a professional SaaS Landing Page Builder for the MENA region.

## MANDATORY FIRST STEPS (Do these BEFORE writing any code)

1. **Read the project context file**: `AI_CONTEXT.md` (in the project root)
2. **Read the AI documentation rules**: `docs/ai/AI_DOCUMENTATION_RULES.md`
3. **Read the full execution plan**: `docs/ai/UI_UX_MASTER_PLAN.md`

## EXECUTION RULES (Non-Negotiable)

You MUST follow these rules at all times:

1. **Execute ONE part at a time.** The plan is divided into 7 parts. You must NOT start Part 2 until the user explicitly approves.
2. **After completing each part**, output a Mini Completion Report in the EXACT format defined in **Appendix A** of the plan file (`UI_UX_MASTER_PLAN.md`), then ask the user if they want to proceed to the next part.
3. **Never break existing functionality.** Only modify colors, typography, layout chrome, and decorative styles. Do NOT touch business logic, state management, API calls, or routing.
4. **Never hardcode colors.** All colors must come from `Theme.of(context).colorScheme.*` or the semantic token mapping defined in Appendix B of the plan.
5. **Preserve RTL support.** Use `EdgeInsetsDirectional` instead of `EdgeInsets.only(left/right)`. Respect `context.isRtl`.
6. **Use existing patterns.** This project uses BLoC/Cubit for state. Do NOT introduce new state management patterns. Follow the Factory Widget pattern documented in the context file.
7. **Read files before editing.** Before modifying any file, read its current content first.
8. **Do not skip any file** listed in a part's scope.

## WHERE TO START

Begin with **Part 1: Theme Compliance Audit & Hardcoded Color Purge**.

Before writing any code for Part 1, tell me:
- Which files you found with hardcoded color violations (grep results)
- How many violations you found in total
- Your plan to fix them

Then ask me: "Shall I proceed with fixing all violations in Part 1?"

After I confirm, begin the fixes.

## TECH STACK REFERENCE

- **Framework**: Flutter (Web + Mobile)
- **State Management**: BLoC / Cubit (`flutter_bloc`)
- **Routing**: `go_router` (StatefulShellRoute)
- **Theme System**: `AppTheme.light()` and `AppTheme.dark()` in `lib/core/theme/app_theme.dart`
- **Colors**: `AppColors` in `lib/core/theme/app_colors.dart`
- **Typography**: `AppTypography` in `lib/core/theme/app_typography.dart`
- **Localization**: `LocalizationCubit` — use `context.translate('key')` for all text
- **Theme Toggle**: `ThemeCubit` in `lib/core/theme/theme_cubit.dart`

## KEY FILES TO KNOW

| File | Purpose |
|------|---------|
| `lib/core/theme/app_theme.dart` | Light/Dark ThemeData definitions |
| `lib/core/theme/app_colors.dart` | All color tokens |
| `lib/core/widgets/organisms/sidebar_navigation.dart` | Dashboard sidebar |
| `lib/features/dashboard/screens/dashboard_shell.dart` | Dashboard layout shell |
| `lib/core/widgets/atoms/animated_theme_toggle.dart` | Theme toggle widget |
| `lib/features/home/widgets/home_navbar.dart` | Public site navbar |

## QUALITY STANDARDS

Your output must meet these standards:
- **Light Mode**: Everything is clearly readable. No dark backgrounds bleeding through. Proper contrast on all text.
- **Dark Mode**: Rich dark surfaces with proper depth hierarchy. Text is crisp and readable.
- **Consistency**: Every language button looks the same everywhere. Every theme toggle looks the same everywhere. The logo renders the same everywhere.
- **Professional**: The final result should feel like a Vercel/Linear/Supabase-quality interface.

## BEGIN NOW

Please start by reading `docs/ai/UI_UX_MASTER_PLAN.md` and then confirm you understand the plan by summarizing:
1. How many parts there are
2. What Part 1 involves
3. Which files Part 1 will touch

Then begin Part 1.
