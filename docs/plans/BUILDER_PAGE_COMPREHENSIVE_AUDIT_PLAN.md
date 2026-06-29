# 🏗️ LandyMaker Builder Page — Comprehensive Audit & Improvement Plan

**Document Version**: 2.0
**Created**: 2026-06-30
**Scope**: Full audit of the Builder Page — widgets, bottom sheets, editors, AI Agent capabilities, section layouts/variants, responsiveness, UI/UX, and shared block properties.

---

## ⚠️ HOW TO USE THIS PLAN (READ FIRST)

This plan is executed by an AI model across multiple sessions. To never lose progress:

1. **Before starting ANY work**: Read `docs/reports/BUILDER_AUDIT_PROGRESS.md` to find your exact resume point.
2. **After completing EACH sub-task** (e.g., task 1.1): Immediately update `docs/reports/BUILDER_AUDIT_PROGRESS.md`.
3. **After completing EACH full phase**: Mark the phase checkbox `[x]` in THIS file, then update the progress file.
4. **The progress file is your single source of truth** — it contains your resume point, key findings so far, and files already read.

---

## 📚 Required Reading (Before ANY Implementation)

- `[ ]` Read `docs/ai/AI_CONTEXT.md`
- `[ ]` Read `docs/ai/AI_DOCUMENTATION_RULES.md` — ALL 41 rules. Non-negotiable.
- `[ ]` Read `docs/ai/BUILDER_ARCHITECTURE.md`
- `[ ]` Read `docs/ai/BLOCK_SCHEMA_REGISTRY.md`
- `[ ]` Read `docs/ai/THEME_SYSTEM.md`
- `[ ]` Read `lib/features/builder/README.md`
- `[ ]` Read `lib/features/public_viewer/README.md`

---

## 📝 Output Files

| File | Purpose |
|------|---------|
| `docs/reports/BUILDER_AUDIT_PROGRESS.md` | **Resume checkpoint** — updated after EVERY sub-task. Read this first on resume. |
| `docs/reports/builder_audit_report.md` | **Full report** — append-only. Never overwrite. Add a section per phase. |

### Report Structure (per phase in `builder_audit_report.md`)
```
## Phase N: [Title]
### ✅ What Was Done
### 🐛 Bugs Found
### 💡 Improvement Suggestions
### ⚠️ Warnings & Risks
### 📊 Code Health Notes
```

---

## Plan Overview

| # | Phase | Priority | Status |
|---|-------|----------|--------|
| 1 | Font Picker Bug | CRITICAL | `[ ]` |
| 2 | Color Palette Picker Bug | CRITICAL | `[ ]` |
| 3 | Block Design Settings — Universal Properties | CRITICAL | `[ ]` |
| 4 | All Block Editors — Content Tab Completeness | CRITICAL | `[ ]` |
| 5 | Hero Section — Multiple Layout Variants | HIGH | `[ ]` |
| 6 | All Other Sections — Variants Completeness | HIGH | `[ ]` |
| 7 | AI Agent — Theme & Global Page Properties | CRITICAL | `[ ]` |
| 8 | AI Agent — Section Properties (All 29 Types) | CRITICAL | `[ ]` |
| 9 | AI Agent — Layout Diversity & Creativity | HIGH | `[ ]` |
| 10 | Section Library Modal — UI/UX & Variants | MEDIUM | `[ ]` |
| 11 | Builder Desktop — UI/UX Issues | HIGH | `[ ]` |
| 12 | Builder Mobile — UI/UX Issues | HIGH | `[ ]` |
| 13 | All Section Renderers — Responsiveness | CRITICAL | `[ ]` |
| 14 | Bottom Sheets — UI/UX Consistency | HIGH | `[ ]` |
| 15 | Documentation Sync | MEDIUM | `[ ]` |

**Recommended Execution Order**: 1 → 2 → 3 → 7 → 8 → 13 → 4 → 5 → 6 → 9 → 11 → 12 → 14 → 10 → 15

---

## Phase 1: Font Picker Bug `[ ]`

### Context
Rule #34: The font picker in `DesignFontsTab` MUST use `BlocBuilder<BuilderThemeCubit, LandingPageTheme>`. User reports **changing the font does not work**.

### Files to Read for This Phase
- `lib/features/builder/widgets/tabs/design_fonts_tab.dart`
- `lib/features/builder/controllers/builder_theme_cubit.dart`
- `lib/features/builder/controllers/builder_cubit.dart`
- `lib/features/builder/models/landing_page_theme.dart`
- `lib/features/public_viewer/widgets/custom_hero_widget.dart`
- `lib/core/services/dynamic_font_service.dart`

### Tasks

- `[ ]` **1.1** — Verify `DesignFontsTab` uses `BlocBuilder<BuilderThemeCubit, LandingPageTheme>` (not `LandingPageBuilderCubit`). Verify `_buildFontPicker()` reads `theme.defaultFont` from `LandingPageTheme`. Verify tapping a font calls `themeCubit.updateThemeProperty('defaultFont', family)`.

- `[ ]` **1.2** — In `builder_cubit.dart` / mixins, find the `StreamSubscription` on `BuilderThemeCubit.stream`. Verify `defaultFont` is synced into `BuilderLoaded.theme`. Verify `_suppressHistoryFromTheme` guard is present. Verify `DynamicFontService.loadFont(family, [400, 700])` is called before applying font to canvas.

- `[ ]` **1.3** — In `custom_hero_widget.dart` and 3+ other renderers, verify `theme?.defaultFont` is applied to text styles. Check `SectionRenderer` passes the `theme` object. Check `SectionBackground` propagates `defaultFont` correctly.

- `[ ]` **1.4** — Fix all bugs found in tasks 1.1–1.3. Do NOT change font picker UI — fix logic only.

