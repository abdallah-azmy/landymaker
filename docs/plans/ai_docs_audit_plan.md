# AI Documentation Audit & Codebase Alignment Plan

> **Mission**: (1) Review every file in `docs/ai/`, cross-reference with the actual codebase, fix outdated/missing documentation, and enforce correct rules. (2) Audit the entire codebase for logic correctness, UI/UX quality, responsiveness, translations, color contrast, AI-readability, and performance. (3) Produce a final Arabic report sourced from the living audit log.
>
> **Language**: This plan is in English. The final report after completing all tasks must be written in **Arabic**.
>
> **Checklist Format**: Mark `[x]` when a task is completed, `[/]` when in progress.
>
> **AI Model Instructions**: You are a careful code auditor AND a frontend quality reviewer. For EVERY file you read, report every line that is interesting, suspicious, outdated, or insightful. Be thorough — leave nothing unexamined.

---

## MANDATORY LIVING AUDIT LOG SYSTEM

Before doing ANY work, you MUST create and maintain a living audit log file. This file is your memory, your scratchpad, and the source of the final report.

### Step 0 (FIRST ACTION): Create the audit log file

Create `docs/tasks/audit_log.md` with the following structure and fill it in as you work. Do NOT wait until the end — update it after EACH part you complete.

```markdown
# LandyMaker Full Audit Log

## STATUS TRACKER
- Current Part: [e.g. Part 3]
- Parts Completed: [1, 2]
- Parts Remaining: [3, 4, 5 ...]
- Last Updated: [timestamp]

## FINDINGS LOG
(Append every finding here as you discover it)

### [FINDING-001] Category: [Bug|Gap|Outdated|Security|UX|Perf|Translation|Contrast|Responsive]
- File: [filename:line]
- Description: [what you found]
- Severity: [Critical|High|Medium|Low|Suggestion]
- Action Taken: [Updated doc / Fixed code / Flagged for report]

## DOCS UPDATED LOG
(List every doc change made)

### [DOC-001] File: docs/ai/SYSTEM_MAP.md
- Lines changed: [X-Y]
- What changed: [description]

## UI/UX ISSUES LOG
(All visual, UX, responsiveness, translation, contrast issues)

### [UX-001] Screen/Widget: [name]
- Issue: [description]
- Severity: [Critical|High|Medium|Low]
- Suggestion: [how to fix]

## PERFORMANCE ISSUES LOG

### [PERF-001] File: [name:line]
- Issue: [description]
- Suggestion: [optimization approach]

## SECURITY ISSUES LOG

### [SEC-001] Area: [name]
- Issue: [description]
- Risk Level: [Critical|High|Medium|Low]

## AI READABILITY ISSUES LOG

### [READ-001] File: [name]
- Issue: [description — why AI models may struggle with this file]
- Suggestion: [how to improve]

## BUSINESS SUGGESTIONS LOG

### [BIZ-001] Feature/Area: [name]
- Suggestion: [description]
- Business Value: [why this helps the SaaS]

## CONTEXT RECOVERY CHECKPOINT
(Update this section every time you finish a Part so you can resume if token limit is hit)

### Last checkpoint
- Completed through: Part [X]
- Key decisions made: [list]
- Open questions: [list]
- Next action: [exactly what to do next]
```

### Context Recovery Protocol (CRITICAL)

If you approach the token limit or are resuming a previous session:
1. Read `docs/tasks/audit_log.md` FIRST before doing anything else.
2. Check `STATUS TRACKER` to know where you stopped.
3. Check `CONTEXT RECOVERY CHECKPOINT` for the exact next action.
4. Continue from where you left off — do NOT restart from the beginning.
5. Before finishing your session, always update the `CONTEXT RECOVERY CHECKPOINT` section.

---

## CRITICAL RULES FOR THE EXECUTING AI MODEL

1. **Create audit_log.md FIRST**: Step 0 must be done before any other work.
2. **Update audit_log.md continuously**: After completing each sub-task, append findings to the log. Never batch findings at the end.
3. **Read before writing**: Before editing any `.md` file, read the corresponding source code files fully.
4. **Report every finding**: Every mismatch, gap, bug, security concern, UX issue, or improvement suggestion MUST be appended to audit_log.md immediately.
5. **Line-level reporting**: When you find a discrepancy, cite both the doc file line number AND the code file+line number.
6. **Do NOT skip sections**: Read EVERY section of every document. Do not summarize without reading.
7. **Check code existence**: Before confirming a documented feature exists, verify the actual Dart/JS/SQL file exists and contains the described logic.
8. **Cross-check block types**: For every block type mentioned in docs, verify it exists in `block_registry.dart` AND in `section_renderer.dart` AND has an editor in `builders/widgets/editors/blocks/`.
9. **Answer the 7 Quality Questions** (see Part 15) for every screen and widget you read.
10. **The final Arabic report must come FROM audit_log.md** — not from memory. Use the log as your single source of truth.

---

## Part 1: Audit AI_CONTEXT.md

**File**: `docs/ai/AI_CONTEXT.md` (504 lines)
**Code references**: Entire codebase

### 1.1 - Verify Directory Structure (Section 1)
- [ ] Read `AI_CONTEXT.md` lines 49-74 (directory structure).
- [ ] Cross-check against the actual `lib/` directory listing.
- [ ] Check: Does `lib/core/animations/` exist? (Referenced in doc as `animations/` under core, but actual directory listing shows it exists only with `entrance_animation_mixin.dart`).
- [ ] Verify `lib/core/services/` directory exists and matches described content.
- [ ] Report any directories in the actual codebase that are NOT documented.
- [ ] Report any directories in the doc that do NOT exist in the actual codebase.
- [ ] If there are gaps, update `AI_CONTEXT.md` Section 1 to reflect reality.

### 1.2 - Verify Supported Block Types (Section 3)
- [ ] Read `AI_CONTEXT.md` lines 101-133 (block types list).
- [ ] Open `lib/features/builder/registries/block_registry.dart` and read it FULLY.
- [ ] Open `lib/features/public_viewer/widgets/section_renderer.dart` and read it FULLY.
- [ ] For EVERY block type in the docs list, confirm it has:
  - A renderer entry in `block_registry.dart`.
  - A widget file in `lib/features/public_viewer/widgets/`.
  - An editor in `lib/features/builder/widgets/editors/blocks/`.
- [ ] Check the block editors directory listing: there are editors for `comparison_table`, `service_steps`, `statistics_grid`, `team_members`, `qr_code`. Are these block types documented in `AI_CONTEXT.md` Section 3?
- [ ] If undocumented block types exist, add them to the docs.
- [ ] Also verify: `custom_whatsapp_widget.dart`, `custom_qr_widget.dart`, `custom_social_qr_widget.dart` - are these distinct block types with correct entries?
- [ ] Update `AI_CONTEXT.md` Section 3 to add any missing block types.

