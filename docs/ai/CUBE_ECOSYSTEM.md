# LandyMaker Cube Ecosystem

## CRITICAL — Read Before Modifying Any Cube Code

This document explains the **entire cube rendering ecosystem** in LandyMaker. There are **two fundamentally different cube systems** that serve different purposes. An AI agent MUST understand which system applies to any given task, and MUST NOT confuse or conflate them.

---

## 1. The Two Cube Systems

### System A: CubeLoader — Loading Indicators (V3 Unified)

| Aspect | Detail |
|--------|--------|
| **Purpose** | Branded loading animations (page load, button spinner, upload progress) |
| **Widget** | `CubeLoader` in `particles/cube_loader.dart` |
| **Max cubes** | 27 (logo variant) / 3 (cluster) / 1 (single) |
| **Rendering** | Single `CustomPaint` with per-instance scratch buffers (thread-safe) |
| **Performance** | Zero allocations per frame; occlusion culling; cached rotation matrix |
| **States** | `idle`, `breathing`, `loading`, `rotatingLayers` |
| **Variants** | `logo` (27, 3×3×3), `single` (1), `cluster` (3 orbiting), `linear` (5 wave), `circular` (6 orbit), `physics` (3 bounce) |
| **Animation** | 4-second `AnimationController.repeat()` with **accumulated rotation angles** (no loop-reset visual jumps) |
| **Corner rounding** | Unified cubic bezier: `(h × 0.22).clamp(0.3, h × 0.4)` for all variants |
| **Ambient occlusion** | Inner cubes darker, faces occluded by neighbor skipped entirely |
| **Legacy wrappers** | `LoadingLogo` → `CubeLoader(variant: logo)`, `CubeSpinner` → `CubeLoader(variant: single)`, `CubeProgress` → `CubeLoader(variant: cluster)` |

### System B: FloatingCubeBackground — Particle System (V2)

| Aspect | Detail |
|--------|--------|
| **Purpose** | Ambient background animation, interactive cube showcase |
| **Widget** | `FloatingCubeBackground` in `particles/floating_cube_background.dart` |
| **Max cubes** | ~150+ (configurable) |
| **Rendering** | Single `_CubePainter (CustomPaint)` with spatial hashing, isolate offloading, adaptive quality |
| **Performance** | O(n) spatial hash; isolate WebWorker offload (≥50 cubes); auto-quality reduction at <30 FPS |
| **Modes** | `standard`, `merge`, `orbit`, `gravity` (controlled by `CubeModeCubit`) |
| **Lighting** | Dynamic per-entity light direction from mouse position (repelPoint) |
| **Corners** | Sharp polygon faces (no rounding — cubes are small particles) |
| **Particles** | 500-pool ring buffer for trail dust + burst dust; 3D spherical distribution on split |
| **Adaptive** | Auto-disables strokes and trails when frame rate drops below 30 FPS for 15+ frames |

### NEVER conflate these two systems. They share the SAME geometry constants (cube_geometry.dart) but are architecturally different.

---

## 2. File Map

### Shared Geometry

| File | Role | Lines |
|------|------|-------|
| `particles/core/cube_geometry.dart` | **Single source of truth** for `cubeVerts` (8 corners), `cubeFaces` (6 face indices), `cubeNormals` (6 unit normals), Euler rotation (`computeRotation` + `rotatePoint`), Lambertian lighting (`lambertBrightness`), rounded quad builder (`buildRoundedQuad`), ambient occlusion, face occlusion. | ~144 |

ALL cube renderers import this file. No cube-rendering code should duplicate these constants.

### System A — CubeLoader (Loading Indicators)

| File | Role | Lines |
|------|------|-------|
| `particles/cube_loader.dart` | **Primary widget**. StatefulWidget + _CubeLoaderPainter (CustomPaint). 6 variants, 4 states, accumulated rotation angles, zero-allocation scratch buffers, interactive tap-to-explode. | ~963 |
| `particles/loading_logo.dart` | Legacy wrapper. Maps `LoadingLogoState` → `CubeLoaderState`, delegates to `CubeLoader(variant: logo)`. | ~67 |
| `atoms/cube_spinner.dart` | Legacy wrapper. Delegates to `CubeLoader(variant: single)`. | ~29 |
| `atoms/cube_progress.dart` | Legacy wrapper. Delegates to `CubeLoader(variant: cluster)` with `value` for determinate progress. | ~33 |
| `atoms/cube_shimmer.dart` | Grid-based shimmer/skeleton effect using rotating 3D cubes. Still independent but uses `cube_geometry.dart`. | ~177 |
| `atoms/cube_refresh_indicator.dart` | Pull-to-refresh with 3 orbiting cubes (`_CubeOrbitPainter` uses `cube_geometry.dart`). | ~346 |

