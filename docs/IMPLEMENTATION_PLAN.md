# LandyMaker — Master Fix & Enhancement Implementation Plan

> **Version:** 1.0  
> **Target AI Model:** Intermediate-level coding AI  
> **Language:** Flutter/Dart (Web)  
> **Project Root:** `/Users/abdallahazmy/Projects/landymaker`

---

## 📌 Before You Start — Mandatory Context Reading

Before executing ANY phase, read these files in order:

1. `/Users/abdallahazmy/Projects/landymaker/AI_CONTEXT.md` — Full project architecture
2. `/Users/abdallahazmy/Projects/landymaker/docs/ai/AI_NAVIGATION.md` — File map
3. `/Users/abdallahazmy/Projects/landymaker/docs/ai/AI_DOCUMENTATION_RULES.md` — Strict coding rules

**Key architecture rules to internalize:**
- Always use `EdgeInsetsDirectional` instead of `EdgeInsets.only(left/right)`
- Never break the `Builder → JSON → Parser → SectionRenderer` data pipeline
- Always use `LayoutBuilder` constraints for responsive decisions, NOT `MediaQuery.of(context).size`
- The `AuthCubit` and `BuilderCubit` are protected core systems — modify carefully with backward compatibility

---

## 🗺️ Phase Overview

| # | Phase | Priority | Risk |
|---|-------|----------|------|
| 1 | Google Sign-In UX + New User Terms Dialog | High | Medium |
| 2 | Media Gallery Mobile Touch Actions | High | Low |
| 3 | PageContextBanner Overflow Fix (All Screens) | High | Low |
| 4 | Builder Mobile Preview — Padding & Section Toolbar | High | Medium |
| 5 | SEO — Logo Background & App Description | Medium | Low |
| 6 | Platform SEO Screen — Pre-seed All App Routes | Medium | Low |
| 7 | Pull-to-Refresh on Landing Pages & Key Screens | Low | Low |
| 8 | Section Delete Button in Edit Bottom Sheet | High | Medium |
| 9 | Quick Contact Form (lead_form) — Fields & Leads Pipeline | High | High |
| 10 | Section Library Modal — Layout UX Overhaul | Medium | Medium |
| 11 | Remove Shape Variants, Keep Only Layouts | Medium | Medium |
| 12 | AI Chat — Per-Page Sessions + Authenticated Preview Button | Medium | Medium |
| 13 | Global Font Picker — Fix Selection Not Applying | High | Low |
| 14 | Eye Icon — Fix Fullscreen/Final Preview Navigation | High | High |

---

## Phase 1 — Google Sign-In UX + New User Terms Dialog

### Objective
- Move the Google Sign-In button **above** the email/password form in both `LoginScreen` and `RegisterScreen`.
- Give the Google button its **own independent loading state** (a separate boolean `_isGoogleLoading`) that does NOT share state with the email/password submit button's loading.
- When a user tries to sign in with Google and they are **new to the platform** (no existing account), show a **Terms & Privacy confirmation dialog** before proceeding to create the account. Only after confirming should registration complete.

### Files to Modify
- `lib/features/auth/screens/login_screen.dart`
- `lib/features/auth/screens/register_screen.dart`
- `lib/features/auth/controllers/auth_cubit.dart`
- `lib/features/auth/controllers/auth_state.dart`
- `lib/core/widgets/atoms/social_sign_in_button.dart`

### Detailed Steps

**Step 1.1 — Add a new AuthState for "Google New User Requires Consent"**

In `auth_state.dart`, add a new state:
```dart
class GoogleNewUserRequiresConsent extends AuthState {
  final String pendingEmail;
  const GoogleNewUserRequiresConsent(this.pendingEmail);
}
```

**Step 1.2 — Update AuthCubit**

In `auth_cubit.dart`, modify `signInWithGoogle()`:
- After the Google OAuth token is retrieved but **before** creating the user session in Supabase, check if this is a new user.
- If new user → emit `GoogleNewUserRequiresConsent(email)` and **store the pending token** in a local field `_pendingGoogleToken`.
- Add a new method: `confirmGoogleNewUser()` that uses `_pendingGoogleToken` to complete the sign-in.
- Add: `cancelGoogleSignIn()` that clears `_pendingGoogleToken` and emits `AuthInitial`.