### 1.3 - Verify Security and Antispam (Section 4)
- [ ] Read `AI_CONTEXT.md` lines 137-153.
- [ ] Open `supabase/functions/lead-submit/` directory and read the `index.ts` file.
- [ ] Open `lib/core/utils/fingerprint_utils.dart` and confirm the SHA-256 fingerprint logic.
- [ ] Open `lib/core/services/` and look for `TurnstileService` - verify it exists.
- [ ] Open `supabase/functions/ai-page-generate/` and confirm quota enforcement via `ai_usage_log` and `check_ai_quota`.
- [ ] Open `supabase/functions/ai-copywrite/` and confirm same quota enforcement.
- [ ] Report any security gaps or missing protections.

### 1.4 - Verify Analytics (Section 5)
- [ ] Read `AI_CONTEXT.md` lines 155-163.
- [ ] Open `lib/core/services/` directory and locate the analytics service.
- [ ] Verify `record_page_event` RPC is called with the documented event types.
- [ ] Verify `visitor_fingerprint` field in analytics.
- [ ] Report any discrepancies.

### 1.5 - Verify Real-Time Notifications (Section 6)
- [ ] Read `AI_CONTEXT.md` lines 165-171.
- [ ] Open `lib/features/dashboard/controllers/` and find `NotificationCubit`.
- [ ] Verify Supabase Realtime broadcast is used.
- [ ] Open `supabase/functions/lead-notify/` and verify `WEBHOOK_SECRET` protection.
- [ ] Check `supabase/functions/send-notification/` - is this related? Is it documented?
- [ ] Report any gaps.

### 1.6 - Verify Multi-Tenant Routing (Section 7)
- [ ] Read `AI_CONTEXT.md` lines 174-184.
- [ ] Open `lib/services/tenant_routing_service.dart` and read it FULLY.
- [ ] Verify all 4 routing methods are implemented.
- [ ] Verify `reservedPaths` set contains all necessary routes.
- [ ] Check `app_router.dart` - are all routes added to `reservedPaths`? (e.g., `/templates`, `/about`, `/privacy-policy`, `/terms`, `/guest-preview`).
- [ ] Report missing reserved paths.
- [ ] If gaps exist, update `AI_CONTEXT.md` Section 7.

### 1.7 - Verify Homepage Dynamism (Section 10 - Implementation Knowledge)
- [ ] Read `AI_CONTEXT.md` lines 222-247.
- [ ] Open `lib/features/home/screens/landymaker_home_screen.dart` and read lines 1-200.
- [ ] Open `lib/features/super_admin/screens/homepage_editor_screen.dart` and read it.
- [ ] Verify `DatabaseService.getHomepageSections()` exists in `lib/services/database_service.dart`.
- [ ] Verify config sheets: `HeroConfigSheet`, `FeatureConfigSheet`, `CtaConfigSheet`.
- [ ] Check if `FooterConfigSheet`, `NavbarConfigSheet`, `DesktopPreviewConfigSheet`, `TemplateConfigSheet` exist in `lib/features/super_admin/screens/` - are these documented?
- [ ] If undocumented config sheets exist, add them to the docs.
- [ ] Update `AI_CONTEXT.md` to document all config sheets.

### 1.8 - Verify Phase 2 UX Patterns (Section 17)
- [ ] Read `AI_CONTEXT.md` lines 413-460.
- [ ] Open `lib/features/builder/widgets/layout_picker/` and list its contents.
- [ ] Verify `LayoutPickerPanel`, `LayoutOptionCard`, `LayoutSlotGrid` exist.
- [ ] Open `lib/core/widgets/visibility_observer.dart` and verify the implementation.
- [ ] Open `lib/core/animations/entrance_animation_mixin.dart` and verify it provides all documented methods.
- [ ] Open `lib/core/responsive/responsive_utils.dart` and verify `HomeBreakpoint.isMobile(width)` exists.
- [ ] Report any discrepancies between docs and code.

### 1.9 - Verify Phase 3 Architecture (Section 18)
- [ ] Read `AI_CONTEXT.md` lines 462-478.
- [ ] Spot-check files like `home_navbar.dart`, `home_footer.dart` - do they follow the Factory pattern with `_DesktopLayout`/`_MobileLayout` classes?
- [ ] Open `lib/features/home/widgets/home_navbar.dart` and verify the pattern.
- [ ] Report if the pattern is correctly followed or if there are deviations.

### 1.10 - Verify Phase 4 UX Compliance (Section 19)
- [ ] Read `AI_CONTEXT.md` lines 481-504.
- [ ] Open `lib/features/auth/widgets/auth_layout_wrapper.dart` - confirm it exists.
- [ ] Open `lib/core/widgets/atoms/language_switcher_button.dart` - verify both variants exist.
- [ ] Verify `AnimatedThemeToggle` is commented out in all listed locations.
- [ ] Read `lib/core/theme/theme_cubit.dart` - confirm `ThemeMode.dark` is forced.
- [ ] Report any location where `AnimatedThemeToggle` is NOT commented out (should be flagged).

---

## Part 2: Audit AI_DOCUMENTATION_RULES.md

**File**: `docs/ai/AI_DOCUMENTATION_RULES.md` (161 lines)
**Code references**: Any widget/service that touches the documented rules.

### 2.1 - Verify Rules 1-15 (Core Development Rules)
- [ ] Read `AI_DOCUMENTATION_RULES.md` lines 49-79.
- [ ] **Rule 5** (`withValues(alpha:)` instead of `withOpacity()`): Search codebase for `withOpacity` calls - are there any violations?
  - Run: `grep -r "withOpacity" lib/ --include="*.dart" | head -30`
  - Report all violations found.
- [ ] **Rule 6** (bg_overlay_opacity slider): Open several block widgets (e.g., `custom_hero_widget.dart`) and verify `bg_overlay_opacity` is handled.
- [ ] **Rule 12** (LayoutBuilder + constraints): Spot-check 3 widgets for `MediaQuery.of(context).size` violations inside block widgets.
  - Run: `grep -r "MediaQuery.of(context).size" lib/features/public_viewer/ --include="*.dart"`
  - Report violations.
- [ ] **Rule 19** (`NumericParser`): Search for raw `double.parse()` or `int.parse()` calls in design map code.
  - Run: `grep -rn "double.parse\|int.parse" lib/features/public_viewer/ --include="*.dart" | head -20`
  - Report violations.

