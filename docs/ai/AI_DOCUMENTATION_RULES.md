# AI Documentation & Execution Rules - LandyMaker

Keep AI-facing docs synchronized with implementation changes. Documentation is part of the architecture contract.

## 1. Documentation Update Rules
**Update Required When Changing:**
- Screens: update `SCREEN_INDEX.md`.
- Routes: update `ROUTE_INDEX.md`.
- Services or infrastructure flows: update `SERVICE_INDEX.md`.
- Business features: update `FEATURE_INDEX.md`.
- Builder sections, templates, registries, schema assumptions, or renderer/editor mappings: update `AI_CONTEXT.md`, `AI_NAVIGATION.md`, and `BUILDER_ARCHITECTURE.md`.
- Folder structure or ownership boundaries: update `PROJECT_STRUCTURE.md`.
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
1. Read `AI_CONTEXT.md`, `AI_ONBOARDING.md`, `AI_NAVIGATION.md`, `TASK_ROUTING_GUIDE.md`, and `AI_DOCUMENTATION_RULES.md`.
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
    - Protect text from overflow in nested columns by using `Expanded`/`Flexible` and `maxLines`.
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
26. **AI-Friendly "Sweet Spot" File Sizing**: To optimize AI context windows, keep the Factory, Props, Desktop Layout, Mobile Layout, and Shared Sub-widgets in ONE file, **but only if the file remains under 800 lines**. If it exceeds this, split it into a directory structure. Files with multiple classes MUST be distinctly separated using large `/// ==========================` comment blocks to prevent AI hallucination.
27. **Static Arrow Icons Rule**: NEVER use direction-aware or locale-dependent arrow icons that swap direction dynamically based on RTL/LTR (e.g. showing a right-facing arrow for back in RTL). Always use static, standard arrow icons (such as `Icons.arrow_back_ios_new_rounded` / `Icons.arrow_back_rounded` for going back/previous, and `Icons.arrow_forward_ios_rounded` / `Icons.arrow_forward_rounded` for going forward/next) directly in the layout widgets to maintain consistent and intuitive UX across all locales.
28. **Safe Back Navigation & Safe Pop Rule**: To prevent infinite loading loops, redirect race conditions, or blank screen hangs when navigating backwards, NEVER hardcode raw routing links (such as `context.go('/')` or `context.go('/login')`) inside page-level back buttons. Instead, always use `context.safePop(fallbackPath: '...')` (e.g., `context.safePop(fallbackPath: '/')` or `context.safePop(fallbackPath: '/login')`). This method uses GoRouter's O(1) inherited-widget-lookup `this.canPop()` and `this.pop()` to instantly pop the current page if a history stack exists, and falls back to the specified route only if accessed directly, eliminating any tree traversal latency.
29. **Reserved Paths for Multi-Tenant Routing**: Any new root-level path added to the application router (such as `/templates`, `/privacy-policy`, etc.) MUST be added to the `reservedPaths` Set in `TenantRoutingService` (located in [tenant_routing_service.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/services/tenant_routing_service.dart)). This ensures the tenant routing resolver does not misidentify these paths as custom subdomain/slug pages when executing back navigation or parsing URLs.
30. **Dynamic Theme Color Enforcement (CRITICAL)**: All UI widgets MUST use `Theme.of(context).colorScheme.*` for surface, text, and border colors. NEVER use `AppColors.background`, `AppColors.cardBg`, `AppColors.border`, `AppColors.textPrimary`, `AppColors.textSecondary`, or `AppColors.textMuted` directly in widget build methods. See [THEME_SYSTEM.md](./THEME_SYSTEM.md) for the full color mapping table and migration rules.
    - **Const Stripping**: When using `Theme.of(context)` inside a constructor argument that was previously `const`, you MUST remove the `const` keyword from that constructor (e.g., `const BoxDecoration` → `BoxDecoration`).
    - **Context Propagation**: Private helper methods that build sub-widgets (e.g., `_buildCard()`) MUST receive `BuildContext context` as their first parameter when they reference `Theme.of(context)`.
    - **Permitted Exceptions**: `AppColors.primary`, `AppColors.secondary`, `AppColors.dangerRed`, `AppColors.activeGreen`, `AppColors.warningOrange`, and `AppColors.primaryGradient` may still be used as brand/semantic colors where a `colorScheme` equivalent is not appropriate.
31. **AnimatedThemeToggle Placement Rule**: The `AnimatedThemeToggle` widget (`lib/core/widgets/atoms/animated_theme_toggle.dart`) MUST appear in every top-level `AppBar` that the user interacts with. Currently required in: `BuilderAppBar` (desktop + mobile), and `DashboardShell` (`_DashboardTopBar` for desktop, mobile `AppBar` for mobile). When adding new top-level screens with their own `AppBar`, include `const AnimatedThemeToggle()` in the `actions` list.