**Step 1.3 — Update Login & Register Screens**

In both `login_screen.dart` and `register_screen.dart`:
- Add a separate `bool _isGoogleLoading = false;` state variable.
- The `isLoading` variable used by the email button should ONLY be true when `state is AuthLoading && !_isGoogleLoading`.
- Add a listener for `GoogleNewUserRequiresConsent` state that shows a `showDialog` with:
  - Title: "مرحباً بك في لاندي ميكر!"
  - Body: Text explaining they are creating a new account, with links to Privacy Policy and Terms.
  - Two buttons: "موافق وأكمل التسجيل" (calls `confirmGoogleNewUser()`) and "إلغاء" (calls `cancelGoogleSignIn()`).
- **Reorder the form layout**: The Google button section should appear **FIRST** (above the email/password fields), then the divider "أو سجل بالبريد الإلكتروني", then the form fields.
- Pass `isLoading: _isGoogleLoading` to `SocialSignInButton` separately.

---

## Phase 2 — Media Gallery Mobile Touch Actions

### Objective
On mobile, the image gallery cards in `MediaGalleryScreen` currently use `MouseRegion` hover to show action buttons (copy link, delete). On touch screens, `MouseRegion` doesn't trigger, leaving mobile users unable to interact with their images.

### Files to Modify
- `lib/features/dashboard/screens/media_gallery_screen.dart`

### Detailed Steps

**Step 2.1 — Replace MouseRegion with persistent mobile controls**

In `_ImageGalleryCardState`:
- Detect if the current device is mobile using `ResponsiveLayout.isMobile(context)`.
- On **desktop**: Keep `MouseRegion` hover behavior (show controls on hover).
- On **mobile**: Show a small semi-transparent action bar **always visible** at the bottom of the card (no hover needed). The bar shows the copy icon and delete icon without requiring hover state.

**Step 2.2 — Verify Delete Confirmation Dialog**

The delete confirmation `AlertDialog` already exists. Make it reachable via the always-visible mobile action bar.

---

## Phase 3 — PageContextBanner Overflow Fix (All Screens)

### Objective
The `PageContextBanner` widget contains a `Row` with a fixed-width `Container(width: 250)` for the `WebsiteSwitcher`. This causes overflow on mobile because the `title` text area doesn't have room to shrink. Fix globally — used in 4 screens.

### Files to Modify
- `lib/core/widgets/molecules/page_context_banner.dart`

### Detailed Steps

**Step 3.1 — Make the banner layout responsive**

Current layout: horizontal `Row` with `[Icon Container] + [Expanded Text Column] + [SizedBox(24)] + [Container(width: 250)]`.

Change to use `LayoutBuilder`:
- If `constraints.maxWidth < 650` (mobile): Stack content vertically — `[Icon + Text]` on top, then `[WebsiteSwitcher]` below, full width.
- If `constraints.maxWidth >= 650` (desktop/tablet): Keep the horizontal `Row` layout.
- Replace hardcoded `width: 250` with `Flexible` or `ConstrainedBox(maxWidth: 250)`.

**This automatically fixes the banner in all 4 screens that use it:**
- `analytics_screen.dart`
- `leads_tracker_screen.dart`
- `product_feed_screen.dart`
- `domain_settings_screen.dart`

---

## Phase 4 — Builder Mobile Preview — Padding & Section Toolbar

### Objective
On mobile in the builder workspace:
1. Remove left/right padding from canvas preview so it fills full screen width.
2. Each section's toolbar should span the full width of the preview.
3. Add a **collapsible arrow** to the section toolbar: collapse to a small arrow, expand back on re-tap.
4. Add a **fake browser address bar** at the top of the preview canvas inside the builder. Hide it in fullscreen/final preview mode.

### Files to Modify
- `lib/features/builder/screens/builder_workspace_screen.dart`
- `lib/features/builder/widgets/organisms/builder_canvas.dart`