### 2.2 - Verify Rules 16-30 (Advanced Rules)
- [ ] Read `AI_DOCUMENTATION_RULES.md` lines 79-103.
- [ ] **Rule 17** (Environment Variables): Open `lib/core/utils/env_utils.dart` and verify all env vars use `const String.fromEnvironment`.
- [ ] **Rule 24** (Clean Responsive UI): Check `home_hero_section.dart` - does it follow the Factory pattern?
- [ ] **Rule 28** (`context.safePop`): Check `lib/core/router/router_extensions.dart` - verify `safePop` is implemented with correct logic.
- [ ] **Rule 29** (Reserved Paths): List all routes in `app_router.dart` and compare with `TenantRoutingService.reservedPaths` - are ALL static routes reserved?
- [ ] **Rule 30** (Dynamic Theme Colors): Search for deprecated static `AppColors` usage in widget build methods.
  - Run: `grep -rn "AppColors.background\|AppColors.cardBg\|AppColors.border\|AppColors.textPrimary\|AppColors.textSecondary\|AppColors.textMuted" lib/ --include="*.dart" | grep -v "app_colors.dart" | grep -v "app_theme.dart" | head -30`
  - Report violations.

### 2.3 - Verify Rules 31-41 (Latest Rules)
- [ ] Read `AI_DOCUMENTATION_RULES.md` lines 104-161.
- [ ] **Rule 31** (`AnimatedThemeToggle` placement): Verify the rule is consistent with what is actually in the code (should be commented out everywhere - rule says it should be in every AppBar, but it is currently disabled).
  - POTENTIAL CONFLICT: Rule 31 says "MUST appear in every top-level AppBar" but `THEME_SYSTEM.md` says it is currently disabled. These two sources conflict. Report this and suggest correcting Rule 31 to clarify the current disabled state.
- [ ] **Rule 36** (Lead Form Defaults): Verify `builder_cubit.dart:addBlock()` contains `fields` arrays for `lead_form` and `lead_magnet` blocks. Open `lib/features/builder/controllers/builder_cubit.dart` and search for `addBlock`.
- [ ] **Rule 39** (Local Font + Cairo): Verify `pubspec.yaml` has Cairo as a local font asset. Verify no `google_fonts` package in `pubspec.yaml`.
  - Run: `grep -ni "google_fonts\|cairo" pubspec.yaml`
- [ ] **Rule 40** (`CubeLoader` System): Spot-check 3 loading indicators in the codebase - do they use `CubeLoader` or old `CircularProgressIndicator`?
  - Run: `grep -rn "CircularProgressIndicator" lib/ --include="*.dart" | head -20`
  - Report violations.
- [ ] **Rule 41** (`DynamicFontService`): Open `lib/core/services/` and locate `DynamicFontService`. Verify the `_failedFonts` set and font loading logic are implemented.

### 2.4 - Check for Missing Rules
- [ ] After reviewing all rules, consider what common patterns exist in the codebase that are NOT yet documented as rules.
- [ ] Specifically check:
  - Is there a documented rule for `cookie_consent_banner.dart`? (File exists in public_viewer/widgets).
  - Is there a documented rule about `FloatingCartWidget` and its interaction with `StickyCtaBar`?
  - Is there a documented rule about `CartCubit`? (Mentioned in SYSTEM_MAP.md).
  - Are there rules about the `ProductFeedScreen` and `generate-product-feed` Edge Function?
- [ ] Add any missing rules to `AI_DOCUMENTATION_RULES.md` with incremented rule numbers (42+).

---

## Part 3: Audit SYSTEM_MAP.md

**File**: `docs/ai/SYSTEM_MAP.md` (202 lines)
**Code references**: `lib/core/router/app_router.dart`, all feature directories

### 3.1 - Verify Feature Directory Table (Section 2)
- [ ] Read `SYSTEM_MAP.md` lines 48-74.
- [ ] For EVERY feature in the table, verify the main entry/screen file and controller/cubit file exist.
- [ ] Check: `CartCubit` is listed in SYSTEM_MAP for "Store Expansion" - open `lib/features/` and find where `CartCubit` lives.
- [ ] Check: `LeadsAnalyticsCubit` - is it in `lib/features/dashboard/controllers/`?
- [ ] Check: `HomepageEditorCubit` - is it in `lib/features/super_admin/controllers/`?
- [ ] Report any phantom files (documented but do not exist).

### 3.2 - Verify Screen Index (Section 3)
- [ ] Read `SYSTEM_MAP.md` lines 77-104.
- [ ] Cross-check every screen path against the `app_router.dart` routes.
- [ ] Note: `SettingsScreen` exists at `/dashboard/settings` in the router - is this documented in SYSTEM_MAP?
- [ ] Note: `GuestPreviewScreen` exists at `/guest-preview` - is this in SYSTEM_MAP?
- [ ] Note: `BlogManagementScreen` is in SYSTEM_MAP - verify the file path is correct.
- [ ] Note: `UserProfileScreen` - is it still in `super_admin/screens/`? Verify.
- [ ] If any screens are missing from SYSTEM_MAP, add them.

### 3.3 - Verify Routes (Section 4)
- [ ] Read `SYSTEM_MAP.md` lines 107-134.
- [ ] Compare against ALL routes in `app_router.dart`.
- [ ] Check: `/dashboard/products` exists in router - is it documented? (Maps to `ProductFeedScreen`).
- [ ] Check: `/dashboard/settings` exists in router - is it documented?
- [ ] Check: `/guest-preview` exists in router - is it documented?
- [ ] Check: `/about`, `/privacy-policy`, `/terms` are in router - are they documented?
- [ ] Add missing routes to SYSTEM_MAP Section 4.

### 3.4 - Verify Services Table (Section 5)
- [ ] Read `SYSTEM_MAP.md` lines 138-155.
- [ ] Open `lib/injection_container.dart` and read it FULLY.
- [ ] For every service in the table, verify it is registered in `injection_container.dart`.
- [ ] Check if any services registered in `injection_container.dart` are missing from the table.
- [ ] Report and add missing services.

---

## Part 4: Audit CUBE_ECOSYSTEM.md

**File**: `docs/ai/CUBE_ECOSYSTEM.md` (467 lines)
**Code references**: `lib/core/widgets/particles/`

### 4.1 - Verify File Map
- [ ] Read `CUBE_ECOSYSTEM.md` lines 47-91 (File Map).
- [ ] Verify every file listed exists in the actual filesystem:
  - `particles/core/cube_geometry.dart` - check if it is in `lib/core/widgets/particles/core/`.
  - `particles/cube_loader.dart` - check actual size vs documented ~897 lines.
  - `particles/loading_logo.dart` - check actual size vs documented ~67 lines.
  - `atoms/cube_spinner.dart` - check actual size vs documented ~29 lines.
  - `atoms/cube_progress.dart` - check actual size vs documented ~33 lines.
  - `atoms/cube_shimmer.dart` - check actual size vs documented ~177 lines.
  - `atoms/cube_refresh_indicator.dart` - check actual size vs documented ~346 lines.
  - `particles/floating_cube_background.dart` - check actual size vs documented ~2398 lines.
  - `particles/cube_mode_cubit.dart` - verify exists.
  - `atoms/animated_cube_mode_toggle.dart` - verify exists.