### System B — FloatingCubeBackground (Particle System)

| File | Role | Lines |
|------|------|-------|
| `particles/floating_cube_background.dart` | **Full particle system**. StatefulWidget with 60s AnimationController, spatial hash grid, isolate offloading, adaptive quality, trail/burst particles, 4 modes, preview mode (gatherIntoLogo / triggerLogoBurst). | ~2104 |
| `particles/cube_mode_cubit.dart` | BLoC/Cubit managing `CubeMode` enum (standard/merge/orbit/gravity). Persists to SharedPreferences. | ~ |
| `atoms/animated_cube_mode_toggle.dart` | Circular toggle button cycling cube modes with bounce animation. Uses icons, NOT cube rendering. | ~108 |

### System C — Preview Mode (Showcase)

| File | Role | Lines |
|------|------|-------|
| `features/home/screens/landymaker_home_screen.dart` | Home screen with `_isPreviewMode` flag. Hides all content, shows FloatingCubeBackground fullscreen + overlay with exit button + `AnimatedCubeModeToggle`. Activated by AR icon in navbar. | ~550 |

### AI Documentation

| File | Role |
|------|------|
| `docs/ai/CUBE_LOADER.md` | Detailed docs for CubeLoader (API, variants, states, architecture, performance) |
| `docs/ai/LOADING_LOGO_SYSTEM.md` | Legacy LoadingLogo docs (marked DEPRECATED in favor of CubeLoader) |
| `docs/ai/FLOATING_CUBE_BACKGROUND.md` | Complete docs for floating cube system: all 4 mode rules, physics, particle system, entity lifecycle, WASM safety |
| `docs/ai/AI_DOCUMENTATION_RULES.md` | Rule 40 (Unified CubeLoader System) — mandates CubeLoader for ALL loading, lists variant/state selection guidance |

---

## 3. When to Use Which Cube System

### Use `CubeLoader` (System A) when:
- Showing a loading indicator on a page, section, button, or overlay
- Showing upload progress with percentage
- Showing a branded cube animation for any loading state
- Creating a single branded cube animation (logo, spinner)
- Any situation with ≤27 cubes that represents a "loading state"

### Use `FloatingCubeBackground` (System B) when:
- Rendering background ambient animation behind page content
- Creating the immersive preview/showcase experience
- Building interactive cube mode experiences (merge, orbit, gravity)
- Any situation with 50+ cubes that represent a "particle system"
- When physics simulation is needed (collisions, orbits, gravity, bursts)

### Use preview mode (System C) when:
- Showing cubes full-screen with mode controls and exit button
- Triggering the logo burst animation on page load
- The `_enterPreviewMode()` / `_exitPreviewMode()` pattern in the home screen

### NEVER:
- Import `CubeLoader` inside `FloatingCubeBackground` (performance would be catastrophic)
- Import `FloatingCubeBackground` for a simple button loading spinner
- Duplicate `cubeVerts`, `cubeFaces`, `cubeNormals` in any new file — always import `cube_geometry.dart`

---

## 4. Performance Rules

### Rule P1: Zero allocations in paint loop
`_CubeLoaderPainter` uses static scratch buffers (`_tv`, `_nv`, `_quadPts`) allocated once. `_CubePainter` (floating background) uses pre-allocated `tv` list, `_neighborScratch` list, and `_FaceDrawData` reused per frame. No `new List` or `List.generate` in paint.

### Rule P2: Static rotation matrix caching
`_lightRot` computed once per frame, reused for all 162 face lighting calculations in logo variant.

### Rule P3: Face occlusion culling
`cg.occludedFaces(i, j, k)` skips faces completely hidden by neighbors in the 3x3x3 grid. Reduces draw calls by ~50% for inner cubes.

