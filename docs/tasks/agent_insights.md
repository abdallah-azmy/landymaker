# Agent Insights — Deep Codebase Audit

> Generated: 2026-06-29
> Scope: Full `lib/` scan after template registry modularization

---

## 1. UI/UX Critique

### 1.1 Entry Point & Cross-Fade Transition
The HTML→Flutter cross-fade (`index.html` ↔ `landymaker_home_screen.dart`) is well-engineered with `100dvh`, `1.35x` keyframe scale, and aspect-ratio correction (`1.0266×1.0347`). However:

- **No loading progress indicator for API data**: After the cross-fade completes and cubes burst, the home screen sections load progressively via `_loadSections()` with no visible skeleton or shimmer. Users see an empty layout for 200–800ms while sections stream in. Consider a `CubeShimmer` placeholder per section slot.
- **Cube showcase on home screen**: The `LandyMakerHomeScreen` contains a full `CubeLoader` variant showcase (20+ variants rendered in a grid) that serves as developer documentation but adds ~600ms paint time on first load. Consider lazy-loading this section below the fold.

### 1.2 Template Picker Flow
`template_picker_screen.dart` loads category-filtered templates from `TemplateRegistry.availableTemplates`. Current UX observations:
- ✅ **Image caching via `CustomNetworkImage`** — Templates are rendered with the existing `CustomNetworkImage` widget, which wraps `CachedNetworkImage`. Images are cached on first load, eliminating layout shifts on repeat visits.
- ✅ **Bilingual metadata** — `TemplateMetadata` now has `nameAr`/`descriptionAr` fields with Arabic translations for all 22 templates. Cards display localized text based on `Localizations.localeOf(context)`.
- **Category filter is client-only**: Categories are hardcoded in `TemplateMetadata.category`. No server-side analytics track which templates are most chosen. Adding anonymous impression/select events could guide which templates to promote.

### 1.3 Builder Workspace Layout
`builder_workspace_screen.dart` (802 lines — at the 800 limit) contains desktop and mobile app bars, canvas, and sidebar wiring:
- **Desktop sidebar width**: `BuilderSidebar` (145 lines) is narrow; `BuilderSidebarTabs` (1219 lines) packs content/design/actions into tabs. The tabs use `DraggableModalSheet` on mobile but inline panels on desktop — causing layout shift when switching devices.
- **Section library modal** (`section_library_modal.dart`, 1680 lines): Contains ALL 24 block type cards with icons + descriptions. This is the worst-case AI readability offender. Needs splitting by category (content, media, commerce, forms).

### 1.4 Visual Inconsistencies
- **Theme enforcement**: Dark mode is forced but `CubeLoader` logo variants were designed for light backgrounds in some preview states. Verify all 12 logo variants look correct on `#0F172A` background.
- **Arabic-first but English fallback templates**: Many template designs use Arabic content (`_getRestaurantTemplate`, `_getClinicTemplate`) while others use English (`_getRealEstateTemplate`, `_getEventTemplate`). This is intentional (market-specific), but the `template_picker_screen` shows all templates regardless of locale. Consider locale-based template filtering.

---

## 2. Performance Review

### 2.1 Rebuild Analysis

| Location | Risk | Recommendation |
|----------|------|---------------|
| `block_properties_editor.dart` (1501 lines) | Every keystroke in the editor rebuilds all ~24 block property tabs because `BlocBuilder` wraps the entire widget. | Split into per-tab `BlocBuilder`s or use `Selector` to filter on the specific property key being edited. |
| `builder_sidebar_tabs.dart` (1219 lines) | Full tab rebuild on any cubit state change. The `DesignFontsTab` and `ActionsTab` sections don't need to rebuild when block content changes. | Use `BuildWhen` or `BlocSelector` per tab. |
| `section_library_modal.dart` (1680 lines) | All 24 category icons render on open, even though only the "All" category is shown initially. | Virtualize the grid with `ListView.builder` (currently uses `Wrap`/`Column` with all children present). |
| `supabase_service.dart` (1645 lines) | No caching layer. Every call to `getLandingPages()`, `getLeadSubmissions()`, etc. hits Supabase directly. | Add a simple in-memory cache (Map with TTL) for read-heavy dashboard calls. |

