# AI Documentation & Execution Rules - LandyMaker

Keep AI-facing docs synchronized with implementation changes. Documentation is part of the architecture contract.

## 1. Documentation Update Rules
**Update Required When Changing:**
- Screens, routes, services, folder structure, business features, or dependency mappings: update `AI_CONTEXT.md` and `docs/ai/SYSTEM_MAP.md`.
- Builder sections, templates, registries, schema assumptions, or renderer/editor mappings: update `AI_CONTEXT.md`, `docs/ai/SYSTEM_MAP.md`, and `BUILDER_ARCHITECTURE.md`.
- Theme system, color tokens, or the `AnimatedThemeToggle` widget: update `THEME_SYSTEM.md`.

**Builder Documentation Rules:**
- Every new section type must be listed in `AI_CONTEXT.md`.
- Every section exposed in `SectionLibraryModal` must have:
  - a matching `LandingPageBuilderCubit.addBlock` default,
  - a `BlockRegistry` renderer mapping,
  - an editor path or a clear generic editing path.
- Future AI-agent hints such as `ai_intent`, `ai_slots`, `ai_role`, and `ai_when_to_use` are advisory only. Renderers must not require them.

**Safety Notes:**
- Do not document behavior that is not implemented.
- Do not remove security notes for Turnstile, rate limiting, fingerprinting, Edge Functions, RLS, or webhook protection.
- Prefer short, navigational documentation over broad codebase summaries.

---

## 2. Project Discovery & Execution Protocol
**Before implementation:**
1. Read `AI_CONTEXT.md`, `docs/ai/SYSTEM_MAP.md`, and `docs/ai/AI_DOCUMENTATION_RULES.md`.
2. Understand the affected architecture and identify affected systems, files, and dependencies.
3. Identify risks (regressions, security, SEO, deployment).
4. Verify existing implementations and reuse existing code whenever possible.
5. **Never assume** widgets, services, routes, APIs, or database structures exist. Verify first.

**Impact Analysis Phase:**
Before coding, explicitly analyze the impact on UI, State Management, Builder (JSON/Parsers), Backend (Supabase/Edge), Security, SEO, and Deployment.

**Reuse-First Policy:**
- Priority order: Reuse > Extend > Refactor > Create new.
- Never duplicate widgets, services, cubits, utilities, or parsers.

**Quality Gate (Before Completion):**
Verify no compile/analyzer errors, no dead code, no duplicate logic, and no regressions in RTL, SEO, or security.

**Protected Systems:**
Never break the systems listed in `AI_CONTEXT.md` Section 12 (Builder Workspace, ActionHandler, Security Layer, etc.). Any modification to these must be explicitly validated.

---

## 3. Strict AI Assistant Development Rules (MUST FOLLOW)