### Detailed Steps

**Step 4.1 — Remove canvas horizontal padding on mobile**

In `_MobileBuilderWorkspace.build()`, find wherever horizontal padding is applied to the canvas container and remove the left/right padding (keep vertical if any).

**Step 4.2 — Add collapsible section toolbar**

In `builder_canvas.dart`, find the section overlay toolbar. Add `bool _isToolbarExpanded = true` state. Add a chevron `IconButton` on one edge. When tapped, toggle `_isToolbarExpanded`. When collapsed, hide all buttons except the toggle arrow. Always use `width: double.infinity` for the toolbar.

**Step 4.3 — Add fake browser bar widget**

Create a `_FakeBrowserBar` widget:
```dart
class _FakeBrowserBar extends StatelessWidget {
  final String pageSlug;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: Row(children: [
        Icon(Icons.lock_rounded, size: 14, color: Colors.green),
        SizedBox(width: 6),
        Expanded(child: Text('landymaker.com/$pageSlug', style: AppTypography.caption, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
```
Add at top of mobile preview canvas. Pass page `subdomain` from builder state. Hide when `previewMode == PreviewMode.fullscreen`.

---

## Phase 5 — SEO: Logo Background & App Description

### Objective
- Ensure logo always has a **black background** in OG images and social previews.
- App meta description should include the Arabic name **"لاندي ميكر"**.

### Files to Modify
- `web/index.html`
- `lib/core/seo/app_seo.dart`

### Detailed Steps

**Step 5.1 — Update meta description in index.html**

Find `<meta name="description">` and update content to include:
`"لاندي ميكر | LandyMaker — منصة بناء صفحات الهبوط الاحترافية للسوق العربي"`

**Step 5.2 — Ensure default OG image has dark background**

In `app_seo.dart` `updateMeta()` and in `web/index.html`, ensure default `og:image` points to `'https://landymaker.com/logo_social.webp'`. Note to the user that the actual image file should have a dark/black background.

---

## Phase 6 — Platform SEO Screen: Pre-seed All App Routes

### Objective
The `PlatformSeoScreen` shows an empty table. Pre-populate it with all known platform routes so the super admin sees them immediately.

### Files to Modify
- `lib/features/super_admin/controllers/super_admin_cubit.dart`
- `lib/features/super_admin/screens/platform_seo_screen.dart`

### Detailed Steps

**Step 6.1 — Define default platform routes**

In `super_admin_cubit.dart`, add a constant list:
```dart
static const List<Map<String, dynamic>> _defaultPlatformRoutes = [
  { 'route_path': '/', 'meta_title': 'لاندي ميكر - منصة بناء صفحات الهبوط', 'meta_description': 'لاندي ميكر | LandyMaker — منصة احترافية...', 'og_image_url': 'https://landymaker.com/logo_social.webp', 'admin_note': 'الصفحة الرئيسية التسويقية' },
  { 'route_path': '/pricing', 'meta_title': 'الأسعار والباقات - لاندي ميكر', 'meta_description': 'اختر الباقة المناسبة...', 'og_image_url': 'https://landymaker.com/logo_social.webp', 'admin_note': 'صفحة الأسعار' },
  { 'route_path': '/templates', 'meta_title': 'قوالب جاهزة - لاندي ميكر', 'meta_description': 'استعرض مئات القوالب...', 'og_image_url': 'https://landymaker.com/logo_social.webp', 'admin_note': 'مكتبة القوالب' },
  { 'route_path': '/login', 'meta_title': 'تسجيل الدخول - لاندي ميكر', 'meta_description': 'سجل دخولك...', 'og_image_url': 'https://landymaker.com/logo_social.webp', 'admin_note': 'صفحة تسجيل الدخول' },
  { 'route_path': '/register', 'meta_title': 'إنشاء حساب - لاندي ميكر', 'meta_description': 'أنشئ حسابك المجاني...', 'og_image_url': 'https://landymaker.com/logo_social.webp', 'admin_note': 'صفحة التسجيل' },
  { 'route_path': '/about', 'meta_title': 'عن لاندي ميكر', 'meta_description': 'تعرف على قصة لاندي ميكر...', 'og_image_url': 'https://landymaker.com/logo_social.webp', 'admin_note': 'صفحة عن المنصة' },
  { 'route_path': '/privacy-policy', 'meta_title': 'سياسة الخصوصية - لاندي ميكر', 'meta_description': 'اقرأ سياسة الخصوصية...', 'og_image_url': 'https://landymaker.com/logo_social.webp', 'admin_note': 'سياسة الخصوصية' },
  { 'route_path': '/terms', 'meta_title': 'الشروط والأحكام - لاندي ميكر', 'meta_description': 'اقرأ الشروط والأحكام...', 'og_image_url': 'https://landymaker.com/logo_social.webp', 'admin_note': 'الشروط والأحكام' },
  { 'route_path': '/blog', 'meta_title': 'المدونة - لاندي ميكر', 'meta_description': 'مقالات وأدلة عملية...', 'og_image_url': 'https://landymaker.com/logo_social.webp', 'admin_note': 'صفحة المدونة' },
  { 'route_path': '/dashboard', 'meta_title': 'لوحة التحكم - لاندي ميكر', 'meta_description': 'أدر صفحاتك...', 'og_image_url': 'https://landymaker.com/logo_social.webp', 'admin_note': 'لوحة تحكم المستخدم' },
];
```