- [ ] NOTE: `CUBE_ECOSYSTEM.md` line 461 says `landymaker_home_screen.dart` is ~1178 lines in System C table, but the actual file is 1366 lines. Update this.
- [ ] Report any line count discrepancies and update the File Inventory table.

### 4.2 - Verify Performance Rules
- [ ] Read `CUBE_ECOSYSTEM.md` lines 122-151 (Performance Rules P1-P9).
- [ ] Open `lib/core/widgets/particles/cube_loader.dart` lines 1-50 to verify `_tv`, `_nv`, `_quadPts` scratch buffers exist (Rule P1).
- [ ] Check if `_CubeLoaderPainter` class is present and uses the described performance patterns.
- [ ] Report if any performance rules are violated in the actual code.

### 4.3 - Verify Brand Logo Spec (Section 10)
- [ ] Read `CUBE_ECOSYSTEM.md` lines 302-444.
- [ ] Open `lib/core/widgets/particles/cube_loader.dart` and search for:
  - `rx = 0.70` (or equivalent) - verify exact value.
  - `baseRy = pi/4` - verify.
  - Corner rounding formula: `(h * 0.22).clamp(0.3, max(0.3, h * 0.4))`.
- [ ] Report if any values in code differ from documentation.

### 4.4 - Check for Missing Documentation
- [ ] NOTE: `CUBE_ECOSYSTEM.md` documents System C (Preview Mode) but the home screen is ~1178 lines according to docs. The actual file is 1366 lines, indicating new features were added. Read `landymaker_home_screen.dart` lines 200-400 to understand what new functionality was added.
- [ ] Update System C documentation if needed.

---

## Part 5: Audit BUILDER_ARCHITECTURE.md

**File**: `docs/ai/BUILDER_ARCHITECTURE.md` (68 lines)
**Code references**: `lib/features/builder/`

### 5.1 - Verify Core Data Flow
- [ ] Read `BUILDER_ARCHITECTURE.md` fully.
- [ ] Open `lib/features/builder/controllers/builder_cubit.dart` and scan first 100 lines.
- [ ] Verify `_history` List and `_historyIndex` exist for undo/redo.
- [ ] Verify `hasUnsavedChanges` flag exists and is used.
- [ ] Verify `TemplateRegistry` in `lib/features/builder/registries/template_registry.dart`.
- [ ] Check if `SectionLibraryModal` documentation (dual preview, `childAspectRatio: 0.62`) matches code.
  - Open `lib/features/builder/widgets/modals/` and find the section library modal.
  - Check if it has `_DualMiniPreview` as described.
- [ ] Report any discrepancies.

### 5.2 - Check for Missing Documentation
- [ ] The doc mentions the `BackgroundPickerTab` under BuilderThemeCubit. Verify it exists in `lib/features/builder/widgets/tabs/`.
- [ ] Open `lib/features/builder/widgets/tabs/` and list all tabs - are they all documented?
- [ ] Check if `DesignFontsTab` is in `builder_sidebar_tabs.dart` as described.
- [ ] Report undocumented tabs or UI components.

---

## Part 6: Audit BLOCK_SCHEMA_REGISTRY.md

**File**: `docs/ai/BLOCK_SCHEMA_REGISTRY.md` (67 lines)
**Code references**: `lib/features/builder/registries/block_registry.dart`, `supabase/functions/shared/schema_registry.json`

### 6.1 - Verify Block Schemas Are Complete
- [ ] Read `BLOCK_SCHEMA_REGISTRY.md` fully.
- [ ] Open `supabase/functions/shared/` and check if `schema_registry.json` exists.
- [ ] Open `lib/features/builder/registries/block_registry.dart` and list all registered block types.
- [ ] Compare the block types in `BLOCK_SCHEMA_REGISTRY.md` against those in `block_registry.dart`.
- [ ] IMPORTANT: Several block types have editors but are NOT in `BLOCK_SCHEMA_REGISTRY.md`:
  - `comparison_table` (has editor `comparison_table_editor.dart`)
  - `service_steps` (has editor `service_steps_editor.dart`)
  - `statistics_grid` (has editor `statistics_grid_editor.dart`)
  - `team_members` (has editor `team_members_editor.dart`)
  - `qr_code` (has editor `qr_code_editor.dart`)
  - `cta_banner` (has editor `cta_banner_editor.dart`)
- [ ] For each missing block type, read its editor and renderer files, then add its schema to `BLOCK_SCHEMA_REGISTRY.md`.
- [ ] Update `BLOCK_SCHEMA_REGISTRY.md` to list ALL block types with their schema properties.

### 6.2 - Verify Schema Registry JSON
- [ ] Open `supabase/functions/shared/schema_registry.json` and verify it contains entries for all block types.
- [ ] Compare with the Dart block registry - are they in sync?
- [ ] Report missing entries in the JSON file.

---

## Part 7: Audit THEME_SYSTEM.md

**File**: `docs/ai/THEME_SYSTEM.md` (165 lines)
**Code references**: `lib/core/theme/`

### 7.1 - Verify ThemeCubit Architecture
- [ ] Read `THEME_SYSTEM.md` fully.
- [ ] Open `lib/core/theme/theme_cubit.dart` and verify the code matches the documented snippet.
- [ ] Verify `ThemeMode.dark` is hardcoded as default.
- [ ] Open `lib/core/theme/app_theme.dart` - verify `AppTheme.light()` and `AppTheme.dark()` exist.

### 7.2 - Verify AnimatedThemeToggle Status Table
- [ ] Read `THEME_SYSTEM.md` lines 78-87 (status table).
- [ ] Open each listed file and confirm the toggle is commented out:
  - `builder_app_bar.dart` in `lib/features/builder/`
  - `dashboard_shell.dart` in `lib/features/dashboard/screens/`
  - `home_navbar.dart` in `lib/features/home/widgets/`
  - `settings_screen.dart` in `lib/features/dashboard/screens/`
  - `auth_layout_wrapper.dart` in `lib/features/auth/widgets/`
- [ ] If any toggle is NOT commented out, flag it as a violation.