1. **Professional Builder Standards**: Every section editor MUST follow the strict tabbed structure: **[Content, Actions, Design]**.
2. **Animation Performance**: All block animations must utilize `BlockAnimationWrapper` with `RepaintBoundary`. Wrap continuous animations in `RepaintBoundary`.
3. **RTL Responsiveness**: Always use `EdgeInsetsDirectional` and ensure `Transform` animations respect text direction (LTR/RTL).
4. **Image Management**: Use `CustomImageField` for all image properties.
5. **Deprecated API Prohibition**: Always use `withValues(alpha:)` instead of the deprecated `withOpacity()`.
6. **Visual Safety**: Sections with background images MUST include a `bg_overlay_opacity` slider (0.0 to 1.0).
7. **Reusability First**: Do not build redundant code. Check `lib/core/widgets/` first. Use `CustomTextField`.
8. **State-Management Cleanliness**: UI widgets must rebuild reactively. Local state (`setState`) is permitted for strictly internal component UI logic.
9. **Build-Phase Redirect Guard**: Wrap route changes in `WidgetsBinding.instance.addPostFrameCallback`.
10. **Bilingual Arabic-First Support**: Always add keys to both `translations_ar.dart` and `translations_en.dart`.
11. **Slug Validation**: Validate subdomains against reserved paths.
12. **Layout & Responsivity Rules (CRITICAL)**: 
    - Standard sections: 80px desktop vertical padding, 40px mobile. Center content in `BoxConstraints(maxWidth: 1200)`.
    - Never use `MediaQuery.of(context).size` inside block widgets to determine `isMobile`. Use `LayoutBuilder` and `constraints.maxWidth`.
    - **Strict `EdgeInsetsDirectional` rule**: Never use `EdgeInsets.only(left/right)`.
    - **Strict `PositionedDirectional` rule**: For any UI elements (especially navigation arrows, icons, and buttons) placed inside a Stack, NEVER use `Positioned` with `left`/`right`. Always use `PositionedDirectional` with `start`/`end` to ensure correct and automatic layout flipping in RTL/LTR language switches.
    - Never use `GridView` with fixed `childAspectRatio` for text-heavy content cards. Use `Row`/`Column` loops with `ResponsiveUtils.getContentColumns`.
    - Protect text from overflow in nested columns by using `Expanded`/`Flexible` and `maxLines`. For components in structured layout grids (like Bento grids or `IntrinsicHeight` rows), utilize `LayoutBuilder` to check `constraints.hasBoundedHeight`. If bounded height is present (e.g., inside `Expanded`/`IntrinsicHeight` children), wrap text/content in `Expanded` or `Flexible` with `TextOverflow.ellipsis` to gracefully handle content compression, and enforce a generous `minHeight` on primary tall containers.
    - Never use scrollable physics inside block components (`public_viewer`). Always use `shrinkWrap: true` and `physics: const NeverScrollableScrollPhysics()`.
13. **Widget State & Animation Rules**:
    - Use `TickerProviderStateMixin` instead of `SingleTickerProviderStateMixin` for multiple animation controllers.
    - Always combine `type`, `index`, and `hashCode` when generating unique `Key`s inside dynamically built lists.
14. **Form Submission & Data Flow**:
    - Always manage an explicit `isLoading` state during async operations to prevent double-submits.
    - Provide inline success/error feedback inside the widget.
15. **UI/UX Design Patterns (CRITICAL)**:
    - **Tables & Lists**: Use `ResponsiveDataTable` for dashboard data. Must have a card fallback for mobile.
    - **Modals**: Use `DraggableModalSheet` for complex editors or large lists.
16. **Workspace Cleanliness**: Never create `.py`, `.sh`, or temporary markdown files for debugging.
17. **Environment Variable Hygiene & CI/CD (CRITICAL)**:
    - NEVER use dynamic retrieval. Use `const String.fromEnvironment('KEY')` wrapped in `cleanEnv()`.
    - Centralize in `lib/core/utils/env_utils.dart`.
    - Always update the GitHub Actions deploy step (`.github/workflows/deploy.yml`) with the new `--dart-define` flag.
18. **Edge Function Development Rules**:
    - Use absolute URLs for imports.
    - Handle CORS `OPTIONS` requests properly.
    - RLS & Security Bypass: Use `SUPABASE_SERVICE_ROLE_KEY` to write to logging/quota tables hidden behind RLS. Never use `ANON_KEY` for background service ops.
    - Do not pass raw backend database error strings to the client.