### Rule P4: Spatial hashing (O(n))
`_SpatialHashGrid` reduces proximity checks from O(n²) to O(n). Fixed 11x11 grid (121 cells). Pre-allocated scratch lists. Used in standard mode (repulsion), merge mode (attraction + spiral), orbit mode (gravity + capture).

### Rule P5: Isolate offloading
Physics repulsion offloaded to Isolate when entity count ≥ 50. Serialized to `Float64List`, results applied asynchronously. Fallback: synchronous on Web (no crash, no parallelism).

### Rule P6: Adaptive quality
Auto-switches to low quality (no strokes, no trails) when frame rate < 30 FPS for 15 consecutive frames.

### Rule P7: RepaintBoundary
Every `CustomPaint` is wrapped in `RepaintBoundary` to isolate from parent widget rebuilds.

### Rule P8: Trail pool ring buffer
500 pre-allocated `_TrailParticle` objects. No `add()`/`remove()` — uses `_writeIndex` pointer wrap. O(500) per frame always.

### Rule P9: Accumulated rotation (no loop jumps)
CubeLoader does NOT use `animValue * rotationSpeed * 2π` directly. Instead, `_rotationAngle` and `_clusterOrbitAngle` are accumulated continuously across controller cycles via `_accumulateAngles()` listener. This eliminates the visual stutter when `AnimationController.repeat()` resets from 1.0 to 0.0.

---

## 5. Cube Geometry API (`cube_geometry.dart`)

```dart
// Constants
cubeVerts       // 8 cube corners (±1 range)
cubeFaces       // 6 face index lists (4 vertices each)
cubeNormals     // 6 face normals (unit vectors)
lx, ly, lz      // Static light direction vector (normalized)

// Functions
computeRotation(rx, ry, rz)     → RotationMatrix (cached trig values)
rotatePoint(List<double>, RotationMatrix, out)  → Euler rotation (X→Y→Z)
lambertBrightness(nx, ny, nz)   → 0.3–1.0 brightness from dot product
buildRoundedQuad(a, b, c, d, r) → Path with cubic bezier corners (auto-falls back to polygon if r < 0.5)
ambientOcclusion(ix, iy, iz)    → 0.85–1.0 factor based on neighbor count in 3×3×3 grid
occludedFaces(ix, iy, iz)       → Bitmask of faces blocked by neighbors
```

The light direction in `cube_geometry.dart` (`lx=0.5, ly=0.5, lz=0.707`) is used by `CubeLoader` and `CubeShimmer`. `FloatingCubeBackground` computes its OWN per-entity light direction dynamically from the mouse position, and uses `0.25 + max(0, dot) * 0.75` for brightness (not `cg.lambertBrightness`). This is intentional — DO NOT change this to use the static light.

---

## 6. FloatingCubeBackground Mode Rules Summary

### Standard Mode
- Cubes drift randomly, small repel small within 0.06 range
- Mouse repulsion within 0.25 range, force 0.30
- Burst: tap explosion within 0.65 range, force 0.60

### Merge Mode
- Similar cubes (sizeRatio ≥ 0.80) attract within 8× baseDist, orbit, death-spiral collapse over 4s
- Third-cube repulsion protects spiraling pairs
- Tap to split merged cubes (2-level recursive split history)
- Split produces 40 3D spherical burst dust particles

### Orbit Mode
- Cores (renderSize > 12, parentCore == null) capture nearby cubes
- Max 12 orbiters per core, orbit at elliptical paths with tilt
- Escape condition: core speed > 0.3 AND orbiter radius > 0.12
- Core-core repulsion + gravitational pull on free cubes

### Gravity Mode
- Uniform downward acceleration (0.005/realDt/frame)
- Physics bounce at bottom (55-65% energy loss)
- Stronger gravity makes cubes settle in 2-3 bounces
- Tap: wider range (0.5), stronger force (0.8) scaled by 1/sizeFactor
- Bottom soft repulsion disabled

---

## 7. AI Documentation Hierarchy

When working on cube-related code, read files in this order:

