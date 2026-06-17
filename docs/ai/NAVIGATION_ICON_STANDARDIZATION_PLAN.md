# Implementation Plan: Navigation and Icon Standardization

## 🎯 Goal
Standardize back navigation logic and arrow icons across the entire application to ensure a consistent, safe, and intuitive user experience in both LTR and RTL locales, as mandated by the project's AI Documentation Rules (Rule 27 & 28).

## 🛠 Proposed Changes

### 1. Router Extensions
- **[NEW] [router_extensions.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/router/router_extensions.dart)**: Move `safePop` extension from `localization_cubit.dart` to this new dedicated file.

### 2. Back Navigation Audit & Fix
- Replace all instances of `Navigator.pop(context)` or direct `context.go('/')` in page-level back buttons with `context.safePop(fallbackPath: '...')`.
- Affected files (provisional list):
    - `lib/features/auth/screens/*`
    - `lib/features/builder/screens/builder_workspace_screen.dart`
    - `lib/features/dashboard/screens/settings_screen.dart`
    - ... and others found via grep.

### 3. Static Arrow Icons Audit & Fix
- Replace all directional or locale-dependent arrow icons with static standard ones:
    - Back/Previous ➔ `Icons.arrow_back_ios_new_rounded` or `Icons.arrow_back_rounded`.
    - Forward/Next ➔ `Icons.arrow_forward_ios_rounded` or `Icons.arrow_forward_rounded`.
- Ensure no icons are flipping manually or automatically in a way that confuses the user in RTL.

## 🏁 Verification Plan
- [ ] Test back navigation from deep links (direct URL access) to verify `fallbackPath` works.
- [ ] Test back navigation from stacked routes to verify `this.canPop()` works.
- [ ] Verify arrow icon directions in both Arabic (RTL) and English (LTR) modes.