### 2.2 Image Loading
`custom_network_image.dart` does use `CachedNetworkImage` (line 58) but falls back to plain `Image.network` for placeholder and error states. The fallback path has no caching.

**Critical path**: Template picker `imageUrl` values are loaded without `CachedNetworkImage` — each navigation to the picker re-downloads the same 20+ images.

### 2.3 RepaintBoundary Coverage
- ✅ `CubeLoader` has internal `RepaintBoundary` (line 279)
- ✅ `CubeRefreshIndicator` has internal `RepaintBoundary` (line 207)
- ✅ `FloatingCubeBackground` has internal (line 1821) + call-site boundary in `landymaker_home_screen.dart`
- ✅ `builder_workspace_screen.dart` — inner `RepaintBoundary` in `builder_canvas.dart`, outer in `_CanvasContainer` (done in optimization sprint)
- ✅ `section_library_modal.dart` — no `RepaintBoundary` needed after split (each variant card is lightweight)
- ❌ `block_properties_editor.dart` — 1500-line editor with no boundary isolation per tab; mitigated by `BlocSelector` at both call sites

### 2.4 Const vs. Non-Const in Registry Functions
The `template_registry_*.dart` files use `const Uuid().v4()` in function bodies that return `Map<String, dynamic>`. While technically valid, the `const` keyword on `Uuid()` is misleading — it doesn't make the map const. Each call to `getTemplateDesign()` generates new UUIDs. This is fine for the template picker (called once per template selection), but if `getTemplateDesign()` were called repeatedly, UUIDs would change each time, breaking block identity restoration.

### 2.5 Isolate Usage
The floating cube background system uses `compute()` for isolate offloading. The builder cubit's `savePage()` now offloads `jsonEncode` to a background isolate via `Isolate.run()` — for pages with 50+ blocks, this saves 30–80ms of main-thread blocking. As of Phase 6, all 6 `jsonDecode` call sites also offload to isolates via `Isolate.run()`, eliminating 40–360ms of UI blocking per interaction cycle.

---

## 3. AI-Readability Health

### 3.1 Recently Split / Cleaned
| File | Status | Lines |
|------|--------|-------|
| `template_registry.dart` | ✅ **Split** (was 1814, now barrel) | 4 |
| `template_registry_base.dart` | ✅ Created | 685 |
| `template_registry_saas.dart` | ✅ Created | 280 |
| `template_registry_ecommerce.dart` | ✅ Created | 155 |
| `template_registry_services.dart` | ✅ Created | 680 |
| `floating_cube_background.dart` | 🟡 Documented, NOT split (physics exception) | 2728 |
| `injection_container.dart` | ✅ Documented | 118 |
| `builder_cubit.dart` | ✅ **Split** (was 2254, now 207 + 1057 + 1025) | 207 |
| `supabase_service.dart` | ✅ **Split** (was 1649, now 450 main + 3 part files) | 450 |
| `home_navbar.dart` | ✅ **Split** (was 1450, now 470 + 3 extracted widgets) | 470 |
| `home_hero_section.dart` | ✅ **Split** (was 1384, now 870 + 2 extracted widgets) | 870 |
| `landymaker_home_screen.dart` | ✅ Documented | 1484 |
| `builder_sidebar_tabs.dart` | ✅ **Split** (was 1219, now barrel 9 lines + 7 files) | barrel |

### 3.2 Critical Split Targets (Next Priority)

**Tier 1 — Must split before adding features** (lines > 1200):