**Step 6.2 — Merge defaults with DB data**

After loading from Supabase, merge: any route in `_defaultPlatformRoutes` NOT already in DB list → add to displayed list in memory. Super admin sees all routes and can save changes.

**Step 6.3 — Add admin note column to the table**

In `platform_seo_screen.dart`, update `ResponsiveDataTable` headers and rows to show `admin_note` as a read-only description column.

---

## Phase 7 — Pull-to-Refresh

### Objective
Add `RefreshIndicator` on 4 key screens.

### Files to Modify
- `lib/features/public_viewer/screens/public_landing_page.dart`
- `lib/features/dashboard/screens/dashboard_home_screen.dart`
- `lib/features/dashboard/screens/analytics_screen.dart`
- `lib/features/dashboard/screens/leads_tracker_screen.dart`

### Detailed Steps

For each screen, wrap the root `SingleChildScrollView` or `ListView` with:
```dart
RefreshIndicator(
  color: Theme.of(context).colorScheme.primary,
  onRefresh: () async {
    await context.read<CorrectCubit>().correctRefreshMethod();
  },
  child: SingleChildScrollView(...),
)
```
Map each screen to its correct refresh method:
- Public viewer → reload page data method in the public viewer cubit.
- Dashboard home → `LandingPagesCubit.loadPages()` or equivalent.
- Analytics → `LeadsAnalyticsCubit.fetchStatsForCurrentUser()`.
- Leads tracker → leads reload method.

---

## Phase 8 — Section Delete Button Fix in Edit Bottom Sheet

### Objective
The delete button in the section edit bottom sheet navigates the user out of the builder instead of deleting the section and closing the sheet.

### Files to Investigate & Modify
- `lib/features/builder/widgets/editors/block_properties_editor.dart`
- `lib/features/builder/controllers/builder_cubit.dart`

### Detailed Steps

**Step 8.1 — Locate the delete button**

Search the `block_properties_editor.dart` file for "delete", "حذف", "remove", "trash". Find the delete action code.

**Step 8.2 — Fix the deletion flow**

Correct flow:
1. Show confirmation `AlertDialog`: "هل تريد حذف هذا القسم؟" with "حذف" (error color) and "إلغاء".
2. On confirm: call `cubit.removeBlock(widget.index)` (or correct method name).
3. Then call `widget.onDone()` to close the bottom sheet.
4. Do NOT use `context.go()` — the user must stay in the builder.

**Step 8.3 — Verify `removeBlock` in builder_cubit.dart**

Ensure the remove method creates a new list without the element, emits `BuilderLoaded` with updated `designMap`, and sets `hasUnsavedChanges: true`.

---

