# THEME SYSTEM - Dynamic Light/Dark Mode Architecture

## Overview
LandyMaker uses a fully dynamic Material 3 theme system. **ALL color values in UI widgets MUST come from `Theme.of(context).colorScheme`**. Hardcoded static `AppColors.*` references for surface/text/border colors are deprecated and forbidden in new code.

---

## 1. Theme Architecture

### ThemeCubit (`lib/core/theme/theme_cubit.dart`)
The single source of truth for the app's theme mode. It emits `ThemeMode` (light/dark).
```dart
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark); // Default: Dark Mode
  bool get isDarkMode => state == ThemeMode.dark;
  void toggleTheme() => emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  void setThemeMode(ThemeMode mode) => emit(mode);
}
```

### AppTheme (`lib/core/theme/app_theme.dart`)
Defines `ThemeData` for both Light and Dark modes using `AppColors` as the base palette. These are the only two places where `AppColors` is legitimately used to define color values.
- `AppTheme.light()` — Full M3 light theme.
- `AppTheme.dark()` — Full M3 dark theme.

---

## 2. Color Mapping: Deprecated → Dynamic

When reading or writing UI code, use this table to map deprecated static colors to dynamic theme equivalents:

| Deprecated (DO NOT USE)       | Dynamic Equivalent (MUST USE)                                          |
|-------------------------------|------------------------------------------------------------------------|
| `AppColors.background`        | `Theme.of(context).colorScheme.surface`                                |
| `AppColors.cardBg`            | `Theme.of(context).colorScheme.surface` or `surfaceContainerHigh`      |
| `AppColors.cardBgHover`       | `Theme.of(context).colorScheme.surfaceContainerHighest`                |
| `AppColors.border`            | `Theme.of(context).colorScheme.outline`                                |
| `AppColors.textPrimary`       | `Theme.of(context).colorScheme.onSurface`                              |
| `AppColors.textSecondary`     | `Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)`       |
| `AppColors.textMuted`         | `Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)`       |

### Still Acceptable (Brand/Static Colors)
These are brand colors, NOT surface colors, and may still be referenced via `AppColors.*`:
- `AppColors.primary` → Use `Theme.of(context).colorScheme.primary` when possible
- `AppColors.secondary` → Use `Theme.of(context).colorScheme.secondary` when possible
- `AppColors.dangerRed` → Use `Theme.of(context).colorScheme.error` when possible
- `AppColors.activeGreen` — Still used as static `Colors.green` equivalent
- `AppColors.warningOrange` — Brand-specific warning color, no M3 equivalent
- `AppColors.primaryGradient` — Static brand gradient asset, acceptable

---

## 3. The AnimatedThemeToggle Widget

**Location**: `lib/core/widgets/atoms/animated_theme_toggle.dart`

A reusable animated toggle button that switches between Light ☀️ and Dark 🌙 modes. It uses `ThemeCubit` for state management and animates with rotation + scale bounce.

```dart
// Usage (in any AppBar actions):
const AnimatedThemeToggle(size: 40),  // Desktop
const AnimatedThemeToggle(size: 36),  // Mobile
```

**Animation Details:**
- Rotation: `Curves.easeOutBack` (180° flip between sun/moon)
- Scale: `TweenSequence` bounce effect (1.0 → 0.8 → 1.2 → 1.0)
- Icon: `Icons.light_mode_rounded` (orange, light) / `Icons.dark_mode_rounded` (amber, dark)

### Placement (Currently Active)
| Location | File | Mode |
|---|---|---|
| Builder Desktop AppBar | `builder_app_bar.dart` | Between SEO and Preview buttons |
| Builder Mobile AppBar | `builder_app_bar.dart` | First action button |
| Dashboard Desktop TopBar | `dashboard_shell.dart` | First item in `_DashboardTopBar` Row |
| Dashboard Mobile AppBar | `dashboard_shell.dart` | First action in mobile `AppBar` |

---

