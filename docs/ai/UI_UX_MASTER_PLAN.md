# LandyMaker — UI/UX Master Improvement Plan
## Complete Dark Mode / Light Mode & UX Excellence Initiative

> **Version**: 1.0.0  
> **Created**: 2026-06-17  
> **Scope**: All user-accessible screens and widgets across the entire application  
> **Execution Model**: Part-by-Part Sequential — AI must complete each part, deliver a mini-report, then ask for approval before proceeding.

---

## 🧭 How to Use This Plan (Instructions for the Executing AI Model)

> **MANDATORY EXECUTION PROTOCOL — READ BEFORE STARTING:**
>
> 1. **Read this entire plan first** before writing a single line of code.
> 2. **Execute ONE part at a time.** Do not proceed to the next part without explicit user approval.
> 3. **At the end of each part**, you MUST output a **Mini Completion Report** in the exact format specified in Appendix A at the bottom of this document.
> 4. **After the report**, ask: *"✅ Part [X] is complete. Would you like me to proceed to Part [X+1]: [Part Title]? Or do you have any changes?"*
> 5. **Never break existing functionality.** All changes are purely UI/UX improvements. Do NOT alter business logic, state management, routing, or data fetching.
> 6. **Never use hardcoded colors** (e.g., `Color(0xFF0A0E1A)`, `Colors.black`, `Colors.white`). All colors MUST come from `Theme.of(context).colorScheme.*` or `AppColors.*` semantic tokens.
> 7. **Read `AI_CONTEXT.md` and `AI_DOCUMENTATION_RULES.md`** before starting if you have not already done so.
> 8. **Preserve RTL support.** Always use `EdgeInsetsDirectional` instead of `EdgeInsets.only(left/right)`. All alignment must respect `context.isRtl`.
> 9. **Do not skip any file** listed in a part's scope. Every file mentioned must be touched.
> 10. **After completing all 7 parts**, output a Final Summary Report covering what was changed across the entire plan.

---

## 📋 Table of Contents

| Part | Title | Screens Covered | Status |
|------|-------|-----------------|--------|
| **1** | Theme Compliance Audit & Hardcoded Color Purge | All screens — global pass | ✅ DONE |
| **2** | Auth Screens Polish (Login, Register, Forgot Password, Reset Password) | `auth/screens/*` | ✅ DONE |
| **3** | Home & Marketing Website Polish | `home/screens/*`, `home/widgets/*` | ✅ DONE |
| **4** | Dashboard Shell, Sidebar & Top Bar Redesign | `dashboard_shell.dart`, `sidebar_navigation.dart` | ✅ DONE |
| **5** | Dashboard Inner Screens Polish | All `dashboard/screens/*` inner screens | ✅ DONE |
| **6** | Builder Workspace Shell & AI Agent Experience | `builder/screens/*`, `guest_preview_screen.dart` | ✅ DONE |
| **7** | Global Controls: Theme Toggle, Language Switcher & Logo Standardization | `animated_theme_toggle.dart`, all language buttons, logo widgets | ✅ DONE |

---

## ═══════════════════════════════════════════════════════
## PART 1 — Theme Compliance Audit & Hardcoded Color Purge
## ═══════════════════════════════════════════════════════

### 🎯 Goal
Identify and eliminate every hardcoded color in the codebase that prevents proper Light/Dark Mode switching. After this part, the app's color system will be 100% driven by `Theme.of(context).colorScheme` and semantic tokens.

### 📁 Files in Scope
All `.dart` files under:
- `lib/features/`
- `lib/core/widgets/`

### 🔍 Step-by-Step Instructions

#### Step 1.1 — Audit & List Violations
Run a codebase grep to find all hardcoded color patterns:
```
Color(0xFF0A0E1A)       ← dark navy, used as scaffold background in some screens
Color(0xFF0F172A)       ← darkSurface, used directly instead of colorScheme.surface
const Color(0xFF...)    ← any other hardcoded hex in widget files
Colors.black            ← only acceptable inside `onPrimary` contexts
Colors.white            ← must be replaced by colorScheme.onPrimary or onSurface
AppColors.darkBackground (used in widget builds — not in theme definitions)
AppColors.darkSurface (used in widget builds — not in theme definitions)
AppColors.darkCardBg (used in widget builds — not in theme definitions)
```

#### Step 1.2 — Replacement Mapping
Apply the following semantic replacements in every `.dart` widget file found:

| Hardcoded Value | Correct Replacement |
|---|---|
| `Color(0xFF0A0E1A)` | `Theme.of(context).colorScheme.surface` |
| `Color(0xFF0F172A)` | `Theme.of(context).colorScheme.surface` |
| `Color(0xFF111827)` | `Theme.of(context).colorScheme.surfaceContainerHigh` |
| `AppColors.darkBackground` (in widgets) | `Theme.of(context).scaffoldBackgroundColor` |
| `AppColors.darkSurface` (in widgets) | `Theme.of(context).colorScheme.surface` |
| `AppColors.darkCardBg` (in widgets) | `Theme.of(context).colorScheme.surfaceContainerHigh` |
| `AppColors.darkBorder` (in widgets) | `Theme.of(context).colorScheme.outlineVariant` |
| `AppColors.darkTextPrimary` (in widgets) | `Theme.of(context).colorScheme.onSurface` |
| `AppColors.darkTextSecondary` (in widgets) | `Theme.of(context).colorScheme.onSurfaceVariant` |
| `AppColors.lightBackground` (in widgets) | `Theme.of(context).scaffoldBackgroundColor` |
| `Colors.white` (as text color on dark bg) | `Theme.of(context).colorScheme.onSurface` |