## Phase 9 — Quick Contact Form (lead_form): Fields, Leads & Notifications

### Objective
The `lead_form` section has no visible input fields because the default block JSON has an empty `fields` array. Fix the default JSON, verify the secure submission pipeline, and verify notifications.

### Files to Modify
- `lib/features/builder/registries/block_registry.dart`
- `lib/services/database_service.dart`
- `supabase/functions/lead-submit/index.ts` (verify, may not need changes)

### Detailed Steps

**Step 9.1 — Fix default JSON in BlockRegistry**

In `block_registry.dart`, find `lead_form` and `lead_magnet` default block definitions. Update `fields` array:
```dart
'fields': [
  {'field_id': 'name', 'field_type': 'text', 'label': 'الاسم الكامل', 'placeholder': 'أدخل اسمك', 'is_required': true},
  {'field_id': 'phone', 'field_type': 'text', 'label': 'رقم الجوال', 'placeholder': '05xxxxxxxx', 'is_required': true},
  {'field_id': 'message', 'field_type': 'textarea', 'label': 'رسالتك', 'placeholder': 'كيف يمكننا مساعدتك؟', 'is_required': false},
],
```

**Step 9.2 — Verify Edge Function routing (SECURITY CRITICAL)**

In `database_service.dart`, find `submitLead`. Confirm call goes to `supabase.functions.invoke('lead-submit', ...)` — NOT `supabase.from('leads').insert()`. If direct insert exists, migrate to Edge Function.

**Step 9.3 — Verify Notification Trigger**

In `supabase/functions/lead-submit/index.ts`, verify it triggers `lead-notify` after successful lead insertion. If not, add the call to notify the page owner.

---

## Phase 10 — Section Library Modal: Layout UX Overhaul

### Objective
Replace the single abstract mini-preview with **two side-by-side previews** (mobile + desktop) for each section variant.

### Files to Modify
- `lib/features/builder/widgets/modals/section_library_modal.dart`

### Detailed Steps

**Step 10.1 — Replace `_SectionMiniPreview` with dual-preview**

Create `_DualMiniPreview` that renders side-by-side mobile (narrower) and desktop (wider) previews using the existing `_buildPattern()` logic with slight visual differences per mode.

**Step 10.2 — Adjust card and header sizing**

- Reduce `childAspectRatio` to `isSmall ? 0.62 : 0.70`.
- Reduce modal title from `AppTypography.h2` to `AppTypography.h3`.
- Remove the subtitle text below the title.

---

## Phase 11 — Remove Shape Variants, Keep Only Layouts

### Objective
Remove the 10 shape variants from the section editor UI. Keep only the `layout_style` selector (the `LayoutPickerPanel`).

### Files to Investigate & Modify
- `lib/features/builder/registries/style_registry.dart`
- `lib/features/builder/widgets/editors/block_properties_editor.dart`

### Detailed Steps

**Step 11.1 — Identify the shapes UI**

Open `style_registry.dart` and read its contents. Find where the 10 shapes are rendered in `block_properties_editor.dart` (likely in the Design/Style tab).

**Step 11.2 — Remove the shapes selector**

In `block_properties_editor.dart`, in `_buildDesignTab()` or equivalent, remove the section that renders the 10 shape options. Keep all other design controls (colors, background, animations).

**Step 11.3 — Verify layout_style selector remains**

Ensure `_showLayoutPicker()` and `LayoutPickerPanel` are still accessible — only the shape selector UI is removed.

---

## Phase 12 — AI Chat: Per-Page Sessions + Authenticated Preview Button

### Objective
1. Scope AI chat sessions per landing page (not shared across pages).
2. Show the page name in the chat header.
3. For logged-in users, show "فتح المحرر الكامل" button instead of "معاينة صفحة الهبوط" (guest preview).

### Files to Modify
- `lib/features/builder/widgets/modals/ai_chat_modal.dart`
- `lib/features/builder/controllers/ai_generation_cubit.dart`

### Detailed Steps

**Step 12.1 — Scope sessions per page**

In `ai_generation_cubit.dart`, add `pageId` field to `AISession`. Use `'ai_session_$pageId'` as session storage key.