- `[ ]` **1.5** — Append `## Phase 1: Font Picker Bug` section to `docs/reports/builder_audit_report.md`.

- `[ ]` **1.6** — Update `docs/reports/BUILDER_AUDIT_PROGRESS.md`: mark Phase 1 done, record key findings, set next task to `2.1`.

---

## Phase 2: Color Palette Picker Bug `[ ]`

### Context
User reports **changing the color palette does not work**. The palette is applied via `BuilderThemeCubit`. `DesignColorsTab` has both a palette list and custom color pickers.

### Files to Read for This Phase
- `lib/features/builder/widgets/tabs/design_colors_tab.dart`
- `lib/features/builder/controllers/builder_theme_cubit.dart`
- `lib/features/builder/models/landing_page_theme.dart`
- `lib/features/builder/widgets/tabs/design_tab.dart`
- `lib/features/builder/screens/builder_workspace_screen.dart`
- `lib/features/public_viewer/widgets/custom_hero_widget.dart`

### Tasks

- `[ ]` **2.1** — In `_buildPalettesList()`, verify: `ListTile.onTap` reads `context.read<BuilderThemeCubit>()` (NOT `widget.cubit`). Verify `palette.copyWith(defaultFont: state.theme.defaultFont)` preserves font. Verify `context.read<BuilderThemeCubit>().updateTheme(newTheme)` is called.

- `[ ]` **2.2** — **KNOWN BUG**: `_buildPalettesList()` uses `BlocBuilder<LandingPageBuilderCubit, BuilderState>` to read `state.theme.name` to detect active palette. There may be a lag/mismatch if `BuilderLoaded.theme` is not synced fast enough from `BuilderThemeCubit`. Investigate and fix if confirmed.

- `[ ]` **2.3** — In `_showColorPicker()`: Find and fix the duplicate `Colors.green` (appears twice in the preset list). Replace second occurrence with a distinct color (e.g., `Colors.indigo` or `const Color(0xFF0EA5E9)`).

- `[ ]` **2.4** — Verify `overlay_opacity` vs `bg_overlay_opacity` dual-write in `block_design_settings.dart` lines ~241–243. Check that all public viewer widgets read `bg_overlay_opacity` as primary (with `overlay_opacity` as fallback). Fix any renderer reading only one key.

- `[ ]` **2.5** — In `builder_cubit.dart`, verify the `StreamSubscription` on `_themeCubit.stream` syncs the full theme (all color fields) into `BuilderLoaded.theme` via `_emitDirty(...)`.

- `[ ]` **2.6** — Fix all bugs found. Verify palette changes are reflected on the canvas.

- `[ ]` **2.7** — Append `## Phase 2: Color Palette Picker Bug` to report. Update progress file.

---

## Phase 3: Block Design Settings — Universal Properties `[ ]`

### Context
Every block supports these **Universal Properties** (from `BLOCK_SCHEMA_REGISTRY.md`): `bg_color`, `bg_image_url`, `bg_overlay_opacity`, `bg_overlay_color`, `bg_blur`, `theme_override`, `vertical_padding`, `is_visible`, `animation`, `fontFamily`, `card_layout_mode`. The `BlockDesignSettings` widget must expose ALL of them with working UI controls.

### Files to Read for This Phase
- `lib/features/builder/widgets/editors/block_design_settings.dart`
- `lib/features/builder/widgets/editors/blocks/editor_utils.dart`
- `lib/features/builder/models/landing_page_theme.dart`
- `lib/core/widgets/section_background.dart`

### Tasks

- `[ ]` **3.1** — Read `block_design_settings.dart` fully. Build a presence/absence table for every universal property control. Record findings in progress file.

- `[ ]` **3.2** — **ADD** `bg_overlay_color` color picker: Place between `bg_image_url` and the overlay opacity slider. Use `showBlockColorPicker(context, cubit, index, 'bg_overlay_color', ...)` from `editor_utils.dart`.

- `[ ]` **3.3** — **ADD** `bg_blur` slider: Range `0.0`–`20.0`. Label `'تمويه الخلفية'`. Place after overlay opacity slider. Calls `cubit.updateBlockProperty(index, 'bg_blur', val)`.

- `[ ]` **3.4** — **ADD** `card_layout_mode` dropdown/toggle with options `['auto', 'equal']`. Label: `'طريقة توزيع البطاقات'`. Only show for types: `features`, `pricing`, `testimonials`, `products`, `faq`, `team_members`, `animated_counter`, `statistics_grid`, `contact_info`, `trust_logos`. Use a `const Set<String>` guard.

- `[ ]` **3.5** — Verify `bg_color` / `background_color` read is consistent: `block['bg_color'] ?? block['background_color']`. Check `SectionBackground` to confirm it reads both keys.

- `[ ]` **3.6** — Verify `overlay_opacity` vs `bg_overlay_opacity` read in `SectionBackground` — it should read both for backward compat: `block['bg_overlay_opacity'] ?? block['overlay_opacity']`.

- `[ ]` **3.7** — Add `///` doc comments to every class and public method touched in this phase.

- `[ ]` **3.8** — Append `## Phase 3` to report. Update progress file.

---

## Phase 4: All Block Editors — Content Tab Completeness `[ ]`

### Context
Every `*_editor.dart` in `lib/features/builder/widgets/editors/blocks/` must expose all key properties for its block type per `BLOCK_SCHEMA_REGISTRY.md`. `title` is handled by `block_properties_editor.dart` — do NOT duplicate it in any editor.

### Files to Read for This Phase
- `lib/features/builder/widgets/editors/content_tab_dispatcher.dart`
- `lib/features/builder/ai/block_schema.dart`
- `docs/ai/BLOCK_SCHEMA_REGISTRY.md`
- Each `*_editor.dart` file listed below (read each before editing it)