1. **This file** (`CUBE_ECOSYSTEM.md`) — understand the two-system architecture
2. `docs/ai/AI_DOCUMENTATION_RULES.md` — especially Rule 40 (CubeLoader usage rules)
3. `docs/ai/CUBE_LOADER.md` — CubeLoader API, variants, states, performance
4. `docs/ai/FLOATING_CUBE_BACKGROUND.md` — mode physics, particles, entity lifecycle, WASM safety
5. The actual source files listed in the File Map above

The documentation in `docs/ai/` is the architecture contract. If you change any behavioral rule, constant, mode transition, entity lifecycle, or physics parameter, you MUST update the corresponding `.md` file.

---

## 8. Critical Safety Notes

### WASM/CanvasKit Crash Prevention (FloatingCubeBackground)
- Three-layer NaN guard: entity update → entity skip → face coordinate guard
- Never iterate over `_entities` while modifying it — always use `_entities.toList()` before add/remove
- `dt` is a fraction of 60 seconds (60s AnimationController) — multiply by 60 for real seconds
- Isolate results are fire-and-forget — clamp to current entity count to avoid OOB

### Scroll Drift Safety (FloatingCubeBackground)
- **Two independent safeguards** protect against overly aggressive scroll drift, both defined in `docs/ai/FLOATING_CUBE_BACKGROUND.md` §9 ("Scroll Drift"):
  1. `scrollDrift.clamp(-0.08, 0.08)` at the read site in `_updateEntities()`
  2. Speed cap `speed > 0.35` in `_MergeEntity.update()` for non-gravity modes
- **DO NOT** raise the multiplier (`scrollDrift × 2.0`) without verifying both safeguards still work together
- **DO NOT** remove either safeguard — a historical bug (multiplier 5.0 + missing speed cap) caused the drift to move cubes 36% of the screen per scroll event, far beyond the intended subtle effect
- See `docs/ai/FLOATING_CUBE_BACKGROUND.md` for the full bug history, physics pipeline, and testing checklist

### Widget Const Correctness (CubeLoader)
- `CubeLoader` constructor IS `const` (all fields are final, no required vsync)
- `_FaceData.ao` defaults to 1.0 for single/cluster variants (no ambient occlusion)
- `animValue` is still passed for glow effects (sin-based, naturally wraps)
- `rotationAngle` and `clusterOrbitAngle` are passed for rotation (continuously accumulated)

### Backward Compatibility
- `LoadingLogo`, `CubeSpinner`, `CubeProgress` are thin wrappers — DO NOT remove them without migration
- New code should use `CubeLoader` directly (not wrappers)
- The wrappers maintain exact same API surface — zero breaking changes to existing call sites
- To add a new loading state, add to `CubeLoaderState` enum AND `loading_logo.dart`'s `LoadingLogoState` map

---

## 9. Migration Patterns

### Adding a new loading animation → use CubeLoader
```dart
// Full logo animation
const CubeLoader(
  variant: CubeLoaderVariant.logo,
  size: 80,
  initialState: CubeLoaderState.loading,
  showGlow: true,
)

// Inline button spinner
const CubeLoader(
  variant: CubeLoaderVariant.single,
  size: 16,
  initialState: CubeLoaderState.loading,
  showGlow: false,
)

// Upload progress
CubeLoader(
  variant: CubeLoaderVariant.cluster,
  size: 48,
  value: uploadProgress, // 0.0–1.0
  showPercentage: true,
)
```

### Replacing a LinearProgressIndicator (loading only, not determinate progress bars)
```dart
// Before
if (isLoading)
  const LinearProgressIndicator(...)

// After
if (isLoading)
  const CubeLoader(
    variant: CubeLoaderVariant.single,
    size: 24,
    initialState: CubeLoaderState.loading,
    showGlow: false,
  )
```

### Adding a new cube system
For any NEW cube rendering system (not loading, not floating background):
1. Import `cube_geometry.dart` for shared constants
2. Do NOT duplicate `cubeVerts`, `cubeFaces`, `cubeNormals`, rotation math, or lighting calculation
3. If it's a loading indicator → make it a variant of `CubeLoader`
4. If it's a background/particle system → make it independent but use `cube_geometry.dart`

---

## 10. Brand Logo Visual Specification — LandyMaker Isometric Cube

This section defines the EXACT visual properties of the LandyMaker brand logo: a cluster of 27 small cubes arranged in a 3×3×3 isometric grid. Any AI agent modifying cube rendering code MUST preserve these properties.

