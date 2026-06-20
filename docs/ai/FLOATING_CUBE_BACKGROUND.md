# Floating Cube Background System

## Overview

A real-time 3D cube particle system with three interactive modes (Standard, Merge, Orbit). Renders cubes using `CustomPaint` with rotation animation and supports mouse hover repulsion.

**Source**: `lib/core/widgets/particles/floating_cube_background.dart`
**Mode Toggle**: `lib/core/widgets/particles/cube_mode_cubit.dart`
**Toggle Widget**: `lib/core/widgets/atoms/animated_cube_mode_toggle.dart`

---

## 1. Architecture

### CubeMode Enum (`cube_mode_cubit.dart`)
- `standard` — Default. Cubes float with random drift; small cubes repel each other.
- `merge` — Similar-size cubes attract, orbit, then death-spiral collapse into one larger cube.
- `orbit` — Large cubes become cores, capturing smaller cubes as orbiters.

### CubeModeCubit
- Persists mode to `SharedPreferences` under key `cube_mode`.
- Cycles: standard → merge → orbit → standard.

### AnimationController
- 60-second loop, drives `_updateEntities` every frame via `addListener`.

---

## 2. Mode Rules

### Standard Mode
- Big cubes ignore small cubes (size ratio < 0.4 — either direction).
- Small cubes repel each other with force `0.04` over range `0.06` (via `applyRepulsionFrom`).
- Optional repel point (mouse hover): pushes cubes away from cursor within `0.25` range, force `0.30`.
- Burst effect: explosion from point within `0.65` range, force `0.60`.

### Merge Mode

**Key Rules & Mechanics:**

**1. Match Conditions:**
- Merging ONLY happens between almost identical cubes (`sizeRatio >= 0.95`).
- Distance logic relies on `baseDistPixel = a.renderSize + b.renderSize`.

**2. Pre-Spiral Phase (Attraction/Repulsion):**
- **Attraction Range**: `baseDistPixel * 8.0`
- **Safe Distance**: `baseDistPixel * 3.0`
- Cubes gently pull each other until they reach `safeDistancePixel`. If they get closer than `0.9 * safeDistancePixel` prematurely, they gently repel back to the safe distance.
- *CRITICAL RULE*: NO orbital/perpendicular forces are applied in this phase. Centrifugal forces would cause them to separate and prevent the death-spiral from ever initiating.

**3. Third-Cube Repulsion ("The Shield"):**
- If a pair is actively in a death-spiral, they must not be interrupted.
- ANY non-spiraling cube entering a massive `repelRange = max(0.1, (baseDistPixel * 5.0) / width)` is pushed away with extreme force. The spiraling pair also gently drifts away from the intruder.

**4. Mismatched Cubes (`sizeRatio < 0.95`):**
- Repel each other if within `baseDistPixel * 3.5`.

**5. Spiral Initiation:**
- Triggers **instantly** (no proximity timers) when identical cubes get within `safeDistancePixel * 1.5`.
- `totalInitRadius` starts at `max(distPixel, safeDistancePixel)`.
- Initial radii are mass-weighted based on cube `count` so the pair rotates around a perfect barycenter.

**6. Death-Spiral Collapse ("The Smash"):**
- **Timer Scaling**: The background is driven by a 60-second `AnimationController`. Thus, `dt` represents a fraction of 60 seconds, not real-time seconds. Timers MUST accumulate `dt * 60` to count in real seconds.
- **Duration**: Exactly `4.0` real seconds.
- **Speed**: `spiralSpeed` linearly accelerates from `1.5` to `12.0` over the duration.
- **The "Smash" Radius**: The final target distance between centers is `collisionRadiusPixel = baseDistPixel * 0.2`. Because the cube's physical boundaries extend roughly `0.5 * baseDist`, a target distance of `0.2` guarantees deep visual overlap (a "smash") in the final frames before merging.
- **Shrink Curve**: `spiralRadius` interpolates from `spiralInitialRadius` to `targetRadius` using a squared curve (`collapseProgress * collapseProgress`), causing a sudden snap at the end.
- **Merge Execution**: Triggers precisely at `collapseProgress >= 0.999`. The loop MUST iterate over `_entities.toList()` to avoid `ConcurrentModificationError` when removing the original cubes and inserting the merged cube.