### Tasks — Hero & Core Sections

- `[ ]` **4.1** — **`hero_editor.dart`**: Add `button_text` (TextField), `button_url` (TextField), `layout_style` dropdown (`standard`, `split`, `centered`, `glass`, `fullWidthBg`, `minimal`), `badge_text` (TextField, for the premium tag). Do NOT add `title` — it's handled by the parent.

- `[ ]` **4.2** — **`hero_saas`**: Check if `hero_saas_editor.dart` exists. If not, create it. Add: `subtitle`, `badge_text`, `button_text`, `button_url`, `image_url`, `layout_style` dropdown (`dashboardSplit`, `launchCenter`, `darkSaas`). Register it in `content_tab_dispatcher.dart`.

- `[ ]` **4.3** — **`features_editor.dart`**: Add `layout_style` dropdown (`grid`/`bento`) and items list with `{title, description, image_url, link_url}` if missing.

### Tasks — Commerce Editors

- `[ ]` **4.4** — **`products_editor.dart`**: Verify `layout_style` (`grid_2`, `grid_3`, `list`, `carousel`), `mobile_columns`, `card_style`, `hover_effect` are all present.

- `[ ]` **4.5** — **`pricing_editor.dart`**: Verify `variant` selector (Grid/Row/Table) and all item fields are present.

- `[ ]` **4.6** — **`featured_product_editor.dart`**: Verify `layout_style` (`split`, `centered`, `reversed`) is present.

- `[ ]` **4.7** — **`bento_store_editor.dart`**: Verify `layout_style` (`modern`, `tight`, `glass`) and `stagger_animations` toggle.

- `[ ]` **4.8** — **`comparison_table_editor.dart`**: Verify `layout_style` (`table`/`cards`) and `items[].is_popular` toggle.

### Tasks — Content Editors

- `[ ]` **4.9** — **`testimonials_editor.dart`**: Verify `variant` selector (Carousel/Grid/Masonry) and all item fields.

- `[ ]` **4.10** — **`faq_editor.dart`**: Verify items with `question`/`answer` and `variant` selector (Accordion/List).

- `[ ]` **4.11** — **`cta_banner_editor.dart`**: Verify `layout_style` (`simple`/`split`/`centered`), `title`, `subtitle`, `button_text`, `button_url`, `image_url`.

- `[ ]` **4.12** — **`animated_counter_editor.dart`**: Verify `variant` (Row/Grid) and items `{value, suffix, label, icon}`.

- `[ ]` **4.13** — **`service_steps_editor.dart`**: Verify `layout_style` (`vertical`/`horizontal`), steps `{number, title, description, icon}`.

- `[ ]` **4.14** — **`statistics_grid_editor.dart`**: Verify `layout_style` (`grid`/`row`), stats `{label, value, prefix, suffix}`.

- `[ ]` **4.15** — **`team_members_editor.dart`**: Verify `variant` (Grid/Carousel) and member fields.

### Tasks — Media & Contact Editors

- `[ ]` **4.16** — **`logo_header_editor.dart`**: Verify `logo_url`, `alignment` dropdown (`right`/`center`/`left`), `logo_height` slider.

- `[ ]` **4.17** — **`gallery_editor.dart`**: Verify `layout_style` (`grid`/`masonry`/`carousel`) and items `{image_url, caption}`.

- `[ ]` **4.18** — **`contact_info_editor.dart`**: Verify all item fields `{icon, label, value, url}` and `variant` (Grid/Row).

- `[ ]` **4.19** — **`trust_logos_editor.dart`**: Verify `layout_style` (`row`/`grid`) and items `{name, logo_url}`.

- `[ ]` **4.20** — **`location_map_editor.dart`**: Verify `address`, `map_iframe_url`, `lat`, `lng`, `zoom`.

- `[ ]` **4.21** — **`video_embed_editor.dart`**: Verify `url`, `autoplay` toggle, `aspect_ratio`.

- `[ ]` **4.22** — **`social_qr_editor.dart`**: Verify all social URL fields.

- `[ ]` **4.23** — **`qr_code_editor.dart`**: Verify `url`, `size`, `foreground_color`, `background_color`.

### Tasks — Forms Editors

- `[ ]` **4.24** — **`lead_form_editor.dart`**: Verify `fields[]`, `button_text`, `whatsapp_auto_open`, `whatsapp_number`, `whatsapp_message_template`.

- `[ ]` **4.25** — **Lead Magnet**: Find where it's edited (check `content_tab_dispatcher.dart`). Verify `layout_style`, `image_url`, `title`, `subtitle`, `fields[]`, `submit_button_text`, `magnet_title`, `whatsapp_*` fields.

- `[ ]` **4.26** — **`multi_step_form_editor.dart`**: Verify `steps[{title, fields[]}]` and `submit_button_text`.

### Tasks — Other

- `[ ]` **4.27** — **`working_hours_editor.dart`**: Verify days list `{day, open, close, is_closed}` and `variant` (List/Table).

- `[ ]` **4.28** — **`basic_section_editor.dart`**: Verify `html_content`, `text_align`.

- `[ ]` **4.29** — **`whatsapp` block**: Check how it's edited. Add `phone_number`, `message`, `button_text` if a dedicated editor is missing.

- `[ ]` **4.30** — Add `///` doc comments to every modified file.

- `[ ]` **4.31** — Append `## Phase 4` to report. Update progress file.

---

## Phase 5: Hero Section — Multiple Layout Variants `[ ]`