### 7.3 - Verify AppBlurEffect Widget
- [ ] Read `THEME_SYSTEM.md` lines 139-165.
- [ ] Open `lib/core/widgets/atoms/blur_effect.dart` and verify the widget API matches documentation.
- [ ] Check if `AppBlurEffect` is used in the codebase - run:
  - `grep -rn "AppBlurEffect" lib/ --include="*.dart" | head -20`
- [ ] Report usage patterns and if documentation needs updating.

---

## Part 8: Audit DEVOPS_AND_ASSETS.md

**File**: `docs/ai/DEVOPS_AND_ASSETS.md` (91 lines)
**Code references**: `.github/workflows/`, `vercel.json`, `web/`

### 8.1 - Verify CI/CD Documentation
- [ ] Read `DEVOPS_AND_ASSETS.md` fully.
- [ ] Open `.github/workflows/deploy.yml` and verify the pipeline steps match documentation.
- [ ] Open `vercel.json` and verify the rewrite rule matches the documented critical rule.
- [ ] Open `middleware.js` lines 1-50 and verify blog routing is at the TOP.
- [ ] Report any mismatches.

### 8.2 - Verify Image Management Rules
- [ ] Rule: "Always use `CustomNetworkImage`". Search for violations:
  - `grep -rn "Image.network\|CachedNetworkImage" lib/ --include="*.dart" | grep -v "custom_network_image.dart" | head -30`
- [ ] Report violations.
- [ ] Verify `image_media_service.dart` implements Pixabay ToS compliance (downloads to memory before upload).

### 8.3 - Verify Asset Files
- [ ] Confirm both sets of icon assets exist:
  - `web/favicon.png`, `web/icons/Icon-*.png`, `web/logo_social.webp`
  - `assets/images/logo.webp`, `assets/images/logo_small.webp`, `assets/images/app_icon_source.png`
- [ ] Report any missing asset files.

---

## Part 9: Audit HTML_LOADING_VIEW.md

**File**: `docs/ai/HTML_LOADING_VIEW.md` (254 lines)
**Code references**: `web/index.html`

### 9.1 - Verify HTML Loading View Documentation
- [ ] Read `HTML_LOADING_VIEW.md` fully.
- [ ] Open `web/index.html` and read it FULLY (focus on the JS loading logic).
- [ ] Verify ALL JS functions documented in Section 5 exist:
  - `updateLogoFrame()` - verify it uses the documented formula.
  - `_forceLogoFinalState()` - verify it exists.
  - `transitionToPersistentLogo()` - verify it calls `stopHtmlSpawning()`, `_forceLogoFinalState()`.
  - `removePersistentLogo()` - verify 1.5s fade exists.
  - `removeLoader()` - verify 0.25s safety fallback.
  - `stopHtmlSpawning()` - verify it sets `_htmlCubesSpawning = false`.
  - `setLogoOpacity(value)` - verify this function EXISTS (added in recent work per AI_PROMPT_FOR_NEW_MODEL.md).
- [ ] Verify `spawnLoop()` implementation - does it use the documented acceleration formula?
- [ ] Verify `window._htmlCubeEdgePositions` is set with 81 positions.
- [ ] Compare the Flutter-side code in `landymaker_home_screen.dart` against the doc's Section 6 "Transition Wire-Up".
- [ ] CRITICAL DISCREPANCY CHECK: `AI_PROMPT_FOR_NEW_MODEL.md` (lines 80-97) describes a "Logo Fade-Out During Building" feature where `setLogoOpacity()` is called from the Flutter building loop. But `HTML_LOADING_VIEW.md` (Section 6) shows `_removePersistentLogo()` being called directly. The ACTUAL code in `landymaker_home_screen.dart` (lines 102-110) shows BOTH `_transitionToPersistentLogo()` AND `_removePersistentLogo()` being called. This means the `AI_PROMPT_FOR_NEW_MODEL.md` describes a future intended state. Check the CURRENT `floating_cube_background.dart` - does it call `setLogoOpacity()` or not? Does it have building mode? Report the actual state clearly, and update `HTML_LOADING_VIEW.md` to match the CURRENT actual implementation.
- [ ] Update `HTML_LOADING_VIEW.md` if implementation has changed from what is documented.

### 9.2 - Verify Service Worker Safety Notes
- [ ] Read `HTML_LOADING_VIEW.md` lines 250-253 (pitfalls 8-10).
- [ ] Open `web/index.html` and find the Service Worker registration block.
- [ ] Verify it checks for localhost and prevents registration in dev mode.
- [ ] Verify the SW catch-all fallback restricts to `text/html` only.
- [ ] Report if these safety measures are implemented.

---

## Part 10: Audit CUBE_LOADER.md

**File**: `docs/ai/CUBE_LOADER.md`
**Code references**: `lib/core/widgets/particles/cube_loader.dart`

### 10.1 - Verify CubeLoader API Documentation
- [ ] Read `CUBE_LOADER.md` fully.
- [ ] Open `lib/core/widgets/particles/cube_loader.dart` and scan for:
  - All 6 variants listed in docs (`logo`, `single`, `cluster`, `linear`, `circular`, `physics`).
  - All 4 states listed (`idle`, `breathing`, `loading`, `rotatingLayers`).
  - `interactive` parameter.
  - `showGlow` parameter.
  - `showPercentage` parameter.
  - `value` parameter for determinate progress.
- [ ] Report any parameters that exist in code but are undocumented.
- [ ] Report any documented parameters that do not exist in code.

---

## Part 11: Audit FLOATING_CUBE_BACKGROUND.md

**File**: `docs/ai/FLOATING_CUBE_BACKGROUND.md`
**Code references**: `lib/core/widgets/particles/floating_cube_background.dart`

### 11.1 - Verify Mode Documentation
- [ ] Read `FLOATING_CUBE_BACKGROUND.md` fully.
- [ ] Open `lib/core/widgets/particles/floating_cube_background.dart` lines 1-100.
- [ ] Verify the 4 modes are documented with correct physics values.
- [ ] Check if `callJsWithArg` is used in the building loop (per `AI_PROMPT_FOR_NEW_MODEL.md`).
- [ ] Check if `_isBuilding`, `_brickRevealProgress`, `_brickTotalDuration` constants exist in the file.
- [ ] Report the current state of the building phase implementation.
- [ ] Update `FLOATING_CUBE_BACKGROUND.md` if implementation has changed.

### 11.2 - Verify Scroll Drift Safety
- [ ] Read `CUBE_ECOSYSTEM.md` lines 226-232 (scroll drift safety).
- [ ] Open `floating_cube_background.dart` and search for `scrollDrift.clamp`.
- [ ] Verify BOTH safeguards are present.
- [ ] Report if either is missing.

---

## Part 12: Audit CONCURRENT_MODIFICATION_CRASH_FIX.md