### Orbit Mode

**Core definition:**
- A cube is a core if `parentCore == null && renderSize > 12.0`.

**Capture mechanics:**
- Core captures cubes within `captureRadius = 0.06 + core.renderSize * 0.006`.
- Captured cube must have `renderSize < core.renderSize * 0.7`.
- Max 12 orbiters per core.
- On capture: core's `count` increases by orbiter's count.

**Orbiter behavior:**
- Position: `x = core.x + orbitRadius * cos(angle)` and `y = core.y + orbitRadius * sin(angle) * cos(orbitTilt)`.
- `orbitRadius = max(dist, 0.04)`.
- `orbitSpeed = (0.5 + random*2.5) / (0.3 + radius*4) * 0.75`. The `* 0.75` is the 25% speed reduction.
- `orbitTilt = (random - 0.5) * 0.6` for 3D visual effect.
- Angle advances by `orbitSpeed * dt * 60 * speed` each frame.

**Escape conditions:**
- Core's speed (`sqrt(vx² + vy²)`) > 0.3 AND orbiter's radius > 0.12.
- On escape: orbiter gets random velocity `(random - 0.5) * 0.08`, core's `orbiterCount` decrements.

**Core-core interaction:**
- Repeated twice per frame for both capture-repulsion and escape-repulsion.
- Repulsion: force `0.02` within range `0.2`, also `0.015` within range `0.03`.
- Absorption: if sizeRatio < 0.4, smaller becomes orbiter of larger.

**Gravitational pull:**
- Cores attract free-floating cubes within `distSq < 0.0625` (0.25 range) with force `0.0005 / (dist + 0.01)`.

**Core growth:**
- Cores do NOT grow visually on capture. Only `count` increases for tracking.
- The `targetSize` is only set on merge (death-spiral or direct merge).

---

## 3. Entity Management

### `_MergeEntity` class
All state fields live on the entity:

| Field | Type | Purpose |
|---|---|---|
| `x`, `y` | double | Position (normalized 0-1) |
| `vx`, `vy` | double | Velocity |
| `_baseVx`, `_baseVy` | double | Base velocity for decay |
| `count` | int | Number of base cubes merged into this |
| `renderSize` | double | Visual size (lerps toward targetSize) |
| `targetSize` | double | Target visual size |
| `rx`, `ry`, `rz` | double | Rotation angles (radians) |
| `vrx`, `vry`, `vrz` | double | Rotation velocities |
| `mergeTimer` | double | Seconds spent near another cube |
| `mergeCooldown` | double | Seconds before can merge again |
| `parentCore` | _MergeEntity? | Orbit core reference |
| `orbitRadius/angle/speed/tilt` | double | Orbital parameters |
| `orbiterCount` | int | Count of orbiters (core only) |
| `spiralPartner` | _MergeEntity? | Death-spiral partner |
| `spiralInitialRadius/angle/radius/speed` | double | Spiral parameters |
| `baseIndices` | List\<int\> | Indices into `_baseData` for split |

### `_BaseCubeData`
Read-only initial state for each base cube (size, position seed, rotation seed). Used when splitting merged entities back to individual cubes.

### Entity lifecycle
- **Init**: `_generateBaseData()` creates `_baseData` list. `_initFromBase()` creates `_entities` with unique offsets.
- **Merge**: Two entities collapse into one with combined `baseIndices`, summed `renderSize` → `targetSize`, mass-weighted position.
- **Split**: On mode change away from merge, `_splitMergedEntities()` reconstructs each base cube from `baseIndices`.
- **Free Orbiters**: On mode change away from orbit, `_freeOrbiters()` nulls all `parentCore` references.

### Mode transitions
- `merge → other`: `_splitMergedEntities()` + `_resetMergeState()`.
- `orbit → other`: `_freeOrbiters()`.
- `other → merge`: `_resetMergeState()`.

