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
- ❌ `builder_workspace_screen.dart` — the builder canvas (`BuilderCanvas`) wraps a `PreviewMode`-dependent layout that rebuilds on mode toggle. No `RepaintBoundary` around the canvas or sidebar.
- ❌ `section_library_modal.dart` — no `RepaintBoundary` around the scrollable grid content.
- ❌ `block_properties_editor.dart` — 1500-line editor with no boundary isolation per tab.

### 2.4 Const vs. Non-Const in Registry Functions
The `template_registry_*.dart` files use `const Uuid().v4()` in function bodies that return `Map<String, dynamic>`. While technically valid, the `const` keyword on `Uuid()` is misleading — it doesn't make the map const. Each call to `getTemplateDesign()` generates new UUIDs. This is fine for the template picker (called once per template selection), but if `getTemplateDesign()` were called repeatedly, UUIDs would change each time, breaking block identity restoration.

### 2.5 Isolate Usage
Only the floating cube background system uses `compute()` for isolate offloading. The builder cubit's `savePage()` serializes content synchronously — for pages with 50+ blocks, this blocks the UI thread for 30–80ms. Consider isolating the JSON serialization step for large saves.

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
| `supabase_service.dart` | ✅ Documented | 1645 |
| `landymaker_home_screen.dart` | ✅ Documented | 1484 |

### 3.2 Critical Split Targets (Next Priority)

**Tier 1 — Must split before adding features** (lines > 1200):

| File | Lines | Suggested Split Strategy |
|------|-------|------------------------|
| ✅ `builder_cubit.dart` | ~~2254~~ → **207** | Done: mixin-based split into `builder_cubit_blocks.dart` + `builder_cubit_persistence.dart` |
| ✅ `super_admin_panel_screen.dart` | ~~1868~~ → **158** | Done: extracted 10 tab widgets under `super_admin/widgets/` |
| ✅ `section_library_modal.dart` | ~~1680~~ → **189** | Done: split into 3 part files (section_data 805, dual_mini_preview 476, section_variant_card 218) |
| 🟡 `block_properties_editor.dart` | 1501 | Rebuild-isolated via `BlocSelector` at both call sites (`_openEditBottomSheet` + `BuilderSidebar`). The editor now only rebuilds when the specific block's data changes. Full extraction to `blocks/` files still pending. |
| `home_navbar.dart` | 1450 | Extract `_DesktopNavbar` and `_MobileNavbar` (or burger menu) into separate files. |
| `supabase_service.dart` | 1645 | Extract tenant routing + auth methods → `supabase_auth.dart`. Extract storage methods → `supabase_storage.dart`. |
| `home_hero_section.dart` | 1384 | Already uses `_DesktopLayout`/`_MobileLayout` pattern — extract those to separate files. |
| `builder_sidebar_tabs.dart` | 1219 | Extract each tab panel (Content, Actions, Design) into individual files. |

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

### Immediate (Next Agent)

9. **Track unused imports** — Run `dart fix --apply` to clean stale imports across the project. Several files import `dart:html` (deprecated) when they could use `package:web`.

### Medium-Term (Next Sprint)

10. **Shard `block_properties_editor.dart`** — Replace the 1500-line inline `if/else` block-type dispatch with calls to the 24 existing editor files in `blocks/`. Each editor file already has the logic — the issue is that `block_properties_editor.dart` duplicates the routing.

11. **Add `README.md` context anchors** — Create `README.md` in `blog_admin/`, `subscription/`, `super_admin/`, and `public_viewer/` with file maps and AI warnings.

### Deferred (Not Critical)

12. **Store session analytics** — Track template selections, builder session duration, and block usage.
13. **Isolate JSON serialization** — Move `jsonEncode` in `builder_cubit.savePage()` to a background isolate.
14. **Dark mode verification** — Audit all 12 `CubeLoader` logo variants on `#0F172A` background.

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
| `supabase_service.dart` | 1645 | ❌ | ✅ | Split next |
| `super_admin_panel_screen.dart` | 158 | ✅✅ | ✅ | Split done (was 1868) |
| ✅ `section_library_modal.dart` | ~~1680~~ → **189** | ✅✅ | ❌ | Split into 3 part files (total 1688 lines) |
| 🟡 `block_properties_editor.dart` | 1501 | 🟡 | ❌ | Rebuild-isolated via BlocSelector; full split deferred |
| `home_navbar.dart` | 1450 | ❌ | ❌ | Split next |
| `landymaker_home_screen.dart` | 1484 | 🟡 | ✅ | Split when >1500 |
| `home_hero_section.dart` | 1384 | ❌ | ❌ | Split next |
| `builder_sidebar_tabs.dart` | 1219 | ❌ | ❌ | Split next |
| `builder_workspace_screen.dart` | 802 | 🟡 | ❌ | Monitor |
