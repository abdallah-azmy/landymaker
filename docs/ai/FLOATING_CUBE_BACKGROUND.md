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

**Key constants:**

| Constant | Value | Description |
|---|---|---|
| `attractRange` | 0.06 | Max distance for attraction/repulsion |
| `attractForce` | 0.008 | Strength of attraction between similar-size cubes |
| `repelForce` | 0.003 | Strength of repulsion between different-size cubes |
| `orbitStrength` | 0.001 | Perpendicular force for orbital motion |
| `mergeDist` | 0.018 | Distance threshold for direct merge |
| `proximityDist` | 0.04 | Distance threshold for proximity tracking |
| `proximityTimerMerge` | 0.3 | Seconds in proximity before direct merge |
| `proximityTimerSpiral` | 0.15 | Seconds in proximity before spiral initiation |
| `spiralAccel` | 0.5 | Acceleration per dt*60 (spiralSpeed += dt*60*0.5) |
| `spiralMaxSpeed` | 6.0 | Max spiral speed before collapse |
| `spiralDist` | 0.04 | Max distance for spiral initiation |
| `spiralSizeRatio` | 0.6 | Min size ratio for attraction/spiral |
| `mergeCooldown` | 0.5 | Seconds after merge before entity can interact again |

**Similar-size cubes (ratio > 0.6):**
- Attract each other with force `0.008` when distance < `0.06`.
- Orbital perpendicular force `0.001` at intermediate distances.
- When proximity timer ≥ `0.15` and distance < `0.04`, they enter death-spiral.

**Death-spiral mechanics:**
- Both entities get `spiralPartner` reference to each other.
- `totalInitRadius` = `max(distPixel, touchRadiusPixel)` where `touchRadiusPixel = (a.renderSize + b.renderSize) * 0.866025` (i.e. `sqrt(3)/2`). This true pixel value accounts for the body diagonal of a 3D rotated cube, guaranteeing no visual overlap at any rotation.
- Radii are mass-weighted to ensure proper barycentric orbit: `a.spiralInitialRadius = totalInitRadius * (b.count / totalCount)`.
- `spiralAngle` initialized perfectly pointing from `cx` to the entity.
- `spiralSpeed` starts at `1.5`, accelerates by `dt * 60 * 0.5` per frame, capped at `6.0`.
- **Radius behavior (two-phase)**:
  1. **Stable orbit phase** (spiralSpeed < 6.0): `spiralRadius = spiralInitialRadius` — constant safe distance. The cubes orbit each other without any visual overlap.
  2. **Collapse phase** (spiralSpeed = 6.0): `spiralCollapseTimer` accumulates real seconds. `spiralRadius` linearly interpolates from `spiralInitialRadius` to the mass-weighted `targetRadius` over 1.5 seconds.
- Positions computed relative to mass-weighted centroid: `cx = (a.x*a.count + b.x*b.count) / totalCount`. The position incorporates true aspect ratio division `(spiralRadius / _screenSize.width)` to ensure perfect circular orbits on any screen size.
- When `collapseProgress >= 1.0` → merge into single entity exactly at centroid `cx, cy` with combined mass and summed renderSize, `targetSize` = sum of both sizes. New entity gets `mergeCooldown = 0.5`.

**Third-cube repulsion during spiral:**
- When a spiraling pair and a non-spiraling cube are within `0.06`:
  - Outsider pushed away with full force `(repelRange - d2) / repelRange * 0.015`.
  - Spiraling pair drifted together with `0.3x` force (same direction as outsider's push).
- Works for any cube size, not just similar sizes.

**Different-size cubes (ratio ≤ 0.6):**
- Repel each other with force `0.003` when distance < `0.06`.

**Direct merge (no spiral):**
- When proximity timer ≥ `0.3` **and** distance < `0.018`.
- Produces combined entity with summed renderSize and merged `baseIndices`.

**Proximity tracking:**
- Uses `inProximity` set to accumulate all entity pairs within `0.04`.
- Timer increments by `+dt` per frame while in proximity.
- Timer decays by `-dt * 3` when not in proximity.

**Attraction/repulsion scan:**
- For each pair where `distSq < 0.0036` (i.e., `0.06` range):
  - Skip if size ratio < 0.5 (too different to interact).
  - Skip if one is spiraling and the other is not (handled by third-cube repulsion above).
  - Skip if both are spiraling (they only interact with each other).
  - Skip if either is on `mergeCooldown`.

**Index shifting bug fix:**
- Uses direct object references (`spiralPartner` fields) instead of fragile index pairs.
- Merge loop uses `processed` set to handle each pair exactly once.
- Spiral initiation runs AFTER all merges complete, so entity list is stable.

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

## 5. WASM Aborted() Issue

**Root cause**: NaN or Infinity values in face coordinates reaching CanvasKit's `Canvas.drawPath`.

**Three-layer safety net**:
1. **Global NaN check** (`_updateEntities`, line 165-169): After every entity update, sanitize x, y, renderSize, targetSize. Applied to ALL entities regardless of mode.
2. **Painter entity skip** (`_CubePainter.paint`, line 959-962): Skip entity entirely if x, y, or renderSize is not finite.
3. **Face coordinate guard** (`_drawFace`, line 1092-1095): Skip face if any of its 8 coordinates is non-finite.

**Known triggers**:
- `cos(infinity)` or `sin(infinity)` during rotation angle computation (if rotation velocities push angles to extreme).
- Non-finite positions from velocity accumulation at low framerates.
- Edge cases in spiral computations with very small entities.

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