**File**: `docs/ai/CONCURRENT_MODIFICATION_CRASH_FIX.md`
**Code references**: `lib/core/widgets/particles/floating_cube_background.dart`

### 12.1 - Verify Fix Is Applied
- [ ] Read `CONCURRENT_MODIFICATION_CRASH_FIX.md` fully.
- [ ] Open `floating_cube_background.dart` and search for `_entities.toList()`.
- [ ] Verify the fix pattern (using `.toList()` before iterating while modifying) is applied.
- [ ] Check if there are any remaining places where `_entities` is iterated without `.toList()` safety.
- [ ] Report findings.

---

## Part 13: Audit API_LOGGING_GUIDE.md

**File**: `docs/ai/API_LOGGING_GUIDE.md` (123 lines)
**Code references**: `lib/core/logger.dart`, `lib/core/`

### 13.1 - Verify Logger Implementation
- [ ] Read `API_LOGGING_GUIDE.md` fully.
- [ ] Open `lib/core/logger.dart` and verify it implements the documented API.
- [ ] Look for `supabase_logging_mixin.dart` - is it at `lib/core/supabase_logging_mixin.dart`?
- [ ] Verify `SupabaseLoggingMixin` provides `logDatabaseOperation`, `logAuthOperation`, `logStorageOperation`.
- [ ] Report if the file location documented is correct.

---

## Part 14: Final Documentation Sync and New Rules

### 14.1 - Add Missing Features to Documentation
- [ ] After completing all audits, compile a list of features/files found in code but NOT in any doc.
- [ ] For each undocumented feature, add it to the appropriate doc file:
  - New block types: `BLOCK_SCHEMA_REGISTRY.md` + `AI_CONTEXT.md` Section 3.
  - New screens: `SYSTEM_MAP.md` Screen Index.
  - New routes: `SYSTEM_MAP.md` Routes section.
  - New services: `SYSTEM_MAP.md` Services table.
  - New UI patterns: `AI_CONTEXT.md` or `AI_DOCUMENTATION_RULES.md`.

### 14.2 - Add Best Practice Rules
Based on your code reading, add any of these rules that are missing from `AI_DOCUMENTATION_RULES.md`:
- [ ] Rule about `CookieConsentBanner` - when and how to use it.
- [ ] Rule about `FloatingCartWidget` overlay behavior and `StickyCtaBar` interaction.
- [ ] Rule about `CartCubit` usage for e-commerce blocks.
- [ ] Rule about `generate-product-feed` Edge Function usage.
- [ ] Rule about `verify-custom-domain` Edge Function usage.
- [ ] Rule about `GlassContainer` widget usage (`lib/core/widgets/atoms/glass_container.dart`).
- [ ] Rule about `LandyMakerLogo` widget (`lib/core/widgets/atoms/landy_maker_logo.dart`).
- [ ] Rule about `ToastService` usage pattern (`lib/core/utils/toast_service.dart`).
- [ ] Rule about blog admin (`BlogManagementScreen`) - what it manages and its route guard.
- [ ] Rule about `OfflineBanner` widget (`lib/core/widgets/offline_banner.dart`).

### 14.3 - Security and Business Improvements
After reviewing the entire codebase, report:
- [ ] Any endpoints, RPCs, or Edge Functions that may lack proper authorization checks.
- [ ] Any rate limiting gaps.
- [ ] Any frontend validation that could be bypassed.
- [ ] Any outdated dependency notices from `pubspec.yaml`.
- [ ] Business suggestions: features that would significantly improve the SaaS product based on what you see in the codebase.
- [ ] Performance improvement suggestions based on code patterns observed.
- [ ] Architectural improvement suggestions.

---

## Part 15: UI/UX Quality Audit (The 7 Quality Questions)

This part must be executed for EVERY screen and major widget you read during Parts 1-14. For each file, answer all 7 questions and log findings in `docs/tasks/audit_log.md` under the UX ISSUES LOG section.

### The 7 Mandatory Quality Questions

For each screen or widget file you open, answer:

**Q1 — Logic & Functionality**: Does every feature in this screen work correctly end-to-end? Is the business logic connected properly to the UI? Are there any dead buttons, unhandled states, missing loading indicators, missing error states, or flows that break the user journey?
- Check: Every button has an `onPressed` handler that does something meaningful.
- Check: Every async operation shows a loading state and handles errors.
- Check: Form submissions have validation, loading prevention (no double-submit), and success/error feedback.
- Check: Navigation flows do not create infinite loops or dead ends.
- Log any Q1 issues as `[UX-XXX] Category: Logic`.

**Q2 — UX Quality & Visual Polish**: Does any element look confusing, ugly, amateur, or unprofessional? Could any UI element distract or confuse the user?
- Check: Spacing, alignment, and visual hierarchy are consistent.
- Check: No overlapping elements, no cut-off text, no broken layouts.
- Check: Buttons are appropriately sized and positioned.
- Check: Empty states are handled gracefully (not just blank screens).
- Check: Error messages are human-friendly (not raw exception strings).
- Check: Loading states are branded (use `CubeLoader`, not `CircularProgressIndicator`).
- Log any Q2 issues as `[UX-XXX] Category: Polish`.

**Q3 — Responsiveness**: Does this screen work correctly on both mobile and desktop screen sizes?
- Check: No hardcoded pixel widths that break on small screens.
- Check: Text does not overflow or get cut off on narrow viewports.
- Check: Buttons and touch targets are at least 48x48px on mobile.
- Check: Images scale appropriately and do not cause horizontal scroll.
- Check: Tables/lists have a proper mobile card fallback.
- For any screen: mentally test at 375px (iPhone SE), 768px (tablet), 1440px (desktop).
- Log any Q3 issues as `[UX-XXX] Category: Responsive`.

**Q4 — Translations**: Is every user-visible string translated in both Arabic and English?
- Check: No hardcoded English or Arabic strings in widget build methods.
- Check: Every string uses `context.translate('key')` or `loc.translate('key')`.
- Check: Both `translations_ar.dart` and `translations_en.dart` have the key.
- Run: `grep -rn '"[A-Z][a-z]\+' lib/features/ --include="*.dart" | grep -v "//" | grep -v "'key'" | head -30` to find hardcoded strings.
- Run: `grep -rn "'[ا-ي]" lib/features/ --include="*.dart" | grep -v "//" | head -20` to find hardcoded Arabic strings.
- Log any Q4 issues as `[UX-XXX] Category: Translation`.