### Context
The Hero section widget supports variants 0–5 and 8, but `layout_picker_panel.dart` defines `gradientOnly` and `fullWidthImage` which have no renderer. `_HeroReverseLayout` is identical to `_HeroSplitLayout`. `_HeroPremiumTag` shows hardcoded branding text on all pages. Image sizing on desktop is inconsistent.

### Files to Read for This Phase
- `lib/features/public_viewer/widgets/custom_hero_widget.dart` (ALL lines)
- `lib/features/builder/widgets/layout_picker/layout_picker_panel.dart` (lines 11–86)
- `lib/features/builder/widgets/modals/section_library/section_data.dart` (lines 44–73)
- `lib/features/builder/widgets/editors/blocks/hero_editor.dart`

### Tasks

- `[ ]` **5.1** — Audit `_effectiveVariant` mapping. Confirm `'gradientOnly'` and `'fullWidthImage'` are missing. Add `case 'gradientOnly': return 6;` and `case 'fullWidthImage': return 7;` to the getter.

- `[ ]` **5.2** — Implement `_HeroGradientOnlyLayout` (variant 6): Gradient background (`primary` → `secondary`) via `LinearGradient` `BoxDecoration`, no content image, `_HeroTextContent` centered. RULES: Use `LayoutBuilder`; no `MediaQuery.size`; no fixed heights; wrap in `ConstrainedBox(minHeight: isMobile ? 300 : 500)`.

- `[ ]` **5.3** — Implement `_HeroFullWidthImageLayout` (variant 7): `Stack` with `Positioned.fill` `CustomNetworkImage(fit: BoxFit.cover)` + `ColorFiltered`/`Opacity` overlay + `_HeroTextContent(alignment: CrossAxisAlignment.center)`. RULES: `ConstrainedBox(minHeight: isMobile ? 300 : 500)`; no `double.infinity` height.

- `[ ]` **5.4** — Fix `_HeroReverseLayout` (variant 5): Implement as a true reverse — image LEFT, text RIGHT on desktop, regardless of RTL direction. Mobile stays stacked.

- `[ ]` **5.5** — Fix `_HeroImage` desktop sizing: Wrap `CustomNetworkImage` in `AspectRatio(aspectRatio: 4/3)` for desktop (when `!props.isMobile`). Keep mobile `height: 300`.

- `[ ]` **5.6** — Fix `_HeroPremiumTag` hardcoded text: Add `badgeText` field to `_HeroProps`. Read it from the block. Only render the tag if `badgeText.isNotEmpty`. Add `badge_text` field to `hero_editor.dart` (after task 4.1).

- `[ ]` **5.7** — Update `section_data.dart`: Add `gradientOnly` and `fullWidthImage` variants to the hero section definition.

- `[ ]` **5.8** — Add `///` doc comments to all touched classes and methods.

- `[ ]` **5.9** — Append `## Phase 5` to report. Update progress file.

---

## Phase 6: All Other Sections — Variants Completeness `[ ]`

### Context
All registered `layout_style` / `variant` values must be implemented in their renderer widgets. Unimplemented variants fall through to the default — silently producing wrong output.

### Files to Read for This Phase
- `lib/features/builder/ai/block_schema.dart` (canonical variants)
- `docs/ai/BLOCK_SCHEMA_REGISTRY.md`
- `lib/features/builder/widgets/layout_picker/layout_picker_panel.dart` (layout picker options per block)
- Each `custom_*_widget.dart` mentioned below

### Implementation Rules for ALL New Variants
- Use `LayoutBuilder` (not `MediaQuery.size`) for `isMobile`
- Use `EdgeInsetsDirectional` (not `EdgeInsets.only(left/right)`)
- Use `PositionedDirectional` (not `Positioned`) for overlay elements
- Use `shrinkWrap: true` + `NeverScrollableScrollPhysics()` for inner lists
- NEVER `IntrinsicHeight` around `LayoutBuilder`
- NEVER `Expanded`/`Flexible` in `SingleChildScrollView > Column` without `SizedBox` height
- Use `NumericParser` for dynamic numeric values

### Tasks

- `[ ]` **6.1** — **`custom_hero_saas_widget.dart`**: Verify `dashboardSplit`, `launchCenter`, `darkSaas` are all implemented. Check `tech_logos` rendering. Implement any missing variants using the Factory Pattern (same as `custom_hero_widget.dart`).

- `[ ]` **6.2** — **`custom_features_widget.dart`**: Verify `grid` and `bento` layouts are both fully implemented and responsive.

- `[ ]` **6.3** — **`custom_pricing_widget.dart`**: Verify variants 0 (Grid), 1 (Row), 2 (Table) are all implemented.

- `[ ]` **6.4** — **`custom_products_widget.dart`**: Verify `grid_2`, `grid_3`, `list`, `carousel` layouts. Check `mobile_columns`, `card_style`, `hover_effect` are read from the block map.

- `[ ]` **6.5** — **`featured_product_widget.dart`**: Verify `split`, `centered`, `reversed` layouts.

- `[ ]` **6.6** — **`bento_store_widget.dart`**: Verify `modern`, `tight`, `glass` layouts.

- `[ ]` **6.7** — **`custom_testimonials_widget.dart`**: Verify Carousel (0), Grid (1), Masonry (2) are all implemented.

- `[ ]` **6.8** — **`custom_faq_widget.dart`**: Verify Accordion (0) and List (1) are both implemented.

- `[ ]` **6.9** — **`custom_gallery_widget.dart`**: Verify `grid`, `masonry`, `carousel` layouts.

- `[ ]` **6.10** — **`custom_contact_info_widget.dart`**: Verify Grid (0) and Row (1) layouts.

- `[ ]` **6.11** — **`custom_cta_banner_widget.dart`**: Verify `simple`, `split`, `centered` layouts.