19. **Safe Sizing & Numeric Parsing**: Always use `NumericParser` to parse spacing/font sizes from dynamic design maps.
20. **Unconstrained Image Sizing Safety**: Never set network image placeholders to `double.infinity` height without bounds constraints.
21. **AI Design Map Application Safety**: Merge updated design fields into the existing `designMap` rather than replacing the entire map.
22. **Partial Edit Fault Tolerance**: Use the subset edit heuristic to merge incoming block(s) by type. Never replace the entire page with a partial list.
23. **Merge Safety**: Recursively strip any keys whose value is `null` or `""` before merging block updates to prevent destroying valid content.
24. **Clean Responsive UI Architecture (CRITICAL)**: When building responsive widgets, do NOT use inline `if (isMobile)` statements within a massive `build` method. Instead, use a `LayoutBuilder` in a parent "Factory" widget, and delegate rendering to separate `_DesktopLayout` and `_MobileLayout` `StatelessWidget` classes. Use `const` constructors heavily to optimize the Render Tree.
25. **State Preservation & Hoisting (CRITICAL)**: When switching between Mobile and Desktop layouts via `LayoutBuilder`, the Render Tree will destroy and rebuild the children. Therefore, ALL state (e.g., `ScrollController`, `TextEditingController`, `GlobalKey`, or async variables) MUST be hoisted to the parent `StatefulWidget` and passed down to the layout classes via constructor props to prevent data loss on screen resize.
26. **AI-Friendly "Sweet Spot" File Sizing**: To optimize AI context windows, keep the Factory, Props, Desktop Layout, Mobile Layout, and Shared Sub-widgets in ONE file, **but only if the file remains under 800 lines**. If it exceeds this, split it into a directory structure. Files with multiple classes MUST be distinctly separated using large `/// ==========================` comment blocks to prevent AI hallucination. **Exception:** Highly coupled Physics/Math engines and custom painters (specifically `lib/core/widgets/particles/floating_cube_background.dart`) MUST remain as a single file regardless of length. Splitting physics state machines from their render logic creates dangerous context "blind spots" for AI models.
27. **Static Arrow Icons Rule**: NEVER use direction-aware or locale-dependent arrow icons that swap direction dynamically based on RTL/LTR (e.g. showing a right-facing arrow for back in RTL). Always use static, standard arrow icons (such as `Icons.arrow_back_ios_new_rounded` / `Icons.arrow_back_rounded` for going back/previous, and `Icons.arrow_forward_ios_rounded` / `Icons.arrow_forward_rounded` for going forward/next) directly in the layout widgets to maintain consistent and intuitive UX across all locales.
28. **Safe Back Navigation & Safe Pop Rule**: To prevent infinite loading loops, redirect race conditions, or blank screen hangs when navigating backwards, NEVER hardcode raw routing links (such as `context.go('/')` or `context.go('/login')`) inside page-level back buttons. Instead, always use `context.safePop(fallbackPath: '...')` (e.g., `context.safePop(fallbackPath: '/')` or `context.safePop(fallbackPath: '/login')`). This method uses GoRouter's O(1) inherited-widget-lookup `this.canPop()` and `this.pop()` to instantly pop the current page if a history stack exists, and falls back to the specified route only if accessed directly, eliminating any tree traversal latency.
29. **Reserved Paths for Multi-Tenant Routing**: Any new root-level path added to the application router (such as `/templates`, `/privacy-policy`, etc.) MUST be added to the `reservedPaths` Set in `TenantRoutingService` (located in [tenant_routing_service.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/services/tenant_routing_service.dart)). This ensures the tenant routing resolver does not misidentify these paths as custom subdomain/slug pages when executing back navigation or parsing URLs.
30. **Dynamic Theme Color Enforcement (CRITICAL)**: All UI widgets MUST use `Theme.of(context).colorScheme.*` for surface, text, and border colors. NEVER use `AppColors.background`, `AppColors.cardBg`, `AppColors.border`, `AppColors.textPrimary`, `AppColors.textSecondary`, or `AppColors.textMuted` directly in widget build methods. See [THEME_SYSTEM.md](./THEME_SYSTEM.md) for the full color mapping table and migration rules.
    - **Const Stripping**: When using `Theme.of(context)` inside a constructor argument that was previously `const`, you MUST remove the `const` keyword from that constructor (e.g., `const BoxDecoration` → `BoxDecoration`).
    - **Context Propagation**: Private helper methods that build sub-widgets (e.g., `_buildCard()`) MUST receive `BuildContext context` as their first parameter when they reference `Theme.of(context)`.
    - **Permitted Exceptions**: `AppColors.primary`, `AppColors.secondary`, `AppColors.dangerRed`, `AppColors.activeGreen`, `AppColors.warningOrange`, and `AppColors.primaryGradient` may still be used as brand/semantic colors where a `colorScheme` equivalent is not appropriate.