> **Exception Rule**: `AppColors.primary`, `AppColors.secondary`, `AppColors.activeGreen`, `AppColors.dangerRed`, `AppColors.warningOrange` are brand accent tokens and MAY remain hardcoded. They are theme-agnostic accent colors.

#### Step 1.3 — Verify `app_theme.dart` ColorScheme Extensions
Ensure both `light()` and `dark()` ThemeData in `lib/core/theme/app_theme.dart` properly set:
- `surfaceContainerHigh` — used for cards, sidebars, top bars
- `surfaceContainerLow` — used for subtle backgrounds
- `onSurfaceVariant` — used for secondary text
- `outlineVariant` — used for dividers and borders

If any of these are missing from the ColorScheme constructor calls, add them with appropriate light/dark values from `AppColors`.

#### Step 1.4 — Settings Screen Special Fix
In `lib/features/dashboard/screens/settings_screen.dart`, line 68:
```dart
// BEFORE (broken in light mode):
backgroundColor: const Color(0xFF0A0E1A),

// AFTER (correct):
backgroundColor: Theme.of(context).scaffoldBackgroundColor,
```

#### Step 1.5 — Dashboard Shell Special Fix  
In `lib/features/dashboard/screens/dashboard_shell.dart`:
- Line 152: `color: AppColors.darkSurface` → `color: Theme.of(context).colorScheme.surface`
- Line 219: `color: const Color(0xFF0A0E1A)` → `color: Theme.of(context).scaffoldBackgroundColor`

### ✅ Success Criteria for Part 1
- [ ] Zero instances of `Color(0xFF0A0E1A)` in any widget file
- [ ] Zero instances of `Color(0xFF0F172A)` in any widget file  
- [ ] Zero instances of raw `AppColors.dark*` tokens used inside widget `build()` methods (theme definition files are exempt)
- [ ] App displays cleanly in both Light and Dark modes without any hardcoded dark backgrounds bleeding through in Light mode

---

## ═══════════════════════════════════════════════════════
## PART 2 — Auth Screens Polish
## ═══════════════════════════════════════════════════════

### 🎯 Goal
Transform the four authentication screens into world-class, premium-looking forms that work beautifully in both Light and Dark modes. The auth flow is the first impression for new users — it must be stunning.

### 📁 Files in Scope
```
lib/features/auth/screens/login_screen.dart
lib/features/auth/screens/register_screen.dart
lib/features/auth/screens/forgot_password_screen.dart
lib/features/auth/screens/reset_password_screen.dart
```

### 🎨 Design Direction
Think: Linear, Vercel, Supabase login pages — clean, centered, with a subtle brand gradient or pattern in the background, a well-defined card/form area, and clear visual hierarchy.

### 🔨 Step-by-Step Instructions

#### Step 2.1 — Background & Layout
- All four screens must use a **centered two-column layout** on desktop (≥ 768px):
  - **Left column (40%)**: Brand panel — LandyMaker logo prominently displayed, a short tagline (translate key: `auth_brand_tagline`), and a subtle animated gradient or geometric pattern. Background uses `AppColors.primaryGradient` with low opacity overlaid on `Theme.of(context).scaffoldBackgroundColor`.
  - **Right column (60%)**: The actual form, white/dark card with `borderRadius: 24`, `padding: 40` on desktop, `28` on mobile.
- On mobile (< 768px): Single column, no brand panel, just the logo + form centered.

#### Step 2.2 — Form Card Styling
- Card background: `Theme.of(context).colorScheme.surface`
- Card border: `Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1)`
- Card elevation: `0` (use border instead)
- Form title: `AppTypography.h2` with `Theme.of(context).colorScheme.onSurface`
- Form subtitle: `AppTypography.bodyMedium` with `Theme.of(context).colorScheme.onSurfaceVariant`

#### Step 2.3 — Input Fields
- All `TextFormField` widgets must use the centralized `inputDecorationTheme` from `AppTheme` — do NOT override with local styles.
- Add a leading `Icon` to each field matching its purpose:
  - Email → `Icons.email_outlined`
  - Password → `Icons.lock_outline_rounded`
  - Name → `Icons.person_outline_rounded`
  - Confirm Password → `Icons.lock_reset_outlined`
- Ensure password fields have a **visibility toggle** (eye icon), using `Theme.of(context).colorScheme.onSurfaceVariant` for the icon color.

#### Step 2.4 — Action Buttons
- Primary CTA (Login / Register / Send / Reset): Full-width `ElevatedButton` using theme defaults.
- Secondary link (Forgot Password, Switch to Register): `TextButton` using `AppColors.primary` as color.
- Loading state: Show `SizedBox(width:20, height:20, child: CircularProgressIndicator(strokeWidth: 2))` inside the button instead of the text.