**Q5 — Color Contrast & Readability**: Is every text element readable against its background?
- Check: Text on dark backgrounds uses light colors (e.g., `colorScheme.onSurface`).
- Check: Text on colored buttons uses contrasting colors.
- Check: No white text on light backgrounds, no dark text on dark cards.
- Check: Placeholder text is visible but distinct from real content.
- Check: Status badges (success/error/warning) use accessible color combinations.
- Check: Any text on top of background images has sufficient overlay opacity.
- Log any Q5 issues as `[UX-XXX] Category: Contrast`.

**Q6 — AI Model Readability**: Is this code file structured in a way that an AI model can easily read, understand, and safely edit it?
- Check: File length — files over 800 lines without clear section separators are AI-hostile. Files over 2000 lines are dangerous (blind spots). Flag these.
- Check: Section separators — complex files use `/// ========================` comment blocks to divide logical sections.
- Check: Variable naming — are variable names descriptive enough for an AI to understand intent?
- Check: Magic numbers — are numeric constants named (e.g., `_brickTotalDuration = 36.0`) or hardcoded inline?
- Check: God widgets — widgets doing too many things in one `build()` method (over 200 lines) create confusion.
- Check: Dead code — commented-out blocks, unused variables, orphaned TODO comments.
- Log any Q6 issues as `[READ-XXX] Category: Readability`.

**Q7 — Performance**: Are there any patterns in this file that could slow down the app or waste resources?
- Check: `setState()` calls inside `build()` or from initState without `addPostFrameCallback`.
- Check: Heavy computations inside `build()` that should be cached.
- Check: Widgets that rebuild unnecessarily — should use `const` constructors or `RepaintBoundary`.
- Check: Large lists without `ListView.builder` (using a `Column` with `.map()` instead).
- Check: Images without `memCacheWidth` limits (OOM risk on large screens).
- Check: `withOpacity()` calls (deprecated, allocation-heavy) instead of `withValues(alpha:)`.
- Check: `Timer` or `Future.delayed` without cancellation on `dispose()`.
- Check: `StreamSubscription` without cancellation on `dispose()`.
- Log any Q7 issues as `[PERF-XXX] Category: Performance`.

### Priority Screen List (must audit all)

Audit these screens in this order (they are the most user-facing):

1. `lib/features/home/screens/landymaker_home_screen.dart` — Marketing homepage
2. `lib/features/home/widgets/home_navbar.dart` — Navigation bar
3. `lib/features/home/widgets/home_hero_section.dart` — Hero section
4. `lib/features/home/widgets/home_feature_bento.dart` — Features grid
5. `lib/features/home/widgets/home_cta_section.dart` — CTA banner
6. `lib/features/home/widgets/home_footer.dart` — Footer
7. `lib/features/home/screens/template_picker_screen.dart` — Template picker
8. `lib/features/auth/screens/login_screen.dart` — Login
9. `lib/features/auth/screens/register_screen.dart` — Register
10. `lib/features/auth/screens/forgot_password_screen.dart` — Password recovery
11. `lib/features/dashboard/screens/dashboard_home_screen.dart` — User dashboard
12. `lib/features/dashboard/screens/dashboard_shell.dart` — App shell & sidebar
13. `lib/features/dashboard/screens/analytics_screen.dart` — Analytics
14. `lib/features/dashboard/screens/leads_tracker_screen.dart` — Leads
15. `lib/features/dashboard/screens/media_gallery_screen.dart` — Media gallery
16. `lib/features/dashboard/screens/settings_screen.dart` — Settings
17. `lib/features/dashboard/screens/notifications_screen.dart` — Notifications
18. `lib/features/builder/screens/builder_workspace_screen.dart` — Builder canvas
19. `lib/features/public_viewer/screens/public_landing_page.dart` — Live page viewer
20. `lib/features/super_admin/screens/super_admin_panel_screen.dart` — Super admin
21. `lib/features/super_admin/screens/homepage_editor_screen.dart` — Homepage editor

For each screen: answer all 7 questions, log findings, then move on.

---

## Part 16: Performance Deep Audit

This part specifically targets performance bottlenecks across the whole codebase.

### 16.1 - Deprecated API Sweep
- [ ] Run: `grep -rn "withOpacity" lib/ --include="*.dart" | grep -v "//" | wc -l`
- [ ] List every file with violations.
- [ ] Fix all violations (replace `withOpacity(x)` with `withValues(alpha: x)`).
- [ ] Log each fix in audit_log.md under DOCS UPDATED LOG.

### 16.2 - Const Constructor Coverage
- [ ] Scan widget files for widgets that could be `const` but are not.
- [ ] Run: `grep -rn "new " lib/ --include="*.dart" | grep -v "//" | head -20` (should be 0 in modern Dart).
- [ ] Scan for `Text("...")` that could be `const Text("...")`.
- [ ] Log any patterns found.

### 16.3 - List Rendering Performance
- [ ] Check every `Column(children: items.map(...).toList())` pattern in public_viewer widgets.
- [ ] Flag any list with potentially >10 items that uses `Column` instead of `ListView.builder`.
- [ ] Log issues and suggest fixes.

### 16.4 - Image Memory Safety
- [ ] Search for `Image.network` calls without `cacheWidth` limits.
- [ ] Search for `CustomNetworkImage` calls — verify `memCacheWidth` is being set.
- [ ] Check `image_media_service.dart` for OOM-safe patterns.
- [ ] Log findings.

### 16.5 - Animation Controller Lifecycle
- [ ] Search for `AnimationController` declarations.
- [ ] Verify every controller has a `dispose()` call.
- [ ] Run: `grep -rn "AnimationController" lib/ --include="*.dart" | wc -l`
- [ ] Spot-check 5 files to verify proper lifecycle.

### 16.6 - Stream and Timer Cleanup
- [ ] Search for `StreamSubscription` — verify all are cancelled in `dispose()`.
- [ ] Search for `Timer.periodic` and `Timer(Duration...)` — verify all are cancelled.
- [ ] Run: `grep -rn "StreamSubscription\|Timer.periodic\|Timer(" lib/ --include="*.dart" | head -30`
- [ ] Log any leaks found.

### 16.7 - Build Method Complexity
- [ ] Identify any `build()` methods over 200 lines (sign of a God widget).
- [ ] Run: Check the largest files: `ls -la lib/features/ -R | sort -k5 -rn | head -20` equivalent.
- [ ] For each God widget found, suggest how to split it.
- [ ] Log findings.

### 16.8 - RepaintBoundary Coverage
- [ ] Verify all `CustomPaint` widgets are wrapped in `RepaintBoundary`.
- [ ] Verify all continuous animations (particles, loaders) are wrapped.
- [ ] Run: `grep -rn "CustomPaint" lib/ --include="*.dart" | head -20`
- [ ] Log any missing boundaries.