## 4. Critical Rules for AI Agents

> [!WARNING]
> **NEVER use `const BoxDecoration`, `const Text`, or `const Icon` with `AppColors.background`, `AppColors.cardBg`, `AppColors.border`, `AppColors.textPrimary`, `AppColors.textSecondary`, or `AppColors.textMuted`.** These are runtime values from `Theme.of(context)` and are NOT compile-time constants. Doing so causes `const_eval_method_invocation` errors.

> [!IMPORTANT]
> **RULE #30 — Dynamic Color Enforcement**: All new widgets and modifications to existing widgets MUST use `Theme.of(context).colorScheme.*` for surface/text/border colors. Running `grep -r "AppColors.background\|AppColors.cardBg\|AppColors.border\|AppColors.textPrimary\|AppColors.textSecondary\|AppColors.textMuted" lib/ --include="*.dart" --exclude="app_colors.dart"` should yield ZERO results in a fully compliant codebase.

> [!NOTE]
> **Const Stripping Rule**: When replacing a static `AppColors.*` value with a dynamic `Theme.of(context).*` value inside a widget tree, you MUST remove the `const` keyword from the enclosing constructor (e.g. `const BoxDecoration(...)` becomes `BoxDecoration(...)`). Also remove `const` from ancestor widgets if necessary to propagate the non-const context.

> [!NOTE]
> **Context Propagation**: Helper methods that build sub-widgets (e.g., `_buildCard()`, `_buildHeader()`) MUST receive `BuildContext context` as their first parameter if they reference `Theme.of(context)`. Never call `Theme.of(context)` in a method that doesn't have context in scope.

---

## 5. Files NOT Yet Fully Migrated (Known Remaining)

As of June 2026, **all user-facing and builder UI files have been fully migrated** to the dynamic Material 3 theme system. There are no known remaining files with deprecated static color tokens (`AppColors.background`, `AppColors.cardBg`, `AppColors.border`, `AppColors.textPrimary`, `AppColors.textSecondary`, or `AppColors.textMuted`).

The dynamic color enforcement (Rule #30) is now fully active across the entire codebase.


---

## 6. Light/Dark Color Palette Reference

### Dark Mode Palette (`AppColors.dark*`)
| Token | Hex | Usage |
|---|---|---|
| `darkBackground` | `#060A12` | Scaffold background |
| `darkSurface` | `#0A0E1A` | Main content area |
| `darkCardBg` | `#111827` | Cards, AppBar |
| `darkBorder` | `#1F2937` | Dividers, borders |
| `darkTextPrimary` | `#F8FAFC` | Primary text |

### Light Mode Palette (`AppColors.light*`)
| Token | Hex | Usage |
|---|---|---|
| `lightBackground` | `#F8FAFC` | Scaffold background |
| `lightSurface` | `#FFFFFF` | Cards, surfaces |
| `lightBorder` | `#E2E8F0` | Dividers, borders |
| `lightTextPrimary` | `#0F172A` | Primary text |

---

## 7. Reusable Backdrop Blur Widget (AppBlurEffect)

**Location**: `lib/core/widgets/atoms/blur_effect.dart`

To ensure a consistent and clean backdrop blur/glassmorphism effect, use the `AppBlurEffect` widget instead of manually implementing `BackdropFilter` and `ClipRRect` in each container.

### Usage:
Wrap any semi-transparent container widget to apply a backdrop blur effect that is perfectly clipped to its border radius:

```dart
AppBlurEffect(
  borderRadius: BorderRadius.circular(30),
  child: Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(30),
    ),
    child: ...
  ),
)
```

**Parameters:**
- `child` (required): The widget to display on top of the blur effect (usually a container with a transparent/semi-transparent background).
- `blur` (default: `10.0`): The amount of blur to apply (sigmaX/sigmaY values).
- `borderRadius` (default: `BorderRadius.zero`): The border radius to clip the blur effect to (must match the container's border radius).