- `[ ]` **6.12** — **`custom_lead_magnet_widget.dart`**: Verify `split` and `centered` layouts.

- `[ ]` **6.13** — **`custom_working_hours_widget.dart`**: Verify List (0) and Table (1) layouts.

- `[ ]` **6.14** — **`custom_animated_counter_widget.dart`**: Verify Row (0) and Grid (1) layouts.

- `[ ]` **6.15** — **`custom_service_steps_widget.dart`**: Verify `vertical` and `horizontal` layouts.

- `[ ]` **6.16** — **`custom_statistics_grid_widget.dart`**: Verify `grid` and `row` layouts.

- `[ ]` **6.17** — **`custom_team_members_widget.dart`**: Verify Grid (0) and Carousel (1) layouts.

- `[ ]` **6.18** — **`custom_trust_logos_widget.dart`**: Verify `row` and `grid` layouts.

- `[ ]` **6.19** — **`custom_comparison_table_widget.dart`**: Verify `table` and `cards` layouts.

- `[ ]` **6.20** — Add `///` doc comments to all modified files.

- `[ ]` **6.21** — Append `## Phase 6` to report. Update progress file.

---

## Phase 7: AI Agent — Theme & Global Page Properties Coverage `[ ]`

### Context
The AI agent (Edge Function `ai-page-generate`) must be able to set AND update ALL global theme properties. Suspected issue: the AI returns a `theme` object but `AIGenerationCubit` may not apply it to `BuilderThemeCubit`.

### Files to Read for This Phase
- `lib/features/builder/controllers/ai_generation_cubit.dart` (ALL 593 lines)
- `lib/features/builder/controllers/builder_cubit.dart`
- `lib/features/builder/controllers/builder_cubit_blocks.dart` (find `applyDesignJson`)
- `lib/features/builder/ai/ai_response_validator.dart`
- `lib/features/builder/models/landing_page_theme.dart`
- `supabase/functions/shared/schema_registry.json`

### Tasks

- `[ ]` **7.1** — In `ai_generation_cubit.dart`, after receiving `data['designJson']`, check if `validatedDesign['theme']` is extracted and applied to `BuilderThemeCubit`. If not, add the application logic. Note: verify `BuilderThemeCubit` is accessible from this cubit (check constructor).

- `[ ]` **7.2** — In `builder_cubit_blocks.dart` (or whichever file has `applyDesignJson`): verify it reads `design['theme']` and calls `_themeCubit.replaceTheme(LandingPageTheme.fromJson(...))`. If missing, add it. Ensure `_suppressHistoryFromTheme` guard is respected.

- `[ ]` **7.3** — In `ai_response_validator.dart`: verify the validator does NOT strip these page-level keys: `theme`, `meta_title`, `meta_description`, `cookie_consent`, `sticky_cta`, `ga_tracking_id`, `pixel_id`. Fix if any are being dropped.

- `[ ]` **7.4** — In `supabase/functions/shared/schema_registry.json`: verify `ThemeModel` section includes ALL properties: `primary`, `secondary`, `background`, `textPrimary`, `textSecondary`, `buttonTextColor`/`button_text_color`, `defaultFont`/`font_family`, `globalBgImageUrl`, `globalBgColorHex`, `name`. Add any missing ones.

- `[ ]` **7.5** — Add `///` doc comments to all modified files.

- `[ ]` **7.6** — Append `## Phase 7` to report. Update progress file.

---

## Phase 8: AI Agent — Section Properties Coverage (All 29 Types) `[ ]`

### Context
The AI must be able to set EVERY property of EVERY section type, including universal properties. We verify: `block_schema.dart` (client-side validator), `schema_registry.json` (server-side AI schema), and `AIResponseValidator`.

### Files to Read for This Phase
- `lib/features/builder/ai/block_schema.dart` (ALL 302 lines)
- `lib/features/builder/ai/ai_response_validator.dart`
- `supabase/functions/shared/schema_registry.json`
- `docs/ai/BLOCK_SCHEMA_REGISTRY.md`

### Tasks

- `[ ]` **8.1** — In `block_schema.dart`, verify `_globalProps` has ALL universal props: `type`, `title`, `variant`, `layout_style`, `fontFamily`, `bg_color`, `bg_image_url`, `bg_overlay_color`, `bg_overlay_opacity`, `overlay_opacity`, `bg_blur`, `is_visible`, `vertical_padding`, `animation`, `card_layout_mode`, `theme_override`. Add any missing ones.

- `[ ]` **8.2** — In `_blockSchemas`, verify hero has: `subtitle`, `image_url`, `button_text`, `button_url`, `layout_style`, `badge_text`. Add `badge_text` if missing.

- `[ ]` **8.3** — In `_blockSchemas`, verify `hero_saas` has: `subtitle`, `badge_text`, `image_url`, `button_text`, `button_url`, `layout_style`, `tech_logos`. Add any missing.

- `[ ]` **8.4** — In `_blockSchemas`, verify `lead_form` and `lead_magnet` have: `whatsapp_auto_open`, `whatsapp_number`, `whatsapp_message_template`. Add if missing.

- `[ ]` **8.5** — In `_blockSchemas`, verify `products` has: `mobile_columns`, `card_style`, `hover_effect`. Add if missing.

- `[ ]` **8.6** — In `_blockSchemas`, verify `logo_header` has: `logo_height`, `alignment`. Add if missing.

- `[ ]` **8.7** — Scan ALL 29 block type entries in `_blockSchemas`. Cross-reference with `BLOCK_SCHEMA_REGISTRY.md`. Add any missing properties. Record ALL gaps found in the report.