---

## 4. Rendering Pipeline

### `_CubePainter` (CustomPainter)
- Entities with NaN/Infinite x, y, or renderSize are skipped (safety guard against WASM Aborted).
- Each entity is projected into screen space via 3D rotation (Euler angles rx, ry, rz) then perspective projection to 2D.
- 8 vertices transformed, then 6 faces sorted by depth (painter's algorithm).
- Face brightness computed from Lambertian dot product with fixed light direction `(0.577, 0.577, 0.577)`, clamped to `0.25-1.0` range.
- Cubes sorted by renderSize (smallest first) for correct layering.
- `_drawFace` guards against non-finite coordinates as final safety layer.

### Color scheme
- Light mode: cube base `#D8D8D8`, stroke `0.7x brightness`.
- Dark mode: cube base `#505050`, stroke `0.7x brightness`.

---

## 5. WASM Aborted() & Physics Freeze Issues

**1. The CanvasKit Rendering Crash (NaN coordinates):**
- **Cause**: NaN or Infinity values in face coordinates reaching CanvasKit's `Canvas.drawPath`.
- **Three-layer safety net**:
  1. **Global NaN check**: After every entity update, sanitize x, y, renderSize, targetSize.
  2. **Painter entity skip**: Skip entity entirely if x, y, or renderSize is not finite.
  3. **Face coordinate guard**: Skip face if any of its 8 coordinates is non-finite.

**2. The `ConcurrentModificationError` Physics Freeze:**
- **Symptom**: Cubes get "stuck" at the end of an animation (like the 4-second merge) and never complete the action, rotating infinitely. The browser console logs a Dart `ConcurrentModificationError`, sometimes followed by a CanvasKit crash due to corrupted state.
- **Cause**: Calling `_entities.add` or `_entities.remove` while iterating directly over `for (final e in _entities)`. This aborts the physics frame halfway through.
- **Fix**: ALWAYS iterate over a copy of the list when modifying it: `for (final e in _entities.toList())`.

**3. The `dt` Time-Scaling Bug:**
- **Symptom**: Timers seem to take minutes instead of seconds to complete.
- **Cause**: The `AnimationController` runs from 0.0 to 1.0 over a 60-second duration. Thus, the computed `dt` is a *fraction of 60 seconds*, not actual seconds. `0.016` dt is actually 1/60th of 60 seconds (1 second).
- **Fix**: When accumulating real-time seconds, always use `timer += dt * 60;`. When applying velocity per-frame, use `vx * dt * 60 * speedMultiplier`.

---

## 6. Key Implementation Details

### Decay system
- Velocity decays toward `_baseVx`/`_baseVy` with factor `1 - 1.5 * dt * 60` each frame.
- Provides natural drift behavior: cubes return to base random movement after being pushed.

### Speed multiplier
- `speed` parameter (1.0 default) scales all velocities, rotation speeds, orbital speeds, and spiral angle advancement.
- Applied as `* widget.speed` in movement and rotation calculations, NOT in velocity decay.

### Boundary handling
- Soft repulsion zone `0.1` from edges with force `0.04`.
- Hard clamp to `[0, 1]` with bounce factor (`* 0.92`). Applied in `_MergeEntity.update()` for all entities.
- **Exception (spiral orbit)**: Death-spiral entities explicitly bypass bounds clamping, soft-edge repulsion, and random velocity perturbations in `_MergeEntity.update()` to preserve the clean circular orbit trajectory and prevent centroid wobble. Cubes may briefly go off-screen; the global NaN/Infinity sanitizer handles extreme values as final safety.
- Scroll drift pushes cubes upward when user scrolls down; drift-aware bounce at top/bottom edges amplifies bounce.

### Size lerp
- `renderSize += (targetSize - renderSize) * dt * 6.0` — smooth size transition.
- `dt * 6.0` ensures frequency-independent convergence.

### Random perturbation
- `vx += (random - 0.5) * 0.02` every `0.033` seconds in `update()`.
- In merge mode, additional `(random - 0.5) * 0.01` per frame added to non-spiraling entities.