31. **AnimatedThemeToggle Placement Rule**: The `AnimatedThemeToggle` widget (`lib/core/widgets/atoms/animated_theme_toggle.dart`) MUST appear in every top-level `AppBar` that the user interacts with. Currently required in: `BuilderAppBar` (desktop + mobile), and `DashboardShell` (`_DesktopTopBar` for desktop, mobile `AppBar` for mobile). When adding new top-level screens with their own `AppBar`, include `const AnimatedThemeToggle()` in the `actions` list.
32. **Consent Dialog Barrier Rule**: Any critical confirmation dialog (e.g., Google new-user consent, section delete) MUST set `barrierDismissible: false` to prevent accidental dismissal without user choice. Inline legal links (privacy/terms) inside such dialogs MUST use `RichText` + `TapGestureRecognizer` for tappable hyperlinks — NEVER concatenate translated strings with plain `Text`.
33. **Section Deletion Flow (CRITICAL)**: The delete action in `block_properties_editor.dart` MUST follow this flow:
    - Show `AlertDialog` with "هل تريد حذف هذا القسم؟" and two buttons: "حذف" (error color) confirming, and "إلغاء" dismissing.
    - On confirm: call `cubit.deleteBlock(widget.index)` then `widget.onDone()` to close the bottom sheet.
    - NEVER use `context.go()` or any navigation call — the user MUST remain in the builder workspace.
34. **Global Font Picker Cubit Binding**: The font picker in `DesignFontsTab` (`lib/features/builder/widgets/tabs/builder_sidebar_tabs.dart`) MUST use `BlocBuilder<BuilderThemeCubit, LandingPageTheme>` — NOT `BlocBuilder<LandingPageBuilderCubit, BuilderState>`. The `BuilderThemeCubit` is the sole owner of `LandingPageTheme`, and the font picker must read `defaultFont` directly from the `LandingPageTheme` parameter.
35. **GuestPreviewScreen Patterns**: The `GuestPreviewScreen` (`lib/features/builder/screens/guest_preview_screen.dart`) is used for unauthenticated landing page previews:
    - Use `PreviewMode.desktop` (not `PreviewMode.fullscreen`) as the default preview mode to avoid layout issues on desktop.
    - Add `initState` with a fallback `cubit.initializeNewPage()` when the cubit state is not `BuilderLoaded`.
    - Wrap the `Scaffold` in a `LayoutBuilder` to derive `isDesktopWidth` from `constraints.maxWidth >= 768`.
    - Show two toggle `IconButton`s in the AppBar when `isDesktopWidth` is true: `Icons.phone_android_rounded` (mobile preview) and `Icons.desktop_windows_rounded` (desktop preview), with the active mode highlighted via `Theme.of(context).colorScheme.primary`.
    - Compute `isMobile` for `BuilderCanvas` as `_previewMode == PreviewMode.mobile || !isDesktopWidth`.
36. **Lead Form Defaults Location**: The default `fields` arrays for `lead_form` and `lead_magnet` blocks are defined in `builder_cubit.dart:addBlock()`, NOT in `block_registry.dart`. When modifying default form fields, edit the `fields` list inside `addBlock()` for each respective block type. The Edge Function `lead-submit` handles Turnstile verification, rate limiting, fingerprinting, and invokes `lead-notify` fire-and-forget with `WEBHOOK_SECRET` auth — never insert leads directly from the client.

37. **`IntrinsicHeight`/`IntrinsicWidth` + `LayoutBuilder` Incompatibility (CRITICAL — Rendering Crash)**: 
    - **Symptom**: `LayoutBuilder does not support returning intrinsic dimensions.` at runtime. The crash points to an `IntrinsicHeight` or `IntrinsicWidth` widget.
    - **Root cause**: `IntrinsicHeight`/`IntrinsicWidth` calculate intrinsic dimensions by running a speculative layout pass. `LayoutBuilder` cannot participate in this because it would require mutating the live render tree speculatively, which Flutter forbids. Any `LayoutBuilder` nested anywhere inside an `Intrinsic` widget triggers this crash.
    - **Fix**: Remove the wrapping `IntrinsicHeight`/`IntrinsicWidth`. If the goal is equal-height children in a `Row`, use `CrossAxisAlignment.stretch` instead. If the goal is intrinsic sizing, restructure using `Row`/`Column` with `MainAxisSize.min` and explicit constraints.
    - **Rule**: NEVER wrap a subtree containing `LayoutBuilder` (directly or indirectly) with `IntrinsicHeight` or `IntrinsicWidth`. The two widgets are fundamentally incompatible.