#### Step 2.5 — Logo Placement in Auth Screens
- Place the `LandyMakerLogo` widget at the top of the form card (or left brand panel on desktop).
- On mobile, center the logo above the form card.
- Logo must render correctly in both Light and Dark modes (check `LandyMakerLogo` widget for any hardcoded colors).

#### Step 2.6 — Theme Toggle on Auth Screens
- Add the `AnimatedThemeToggle` widget to the **top-right corner** of all auth screens (outside the form card, as a floating button or in a top AppBar).
- This is the ONLY place where a theme toggle should be visible on public/auth screens (not inside any sidebar since there's no sidebar here).

#### Step 2.7 — Language Switcher on Auth Screens  
- Add a **unified language switcher button** (icon: `Icons.language_rounded`, color: `Theme.of(context).colorScheme.onSurfaceVariant`) next to the theme toggle in the top-right area.
- The style of this button must be consistent across all four auth screens — use a shared `_AuthTopBar` widget or similar.

#### Step 2.8 — Accessibility & Polish
- Ensure proper `AutofillHints` on relevant fields (email, password, name).
- Ensure `TextInputAction.next` / `TextInputAction.done` are set correctly.
- Add smooth `AnimatedSwitcher` transitions when switching between form states (loading/error/success).

### ✅ Success Criteria for Part 2
- [ ] All 4 auth screens look premium in both Light and Dark mode
- [ ] No hardcoded colors in any auth screen file
- [ ] Desktop shows 2-column layout; mobile shows single-column
- [ ] Language switcher and theme toggle are visible on all auth screens
- [ ] Form card uses correct semantic colors
- [ ] Password visibility toggle works correctly

---

## ═══════════════════════════════════════════════════════
## PART 3 — Home & Marketing Website Polish  
## ═══════════════════════════════════════════════════════

### 🎯 Goal
Elevate the public marketing homepage to a world-class SaaS landing page that wows visitors in both Light and Dark modes. The home page is the product's shopfront.

### 📁 Files in Scope
```
lib/features/home/screens/landymaker_home_screen.dart
lib/features/home/screens/template_picker_screen.dart
lib/features/home/screens/legal_page.dart
lib/features/home/widgets/home_navbar.dart
lib/features/home/widgets/home_hero_section.dart
lib/features/home/widgets/home_feature_bento.dart
lib/features/home/widgets/home_cta_section.dart
lib/features/home/widgets/home_stats_section.dart
lib/features/home/widgets/home_testimonials_section.dart
lib/features/home/widgets/home_footer.dart
lib/features/home/widgets/home_trust_logos.dart
lib/features/home/widgets/home_template_strip.dart
lib/features/home/widgets/home_luxurious_template_slider.dart
```

### 🔨 Step-by-Step Instructions

#### Step 3.1 — Home Navbar: Theme Toggle & Language Switcher
The `HomeNavbar` currently shows:
- Desktop: Language button (TextButton.icon) on the right
- Mobile: Language icon button on the right

**Changes Required:**
- **Add `AnimatedThemeToggle`** to the desktop navbar, placed BEFORE the language button in the right actions row.
- **Add `AnimatedThemeToggle`** to the mobile navbar main bar, placed BEFORE the language icon button.
- The language button style on desktop should use: icon `Icons.language_rounded` + text from translation, color `Theme.of(context).colorScheme.onSurface`.
- The language icon on mobile should use the same icon style as desktop.
- **Standardize the logo section**: The `_LogoSection` widget currently renders text BEFORE the image (reversed visual order). Fix the order to: `Image` → `Text` (left to right in LTR, reversed in RTL).

#### Step 3.2 — Home Navbar: Light Mode Glassmorphism
The navbar uses `BackdropFilter` blur — ensure it works correctly in Light mode:
- The container color `Theme.of(context).colorScheme.surface.withValues(alpha: 0.75)` is correct.
- The border color `Theme.of(context).colorScheme.outlineVariant` is correct.
- Verify no hardcoded colors override the glassmorphism effect in Light mode.

#### Step 3.3 — Hero Section Light Mode Fix
In `home_hero_section.dart`:
- Search for any gradient that uses hardcoded dark colors for the background overlay.
- Replace background color tokens with `Theme.of(context).scaffoldBackgroundColor` or appropriate semantic tokens.
- Text colors must use `Theme.of(context).colorScheme.onSurface` for primary text and `Theme.of(context).colorScheme.onSurfaceVariant` for subtitles.
- Gradient overlays that are decorative (not text) may remain dark, but must use `AppColors.darkGradient` or similar named tokens, not raw hex values.

#### Step 3.4 — Feature Bento, Stats, Testimonials, CTA, Trust Logos
For each widget in this list:
- `home_feature_bento.dart`
- `home_stats_section.dart`
- `home_testimonials_section.dart`
- `home_cta_section.dart`
- `home_trust_logos.dart`

Apply:
1. Replace any hardcoded background colors with `Theme.of(context).colorScheme.surface` or `Theme.of(context).colorScheme.surfaceContainerHigh`.
2. Replace any hardcoded text colors with `Theme.of(context).colorScheme.onSurface` / `onSurfaceVariant`.
3. Replace any hardcoded border colors with `Theme.of(context).colorScheme.outlineVariant`.
4. Card containers should use the `cardTheme` from `AppTheme` (via `Card` widget or mimic its decoration).

#### Step 3.5 — Template Picker Screen
In `template_picker_screen.dart`:
- The scaffold background must use `Theme.of(context).scaffoldBackgroundColor`.
- Filter chips / category tabs must use `Theme.of(context).colorScheme.primary` for selected state and `Theme.of(context).colorScheme.outlineVariant` for unselected.
- Template cards must use the centralized `cardTheme`.

#### Step 3.6 — Legal Page
In `legal_page.dart`:
- Full semantic color compliance.
- Clean typography using `AppTypography` scale.

#### Step 3.7 — Footer
In `home_footer.dart`:
- Footer background should use a slightly darker variation in Light mode: `Theme.of(context).colorScheme.surfaceContainerHigh`.
- Footer text should use `Theme.of(context).colorScheme.onSurfaceVariant`.
- Social links and copyright should be clearly visible in both modes.

### ✅ Success Criteria for Part 3
- [ ] Home navbar has both ThemeToggle and Language button in desktop and mobile views
- [ ] Logo section shows correct order (image + text)
- [ ] All home sections are fully Light/Dark mode compliant
- [ ] No hardcoded colors in any home widget
- [ ] Template picker uses semantic theme colors throughout

---

## ═══════════════════════════════════════════════════════
## PART 4 — Dashboard Shell, Sidebar & Top Bar Redesign
## ═══════════════════════════════════════════════════════

### 🎯 Goal
Redesign the dashboard shell, sidebar navigation, and top bar to match the quality of professional SaaS platforms like Linear, Notion, Vercel, and Supabase. The sidebar should feel like a premium navigation experience.

### 📁 Files in Scope
```
lib/features/dashboard/screens/dashboard_shell.dart
lib/core/widgets/organisms/sidebar_navigation.dart
lib/core/widgets/molecules/website_switcher.dart
```

### 🔨 Step-by-Step Instructions

#### Step 4.1 — Remove Language Toggle from Dashboard Top Bar
**Critical UX Decision**: Per the plan requirements, language switching inside the dashboard must be ONLY in the Settings screen, NOT in the top bar or sidebar language button.

In `dashboard_shell.dart`:
- **Desktop `_DashboardTopBar`**: REMOVE the `IconButton(Icons.language_rounded)` widget entirely.
- **Mobile `_MobileDashboardShell` AppBar actions**: REMOVE the `IconButton(Icons.language_rounded)` widget.

In `sidebar_navigation.dart`:
- At the bottom of the sidebar, there is currently a `TextButton.icon` for language switching.
- **Replace** this button with a subtle text label linking to Settings: `"⚙️ Language & More Settings"` that navigates to `/dashboard/settings` using `context.go('/dashboard/settings')`. This redirects users to the proper Settings screen for language changes.
- **OR** simply remove the language button from the sidebar footer entirely, since the Settings screen will handle it.

**Rationale**: Centralizing language change in Settings creates a consistent mental model. Having it in 3 different places (top bar, sidebar, settings) confuses users.

#### Step 4.2 — Dashboard Top Bar: Theme Toggle Only
After removing language button, the top bar (`_DashboardTopBar`) on desktop should contain:
- `AnimatedThemeToggle` (keep as-is)
- `_NotificationBell` (keep as-is)
- A divider or spacing
- A compact **user profile chip** (avatar circle + email truncated) — this replaces the need for redundant info

The user profile chip should:
- Show `CircleAvatar` with the user's initial (same as sidebar)
- Show truncated email on hover/click (tooltip)
- On click: show a minimal `PopupMenuButton` with: `Profile` (placeholder), `Settings` (→ `/dashboard/settings`), `Logout`
- Colors: background `Theme.of(context).colorScheme.surfaceContainerHigh`, text `Theme.of(context).colorScheme.onSurface`

#### Step 4.3 — Mobile AppBar: Theme Toggle Only (Remove Language)
Mobile AppBar actions should be:
1. `AnimatedThemeToggle`
2. `_NotificationBell`
3. *(Language removed — now in Settings)*

#### Step 4.4 — Sidebar Navigation Redesign
Redesign `SidebarNavigation` to match professional SaaS platforms:

**4.4.1 — Logo Section**
- Keep the logo + app name at the top.
- Add a very subtle gradient shimmer or a thin colored top border using `AppColors.primary` (2px height, full width at the top of the sidebar).

**4.4.2 — Website Switcher**
- Keep `WebsiteSwitcher` widget in place.
- Ensure it uses `Theme.of(context).colorScheme.surfaceContainerHigh` background.
- Ensure border uses `Theme.of(context).colorScheme.outlineVariant`.

**4.4.3 — Navigation Items Visual Upgrade**
- **Selected item**: Background `AppColors.primary.withValues(alpha: 0.12)`, left border accent `2px` solid `AppColors.primary` (using `BorderSide` on the container decoration), icon color `AppColors.primary`, text color `Theme.of(context).colorScheme.onSurface`, `FontWeight.w600`.
- **Unselected item**: Background `transparent`, icon color `Theme.of(context).colorScheme.onSurfaceVariant`, text color `Theme.of(context).colorScheme.onSurfaceVariant`, `FontWeight.w400`.
- **Hover state**: Wrap each item in `MouseRegion` + `AnimatedContainer` to show `Theme.of(context).colorScheme.surfaceContainerHigh` on hover.
- **Builder item** (the "Go to Builder" link): Give it a special treatment — add a subtle gradient background using `AppColors.primaryGradient` at 0.08 opacity and a star or magic wand icon (`Icons.auto_fix_high_rounded`).

**4.4.4 — Section Headers**
- Current headers are plain text. Make them more visually structured:
  - Use `UPPERCASE` with `letterSpacing: 1.5` and `fontSize: 10`
  - Color: `Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6)`
  - Add a thin horizontal line before the header: `Divider` → only if not the first section

**4.4.5 — Sidebar Footer**
- Remove language button (per Step 4.1).
- Keep the user profile card at the bottom.
- Add a **subtle version/plan badge** inside the user card: Show `"Free Plan"` or `"Pro"` based on the page limit from `LandingPagesCubit`.
- Keep the logout `IconButton` (power icon, `AppColors.dangerRed`).
- The usage progress bar should use `AppColors.primary` color for normal usage and `AppColors.dangerRed` when at 100%.

**4.4.6 — Sidebar Width & Responsive**
- Desktop sidebar width: `260px` (reduce from 270 to match modern SaaS standards).
- Sidebar must be scrollable if items overflow (already using `ListView` — verify).
- On mobile, sidebar appears in `Drawer` — ensure the drawer has the correct background color.

#### Step 4.5 — Dashboard Scaffold Background Fix
Ensure the main content area background uses `Theme.of(context).scaffoldBackgroundColor` (not any hardcoded dark color). Already partially done in `DashboardShell`, but verify all breakpoints.

### ✅ Success Criteria for Part 4
- [ ] Language toggle REMOVED from top bar (desktop and mobile)
- [ ] Language toggle REMOVED from sidebar bottom
- [ ] Top bar contains: ThemeToggle + NotificationBell + User Profile Chip
- [ ] Sidebar selected item has left accent border + primary tinted bg
- [ ] Sidebar navigation items have hover states
- [ ] Sidebar footer shows plan badge + usage bar + logout only
- [ ] All sidebar colors are theme-aware (no hardcoded dark colors)
- [ ] Dashboard content area uses `scaffoldBackgroundColor`

---

## ═══════════════════════════════════════════════════════
## PART 5 — Dashboard Inner Screens Polish
## ═══════════════════════════════════════════════════════

### 🎯 Goal
Polish all individual dashboard screens so they are fully theme-compliant, visually consistent, and professionally structured. Each screen should feel like a section of a premium SaaS dashboard.

### 📁 Files in Scope
```
lib/features/dashboard/screens/dashboard_home_screen.dart
lib/features/dashboard/screens/analytics_screen.dart
lib/features/dashboard/screens/leads_tracker_screen.dart
lib/features/dashboard/screens/media_gallery_screen.dart
lib/features/dashboard/screens/product_feed_screen.dart
lib/features/dashboard/screens/domain_settings_screen.dart
lib/features/dashboard/screens/settings_screen.dart
lib/features/dashboard/widgets/analytics_overview_widget.dart
lib/features/dashboard/widgets/create_page_modal.dart
lib/features/dashboard/widgets/domain_setup_widget.dart
lib/features/dashboard/widgets/empty_workspace_state.dart
lib/features/dashboard/widgets/notification_inbox_modal.dart
lib/features/dashboard/widgets/upgrade_limit_modal.dart
```

### 🔨 Step-by-Step Instructions

#### Step 5.1 — Global Dashboard Screen Rules
Apply these rules to ALL files listed above:
1. **Scaffold background**: `Theme.of(context).scaffoldBackgroundColor` — never hardcoded.
2. **AppBar** (where present): `backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh`. Note: In the `DashboardShell`, screens nested inside the shell do NOT need their own `AppBar` on desktop (since the top bar is in the shell). Remove redundant `AppBar` widgets in nested screens if the shell already provides the top bar. Keep AppBar only for screens that need their own title (analytics, leads, etc.).
3. **Section/page titles**: Use `AppTypography.h2` or `AppTypography.h3` with `Theme.of(context).colorScheme.onSurface`.
4. **Cards**: Use `Theme.of(context).colorScheme.surfaceContainerHigh` as the card background, with `borderRadius: 16` and `border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1)`.
5. **Buttons**: Use theme defaults from `AppTheme`.

#### Step 5.2 — Settings Screen Upgrade
The Settings screen currently only has Notifications and PWA Install. Expand it to include:

**New Settings Sections to Add:**
1. **Appearance** (NEW Section):
   - Theme Mode Toggle: A `ListTile` with `AnimatedThemeToggle` as the trailing widget and title `loc.translate('theme_mode')`.
   - Description: `loc.translate('theme_mode_desc')` (add translation keys).
   
2. **Language** (NEW Section):
   - Language Switcher: A `ListTile` with current language shown as subtitle, and a `TextButton` trailing that calls `loc.toggleLanguage()`.
   - Show the current active language: "العربية" or "English".
   - Description: Short text explaining the language change.

3. **Notifications** (existing): Keep as-is, just ensure theme compliance.
4. **Install App** (existing): Keep as-is, just ensure theme compliance.

This makes Settings the canonical hub for both appearance and language preferences, consistent with the strategy of removing language/theme from the top bar inside the dashboard.

#### Step 5.3 — Dashboard Home Screen
In `dashboard_home_screen.dart`:
- Page header (if any) must use semantic colors.
- Quick action cards (create new page CTA) must use `AppColors.primary` gradient with correct `onPrimary` foreground text.
- The empty workspace state widget (`empty_workspace_state.dart`) must be themed correctly — illustration tints should adapt to dark/light.

#### Step 5.4 — Analytics Screen
In `analytics_screen.dart` and `analytics_overview_widget.dart`:
- Chart colors must use `AppColors.primary` and `AppColors.secondary` (brand-safe, theme-agnostic).
- Chart background containers must use `Theme.of(context).colorScheme.surfaceContainerHigh`.
- Stat numbers: `AppTypography.h1` with `Theme.of(context).colorScheme.onSurface`.
- Stat labels: `AppTypography.caption` with `Theme.of(context).colorScheme.onSurfaceVariant`.

#### Step 5.5 — Leads Tracker Screen
In `leads_tracker_screen.dart`:
- Table/List header background: `Theme.of(context).colorScheme.surfaceContainerHigh`.
- Row alternating backgrounds (if any): Use `Theme.of(context).colorScheme.surface` and `Theme.of(context).colorScheme.surfaceContainerLow`.
- Lead status badges: Use `AppColors.activeGreen`, `AppColors.warningOrange`, or `AppColors.dangerRed` with corresponding `withValues(alpha: 0.15)` backgrounds.

#### Step 5.6 — Media Gallery Screen
In `media_gallery_screen.dart`:
- Image grid cards must use `Theme.of(context).colorScheme.surfaceContainerHigh` as shimmer/loading placeholder background.
- Upload area: `Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)` dashed border, `AppColors.primary` icon color.
- Empty state: themed icon and text.

#### Step 5.7 — Domain Settings Screen
In `domain_settings_screen.dart` and `domain_setup_widget.dart`:
- Information boxes (tips, warnings): Use `AppColors.warningOrange.withValues(alpha: 0.10)` with `warningOrange` left border for warning states.
- Success state: `AppColors.activeGreen.withValues(alpha: 0.10)` with `activeGreen` left border.
- Input fields: Must use theme-default decoration.

#### Step 5.8 — Modals Polish
In `create_page_modal.dart`, `notification_inbox_modal.dart`, `upgrade_limit_modal.dart`:
- Modal background: `Theme.of(context).colorScheme.surface`.
- Modal border/shadow: `Theme.of(context).colorScheme.outlineVariant`.
- All text inside modals must use semantic color tokens.
- The upgrade modal should have a gradient accent using `AppColors.primaryGradient` for the upgrade CTA button.

### ✅ Success Criteria for Part 5
- [ ] All dashboard screens have zero hardcoded colors
- [ ] Settings screen has new Appearance and Language sections
- [ ] Language switcher is fully functional in Settings
- [ ] Theme mode toggle is fully functional in Settings
- [ ] All cards, tables, and charts use semantic theme colors
- [ ] Modals use theme-correct backgrounds
- [ ] All status badges use correct semantic colors

---

## ═══════════════════════════════════════════════════════
## PART 6 — Builder Workspace Shell & AI Agent Experience
## ═══════════════════════════════════════════════════════

### 🎯 Goal
Ensure the Builder workspace and Guest Preview screen are fully theme-compliant. The builder is the core product — its shell must be pristine and professional.

### 📁 Files in Scope
```
lib/features/builder/screens/builder_workspace_screen.dart
lib/features/builder/screens/guest_preview_screen.dart
```

### ⚠️ Critical Warning
> **DO NOT modify Builder Engine internals** (drag & drop logic, section rendering, JSON schema, undo/redo system, auto-save). Only modify the **shell/layout/UI chrome** — the AppBar, sidebars, panels, and color tokens in the workspace container. The content preview area renders the user's landing page, which has its own design system and must NOT be affected.

### 🔨 Step-by-Step Instructions

#### Step 6.1 — Builder AppBar Theme Compliance
In `builder_workspace_screen.dart`, locate the `AppBar` or custom top bar of the builder:
- Background: `Theme.of(context).colorScheme.surfaceContainerHigh`
- Title/Logo: Use `LandyMakerLogo` widget or `AppTypography.h3` with `Theme.of(context).colorScheme.onSurface`
- Action buttons (Save, Publish, Preview): Use `ElevatedButton` with theme defaults for the primary action (Publish), `OutlinedButton` for secondary actions (Save Draft, Preview).
- All icons in the AppBar must use `Theme.of(context).colorScheme.onSurface` or `onSurfaceVariant` as color.

#### Step 6.2 — Builder Panels Theme Compliance
The builder has left/right property panels:
- Panel background: `Theme.of(context).colorScheme.surface`
- Panel border: `Theme.of(context).colorScheme.outlineVariant`
- Panel section headers: `AppTypography.caption` with `Theme.of(context).colorScheme.onSurfaceVariant`
- Input fields within panels: Must use theme-default decoration from `AppTheme`

#### Step 6.3 — Guest Preview Screen
In `guest_preview_screen.dart`:
- The outer scaffold background: `Theme.of(context).scaffoldBackgroundColor`
- The preview frame border: `Theme.of(context).colorScheme.outlineVariant`
- Top bar (if present) with preview controls: `Theme.of(context).colorScheme.surfaceContainerHigh`
- CTAs like "Sign Up to Edit": Use `AppColors.primaryGradient` or `ElevatedButton` with theme defaults.
- Ensure the "Login / Sign Up" buttons visible to guest users are prominently styled and use proper theme colors.

#### Step 6.4 — AI Agent Chat Interface (if applicable)
If there is an AI chat panel or AI generation UI within the builder scope:
- Chat bubble background (user): `AppColors.primary.withValues(alpha: 0.15)`
- Chat bubble background (AI): `Theme.of(context).colorScheme.surfaceContainerHigh`
- Input box: Theme-default decoration
- Send button: `AppColors.primary` background, `Colors.black` foreground (as per `onPrimary`)

### ✅ Success Criteria for Part 6
- [ ] Builder AppBar is fully theme-compliant
- [ ] Builder panels use semantic theme colors
- [ ] Guest preview screen uses semantic theme colors
- [ ] No hardcoded colors in either builder screen file
- [ ] Builder engine internals are completely untouched

---

## ═══════════════════════════════════════════════════════
## PART 7 — Global Controls: Theme Toggle, Language Switcher & Logo Standardization
## ═══════════════════════════════════════════════════════

### 🎯 Goal
Standardize the appearance and behavior of the three globally recurring UI controls:
1. **Theme Toggle (Dark/Light Mode switcher)**
2. **Language Switcher**
3. **LandyMaker Logo**

These three elements appear across multiple screens and must have a single, consistent design language everywhere they appear.

### 📁 Files in Scope
```
lib/core/widgets/atoms/animated_theme_toggle.dart
lib/core/widgets/atoms/landy_maker_logo.dart
lib/core/widgets/atoms/language_switcher_button.dart  ← CREATE THIS NEW FILE
```
Plus any screen file that renders a language button (consolidated list from Parts 2–6).

### 🔨 Step-by-Step Instructions

#### Step 7.1 — Create `LanguageSwitcherButton` Atom Widget
Create a new file: `lib/core/widgets/atoms/language_switcher_button.dart`

This widget should be the **single source of truth** for all language switcher buttons in the app. It must support two display variants:

```dart
/// Variant enum
enum LanguageSwitcherVariant {
  iconOnly,    // Just the language icon (for compact spaces like mobile nav)
  iconAndText, // Icon + translated label (for desktop navbar, auth screens)
}
```

Widget properties:
- `variant`: `LanguageSwitcherVariant` (required)
- `color`: `Color?` (optional, defaults to `Theme.of(context).colorScheme.onSurfaceVariant`)

Implementation:
- Icon: `Icons.language_rounded`
- On tap: `context.read<LocalizationCubit>().toggleLanguage()`
- `iconOnly` variant: Renders as `IconButton` with tooltip = `loc.translate('switch_language')`
- `iconAndText` variant: Renders as `TextButton.icon` with label = `loc.translate('switch_language')`
- Both variants must use the same icon size (`20.0`) for visual consistency

#### Step 7.2 — Replace All Language Buttons with `LanguageSwitcherButton`
Find every place in the codebase (outside of Settings screen and the removed locations in Part 4) where a language button is rendered and replace it with the new `LanguageSwitcherButton` widget:

| Location | Variant to Use |
|---|---|
| `home_navbar.dart` — Desktop | `iconAndText` |
| `home_navbar.dart` — Mobile | `iconOnly` |
| `auth screens` — Top area | `iconOnly` |
| `settings_screen.dart` — Language section | Custom tile (not this widget) |

#### Step 7.3 — Audit `AnimatedThemeToggle`
Inspect `lib/core/widgets/atoms/animated_theme_toggle.dart`:
- Ensure the toggle renders correctly in both Light and Dark modes (the icon and animation must be correct in both states).
- The toggle should show:
  - **Dark mode active**: `Icons.dark_mode_rounded` (filled) or moon icon
  - **Light mode active**: `Icons.light_mode_rounded` (filled) or sun icon
- The toggle background/container should use `Theme.of(context).colorScheme.surfaceContainerHigh` as the chip/button background.
- Icon color: `Theme.of(context).colorScheme.onSurface`
- The animation must be smooth (already using `AnimatedSwitcher` presumably — verify).
- Ensure the `ThemeCubit` in `lib/core/theme/theme_cubit.dart` properly persists the theme preference (check if it saves to `SharedPreferences` or similar). If not, add `SharedPreferences` persistence so the user's choice survives app restarts.

#### Step 7.4 — Audit `LandyMakerLogo`
Inspect `lib/core/widgets/atoms/landy_maker_logo.dart`:
- The logo text color must adapt to the current theme: `Theme.of(context).colorScheme.onSurface` for the wordmark text.
- The accent/gradient part of the logo (if any) should use `AppColors.primaryGradient` or `AppColors.primary`.
- Verify the logo is readable in BOTH Light mode (dark text on light bg) and Dark mode (light text on dark bg).
- If the logo uses an `Image.asset`, ensure there's a light-mode and dark-mode variant (or use an SVG that adapts), or switch the image asset based on theme brightness.

#### Step 7.5 — Placement Audit Summary
After Parts 2–7, the final placement of controls across the app should be:

| Screen Zone | Theme Toggle | Language Switcher |
|---|---|---|
| Home Navbar (Desktop) | ✅ Yes | ✅ Yes (icon+text) |
| Home Navbar (Mobile) | ✅ Yes | ✅ Yes (icon only) |
| Auth Screens (all 4) | ✅ Yes (top-right) | ✅ Yes (top-right, icon only) |
| Dashboard Top Bar (Desktop) | ✅ Yes | ❌ No (moved to Settings) |
| Dashboard AppBar (Mobile) | ✅ Yes | ❌ No (moved to Settings) |
| Sidebar Footer | ❌ No (removed) | ❌ No (removed) |
| Settings Screen | ✅ Yes (in Appearance section) | ✅ Yes (in Language section) |
| Builder Top Bar | ❌ Optional (not required) | ❌ No |

#### Step 7.6 — Final Theme Persistence Verification
- Test that selecting Light Mode persists after navigating between screens.
- Test that selecting Dark Mode persists after navigating between screens.
- If `ThemeCubit` does not yet use `SharedPreferences`, add it now:

```dart
// In ThemeCubit:
import 'package:shared_preferences/shared_preferences.dart';

static const _key = 'theme_mode';

Future<void> toggleTheme() async {
  final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  emit(newMode);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_key, newMode.name);
}

static Future<ThemeMode> loadSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_key);
  return saved == 'light' ? ThemeMode.light : ThemeMode.dark;
}
```
- Call `loadSavedTheme()` in `main.dart` during app initialization to restore the user's preference.

### ✅ Success Criteria for Part 7
- [ ] `LanguageSwitcherButton` atom widget created and used in all applicable locations
- [ ] `AnimatedThemeToggle` renders correctly in both modes with correct icons
- [ ] `LandyMakerLogo` adapts to theme brightness
- [ ] Placement audit table is accurately reflected in the running app
- [ ] Theme preference persists across app restarts (SharedPreferences)

---

## ═══════════════════════════════════════════════════════════
## APPENDIX A — Mini Completion Report Format
## ═══════════════════════════════════════════════════════════

After completing each part, the AI model MUST output a report in this exact format:

```
─────────────────────────────────────────────
✅ PART [NUMBER] COMPLETION REPORT
─────────────────────────────────────────────
Part Title: [Title of the Part]
Status: COMPLETE

Files Modified:
• [path/to/file1.dart] — [brief description of change]
• [path/to/file2.dart] — [brief description of change]
...

Files Created (if any):
• [path/to/new_file.dart] — [brief description]

Key Changes:
• [Bullet point describing key UI/UX improvement]
• [Bullet point describing another key change]
• [...]

Theme Compliance:
• All hardcoded colors replaced: YES/NO
• Light mode verified: YES/NO
• Dark mode verified: YES/NO

Known Limitations / Deferred Items:
• [Any items that could not be completed and why]
─────────────────────────────────────────────

Would you like me to proceed to Part [N+1]: [Next Part Title]?
Or do you have any changes or feedback on Part [N] before we continue?
```

---

## APPENDIX B — Quick Reference: Semantic Color Tokens

| Token | Light Mode Value | Dark Mode Value | Usage |
|---|---|---|---|
| `colorScheme.surface` | `#FFFFFF` | `#0F172A` | Widget backgrounds |
| `scaffoldBackgroundColor` | `#F8FAFC` | `#030712` | Page backgrounds |
| `colorScheme.surfaceContainerHigh` | (auto) | `#111827` | Cards, sidebars |
| `colorScheme.onSurface` | `#0F172A` | `#F3F4F6` | Primary text |
| `colorScheme.onSurfaceVariant` | `#475569` | `#94A3B8` | Secondary text |
| `colorScheme.outlineVariant` | `#E2E8F0` | `#1F2937` | Borders, dividers |
| `colorScheme.primary` | `#00E5FF` | `#00E5FF` | Accent, CTAs |
| `colorScheme.secondary` | `#1E3A8A` | `#1E3A8A` | Secondary accent |
| `AppColors.activeGreen` | `#10B981` | `#10B981` | Success states |
| `AppColors.dangerRed` | `#EF4444` | `#EF4444` | Error/danger |
| `AppColors.warningOrange` | `#F59E0B` | `#F59E0B` | Warnings, premium |

---

## APPENDIX C — Protected Systems (DO NOT TOUCH)

The following systems must NOT be modified during this UI/UX plan:
- Builder engine: Drag & drop, section rendering, JSON schema, undo/redo, auto-save
- `SectionRenderer` and all public viewer rendering logic
- `ActionHandlerService`
- Supabase client and all API calls
- `AuthCubit` and authentication state machine
- Edge Functions and security layer
- `TenantRoutingService` and routing logic
- `ValidationEngine` and `FieldRenderer`

---

*End of LandyMaker UI/UX Master Improvement Plan v1.0.0*