- `[ ]` **8.8** — In `ai_response_validator.dart`: if it uses a property whitelist, verify it includes ALL universal properties (`bg_color`, `theme_override`, `bg_blur`, `card_layout_mode`, `layout_style`, `badge_text`, etc.). Fix any whitelist gaps.

- `[ ]` **8.9** — In `schema_registry.json`: verify it has entries for all 29 block types. For each entry, verify all key properties are listed. Note any missing block types or properties in the report.

- `[ ]` **8.10** — Add `///` doc comments to all modified files.

- `[ ]` **8.11** — Append `## Phase 8` to report. Update progress file.

---

## Phase 9: AI Agent — Layout Diversity & Creativity `[ ]`

### Context
AI-generated pages always look similar. The AI must know all layout options and be instructed to vary them.

### Files to Read for This Phase
- `supabase/functions/ai-page-generate/index.ts` (or the main Edge Function file — find the system prompt)
- `supabase/functions/shared/schema_registry.json`
- `lib/features/builder/registries/template_registry_saas.dart`
- `lib/features/builder/registries/template_registry_services.dart`
- `lib/features/builder/registries/template_registry_ecommerce.dart`

### Tasks

- `[ ]` **9.1** — Open the `ai-page-generate` Edge Function. Find the system prompt string. Read it fully. Record what `layout_style` / `variant` instructions (if any) it currently contains.

- `[ ]` **9.2** — In `schema_registry.json`, for each block type that has layout variants, add an explicit `allowedLayoutStyles` array (e.g., `"allowedLayoutStyles": ["standard", "split", "centered", "glass", "fullWidthBg", "minimal", "gradientOnly", "fullWidthImage"]` for hero).

- `[ ]` **9.3** — Update the AI system prompt to add layout diversity instructions:
  - "Vary `layout_style` values — do not default to `standard` or `split` every time."
  - "Never use the same `layout_style` for two hero sections in the same page."
  - "Alternate between `grid` and `bento` for features sections."
  - "Avoid the cliche `logo_header > hero > features > cta_banner` pattern unless explicitly requested."
  - "Every page must have a distinct visual identity via `theme`, `bg_color`, and `bg_image_url` on key sections."

- `[ ]` **9.4** — For each block type in `schema_registry.json`, add `ai_intent`, `ai_when_to_use`, and optionally `ai_avoid_when` fields. Mirror values from `section_data.dart`'s `aiRole` / `aiWhenToUse`.

- `[ ]` **9.5** — Read the template registries. Note any patterns that can help the AI understand section diversity. Record in report.

- `[ ]` **9.6** — Append `## Phase 9` to report. Update progress file.

---

## Phase 10: Section Library Modal — UI/UX & Variant Accuracy `[ ]`

### Context
The Section Library Modal (`section_library_modal.dart` + 3 part files) is how users add sections. Each section can have multiple variants with dual mini-previews.

### Files to Read for This Phase
- `lib/features/builder/widgets/modals/section_library_modal.dart`
- `lib/features/builder/widgets/modals/section_library/section_data.dart` (ALL 806 lines)
- `lib/features/builder/widgets/modals/section_library/section_variant_card.dart`
- `lib/features/builder/widgets/modals/section_library/dual_mini_preview.dart`

### Tasks

- `[ ]` **10.1** — In `section_data.dart`, verify ALL 29 block types from `BlockRegistry` have an entry. List missing types in report. Add minimal entries with at least one variant for any missing types (focus on: `qr_code`, `social_qr`, `video_embed`, `location_map`, `whatsapp`).

- `[ ]` **10.2** — For each section's `variants` list, verify the `layout_style` / variant key matches what the renderer actually accepts. Fix any mismatches (e.g., a variant calling `'image_backdrop'` when the renderer expects `'fullWidthBg'`).

- `[ ]` **10.3** — After Phase 5: Add `gradientOnly` and `fullWidthImage` hero variants to `section_data.dart`.

- `[ ]` **10.4** — In `dual_mini_preview.dart`: verify all section renders inside the preview are wrapped in `RepaintBoundary`. Check for overflow/render errors in complex section previews (social_qr, products, etc.).

- `[ ]` **10.5** — Verify the category filter chips scroll horizontally on narrow screens. Verify the selected category has a clear visual highlight. Verify search filters correctly.

- `[ ]` **10.6** — Append `## Phase 10` to report. Update progress file.

---

## Phase 11: Builder Desktop — UI/UX Issues `[ ]`

### Files to Read for This Phase
- `lib/features/builder/screens/builder_workspace_screen.dart` (ALL 812 lines)
- `lib/features/builder/widgets/organisms/builder_app_bar.dart` (ALL 611 lines)
- `lib/features/builder/widgets/organisms/builder_sidebar.dart`
- `lib/features/builder/widgets/organisms/builder_canvas.dart`
- `lib/features/builder/widgets/molecules/section_toolbar_overlay.dart`

### Tasks

- `[ ]` **11.1** — **AppBar**: Verify `onShowFonts` opens specifically the fonts section (not a generic design modal). Separate these callbacks if conflated.

- `[ ]` **11.2** — **AppBar**: Verify `state.hasUnsavedChanges` shows a clear visual indicator (dot, label, or color change on save button).

- `[ ]` **11.3** — **AppBar**: Verify desktop/mobile preview toggle buttons update `_previewMode` correctly. Verify the active mode button is highlighted. Verify the canvas constrains width correctly for `PreviewMode.mobile` on desktop.

- `[ ]` **11.4** — **Sidebar**: Verify switching between tabs is smooth. Verify `BlockPropertiesEditor` shows when a block is selected. Verify returning to tab view after done editing is seamless.

- `[ ]` **11.5** — **Canvas**: In `builder_canvas.dart`, verify each section is wrapped in `RepaintBoundary`. Verify `SectionToolbarOverlay` does not cause excessive rebuilds.

