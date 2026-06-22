# Loading Logo Design System (Legacy)

> **DEPRECATED**: This system has been superseded by the [Unified CubeLoader](CUBE_LOADER.md).
> `LoadingLogo` is now a thin wrapper around `CubeLoader(variant: logo)`.
> All new code should use `CubeLoader` directly.

## Overview

The LoadingLogo was the second-generation unified brand loading indicator based on the LandyMaker isometric cube cluster logo. It replaced the three legacy files (`loading_logo_modified.dart`, `loading_logo.dart`, `loading_logo_original.dart`).

**Legacy source**: `lib/core/widgets/particles/loading_logo.dart`
**New source**: `lib/core/widgets/particles/cube_loader.dart`
**Shared geometry**: `lib/core/widgets/particles/core/cube_geometry.dart`

---

## 1. API (Legacy — Prefer CubeLoader)

```dart
const LoadingLogo({
  Key? key,
  this.size = 48.0,          // Supports 16–256
  this.initialState = LoadingLogoState.breathing,
  this.interactive = false,   // Enable tap/hover interactions
  this.showGlow = true,       // Glow in breathing/loading states
})
```

### States (`LoadingLogoState`)
| State | Behavior |
|-------|----------|
| `idle` | Very slow rotation (0.05×), minimal animation |
| `breathing` | Slow rotation + pulsing cube gap breathing |
| `loading` | Fast rotation (0.3×) + breathing + pulse glow |
| `rotatingLayers` | Medium rotation (0.2×) with per-horizontal-layer Y-axis rotation |

---

## 2. Size Tiers

The component adapts rendering complexity based on size:

| Tier | Size Range | Rendering |
|------|-----------|-----------|
| `micro` | ≤ 24px | 3×3×3 cube grid, no face fill, 1px stroke |
| `tiny` | 25–32px | Full 27 cubes, minimal face detail, 1.2px stroke |
| `small` | 33–48px | Full detail, 1.6px stroke |
| `medium` | 49–96px | Full detail + glow effects |
| `large` | ≥ 97px | Full detail + enhanced glow |

Target sizes without degradation: 16, 20, 24, 32, 48, 64, 96, 128, 256.

---

## 3. Interaction Design

### Web Hover (when `interactive: true`)
- Subtle brightness increase on hovered faces
- Slight rotation offset (+0.04 rad rx, +0.03 rad ry)

### Tap (when `interactive: true`)
- 3-phase sequence (~960ms total):
  1. **Explode** (0–320ms): Cubes scatter outward from center
  2. **Hold** (320–640ms): Cubes hold at max scatter
  3. **Reassemble** (640–960ms): Cubes return to original positions
- Automatically returns to `initialState`

---

## 4. Performance Design

- **RepaintBoundary**: `CustomPaint` wrapped in `RepaintBoundary` to isolate painting from parent rebuilds.
- **Single AnimationController**: One controller with `.repeat()` drives all animations.
- **No allocations in paint**: All geometry data (`_verts`, `_faces`, `_normals`) are static const lists. Face data is collected into a list per frame (necessary for depth sorting).
- **No external dependencies**: Pure `CustomPaint` — no `shimmer`, no `lottie`, no third-party animation packages.
- **Micro tier optimization**: Limited cube count + no face fills for smallest sizes.

---

## 5. Usage Guidelines

### Category A — Tiny inline (buttons, chips, compact controls)
```dart
LoadingLogo(size: 16, initialState: LoadingLogoState.loading)
```

### Category B — Section loading (cards, panels)
```dart
const LoadingLogo(size: 48)
```

### Category C — Page loading (page fetches, initial load)
```dart
const LoadingLogo(size: 80)
```

### Category D — Overlay / premium loading (dialog ops, AI generation)
```dart
const LoadingLogo(size: 96, initialState: LoadingLogoState.loading, showGlow: true)
```

---

## 6. Color System

- **Cube faces**: `surface`-derived (dark: `#1E293B`, light: `#E2E8F0`), modulated by face brightness (Lambertian dot product).
- **Edges**: `colorScheme.primary` at 0.6 alpha (increased to 0.9 on hover).
- **Success tint**: Green (`#22C55E`) mixed into face color at 30%.
- **Error tint**: Red (`#EF4444`) mixed into face color at 30%.
- **Glow**: `primaryColor` with alpha controlled by state.

---

## 7. Migration Notes

- **Legacy replacement**: `loading_logo_modified.dart` → `loading_logo.dart`
- **API change**: `mode: LoadingLogoMode.breathing` → `initialState: LoadingLogoState.breathing`
- **API change**: `mode: LoadingLogoMode.rotatingLayers` → `initialState: LoadingLogoState.loading`
- **Default size changed** from `120` to `48`. Update explicit sizes for page-level loaders.
- `TechLoadingScreen` now uses `LoadingLogo(size: 80, initialState: LoadingLogoState.loading)`.