### 16.9 - Supabase Query Efficiency
- [ ] Read `lib/services/supabase_service.dart` and `lib/services/database_service.dart`.
- [ ] Check for N+1 query patterns (fetching in a loop).
- [ ] Check for queries without `.select()` column filters (fetching * unnecessarily).
- [ ] Check for missing `.limit()` on potentially large table queries.
- [ ] Log findings.

### 16.10 - Web Bundle Size Awareness
- [ ] Check `pubspec.yaml` for heavy dependencies that could inflate bundle size.
- [ ] Verify deferred loading is considered for large features.
- [ ] Check for unused packages.
- [ ] Log suggestions.

---

## Part 17: Comprehensive Translation & Localization Audit

This part ensures the app is truly bilingual (Arabic + English) with no gaps.

### 17.1 - Scan for Hardcoded Strings
- [ ] Run: `grep -rn '"[A-Z]' lib/features/ --include="*.dart" | grep -v "//' | grep -v 'key\|route\|url\|http\|asset\|font\|family\|svg\|png\|webp\|jpg' | head -50`
- [ ] Run: `grep -rn "'[A-Z]" lib/features/ --include="*.dart" | grep -v "//" | grep -v "'key'\|route\|url\|http\|asset\|font" | head -50`
- [ ] Log every hardcoded English string found.
- [ ] Run: `grep -rn "'[ا-ي]" lib/features/ --include="*.dart" | grep -v "//" | head -30`
- [ ] Log every hardcoded Arabic string found.

### 17.2 - Translation Key Coverage
- [ ] Open `lib/core/localization/translations_ar.dart` and `translations_en.dart`.
- [ ] Verify every key in `translations_ar.dart` exists in `translations_en.dart` and vice versa.
- [ ] Check for keys that have empty or placeholder translations.
- [ ] Log any missing or incomplete translations.

### 17.3 - RTL Layout Compliance
- [ ] Run: `grep -rn "EdgeInsets.only(left\|EdgeInsets.only(right" lib/ --include="*.dart" | grep -v "//" | head -30`
- [ ] Report violations of Rule 12 (`EdgeInsetsDirectional` should be used instead).
- [ ] Run: `grep -rn "Positioned(left:\|Positioned(right:" lib/ --include="*.dart" | grep -v "//" | head -30`
- [ ] Report violations of the `PositionedDirectional` rule.
- [ ] Log all RTL violations found.

### 17.4 - Date and Number Localization
- [ ] Check how dates are displayed in analytics, leads, and notifications screens.
- [ ] Verify numbers respect locale (e.g., Arabic numerals vs Western numerals).
- [ ] Check currency display in pricing blocks.
- [ ] Log any localization gaps.

---

## Final Deliverable: Arabic Report (From audit_log.md)

After completing ALL tasks above (Parts 1-17), produce the final report IN ARABIC by reading `docs/tasks/audit_log.md` and synthesizing all findings. The report must be thorough, specific, and actionable.

The Arabic report must answer these specific questions the owner asked:

1. **هل كل وظيفة في الموقع تعمل بصورة صحيحة من ناحية ترابط الـ logic مع الـ UI والـ UX؟**
   (Answer from Q1 findings in audit_log.md)

2. **هل هناك أشياء في واجهات المستخدم يمكن أن تشتته أو شكلها سيء وغير احترافي ويجب تجميلها؟**
   (Answer from Q2 findings in audit_log.md)

3. **هل كل الواجهات تعمل بصورة صحيحة في كل الأحجام سواء موبايل أو ديسكتوب؟**
   (Answer from Q3 findings in audit_log.md)

4. **هل كل النصوص مترجمة بالعربية والإنجليزية؟**
   (Answer from Q4 + Part 17 findings in audit_log.md)

5. **هل كل النصوص بألوان واضحة تجعلها قابلة للقراءة على الخلفية التي تظهر فوقها؟**
   (Answer from Q5 findings in audit_log.md)

6. **هل كل ملفات الأكواد readable and easy editable by AI models؟**
   (Answer from Q6 + AI readability findings in audit_log.md)

7. **هل هناك تحسينات يجب أن نضيفها لكي نجعل الأداء خرافياً والموقع خفيفاً وسريعاً؟**
   (Answer from Q7 + Part 16 findings in audit_log.md)

Plus the original sections:

8. الثغرات الأمنية المكتشفة (from SEC findings)
9. مشاكل التوثيق ومطابقة الكود (from FINDING entries)
10. التحديثات التي تمت على الوثائق (from DOCS UPDATED LOG)
11. اقتراحات تطوير المنتج (Business) (from BIZ suggestions)
12. الخلاصة والتوصيات النهائية

---

## Notes for the Executing AI Model

This plan was created by reviewing 14 documentation files and 50+ source code files.
The biggest gaps found during plan creation:

1. **Missing block types in docs**: `comparison_table`, `service_steps`, `statistics_grid`, `team_members`, `qr_code`, `cta_banner` have editors in the builder AND renderer widgets in public_viewer, but are NOT listed in `AI_CONTEXT.md` Section 3 or `BLOCK_SCHEMA_REGISTRY.md`.

2. **Missing screens in SYSTEM_MAP**: `SettingsScreen` at `/dashboard/settings` and `GuestPreviewScreen` at `/guest-preview` are registered routes in `app_router.dart` but are NOT in `SYSTEM_MAP.md`'s Screen Index.

3. **Missing routes in SYSTEM_MAP**: `/dashboard/products` is in the router but may not be documented. `/dashboard/settings`, `/guest-preview`, `/about`, `/privacy-policy`, `/terms` need verification.

4. **Config sheets not documented**: `FooterConfigSheet`, `NavbarConfigSheet`, `DesktopPreviewConfigSheet`, `TemplateConfigSheet` exist as files in `lib/features/super_admin/screens/` but are only partially documented in `AI_CONTEXT.md`.

5. **Rule 31 conflict**: The `AnimatedThemeToggle` rule says "MUST appear in every top-level AppBar" but `THEME_SYSTEM.md` says it is currently commented out everywhere. These two sources conflict and Rule 31 needs clarification.

6. **Home screen line count mismatch**: `CUBE_ECOSYSTEM.md` says `landymaker_home_screen.dart` is ~1178 lines but the actual file is 1366 lines.

7. **First-load flow discrepancy**: `AI_PROMPT_FOR_NEW_MODEL.md` and `HTML_LOADING_VIEW.md` describe slightly different loading flows. The actual code must be verified to determine the current true state.

8. **7 Quality Questions must be answered for every screen**: The owner specifically wants answers to logic correctness, UX polish, responsiveness, translations, contrast, AI readability, and performance — for every screen, not just spot checks.

9. **audit_log.md is sacred**: It is the memory of the entire audit. Update it after EVERY finding. Never rely on context window memory alone.