- `[ ]` **11.6** — **Back Navigation**: Verify `_setupBrowserWarning()` works with `html.window.onBeforeUnload`. Verify both `_onWillPop()` and `_handleBack()` dialogs are consistent in copy and actions.

- `[ ]` **11.7** — Append `## Phase 11` to report. Update progress file.

---

## Phase 12: Builder Mobile — UI/UX Issues `[ ]`

### Files to Read for This Phase
- `lib/features/builder/widgets/molecules/builder_mobile_toolbar.dart` (ALL 314 lines)
- `lib/features/builder/screens/builder_workspace_screen.dart` (mobile layout section)
- `lib/features/builder/widgets/organisms/builder_canvas.dart`
- `lib/core/widgets/draggable_modal_sheet.dart`

### Tasks

- `[ ]` **12.1** — **Toolbar Layout**: Verify all action buttons fit on a single row without overflow. On screens <360px wide, check for overflow. If too many buttons, group less-used actions under a "More" button.

- `[ ]` **12.2** — **Preview Toggle**: Verify mobile preview toggle is present. Verify `PreviewMode.mobile` is default on mobile (per Rule #35). Verify canvas `isMobile` reflects `_previewMode` correctly.

- `[ ]` **12.3** — **Edit Bottom Sheet**: Verify `initialChildSize: 0.8` shows editor tabs without clipping. Verify "Close" button works. Verify "Delete" button follows Rule #33 (AlertDialog, `barrierDismissible: false`, calls `cubit.deleteBlock()` then `widget.onDone()`).

- `[ ]` **12.4** — **Design Menu**: Verify the design menu bottom sheet is fully scrollable and shows palette, custom colors, and fonts in one scrollable column.

- `[ ]` **12.5** — **Keyboard Avoidance**: Verify that focusing a text field inside a bottom sheet pushes the sheet up to avoid the keyboard.

- `[ ]` **12.6** — **AI Chat Mobile**: Verify the chat modal fills the screen. Verify loading indicators use `CubeLoader` (NOT `CircularProgressIndicator` — Rule #40). Verify text input is not obscured by keyboard.

- `[ ]` **12.7** — Append `## Phase 12` to report. Update progress file.

---

## Phase 13: All Section Renderers — Responsiveness & Overflow Safety `[ ]`

### Context
**MOST CRITICAL PHASE**. All 32 renderer widgets in `lib/features/public_viewer/widgets/` must be pixel-perfect. Overflow = visual crash. Applies Rules #12, #37, #38 from `AI_DOCUMENTATION_RULES.md`.

### Files to Read for This Phase
- ALL 32 files in `lib/features/public_viewer/widgets/`
- `lib/core/widgets/section_background.dart`
- `lib/core/responsive/responsive_layout.dart`
- `lib/core/utils/numeric_parser.dart`

### Tasks — Per-Renderer Audit (read each file, fix all issues, check all boxes)

- `[ ]` **13.1** — `custom_hero_widget.dart` — LayoutBuilder ✓, EdgeInsetsDirectional, PositionedDirectional, no IntrinsicHeight+LayoutBuilder, no Expanded in unbounded, NumericParser, no infinity heights, shrinkWrap+NeverScrollable, text overflow protection
- `[ ]` **13.2** — `custom_hero_saas_widget.dart` — same checklist
- `[ ]` **13.3** — `custom_features_widget.dart` — same checklist
- `[ ]` **13.4** — `custom_pricing_widget.dart` — same checklist
- `[ ]` **13.5** — `custom_products_widget.dart` — same checklist (23KB file, read carefully)
- `[ ]` **13.6** — `featured_product_widget.dart` — same checklist
- `[ ]` **13.7** — `bento_store_widget.dart` — same checklist
- `[ ]` **13.8** — `custom_testimonials_widget.dart` — same checklist
- `[ ]` **13.9** — `custom_faq_widget.dart` — same checklist
- `[ ]` **13.10** — `custom_gallery_widget.dart` — same checklist (15KB file)
- `[ ]` **13.11** — `custom_contact_info_widget.dart` — same checklist
- `[ ]` **13.12** — `custom_cta_banner_widget.dart` — same checklist (14KB file)
- `[ ]` **13.13** — `custom_lead_form_widget.dart` — same checklist (15KB file)
- `[ ]` **13.14** — `custom_lead_magnet_widget.dart` — same checklist (16KB file)
- `[ ]` **13.15** — `custom_multi_step_form_widget.dart` — same checklist (16KB file)
- `[ ]` **13.16** — `custom_video_embed_widget.dart` — same checklist
- `[ ]` **13.17** — `custom_team_members_widget.dart` — same checklist
- `[ ]` **13.18** — `custom_logo_header_widget.dart` — same checklist
- `[ ]` **13.19** — `custom_animated_counter_widget.dart` — same checklist
- `[ ]` **13.20** — `custom_comparison_table_widget.dart` — same checklist
- `[ ]` **13.21** — `custom_whatsapp_widget.dart` — same checklist
- `[ ]` **13.22** — `custom_service_steps_widget.dart` — same checklist
- `[ ]` **13.23** — `custom_statistics_grid_widget.dart` — same checklist
- `[ ]` **13.24** — `custom_trust_logos_widget.dart` — same checklist
- `[ ]` **13.25** — `custom_working_hours_widget.dart` — same checklist
- `[ ]` **13.26** — `custom_social_qr_widget.dart` — same checklist (16KB file)
- `[ ]` **13.27** — `custom_qr_widget.dart` — same checklist
- `[ ]` **13.28** — `custom_location_map_widget.dart` — same checklist
- `[ ]` **13.29** — `section_renderer.dart` — verify all 29 block types are handled; no crash on unknown type (fallback to `basic_section_renderer.dart`)
- `[ ]` **13.30** — `basic_section_renderer.dart` — verify it handles all fallback cases gracefully
- `[ ]` **13.31** — `section_background.dart` — verify it reads `bg_overlay_opacity ?? overlay_opacity` and `bg_color ?? background_color`
- `[ ]` **13.32** — `floating_cart_widget.dart` — verify responsiveness and no overflow (17KB file)

- `[ ]` **13.33** — Add `///` doc comments to every modified file.
- `[ ]` **13.34** — Append `## Phase 13` to report. Update progress file.

---

## Phase 14: Bottom Sheets — UI/UX Consistency & Correctness `[ ]`

### Files to Read for This Phase
- `lib/core/widgets/draggable_modal_sheet.dart`
- `lib/features/builder/widgets/modals/builder_options_modal.dart`
- `lib/features/builder/widgets/modals/ai_chat_modal.dart`
- `lib/features/builder/widgets/modals/seo_settings_modal.dart`
- `lib/features/builder/widgets/modals/image_picker_modal.dart`
- `lib/features/builder/widgets/modals/section_library_modal.dart`
- `lib/features/builder/widgets/modals/pixabay_selector_modal.dart`
- `lib/features/builder/widgets/layout_picker/layout_picker_panel.dart`

### Tasks

- `[ ]` **14.1** — **`DraggableModalSheet`**: Verify all call sites pass a meaningful `title`, have `minChildSize` set for complex editors, and `maxChildSize: 1.0` for full-screen sheets (AI Chat).

- `[ ]` **14.2** — **`builder_options_modal.dart`**: Verify view navigation (main → save → publish) is smooth. All action buttons have loading states. "Publish" action calls `cubit.updateSettings(isPublished: true)` + `cubit.saveForCurrentUser()` + shows success toast.

- `[ ]` **14.3** — **`seo_settings_modal.dart`**: Verify all SEO fields: `meta_title`, `meta_description`, `og_image_url` (use `CustomImageField`), `favicon_url`. Verify save action works.

- `[ ]` **14.4** — **`image_picker_modal.dart`**: Verify Upload / Pixabay / URL tabs all work. Verify upload uses `UploadManagerCubit` and shows progress.

- `[ ]` **14.5** — **`ai_chat_modal.dart`**: Verify chat scrolls to bottom on new message. Verify thinking/generating states use `CubeLoader` (Rule #40). Verify template fallback state is handled gracefully in UI. Verify keyboard does not obscure input.

- `[ ]` **14.6** — **`layout_picker_panel.dart`**: Verify all block types listed in the panel have matching entries. Verify selecting a layout applies `layout_style` to the block via `cubit.updateBlockProperty(...)`.

- `[ ]` **14.7** — Append `## Phase 14` to report. Update progress file.

---

## Phase 15: Documentation Sync `[ ]`

### Tasks

- `[ ]` **15.1** — Update `docs/ai/BLOCK_SCHEMA_REGISTRY.md`: Add new hero `layout_style` values. Update any block types with new variants from Phase 6. Update Universal Properties table if Phase 3 added new entries.

- `[ ]` **15.2** — Update `docs/ai/BUILDER_ARCHITECTURE.md`: Document the AI theme application flow if Phase 7 changed it.

- `[ ]` **15.3** — Update `lib/features/builder/README.md`: Update File Map for any new files created (e.g., `hero_saas_editor.dart`). Update AI Warnings if new gotchas were found.

- `[ ]` **15.4** — Update `lib/features/public_viewer/README.md`: Update File Map if renderers were significantly modified.

- `[ ]` **15.5** — Update `AI_CONTEXT.md` if the total block count changed.

- `[ ]` **15.6** — Write `## Summary` section in `docs/reports/builder_audit_report.md`:
  - Total bugs fixed
  - Total improvements made
  - Remaining known issues (deferred)
  - Top 5 improvement suggestions for future sprints

- `[ ]` **15.7** — Update `docs/reports/BUILDER_AUDIT_PROGRESS.md`: Mark all phases complete. Write final status.

---

## Critical Rules Reminder

| Rule | What To Do |
|------|-----------|
| Mixin files | NEVER merge `builder_cubit_blocks.dart` / `builder_cubit_persistence.dart` |
| New block editors | Create new `blocks/*_editor.dart` — NEVER add handlers to `block_properties_editor.dart` |
| Cubit emit | ALWAYS use `_emitDirty()` instead of `emit()` directly |
| Mobile detection | NEVER `MediaQuery.size.width` in blocks — use `LayoutBuilder` + `constraints.maxWidth` |
| Layout crash | NEVER `IntrinsicHeight` around `LayoutBuilder` |
| Scroll crash | NEVER `Expanded`/`Flexible` in `SingleChildScrollView > Column` without `SizedBox` height |
| Colors | ALL colors use `Theme.of(context).colorScheme.*` — not `AppColors.background/cardBg/border/textPrimary` |
| Loading | ALL loaders use `CubeLoader` — NEVER `CircularProgressIndicator` |
| JSON | ALL JSON ops use `parseJsonDesign()` or `Isolate.run()` |
| Images | NEVER `height: double.infinity` on network images |
| Directional | ALWAYS `EdgeInsetsDirectional` — NEVER `EdgeInsets.only(left/right)` |
| Stack | ALWAYS `PositionedDirectional` inside Stack |
| Inner lists | ALL inner lists: `shrinkWrap: true` + `NeverScrollableScrollPhysics()` |
| Doc comments | After EVERY file modification: add `///` to every class and public method touched |
| File size | Keep every file under 800 lines — split before adding more |