**Step 12.2 — Display page context in header**

In `_buildHeader()` in `ai_chat_modal.dart`, add below the title:
```dart
Text('صفحة: ${builderState.subdomain}', style: AppTypography.caption.copyWith(color: colorScheme.onSurfaceVariant)),
```

**Step 12.3 — Fix preview button for authenticated users**

In `_buildMessageBubble()`, check `context.read<AuthCubit>().state is Authenticated`:
- **Not authenticated**: existing "معاينة صفحة الهبوط" → `/guest-preview`
- **Authenticated**: "فتح المحرر الكامل" button with `Icons.edit_rounded` → `/builder/${pageId}`

---

## Phase 13 — Global Font Picker: Fix Selection Not Applying

### Objective
When a user selects a new font in the builder's global font settings, it does not apply. Fix the state listener and update mechanism.

### Files to Investigate & Modify
- `lib/features/builder/controllers/builder_theme_cubit.dart`
- `lib/features/builder/widgets/modals/builder_options_modal.dart`
- Any global editor widget that renders the font picker cards

### Detailed Steps

**Step 13.1 — Locate the font picker**

Find the font card list in the builder options (under `BuilderOptionView.fonts`). Identify where font card taps are handled.

**Step 13.2 — Diagnose the bug**

Common causes:
1. Font picker widget listens to wrong cubit (reads `LandingPageBuilderCubit` instead of `BuilderThemeCubit`).
2. `isSelected` comparison uses wrong field name.
3. Google Font not injected into DOM on web.

**Step 13.3 — Fix**

- Ensure font picker is inside `BlocBuilder<BuilderThemeCubit, BuilderThemeState>`.
- Ensure `onTap` calls `context.read<BuilderThemeCubit>().updateFont(fontName)`.
- Verify the stream subscription between `BuilderThemeCubit` and `LandingPageBuilderCubit` is active (as documented in AI_CONTEXT.md section 12).
- For web: inject Google Fonts link tag into `dart:html`'s `document.head` when font changes.

---

## Phase 14 — Eye Icon: Fix Final Preview Navigation

### Objective
Tapping the eye icon (fullscreen/final preview) in the builder opens a blank page. Fix the navigation and state provisioning.

### Files to Investigate & Modify
- `lib/features/builder/screens/builder_workspace_screen.dart`
- `lib/features/builder/widgets/molecules/builder_mobile_toolbar.dart`
- `lib/features/builder/screens/guest_preview_screen.dart`
- `lib/features/builder/widgets/organisms/builder_canvas.dart`
- `lib/core/router/app_router.dart`

### Detailed Steps

**Step 14.1 — Trace the fullscreen mode flow**

Desktop: `PreviewMode.fullscreen` selected → `_DesktopBuilderWorkspace` hides appBar/sidebar → `_CanvasContainer` renders with fullscreen mode. Check if canvas is actually empty.

Mobile: Eye icon in mobile toolbar → `onChangePreview(PreviewMode.fullscreen)` → `_MobileBuilderWorkspace` renders with fullscreen mode. Verify canvas renders correctly.

**Step 14.2 — Investigate GuestPreviewScreen blank page**

`GuestPreviewScreen` at `/guest-preview` uses `BuilderCanvas`. If `BuilderLoaded` state is not accessible in this route's context, it shows a spinner forever.

Check `app_router.dart`: ensure `/guest-preview` route is wrapped with the same `BlocProvider`s as `/builder/:pageId`, or ensure the cubits are provided at a higher level in the widget tree.

**Step 14.3 — Fix**

If state not provided to route:
- In `app_router.dart`, wrap `/guest-preview` with the required `MultiBlocProvider` for `LandingPageBuilderCubit` and `AIGenerationCubit`.

If fullscreen canvas is blank:
- In `BuilderCanvas.build()`, ensure fullscreen mode renders all blocks without special conditions that could result in empty renders.
- Test by temporarily using `PreviewMode.desktop` in `GuestPreviewScreen` to isolate mode-specific bugs.

---