38. **`Expanded`/`Flexible` in Unbounded ScrollView Columns (CRITICAL — Infinite Height Crash)**: 
    - **Symptom**: `BoxConstraints forces an infinite height.` Debug console shows `BoxConstraints(0.0<=w<=Infinity, h=Infinity)` on a `Row` or `Column`. The crash happens only on desktop layouts inside a `SingleChildScrollView > Column`.
    - **Root cause**: Widgets inside `SingleChildScrollView > Column` receive infinite height constraints because the scroll view provides unbounded space. `Expanded` and `Flexible` children cannot function in unbounded main-axis space and crash. `CrossAxisAlignment.stretch` on a `Row` also crashes because it tries to give children infinite cross-axis extent.
    - **Why removing `IntrinsicHeight` triggers it**: `IntrinsicHeight` previously clamped the infinite height to the content's intrinsic size. Removing it exposes the raw infinite constraint, causing `Row` with `CrossAxisAlignment.stretch` to crash.
    - **Fix for bento grids and similar layouts**: Replace `Expanded`/`Flexible` with `SizedBox` having an explicit computed height (e.g., `height: (constraints.maxWidth * 0.3).clamp(280.0, 420.0)`). The `SizedBox` provides a definitive finite height regardless of parent constraints. Inside each `SizedBox`, `CrossAxisAlignment.stretch` and nested `Expanded` children work correctly because they now have finite bounds.
    - **Alternative fixes**: 
      - Give the entire section a fixed height using `SizedBox` or `ConstrainedBox`.
      - Remove `CrossAxisAlignment.stretch` and all vertical `Expanded` children, letting intrinsic content sizing take over (works when `_BentoCard`-style widgets handle both bounded/unbounded cases via `LayoutBuilder` + `hasBoundedHeight`).
      - Use `MediaQuery` to calculate viewport-based heights.
    - **Rule**: Inside any widget tree that receives infinite height (inside `SingleChildScrollView > Column`, `ListView`, `CustomScrollView`), NEVER use `Expanded`/`Flexible` or `CrossAxisAlignment.stretch` without wrapping the subtree in a `SizedBox`/`ConstrainedBox` with an explicit height. Always verify the parent constraint chain when adding or removing `IntrinsicHeight` wrappers.

39. **CanvasKit WASM Font Loading Safety (CRITICAL — White Screen Crash)**: 
    - **Symptom**: App renders a white page with no error UI. Debug console shows:
      ```
      Error: RuntimeError: memory access out of bounds
      ...canvaskit.wasm...
      MakeFreeTypeFaceFromData
      canvaskit_api.dart:2285
      fonts.dart:133
      ```
    - **Root cause**: `GoogleFonts.pendingFonts()` downloads font bytes and passes them to CanvasKit's `MakeFreeTypeFaceFromData`. On some environments, the WASM binary raises a `RuntimeError` that is **not a Dart exception** and **bypasses `try/catch` entirely**, crashing the app before `runApp()` completes.
    - **Why it appears after unrelated changes**: Any hot restart can trigger this pre-existing flake. It is never caused by the code being edited.
    - **Fix** (see `lib/main.dart`): Fire font preloading as a **fire-and-forget microtask** (`Future(() async { ... })`) — NEVER `await` it inside the initialization `try` block. The `<link>` preload tags in `web/index.html` guarantee fonts are available even if the Dart API fails.
    - **Golden rule**: NEVER `await` a `google_fonts` call (`pendingFonts`, `getFont`, `getTextTheme`, etc.) in the startup sequence that blocks `runApp()`.