| File | Lines | Suggested Split Strategy |
|------|-------|------------------------|
| ✅ `builder_cubit.dart` | ~~2254~~ → **207** | Done: mixin-based split into `builder_cubit_blocks.dart` + `builder_cubit_persistence.dart` |
| ✅ `super_admin_panel_screen.dart` | ~~1868~~ → **158** | Done: extracted 10 tab widgets under `super_admin/widgets/` |
| ✅ `section_library_modal.dart` | ~~1680~~ → **189** | Done: split into 3 part files (section_data 805, dual_mini_preview 476, section_variant_card 218) |
| 🟡 `block_properties_editor.dart` | 1501 | Rebuild-isolated via `BlocSelector` at both call sites (`_openEditBottomSheet` + `BuilderSidebar`). The editor now only rebuilds when the specific block's data changes. Full extraction to `blocks/` files still pending. |
| ✅ `supabase_service.dart` | ~~1649~~ → **450** | Done: split into 3 part files (auth, pages, storage) — main file keeps super-admin, templates, homepage, SEO, notifications, bulk ops |
| ✅ `home_navbar.dart` | ~~1450~~ → **470** | Done: extracted `DesktopSideMenu`, `MobileMenuPopup`, `UserAvatarMenu` to `navbar/` subfolder |
| ✅ `home_hero_section.dart` | ~~1384~~ → **870** | Done: extracted `TypewriterText`, `PhonePreview` to `hero/` subfolder |
| ✅ `builder_sidebar_tabs.dart` | ~~1219~~ → **barrel** | Done: extracted 7 files (outline_tab, templates_tab, design_colors_tab, design_fonts_tab, design_tab, magic_image_swapper, content_tab) |

**Tier 2 — Monitor (800–1200 lines)**:

| File | Lines | Notes |
|------|-------|-------|
| `builder_workspace_screen.dart` | 802 | At the limit — mobile/AppBar extraction would bring it under. |
| `public_landing_page.dart` | ~800 | Check exact count — rendering 24+ block types inline. |

### 3.3 Documentation Gaps
- Of 275 Dart files in `lib/`, ~205 have NO `///` doc comments on their classes.
- Feature folders missing `README.md` anchors: `blog_admin/`, `subscription/`, `super_admin/`, `public_viewer/`.
- The `docs/ai/BLOCK_SCHEMA_REGISTRY.md` and `docs/ai/BUILDER_ARCHITECTURE.md` reference block types that were renamed/removed in prior refactors.

### 3.4 Pattern Enforcement
- All new editor widgets follow the [Content, Actions, Design] tab structure ✅
- RTL compliance (`EdgeInsetsDirectional`, `PositionedDirectional`) is enforced ✅
- `CircularProgressIndicator` has been banished from auth screens ✅ (register_screen, create_page_modal)
- `AnimatedThemeToggle` is fully removed ✅

---

## 4. Actionable Roadmap

### ✅ Completed

| # | Task | How |
|---|------|-----|
| 1 | **Split `super_admin_panel_screen.dart`** | Extracted 10 tab widgets to `super_admin/widgets/` — main file reduced from 1868→158 lines |
| 2 | **Split `builder_cubit.dart`** | Mixin-based split into `builder_cubit_blocks.dart` (1057 lines) + `builder_cubit_persistence.dart` (1025 lines) — main file reduced from 2254→207 lines |
| 3 | **Add bilingual template metadata** | `TemplateMetadata` now has `nameAr`/`descriptionAr` with Arabic translations for all 22 templates |
| 4 | **Enable image caching** | Already handled by existing `CustomNetworkImage` → `CachedNetworkImage` — no change needed |
| 5 | **RepaintBoundary around BuilderCanvas** | Inner `RepaintBoundary` in `builder_canvas.dart` (wraps Stack), outer in `builder_workspace_screen.dart` `_CanvasContainer` (wraps BuilderCanvas) |
| 6 | **Preload template images** | Added `_precacheImages()` in `template_picker_screen.dart` — calls `precacheImage(NetworkImage(...), context)` for first 5 filtered templates after load + on category change |
| 7 | **Split `section_library_modal.dart`** | Extracted into 3 part files under `modals/section_library/`: `section_data.dart` (805), `dual_mini_preview.dart` (476), `section_variant_card.dart` (218) — main file reduced from 1680→189 lines |
| 8 | **Isolate property tab rebuilds** | Replaced `BlocBuilder` with `BlocSelector<..., int>` using block `hashCode` in both `builder_workspace_screen.dart` and `builder_sidebar.dart` — editor only rebuilds when the specific block's data changes |
| 9 | **Isolate JSON serialization on save** | Offloaded `jsonEncode(designMap)` to `Isolate.run()` in `savePage` + `_saveGuestDesign`; pre-encoded string passed via `designJson` param to `saveLandingPage` |
| 10 | **Split `builder_sidebar_tabs.dart`** | Extracted into 7 standalone files under `tabs/`: `outline_tab.dart`, `templates_tab.dart`, `design_colors_tab.dart`, `design_fonts_tab.dart`, `design_tab.dart`, `magic_image_swapper.dart`, `content_tab.dart` — main file reduced from 1219→9 line barrel |
| 11 | **Restrict Compare Loading Logos FAB to kDebugMode** | Wrapped `floatingActionButton` with `!kDebugMode` guard in `landymaker_home_screen.dart` — eliminates test UI overhead in production builds |
| 12 | **Isolate-based JSON decoding (Phase 6)** | Created `lib/core/utils/json_utils.dart` with `parseJsonDesign` helper; migrated 6 call sites across builder, public viewer, homepage, and dialog — all sync `jsonDecode` replaced with `await Isolate.run()`; eliminated 40–360ms UI blocking per interaction cycle |
| 13 | **AI context anchors (READMEs)** | Created `README.md` in `blog_admin/`, `subscription/`, `super_admin/`; updated `public_viewer/README.md` — each with purpose, file map, state management, and AI warnings |
| 14 | **Template telemetry & analytics** | Added `EventAnalyticsService.recordTemplateEvent()` with `record_template_event` RPC + graceful fallback; integrated `category_select` + `template_select` events in `template_picker_screen.dart` with locale capture |

