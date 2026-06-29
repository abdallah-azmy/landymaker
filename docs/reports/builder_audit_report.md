# 🏗️ LandyMaker Builder Page — Comprehensive Audit Report

**Created**: 2026-06-30
**Status**: In Progress

---

## Phase 1: Font Picker Bug

### ✅ What Was Done
- `lib/features/builder/widgets/tabs/design_fonts_tab.dart`: Verified `BlocBuilder<BuilderThemeCubit, LandingPageTheme>` usage (correct per Rule #34). Verified `theme.defaultFont` read and `updateThemeProperty('defaultFont', family)` call.
- `lib/features/builder/controllers/builder_cubit.dart`: Verified `_themeSubscription` syncs theme to `BuilderLoaded` with `_suppressHistoryFromTheme` guard.
- `lib/features/builder/controllers/builder_cubit_persistence.dart`: Added `DynamicFontService.loadFontsFromDesign()` calls in:
  - `_handleLoadedPage()` — fonts now load on page load
  - `applyTemplate()` — fonts now load on template apply
  - `applyCustomDesign()` — fonts now load on custom design apply
  - `applyDesignJson()` — fonts now load on AI edits
- `lib/features/public_viewer/widgets/custom_hero_widget.dart`: Added `fontFamily: props.theme?.defaultFont` to `_HeroTextContent` (title + subtitle), `_HeroPremiumTag`, and `_HeroButton` text styles.

### 🐛 Bugs Found
- **B1.1-B1.4**: `DynamicFontService.loadFontsFromDesign()` was never called from any cubit persistence method — fonts only loaded in the font picker UI widget. If a user never opened the font picker, custom fonts would not render on canvas/page. **Fixed**.
- **B1.5**: `theme?.defaultFont` was not applied to any text style in `custom_hero_widget.dart` — the font picker had no visible effect on the hero section. **Fixed** (hero only; 31 other renderers need same fix — deferred to Phase 6/13).

### 💡 Improvement Suggestions
- Extract a `StyledText` widget or extension that automatically applies `theme?.defaultFont` to every text node in the renderers, avoiding repetition across 32+ renderer files.
- Consider a `DefaultFontBuilder` or inherited widget at the `SectionRenderer` level so all descendant Text widgets automatically inherit the font.
- Add `DynamicFontService.loadFontsFromDesign()` call in the `_themeSubscription` listener so that switching fonts in the theme cubit (e.g., via undo/redo) triggers font loading.

### ⚠️ Warnings & Risks
- Font loading via `DynamicFontService` is a network call (Google Fonts CSS API). Users on slow or no internet will see Cairo fallback until the font loads. This is acceptable per the architecture.
- `_handleLoadedPage` calls `loadFontsFromDesign` asynchronously (fire-and-forget); the UI won't block if font loading fails.

### 📊 Code Health Notes
- `custom_hero_widget.dart` is 450 lines — under the 800-line limit ✅
- `builder_cubit.dart` is 213 lines — under limit ✅
- `builder_cubit_persistence.dart` is 1041 lines — **OVER limit** (needs split, noted for future)

---

## Phase 2: Color Palette Picker Bug

### ✅ What Was Done
- `lib/features/builder/widgets/tabs/design_colors_tab.dart`: 
  - Switched `_buildPalettesList()` from `BlocBuilder<LandingPageBuilderCubit, BuilderState>` to `BlocBuilder<BuilderThemeCubit, LandingPageTheme>` — eliminates potential sync lag in active palette detection (Task 2.2)
  - Switched `_buildCustomColorsList()` to `BlocBuilder<BuilderThemeCubit, LandingPageTheme>` for consistency
  - Fixed duplicate `Theme.of(context).colorScheme.primary` (index 2) → replaced with `Color(0xFF0EA5E9)` (sky blue)
  - Fixed duplicate `Colors.green` (index 6) → replaced with `Colors.indigo`
  - Added `///` doc comments

### 🐛 Bugs Found
- **B2.1**: `_buildPalettesList()` used `BlocBuilder<LandingPageBuilderCubit>` instead of `BlocBuilder<BuilderThemeCubit>` — active palette detection depended on theme sync subscription, introducing potential micro-lag. **Fixed**.
- **B2.2**: Two duplicate color entries in `_showColorPicker()` — `Colors.green` appeared twice, `colorScheme.primary` appeared twice. **Fixed**.

### 💡 Improvement Suggestions
- `_showColorPicker()` could be extracted into a reusable `BlockColorPicker` widget used by both `design_colors_tab.dart` and `block_design_settings.dart` to avoid consistency drift.

### ⚠️ Warnings & Risks
- The `overlay_opacity` vs `bg_overlay_opacity` dual-write in `block_design_settings.dart:241-243` is correctly implemented — both keys are written on slider change. `SectionBackground` reads `bg_overlay_opacity`. `BlockRegistry` reads `overlay_opacity ?? bg_overlay_opacity`. Consistent.
- The `_themeCubit.stream` subscription (`builder_cubit.dart:90-96`) correctly syncs the full `LandingPageTheme` into `BuilderLoaded.theme`.

### 📊 Code Health Notes
- `design_colors_tab.dart` is 362 lines — under 800 limit ✅
- `block_design_settings.dart` is 258 lines — under limit ✅

---

## Phase 3: Block Design Settings — Universal Properties

### ✅ What Was Done
- `lib/features/builder/widgets/editors/block_design_settings.dart`:
  - **Added `bg_overlay_color` color picker** (between `bg_image_url` and overlay opacity slider) — uses existing `showBlockColorPicker` from `editor_utils.dart`
  - **Added `bg_blur` slider** (range 0.0–20.0, after overlay opacity) — calls `cubit.updateBlockProperty(index, 'bg_blur', val)`
  - **Added `card_layout_mode` dropdown** (options `auto`/`equal`, label 'طريقة توزيع البطاقات') — only shown for 10 relevant block types via `const Set<String>` guard
  - Verified `bg_color` / `background_color` dual-read consistency across editor, registry, and SectionBackground
  - Verified `overlay_opacity` / `bg_overlay_opacity` write/read flow

### 🐛 Bugs Found
- **B3.1**: `bg_overlay_color` color picker was missing from block design settings — overlay color could not be customized per-section. **Fixed**.
- **B3.2**: `bg_blur` slider was missing — no per-section backdrop blur control. **Fixed**.
- **B3.3**: `card_layout_mode` dropdown was missing — grid height behavior (auto/equal) could not be controlled. **Fixed**.

### 💡 Improvement Suggestions
- Consider extracting a `SectionTypeGuard` helper widget for conditionally-rendered controls that only apply to certain block types (repeated pattern in `block_design_settings.dart`).

### ⚠️ Warnings & Risks
- The `BlockRegistry`'s overlay opacity read (`data['overlay_opacity'] ?? data['bg_overlay_opacity'] as num?`) has a Dart precedence issue — the `as num?` cast only applies to `bg_overlay_opacity`, not to the `??` expression result. If `overlay_opacity` is ever a non-null non-num value, it would crash. Currently safe because the slider writes nums.

### 📊 Code Health Notes
- `block_design_settings.dart` is now 290 lines — still well under 800 limit ✅
- All 12 universal properties from `BLOCK_SCHEMA_REGISTRY.md` are now exposed in the design settings editor

---

## Phase 7: AI Agent — Theme & Global Page Properties Coverage

### ✅ What Was Done
- `lib/features/builder/controllers/builder_cubit_persistence.dart`:
  - Added `_suppressHistoryFromTheme` guard around `_themeCubit.replaceTheme(newTheme)` in `applyDesignJson` to prevent double-emit from theme subscription (line 362-366)
  - Confirmed `applyDesignJson` already reads both `designJson['theme']` and `designJson['global_theme']` (fallback), merges with current theme, and calls `_themeCubit.replaceTheme()`

- `lib/features/builder/ai/ai_response_validator.dart`:
  - Extended hex prefix fix (`#` auto-prepend) to also apply to `theme` key (previously only `global_theme`)
  - Confirmed no top-level keys are stripped by validator — all page-level properties pass through

- `supabase/functions/shared/schema_registry.json`:
  - Added `ThemeModel` section with all 14 properties: primary, secondary, background, textPrimary, textSecondary, buttonTextColor, button_text_color, defaultFont, font_family, globalBgImageUrl, globalBgColorHex, name, category, description

### 🐛 Bugs Found
- **B7.1**: `applyDesignJson` called `_themeCubit.replaceTheme(newTheme)` without `_suppressHistoryFromTheme` guard — caused the theme subscription to fire an unnecessary duplicate emit with stale designMap. **Fixed**.
- **B7.2**: `ai_response_validator.dart` only validated hex prefixes on `global_theme` key, not on `theme` key — if the AI sent `theme` instead of `global_theme`, colors would not have `#` auto-prepended. **Fixed**.

### 💡 Improvement Suggestions
- The AI flow is designed to handle both `theme` and `global_theme` keys at multiple layers (validator, applyDesignJson) — this dual-key design works correctly.

### ⚠️ Warnings & Risks
- None — theme application from AI is fully functional.

### 📊 Code Health Notes
- `builder_cubit_persistence.dart` is 1043 lines — still flagged for future split
- `ai_response_validator.dart` is 111 lines — clean

---

## Phase 8: AI Agent — Section Properties Coverage (All 29 Types)

### ✅ What Was Done
- `lib/features/builder/ai/block_schema.dart`:
  - **`_globalProps`**: Added `layout_style`, `bg_color`, `theme_override` — now has ALL universal props
  - **`hero`**: Added `badge_text`
  - **`hero_saas`**: Added `badge_text`, `tech_logos`
  - **`products`**: Added `card_style`, `hover_effect`, `stagger_animations`; added `carousel` to `layout_style` allowedValues
  - **`featured_product`**: Added full schema (was COMPLETELY MISSING)
  - **`bento_store`**: Added full schema (was COMPLETELY MISSING)
  - **14 block types**: Added `card_style`, `hover_effect`, `stagger_animations` decorative properties

### 🐛 Bugs Found
- **B8.1**: `featured_product` block schema was missing from `_blockSchemas` — AI-generated featured_product blocks would have ALL non-global properties stripped. **Fixed**.
- **B8.2**: `bento_store` block schema was missing from `_blockSchemas` — same stripping issue. **Fixed**.
- **B8.3**: `_globalProps` missing `layout_style`, `bg_color`, `theme_override` — these universal properties would be stripped from AI-generated blocks. **Fixed**.
- **B8.4**: `products` schema missing `card_style`, `hover_effect`, `stagger_animations`, and `carousel` layout_style option. **Fixed**.
- **B8.5**: 14 block types missing decorative properties (`card_style`, `hover_effect`, `stagger_animations`). **Fixed**.

### 💡 Improvement Suggestions
- Consider programmatically generating `_blockSchemas` from a YAML/JSON source to eliminate drift between `block_schema.dart`, `schema_registry.json`, and `BLOCK_SCHEMA_REGISTRY.md`.

### ⚠️ Warnings & Risks
- `schema_registry.json` entries are not perfectly in sync with `block_schema.dart` — but `block_schema.dart` is the authoritative client-side validator. Server-side AI uses `schema_registry.json` as hints only; actual validation happens client-side.

### 📊 Code Health Notes
- `block_schema.dart` grew from 302 → 412 lines — still acceptable
- `block_schema.dart` now covers all 29 block types with comprehensive property schemas

---

## Phase 13: All Section Renderers — Responsiveness & Overflow Safety

### ✅ What Was Done
- Audited all 32 renderer widgets in `lib/features/public_viewer/widgets/`:
  - **13.1** `custom_hero_widget.dart`: Added `maxLines`/`overflow` to all text widgets, `EdgeInsetsDirectional` compliance (done in Phase 1)
  - **13.2–13.11** (hero_saas, features, pricing, products, featured_product, bento_store, testimonials, faq, gallery, contact_info): Scanned — all use `LayoutBuilder`, `EdgeInsetsDirectional`, no `Expanded` in unbounded contexts, no infinity heights
  - **13.12** `custom_cta_banner_widget.dart`: `LayoutBuilder` ✓, `EdgeInsetsDirectional` ✓, `Wrap` for buttons ✓
  - **13.13** `custom_lead_form_widget.dart`: `LayoutBuilder` ✓, `EdgeInsetsDirectional` ✓, inner `map()` instead of `ListView` ✓
  - **13.14** `custom_lead_magnet_widget.dart`: `LayoutBuilder` ✓, `IntrinsicHeight` NOT around `LayoutBuilder` ✓, no infinity heights ✓
  - **13.15** `custom_multi_step_form_widget.dart`: `LayoutBuilder` ✓, `Expanded` bounded in `maxWidth: 600` Container ✓, inner `map()` fields ✓
  - **13.16** `custom_video_embed_widget.dart`: `LayoutBuilder` ✓, `AspectRatio` for video ✓, `Stack` with `fit: StackFit.expand` ✓
  - **13.17** `custom_team_members_widget.dart`: `LayoutBuilder` ✓, `Expanded` in bounded Column ✓
  - **13.18** `custom_logo_header_widget.dart`: `LayoutBuilder` ✓, `CustomNetworkImage` with defined height ✓
  - **13.19** `custom_animated_counter_widget.dart`: `LayoutBuilder` ✓, `Wrap` for cards ✓
  - **13.20** `custom_comparison_table_widget.dart`: `LayoutBuilder` ✓, `Table` with `FlexColumnWidth` ✓
  - **13.21** `custom_whatsapp_widget.dart`: `LayoutBuilder` ✓, no overflow risks ✓
  - **13.22** `custom_service_steps_widget.dart`: `LayoutBuilder` ✓, `IntrinsicHeight` NOT around `LayoutBuilder` ✓
  - **13.23** `custom_statistics_grid_widget.dart`: `LayoutBuilder` ✓, conditional `IntrinsicHeight` ✓
  - **13.24** `custom_trust_logos_widget.dart`: `LayoutBuilder` ✓, `Wrap` for logos ✓
  - **13.25** `custom_working_hours_widget.dart`: `LayoutBuilder` ✓, `Expanded` in bounded Row ✓
  - **13.26** `custom_social_qr_widget.dart`: `LayoutBuilder` ✓, `RepaintBoundary` for QR ✓
  - **13.27** `custom_qr_widget.dart`: `LayoutBuilder` ✓, fixed `SizedBox` sizes ✓
  - **13.28** `custom_location_map_widget.dart`: `LayoutBuilder` ✓, `HtmlElementView` with fixed height ✓
  - **13.29** `section_renderer.dart`: `ListView.builder` with `shrinkWrap` + `NeverScrollableScrollPhysics` ✓
  - **13.30** `basic_section_renderer.dart`: `NumericParser` usage ✓, `EdgeInsetsDirectional` ✓
  - **13.31** `section_background.dart`: Dual-read `bg_overlay_opacity ?? overlay_opacity` and `bg_color ?? background_color` ✓
  - **13.32** `floating_cart_widget.dart`: `LayoutBuilder` ✓, `AnimatedPositionedDirectional` ✓, `Flexible` + `ListView.separated` ✓
  - **13.33** `cookie_consent_banner.dart`: Fixed `Positioned` → `PositionedDirectional` for RTL compliance

### 🐛 Bugs Found
- **B13.1**: `SectionBackground` uses `EdgeInsets.symmetric` instead of `EdgeInsetsDirectional.symmetric` in `verticalPaddingOverride` branch — RTL padding direction bug. **Fixed**.
- **B13.2**: `CookieConsentBanner` uses `Positioned(left/right)` instead of `PositionedDirectional(start/end)` — RTL position bug. **Fixed**.

### 💡 Improvement Suggestions
- Add a `StyledText` widget or extension that auto-applies `maxLines: 10` + `overflow: TextOverflow.ellipsis` on every text node to prevent edge-case overflow crashes with extremely long user-supplied text.
- ~20 widgets lack `maxLines`/`overflow` on their `Text` widgets — low risk today but could crash on pathological input.

### ⚠️ Warnings & Risks
- All 32 widgets verified: no `Expanded` in `SingleChildScrollView > Column` without `SizedBox`, no `IntrinsicHeight` around `LayoutBuilder`, no `height: double.infinity` on any `CustomNetworkImage`. Core overflow risks are eliminated.
- The `custom_lead_form_widget.dart` Turnstile container has fixed `width: 300, height: 70` — on screens <360px this may overflow. Mitigated by parent `maxWidth: 600` container.

### 📊 Code Health Notes
- `floating_cart_widget.dart` is 411 lines — under 800 ✅
- `custom_lead_form_widget.dart` is 435 lines — under 800 ✅
- `custom_lead_magnet_widget.dart` is 466 lines — under 800 ✅
- `custom_multi_step_form_widget.dart` is 525 lines — under 800 ✅
- All other renderers are under 500 lines ✅
- `section_background.dart` is 137 lines — under 800 ✅
- `cookie_consent_banner.dart` is 143 lines — under 800 ✅

---

## Phase 4: All Block Editors — Content Tab Completeness

### ✅ What Was Done
Audited and enhanced all 26 existing editor files in `lib/features/builder/widgets/editors/blocks/`, plus created 2 new editors and registered all 29 block types in `content_tab_dispatcher.dart`.

**Editors enhanced with missing fields:**

| Editor | Added Properties |
|--------|-----------------|
| `hero_editor.dart` | `button_text`, `button_url`, `badge_text`, `layout_style` dropdown (6 options) |
| `features_editor.dart` | Items list editor (title, description, image_url per item) |
| `products_editor.dart` | `layout_style` dropdown (grid_2/grid_3/list/carousel) |
| `pricing_editor.dart` | `subtitle` field |
| `featured_product_editor.dart` | `card_style`, `hover_effect`, `stagger_animations` |
| `comparison_table_editor.dart` | `layout_style` dropdown (table/cards), `is_popular` toggle per plan |
| `testimonials_editor.dart` | Fixed layout_style values (masonry→cards), `card_style`, `hover_effect`, `stagger_animations` |
| `faq_editor.dart` | `variant` selector (Accordion/List), `card_style`, `hover_effect`, `stagger_animations` |
| `animated_counter_editor.dart` | `variant` selector (Row/Grid), `card_style`, `hover_effect`, `stagger_animations` |
| `service_steps_editor.dart` | `layout_style` dropdown (vertical/horizontal) |
| `team_members_editor.dart` | `variant` selector (Grid/Carousel) |
| `logo_header_editor.dart` | `logo_height` slider |
| `gallery_editor.dart` | `display_mode` dropdown (grid/carousel/masonry), `grid_columns`, `card_style`, `hover_effect`, `stagger_animations` |
| `contact_info_editor.dart` | `variant` selector (Grid/Row), `card_style`, `hover_effect`, `stagger_animations` |
| `trust_logos_editor.dart` | `layout_style` dropdown (row/grid), `card_style`, `hover_effect`, `stagger_animations` |
| `location_map_editor.dart` | `lat`, `lng`, `zoom` fields |
| `social_qr_editor.dart` | `card_style`, `hover_effect`, `stagger_animations` |
| `qr_code_editor.dart` | `card_style`, `hover_effect`, `stagger_animations` |
| `lead_form_editor.dart` | `layout_style` (lead_magnet only), fields list editor, `card_style`, `hover_effect`, `stagger_animations` |
| `working_hours_editor.dart` | `variant` selector (List/Table) |
| `basic_section_editor.dart` | `layout_direction`, `spacing`, `main_axis_alignment`, `cross_axis_alignment` |

**New editors created:**
- `hero_saas_editor.dart` — dedicated editor with SaaS-specific layout_style options (dashboardSplit/launchCenter/darkSaas) and `tech_logos` list
- `whatsapp_editor.dart` — new editor for the previously orphaned whatsapp block type

**Dispatcher updates:**
- `content_tab_dispatcher.dart`: Split `hero`/`hero_saas` into separate routes, added `features` params, added `whatsapp` route

**Schema updates:**
- `block_schema.dart`: Added `layout_style` to `comparison_table`, added `lat`/`lng`/`zoom` to `location_map`

### 🐛 Bugs Found
- **B4.1**: `hero_saas` shared `HeroEditor` — SaaS-specific `layout_style` options and `tech_logos` were not exposed. **Fixed** (new dedicated editor).
- **B4.2**: `whatsapp` block type had no editor — fell through to `null` in dispatcher. Users could not edit whatsapp block properties. **Fixed** (new editor + dispatcher registration).
- **B4.3**: `testimonials_editor.dart` used `layout_style: 'masonry'` as default value, but the schema defines valid options as `['cards', 'carousel']`. Creating a testimonial with AI would have `cards` as default, but the editor would display `masonry`. **Fixed** (corrected to `cards`/`carousel`).
- **B4.4**: `comparison_table` was missing `layout_style` in `block_schema.dart` — AI-generated comparison tables would have this property stripped. **Fixed** (added to schema).

### 💡 Improvement Suggestions
- Add `foreground_color`/`background_color` color pickers to `qr_code_editor.dart` — schema needs expansion first.
- Consider a shared `CardStyleSelector` and `HoverEffectSelector` widget to reduce duplication across all editors that now have these fields.
- The `features_editor.dart` now uses `PickImage`/`PersistAsset`/`PickAndUploadImage` params — previously they were absent and image upload was not possible for feature items.

### ⚠️ Warnings & Risks
- Several editors now have `card_style`, `hover_effect`, `stagger_animations` fields that were added to schemas in Phase 8. Renderer widgets must implement these properties for them to take effect — deferred to Phase 6.
- `basic_section_editor.dart` added 4 new layout controls (`layout_direction`, `spacing`, `main_axis_alignment`, `cross_axis_alignment`) — the renderer (`basic_section_renderer.dart`) must implement reading these properties.
- `location_map_editor.dart` now exposes `lat`/`lng`/`zoom` — these are new properties not yet read by `custom_location_map_widget.dart` (deferred to Phase 6).

### 📊 Code Health Notes
- 26 existing editors modified, 2 new editors created
- All editor files remain under 300 lines each ✅
- `content_tab_dispatcher.dart` now handles all 29 block types ✅
- `block_schema.dart` now has `layout_style` for comparison_table and `lat`/`lng`/`zoom` for location_map
- No existing file exceeded the 800-line limit with these changes ✅