40. **Unified CubeLoader System (CRITICAL)**: ALL loading indicators MUST use either `CubeLoader` or its backward-compatible wrappers. The `CubeLoader` (`lib/core/widgets/particles/cube_loader.dart`) unifies `LoadingLogo`, `CubeSpinner`, and `CubeProgress` into a single optimized widget with shared geometry.
     - **Primary widget**: `CubeLoader` — use for new code. Has `variant: logo|single|cluster|linear|circular|physics`.
    - **Legacy wrappers** (delegate to CubeLoader, no breaking changes): `LoadingLogo`, `CubeSpinner`, `CubeProgress`.
    - **Size selection**: Page loaders → `size: 80`, Section loaders → `size: 48`, Inline/Tiny → `size: 24` or `size: 16`.
     - **State selection**: Page/API loading → `initialState: CubeLoaderState.loading`, Brand showcase → `initialState: CubeLoaderState.breathing`, Rotating layers → `initialState: CubeLoaderState.rotatingLayers`, Static → `initialState: CubeLoaderState.idle`.
     - **Variant selection**: Full logo (27 cubes) → `variant: CubeLoaderVariant.logo`, Single spinner → `variant: CubeLoaderVariant.single`, Upload progress → `variant: CubeLoaderVariant.cluster` + `value:`, Linear wave → `variant: CubeLoaderVariant.linear`, Circular ring → `variant: CubeLoaderVariant.circular`, Bounce → `variant: CubeLoaderVariant.physics`.
    - **Button loading**: Use `PrimaryButton(isLoading: true)` or `CubeLoader(variant: single, size: 16, color: Colors.white)`.
    - **Image loading**: `CustomNetworkImage` uses `CubeShimmer` (still independent, uses shared geometry).
    - **Image upload progress**: `CubeLoader(variant: cluster, value: progress, showPercentage: true)`.
    - **Pull to refresh**: `CubeRefreshIndicator` (remains independent).
     - **Interactive mode**: Set `interactive: true` for hero/standalone logos to enable hover glow, tap explode, AND hover layer highlighting in `rotatingLayers` state (hovered layer rotates 1.8× faster).
     - **Smooth speed transitions**: Speed changes between states lerp automatically (~500ms) — no visual snap.
     - **Percentage overlay**: When `showPercentage: true`, the percentage text has a `Colors.black.withValues(alpha: 0.45)` rounded background for readability on any background.
     - See `docs/ai/CUBE_LOADER.md` for comprehensive documentation.

41. **Google Fonts Loading Screen Protocol**:
    - **Why**: After implementing Rule 39 (fire-and-forget font preloading), the home screen may render before Google Fonts are fully loaded. If text widgets render with system fonts, they will swap (FOUT) when Google Fonts arrive, or show tofu if fonts fail.
    - **Fix** (`lib/core/services/font_load_notifier.dart`): A top-level `FontLoadNotifier` (global singleton `fontLoadNotifier`) signals when font loading completes. The notifier is defined as a simple top-level variable (not registered in DI) so it can be accessed from both `_preloadFonts()` microtask (which runs before `sl` is initialized) and `landymaker_home_screen.dart`.
    - **Screen behavior**: When fonts are not yet ready, the home screen renders ONLY the cube background (`FloatingCubeBackground` inside `Positioned.fill`) — no `AppBar`, no scroll content, no widgets. When `fontLoadNotifier.markReady()` fires, `_fontsReady` transitions to `true`, causing a full rebuild that shows all content with their natural entrance animations.
    - **Implementation** (see `lib/features/home/screens/landymaker_home_screen.dart`):
      1. Import `fontLoadNotifier` from `font_load_notifier.dart`.
      2. In `initState`: check `fontLoadNotifier.ready` immediately; if false, `addListener(_onFontsReady)`.
      3. `_onFontsReady`: `if (mounted) setState(() => _fontsReady = true)` then `removeListener`.
      4. In build: `Scaffold(appBar: _fontsReady ? HomeNavbar(...) : null)` and `if (_fontsReady) SingleChildScrollView(...)`.
    - **main.dart** (`_preloadFonts`): After `await GoogleFonts.pendingFonts([...])` completes (or fails), call `fontLoadNotifier.markReady()` — regardless of success/failure, so the UI is never stuck.
    - **Notifier lifecycle**: Since `fontLoadNotifier` is never disposed, `removeListener` in both `_onFontsReady` and `dispose` prevents memory leaks. Once `ready` is true, the listener is removed and subsequent home screen visits use `fontLoadNotifier.ready` directly.