### 10a. Grid & Count

| Property | Value |
|----------|-------|
| Grid dimensions | 3 × 3 × 3 |
| Total cubes | **27** (not 125, not 64 — exactly 27) |
| Cube spacing (`gap`) | `size.width × 0.29` + breathing offset (up to `size.width × 0.04`) |
| Cube face size (`cubeH`) | `size.width × 0.24` |
| Half-size (`h`) | `cubeH × 0.5 = size.width × 0.12` |
| Grid loop range | i, j, k ∈ {−1, 0, 1} — never use `maxI = 2` |

### 10b. Isometric View Angles

The logo is rendered in an isometric perspective using Euler rotation (X → Y → Z order):

```
fixedRx = 0.70 radians  (≈40°, NOT the true isometric asin(tan(30°)) ≈ 0.615)
baseRy  = π/4 radians   (45°, standard isometric Y rotation)
rz      = 0
```

The `rx = 0.70` (not 0.615) is intentional — it reveals slightly more of the top face than true isometric, giving a better visual silhouette. **NEVER change this to 0.615 or any other value.**

Total Y rotation at any frame: `ry = π/4 + accumulatedRotationAngle` (continuously accumulated, no loop-reset jumps).

### 10c. Corner Rounding

Each individual cube face has rounded corners implemented with cubic bezier curves using a **unified formula across all variants**:

```
cornerRadius = (h × 0.22).clamp(0.3, h × 0.4)
```

This gives approximately **22% of the face half-width** as the corner radius—a slightly tighter, more premium rounded look. The `buildRoundedQuad` function additionally clamps to `minEdge × 0.5`. For very small faces (cr < 0.5px), it falls back to sharp polygon (`addPolygon`).

The control point distance for the cubic bezier is `cr × 0.55` (standard approximation of a quarter-circle arc, ≈ 4/3 × tan(π/8)).

If `buildRoundedQuad` receives rounded corners from `FloatingCubeBackground` (in logo state), the same unified formula `(h * 0.22).clamp(0.3, h * 0.4)` is used.

### 10d. Colors

| Element | Light Theme | Dark Theme | Override |
|---------|-------------|------------|----------|
| Cube faces | `#E2E8F0` (slate-200) | `#1E293B` (slate-800) | via `CubeLoader.color` |
| Cube strokes | `colorScheme.primary` | `colorScheme.primary` | via `CubeLoader.color` |
| Face brightness | Lambertian (see below) | Lambertian (see below) | — |
| Loading pulse | +0.08 sin-brightness boost on `loading` state | +0.08 sin-brightness boost on `loading` state | built-in animation |
| Glow | `primaryColor` at varying alpha | `primaryColor` at varying alpha | controllable via `showGlow` |

### 10e. Lighting Model

The logo uses a STATIC light direction (NOT the dynamic mouse-based light from FloatingCubeBackground):

```dart
lx = 0.5    // normalized light X
ly = 0.5    // normalized light Y
lz = 0.707  // normalized light Z (45° above-horizontal)
```

Face brightness is computed as **Lambertian diffuse**:

```
dot = nx × lx + ny × ly + nz × lz       // face normal · light direction
brightness = 0.3 + max(0, dot) × 0.7    // ambient (30%) + diffuse (70%)
```

The light direction is NOT per-entity and NOT mouse-dependent — it is fixed in world space. The rotation matrix `_lightRot` is pre-computed once per frame and applied to all normals.

### 10f. Ambient Occlusion

Each cube in the 3×3×3 grid has an AO factor based on how many of its 6 faces are adjacent to a neighbor:

```dart
brightness ×= ambientOcclusion(i, j, k)
// = 1.0 - ((neighborCount - 3) / 3.0) × 0.35
// Range: 0.65 (center cube, 6 neighbors) to 1.0 (corner cube, 3 neighbors)
```

Additionally, faces that are COMPLETELY OCCLUDED by a neighbor are SKIPPED entirely (not drawn):

```dart
final mask = occludedFaces(i, j, k);  // bitmask, bit f = 1 if face f is occluded
if ((mask & (1 << f)) != 0) continue; // skip this face entirely
```

This provides correct depth perception — inner cubes appear darker, hidden faces don't waste draw calls.