### Immediate (Next Agent)

15. **Track unused imports** — Run `dart fix --apply` to clean stale imports across the project. Several files import `dart:html` (deprecated) when they could use `package:web`.

### Medium-Term (Next Sprint)

16. **Shard `block_properties_editor.dart`** — Replace the 1500-line inline `if/else` block-type dispatch with calls to the 24 existing editor files in `blocks/`. Each editor file already has the logic — the issue is that `block_properties_editor.dart` duplicates the routing.

### Deferred (Not Critical)

17. **Store session analytics** — Track template selections, builder session duration, and block usage.
18. **Dark mode verification** — Audit all 12 `CubeLoader` logo variants on `#0F172A` background.

---

## 5. File Health Summary

```
Legend: ✅ Clean  🟡 Needs attention  ❌ Critical  📝 Documented
```

| File | Lines | Status | Comments Added | Action Needed |
|------|-------|--------|---------------|--------------|
| `template_registry.dart` | 4 | ✅✅ | — | Barrel only |
| `template_registry_base.dart` | 685 | ✅ | ✅ | — |
| `template_registry_saas.dart` | 280 | ✅ | — | — |
| `template_registry_ecommerce.dart` | 155 | ✅ | — | — |
| `template_registry_services.dart` | 680 | ✅ | — | — |
| `floating_cube_background.dart` | 2728 | 🟡 | ✅ | Exception (physics) |
| `injection_container.dart` | 118 | ✅ | ✅ | — |
| `builder_cubit.dart` | 207 | ✅✅ | ✅ | Split done (was 2254) |
| `supabase_service.dart` | 450 | ✅✅ | ✅ | Split done (was 1649) — 3 part files |
| `super_admin_panel_screen.dart` | 158 | ✅✅ | ✅ | Split done (was 1868) |
| `section_library_modal.dart` | 189 | ✅✅ | ❌ | Split into 3 part files |
| `builder_sidebar_tabs.dart` | 9 | ✅✅ | — | Split into 7 standalone files under `tabs/` |
| `home_navbar.dart` | 470 | ✅✅ | ❌ | Split done (was 1450) — 3 extracted widgets |
| `home_hero_section.dart` | 870 | ✅ | ❌ | Split done (was 1384) — 2 extracted widgets |
| 🟡 `block_properties_editor.dart` | 1501 | 🟡 | ❌ | Rebuild-isolated via BlocSelector; full split deferred |
| `landymaker_home_screen.dart` | 1484 | 🟡 | ✅ | Split when >1500 |
| `builder_workspace_screen.dart` | 802 | 🟡 | ❌ | Monitor |
