# Unified Cube Loader System (V3)

## Overview

The CubeLoader is the **third-generation** unified brand loading indicator. It replaces three separate implementations (LoadingLogo, CubeSpinner, CubeProgress) with a single optimized widget backed by shared geometry in `core/cube_geometry.dart`.

## Architecture

```
cube_loader.dart          ← Widget frontend (state, animation, interaction)
  └─ _CubeLoaderPainter   ← CustomPainter (all rendering logic)
       └─ cube_geometry.dart  ← Shared geometry, math, lighting (no widget code)

loading_logo.dart  ──→  delegates to CubeLoader(variant: logo)
cube_spinner.dart  ──→  delegates to CubeLoader(variant: single)
cube_progress.dart ──→  delegates to CubeLoader(variant: cluster)
```

### Files

| File | Purpose | Lines |
|------|---------|-------|
| `lib/core/widgets/particles/cube_loader.dart` | Unified CubeLoader widget | ~450 |
| `lib/core/widgets/particles/core/cube_geometry.dart` | Shared cube math (verts, faces, normals, rotation, lighting) | ~120 |
| `lib/core/widgets/particles/loading_logo.dart` | Legacy wrapper (delegates to CubeLoader) | ~50 |
| `lib/core/widgets/atoms/cube_spinner.dart` | Legacy wrapper (delegates to CubeLoader) | ~30 |
| `lib/core/widgets/atoms/cube_progress.dart` | Legacy wrapper (delegates to CubeLoader) | ~40 |
| `lib/core/widgets/atoms/cube_shimmer.dart` | Grid-based shimmer (still independent, uses cube_geometry) | ~150 |
| `lib/core/widgets/particles/floating_cube_background.dart` | _CubePainter uses cube_geometry for verts/faces/normals/rotation | ~2100 |
| `lib/core/widgets/atoms/cube_refresh_indicator.dart` | _CubeOrbitPainter uses cube_geometry for verts/faces/normals/rotation | ~340 |

## API

```dart
const CubeLoader({
  Key? key,
  this.size = 48.0,                    // 16–512
  this.initialState = CubeLoaderState.breathing,
  this.variant = CubeLoaderVariant.logo, // logo | single | cluster
  this.interactive = false,             // hover glow + tap explode
  this.showGlow = true,
  this.value,                           // determinate progress (0.0–1.0)
  this.showPercentage = false,          // show % text overlay
  this.color,                           // override colors (used by CubeSpinner)
})
```

### Variants (`CubeLoaderVariant`)

| Variant | Cubes | Replaces | Usage |
|---------|-------|----------|-------|
| `logo` | 27 (3×3×3) | `LoadingLogo` | Page/section/overlay loading |
| `single` | 1 | `CubeSpinner` | Buttons, inline spinners |
| `cluster` | 3 (orbit) | `CubeProgress` | Upload progress, image picker |

### States (`CubeLoaderState`)

| State | Behavior |
|-------|----------|
| `idle` | Very slow rotation (0.05×) |
| `breathing` | Slow rotation + pulsing gap |
| `loading` | Fast rotation (0.3×) + pulse glow |
| `success` | Very slow rotation, green tint |
| `error` | Almost static, red tint |

## Rendering Improvements (vs V2 LoadingLogo)

### Shared Geometry (`cube_geometry.dart`)
- Single source of truth for `cubeVerts`, `cubeFaces`, `cubeNormals`
- All six painter consumers now use it: `cube_loader`, `cube_shimmer`, `floating_cube_background`, `cube_refresh_indicator`
- Eliminates the 4× duplication of the same 50-line constants block

### Zero-Allocation Painter
- Static scratch buffers (`_tv`, `_nv`, `_path`, `_quadPts`) reused across all frames
- No `List.generate` or `new Path()` in the paint loop
- Single `RotationMatrix` computed once per frame, reused for all cubes and all faces

### Improved Rounding
- Cubic bezier corner interpolation (vs quadratic bezier in v2)
- Smoother, more premium look at all sizes

### Ambient Occlusion
- Cubes with more neighbors get darker (`0.85–1.0` brightness factor)
- Occluded faces (neighbor completely blocking) are skipped entirely
- Improves depth perception without extra draw calls

### Cached Lighting Rotation
- `_lightRot` cached once per frame — no redundant `computeRotation` calls per face
- Lighting tracks the animated rotation precisely

## Performance Characteristics

| Metric | V2 LoadingLogo | V3 CubeLoader |
|--------|---------------|---------------|
| Allocations in paint | ~162 `_FaceInfo` + `List.generate` | 0 (static buffers) |
| Draw calls per frame (logo) | 27×6×2 = 324 | 27×~3×2 = ~162 (backface + occlusion culled) |
| `Path` objects per frame | 162 | 0 (reuses static `_path`) |
| Rotation computations per frame | 27×6 = 162 | 1 (cached `_lightRot`) |
| File size | 653 lines | ~450 lines |

## Migration Notes

- `LoadingLogo` and `CubeSpinner` and `CubeProgress` are now thin wrappers — no breaking changes
- New code should use `CubeLoader` directly for clarity
- The `color` parameter on `CubeLoader` overrides both stroke and fill (used by CubeSpinner's custom colors)
- `CubeShimmer` remains independent but now imports `cube_geometry.dart` for shared constants

## Architecture Discoveries

1. **Static scratch buffers in CustomPainter** are safe because Flutter renders frames sequentially. This is the standard approach for high-performance CustomPainters (used internally by Flutter framework).

2. **Euler rotation normalization**: The `(rx=0.70, ry=π/4)` angles produce an approximately isometric view. True isometric would be `rx=asin(tan(30°))≈0.615`, but 0.70 gives a slightly better visual (more top-face visible).

3. **Face occlusion via neighbor check** (`occludedFaces`): The 3×3×3 grid means each cube has 0–6 neighbors. Faces facing a neighbor are invisible and can be skipped. This reduces draw calls by ~50% for inner cubes.