### 10g. Stroke (Edge Lines)

| Property | Value |
|----------|-------|
| Stroke width (logo) | `(h × 0.08).clamp(0.8, 2.0)` |
| Stroke color | `primaryColor` at 0.6 alpha (increased to 0.9 on hover) |
| Stroke cap | `StrokeCap.round` |
| Stroke join | `StrokeJoin.round` |

Strokes are drawn AFTER fills (in `_drawFaces`), so edges appear on top of face colors.

### 10h. Glow Effect

The glow is an additional stroke drawn around each cube face with:

```dart
glowPaint.color = primaryColor with alpha from:
  CubeLoaderState.breathing → 0.2 + max(0, breath) × 0.4
  CubeLoaderState.loading   → 0.2 + sin(animValue × 4π).abs() × 0.3
  hovered → 0.3
  other states → 0.0
```

The glow is drawn with a slightly larger path (blur + stroke) behind the main stroke. It pulses with the breath animation.

### 10i. Animation Parameters

| State | Rotation Speed (rad/s) | Breath | Glow |
|-------|----------------------|--------|------|
| `idle` | Very slow (0.05 × 2π per 4s) | No | No |
| `breathing` | Slow (0.08 × 2π per 4s) | Yes (gap pulsing) | Soft pulse |
| `loading` | Fast (0.3 × 2π per 4s) | Yes | Bright pulse |
| `rotatingLayers` | Medium (0.2 × 2π per 4s) | No (uses base gap) | No |

The breath is: `breath = sin(controllerValue × 2π)` — modulates the gap between cubes by `±size.width × 0.04`.

Rotation angles accumulate continuously via `_accumulateAngles()` — they do NOT reset when the animation controller loops. This ensures visually seamless rotation.

### 10j. Visual Guarantees (DO NOT BREAK)

1. The logo MUST always render as a 3×3×3 grid of 27 cubes — no more, no less
2. The isometric view MUST use rx = 0.70, baseRy = π/4 — these angles define the brand identity
3. The light direction MUST remain fixed in world space (not per-entity, not mouse-dependent)
4. Corners MUST be rounded with cubic bezier curves (not sharp, not quadratic bezier)
5. The center cube MUST be darker (ambient occlusion) — this is a key depth cue
6. The loading animation MUST loop seamlessly with NO visual discontinuity when the controller resets
7. The cube colors MUST adapt to light/dark theme via `colorScheme` unless an explicit `color` override is provided

---

## 11. Complete File Inventory

| File | System | Lines | Primary Function |
|------|--------|-------|-----------------|
| `core/cube_geometry.dart` | Shared | ~150 | Cube math constants and functions |
| `particles/cube_loader.dart` | A | ~963 | Unified loading indicator widget |
| `particles/loading_logo.dart` | A | ~65 | Legacy wrapper → CubeLoader |
| `atoms/cube_spinner.dart` | A | ~29 | Legacy wrapper → CubeLoader |
| `atoms/cube_progress.dart` | A | ~33 | Legacy wrapper → CubeLoader |
| `atoms/cube_shimmer.dart` | A | ~177 | Cube-based skeleton shimmer |
| `atoms/cube_refresh_indicator.dart` | A | ~346 | Pull-to-refresh orbit animation |
| `particles/floating_cube_background.dart` | B | ~2126 | Full particle system with 4 modes |
| `particles/cube_mode_cubit.dart` | B | ~ | Mode state management |
| `atoms/animated_cube_mode_toggle.dart` | B | ~108 | Mode toggle UI button |
| `features/home/screens/landymaker_home_screen.dart` | C | ~844 | Preview mode overlay |
| `docs/ai/CUBE_ECOSYSTEM.md` | Doc | — | This file — master reference |
| `docs/ai/CUBE_LOADER.md` | Doc | ~112 | CubeLoader detailed docs |
| `docs/ai/LOADING_LOGO_SYSTEM.md` | Doc | ~121 | Legacy LoadingLogo (DEPRECATED) |
| `docs/ai/FLOATING_CUBE_BACKGROUND.md` | Doc | ~496 | Floating cube physics & rules |
| `docs/ai/AI_DOCUMENTATION_RULES.md` | Doc | ~173 | Rule 40 for CubeLoader |
