# Floating Cube Background System (V2)

## Overview

A V2 real-time 3D cube particle system with four interactive modes (Standard, Merge, Orbit, Gravity). Renders cubes using `CustomPaint` with rotation animation. Features Spatial Hashing (O(n) collision), Isolate offloading, Adaptive Rendering, Trail/Dust particles (primaryColor), and mouse hover repulsion.

**Source**: `lib/core/widgets/particles/floating_cube_background.dart`
**Mode Toggle**: `lib/core/widgets/particles/cube_mode_cubit.dart`
**Toggle Widget**: `lib/core/widgets/atoms/animated_cube_mode_toggle.dart`
**Shared Math**: `lib/core/widgets/particles/core/cube_geometry.dart` — `_CubePainter` delegates to `cg.cubeVerts`, `cg.cubeFaces`, `cg.cubeNormals`, `cg.computeRotation`, `cg.rotatePoint` (no duplicated constants).

---

## 1. Architecture

### CubeMode Enum (`cube_mode_cubit.dart`)
- `standard` — Default. Cubes float with random drift; small cubes repel each other.
- `merge` — Similar-size cubes attract, orbit, then death-spiral collapse into one larger cube.
- `orbit` — Large cubes become cores, capturing smaller cubes as orbiters.
- `gravity` — A constant downward acceleration pulls cubes toward the bottom of the screen, creating a falling/settling effect. Scroll drift still pushes cubes upward when the user scrolls down.

### CubeModeCubit
- Persists mode to `SharedPreferences` under key `cube_mode`.
- Cycles: standard → merge → orbit → gravity → standard.
- On construction, `loadSavedMode()` is called to restore the last saved mode from preferences.

### AnimationController
- 60-second loop, drives `_updateEntities` every frame via `addListener`.

### FloatingCubeBackgroundController & UI Integration
- Exposes `ValueNotifier<int> cubeCount` which tracks the exact number of entities. Used by `HomeNavbar` to display a live counter in Merge mode.

### `FloatingCubeBackground` parameters
- `topExclusion` (double, default `0.0`): Normalized fraction of the top area to exclude from cube spawning and movement. The home screen passes `70 / screenHeight` to reserve space for the app bar. Cubes spawn below this line, soft-repel at `topExclusion + 0.1`, and hard-clamp to `topExclusion`.

### Logo Burst Animation (Initial Load)
- A unified 1500ms `AnimationController` (`_logoAnimController`) orchestrates the entire transition in phases:
  - **0.0–0.15** (0–225ms): Logo at full size (scale=1.0), full opacity — allows HTML loader fade-out (300ms) to complete without visual gap.
  - **0.15–0.35** (225–525ms): Logo scales up from 1.0→1.15 (anticipation phase).
  - **0.35** (525ms): `triggerLogoBurst` fires at the peak of the scale, teleporting all cubes to the screen center with strong outward radial velocities and randomized rotations.
  - **0.35–0.40** (525–600ms): Logo holds at peak scale briefly as cubes begin to spread.
  - **0.40–1.0** (600–1500ms): Logo scales down (1.15→0.95) and fades out (1.0→0.0) simultaneously, revealing cubes already spread across the screen.
- The `triggerLogoBurst` function spawns cubes tightly behind the logo (radius ~ 0.0) with a strong outward velocity, creating a perfect "logo explodes into cubes" effect as the logo fades.

### Split-on-Tap (Merge Mode)
- In merge mode, tapping a merged cube (one with `count > 1`) splits it back into its two constituent cubes.
- Hit detection: largest cubes (drawn on top) are checked first; a hit occurs if the normalized tap point falls within the cube's bounding box (`renderSize × renderSize` centered on the entity's position).
- **Single-level undo**: Each merge stores the left and right `baseIndices` lists in `splitLeft` and `splitRight`. Split reconstructs two entities from these index lists, preserving the `_baseData`-sourced sizes accurately.
- **Two-level split history**: Deeper split fields (`splitLeftLeft`, `splitLeftRight`, `splitRightLeft`, `splitRightRight`) are propagated from the merging entities, allowing a split-once-merged entity to be split again — up to 2 recursive levels.
- **Escape Corner Trap (`ignoreRepelTimer`)**: Splitting gives the two new entities a 1.0 second `ignoreRepelTimer`. During this second, they completely ignore the mouse repulsion (`_hasRepelPoint`), allowing them to physically escape the cursor and screen corners without getting trapped.
- **Splitting during a spiral**: If a tapped cube is actively in a death spiral, the link to its `spiralPartner` is broken gracefully. The partner receives a short cooldown and a light repulsion velocity to safely interrupt the merge without causing a physics crash or `ConcurrentModificationError` side-effects.
- Tap dispatch logic in home screen: `trySplit(normalized)` is tried first. If it returns false (no merged cube hit), the fallback `burstAt` explosion fires.

---

## 2. V2 Performance Upgrades

### 2a. Spatial Hashing (`_SpatialHashGrid`)

**Purpose**: Replace O(n²) brute-force proximity checks with O(n) cell-based lookups. Essential for maintaining 60 FPS at higher cube counts on both mobile and desktop.

**Implementation**:
- `_SpatialHashGrid` class with an 11×11 fixed grid (121 cells, cell size = 0.1 normalized units).
- Pre-allocated `List<List<int>>` cells to avoid GC allocations per frame.
- `occupied` flag array tracks which cells are populated; `clear()` only visits occupied cells.
- `queryNeighbors(x, y, out)` collects entity indices from the cell containing (x,y) plus the 8 adjacent cells (9 cells total), filtering to the grid bounds.

**Usage per mode**:
- **Standard mode**: One spatial hash pass replaces the O(n²) `applyRepulsionFrom` loop.
- **Merge mode**: Two separate spatial hash passes — one for attract/repel/third-cube repulsion, one for spiral initiation.
- **Orbit mode**: Built once per frame, reused for gravitational pull, capture checks, and close-range repulsion. Core-core loops remain direct O(k²) since core count is typically < 10.

**SCRATCH LIST**: `_neighborScratch` is a single pre-allocated `List<int>` reused across all queries. Cleared inside `queryNeighbors()` each call.

### 2b. Isolate / WebWorker Offloading

**Purpose**: Offload math-heavy O(n²) repulsion calculations off the UI thread to avoid jank on low-powered devices.

**Implementation**:
- Top-level function `_physicsWorker(_PhysicsPayload)` annotated with `@pragma('vm:isolate-untagged')`.
- State serialized into `Float64List` (positions, sizes) and sent via `compute()` from `package:flutter/foundation.dart`.
- Worker returns `_PhysicsResult` containing `Float64List` of force deltas (fx, fy per entity).
- **Threshold**: Only triggers when `_entities.length >= 50` (configurable guard).
- **Fire-and-forget**: `_tryRunIsolate()` checks if a previous future is still pending; if not, sends a new payload. Results are applied in `.then()` callback when the future completes.
- **Safety**: Result length is clamped to current entity count to prevent index-out-of-bounds if entities were added/removed during computation.
- **Fallback**: On web, `compute()` executes synchronously on the main thread; no crash, just no parallelism.

**Current scope**: Only standard mode repulsion is offloaded. Merge and Orbit modes remain on the main thread because their logic is deeply coupled with entity object state (spiral cooldowns, core references, etc.). Spatial hashing provides the primary O(n) optimization for those modes.

### 2c. Adaptive Rendering (`_AdaptiveQuality`)

**Purpose**: Automatically reduce rendering complexity when frame rate drops below 30 FPS for 15+ consecutive frames, ensuring smooth interactivity.

**Implementation**:
- `_AdaptiveQuality` class tracks `_slowFrameCount`: incremented each frame where `dt > 0.033` (sub-30 FPS), reset to 0 on healthy frames.
- When `_slowFrameCount >= 15`, switches to `_QualityMode.low`.
- In **low quality mode**:
  1. `strokePaint` is **not drawn** in `_CubePainter` — saves fill+stroke double-draw per face.
  2. Trail/Dust particles are **disabled** — no spawn and no draw.
- In **high quality mode** (default): all features enabled.

---

## 3. V2 Visual & Interaction Upgrades

### 3a. Trail & Dust Particles (`_TrailPool`)

**Purpose**: Fast-moving cubes leave kinetic sparkle trails, and split explosions produce 3D spherical dust clouds. Both use the application's `primaryColor` for a cohesive branded look.

**`_TrailParticle` class**:
| Field | Type | Default | Purpose |
|---|---|---|---|
| `x`, `y` | double | 0 | Position (normalized 0–1) |
| `vx`, `vy` | double | 0 | Velocity — burst particles move, trail particles stay |
| `size` | double | 0 | Radius in pixels for `canvas.drawCircle()` |
| `opacity` | double | 0 | 1.0 = fully opaque, fades each frame |

**`_TrailPool`**: Ring buffer of **500 pre-allocated** particles. **Never uses `.add()` or `.remove()`**. `_writeIndex` cycles through the pool; each `spawn()`/`spawnBurst()` overwrites the particle at the current index.

**Kinetic trails** (`spawn()`):
- Trigger: entity speed `sqrt(vx² + vy²) > 0.15`.
- 1 particle per qualifying entity per frame, with positional jitter `±0.005` normalized.
- **Size**: `(0.5–1.2) × scale` where `scale = (entitySize / 12).clamp(0.3, 2.5)` — proportional to cube size but very small (average ~0.8 px radius).
- **Opacity**: `0.5–0.8` (randomized per particle for varied brightness).
- **Velocity**: Always 0 — trail particles do not move, they simply fade and shrink.

**Burst dust** (`spawnBurst()`):
- Trigger: `_splitEntity()` only (NOT on general tap).
- **3D Spherical Distribution**: Each particle is placed within a sphere using:
  ```dart
  theta = random × 2π                  // azimuth
  phi = acos(2 × random - 1)           // polar (uniform on sphere)
  r = spread × random^(1/3)            // cube-root for uniform volume
  dx = r × sin(phi) × cos(theta)
  dy = r × sin(phi) × sin(theta)
  dz = r × cos(phi)
  ```
  This creates a uniform particle cloud throughout the sphere volume, not just on the surface.
- **`dz` depth cue**: `zFactor = dz / spread` affects both size and opacity — particles toward the viewer (z > 0) are larger and brighter, particles away (z < 0) are smaller and dimmer, creating a 3D spherical illusion.
- **Size**: `(2.5–6.0 + zFactor × 1.5) × scale` — 3× larger than trail particles on average.
- **Velocity (Explosion Physics)**:
  ```dart
  speed = (0.8–2.3) × (dist / spread)  // farther from center = faster
  vx = (dx / dist) × speed + jitter
  vy = (dy / dist) × speed + jitter
  ```
  Each particle flies outward from the explosion center at a speed proportional to its distance from the center, simulating a real blast wave.

**Per-frame physics** (`_TrailPool.update()`):
```
// Movement
p.x += p.vx × realDt
p.y += p.vy × realDt

// Drag (slows down burst particles)
p.vx ×= 0.96^realDt
p.vy ×= 0.96^realDt

// Shrink (burst only — particles with non-zero velocity)
if (has velocity) p.size -= realDt × 0.12

// Fade (all particles)
p.opacity -= realDt × 0.02
```
- Drag factor 0.96 per frame means velocity decays to ~40% after 30 frames (0.5s).
- Shrink rate 0.12/s matches fade-out time — burst particles reach radius 0 and opacity 0 simultaneously.
- Trail particles (vx=0, vy=0) skip the shrink step — they only fade, maintaining their sparkle size.

**Rendering**: Drawn as small filled **circles** (`canvas.drawCircle`) **in front of** all cubes in `_CubePainter`. Color uses `primaryColor` with opacity × 0.35 for a subtle branded sparkle.
- **Disabled in low quality mode**.

**Usage**:
| Call Site | Count | Spread | Size Source |
|---|---|---|---|
| `_splitEntity()` | 40 | 0.06 | `source.renderSize` (split cube) |

### 3b. Mouse Hover Repulsion

**Purpose**: Cubes push away from the cursor, creating an interactive, lively feel.

**Implementation** (in `_MergeEntity.update()`):
- When `repelPoint` is set and entity is within `0.25` normalized units, apply outward force:
  ```dart
  final force = (0.25 - dist) / 0.25 * 0.30;
  vx += (dx / dist) * force;
  vy += (dy / dist) * force;
  ```
- The `ignoreRepelTimer` (from split escape logic) suppresses repulsion for 1 second after a split, allowing cubes to escape the cursor.

### 3c. Dynamic Mouse Light Source

**Purpose**: The mouse cursor acts as the 3D light source that illuminates cube faces. When the user moves the mouse, the lighting shifts dynamically as if a flashlight is following the cursor.

**Implementation** (in `_CubePainter.paint()`):
- `_CubePainter` receives an optional `repelPoint` (Offset?) parameter from the state.
- If `repelPoint != null` (mouse is over the widget), the light source is positioned at `(repelPoint.dx, repelPoint.dy, 0.5)` — the mouse X/Y in normalized space at fixed Z-depth above the cube plane.
- If `repelPoint == null` (mouse not over widget), the light source falls back to the fixed position `(isRtl ? 0.9 : 0.1, 0.05, 0.5)` — top corner based on layout direction.
- Per-entity light vector computation:
  ```dart
  ldx = lightX - entity.x
  ldy = entity.y - lightY
  ldz = 0.5
  // Normalize to unit vector, then Lambertian dot product per face:
  dot = nx × lx + ny × ly + nz × lz
  brightness = 0.25 + max(0, dot) × 0.75
  ```
- Same number of math operations whether mouse is active or not — **zero performance cost**.
- Covers all states:
  - **Mouse never touched**: `repelPoint` stays null → fixed light
  - **Mouse over widget**: `repelPoint` updates → light follows cursor every frame
  - **Mouse left widget**: `repelAt(null)` clears repelPoint → smoothly returns to fixed light
  - **Desktop/laptop with no mouse**: no PointerEvents → `repelPoint` never set → fixed light

---

## 4. Mode Rules

### Standard Mode
- Big cubes ignore small cubes (size ratio < 0.5 — either direction).
- Small cubes repel each other with force `0.04` over range `0.06` (via `applyRepulsionFrom`). Accelerated by Spatial Hashing + optional Isolate offloading.
- Mouse hover repulsion: pushes cubes away from cursor within `0.25` range, force `0.30`.
- Burst effect: explosion from point within `0.65` range, force `0.60`, plus extra close-range push (force 0.4 within 0.35).

### Merge Mode

**Key Rules & Mechanics:**

> **Attraction/Safe/Repel Ranges**: All normalized distance thresholds are capped to prevent cascade merges across the screen: `attractRangePixel` ≤ 300px, `safeDistancePixel` ≤ 150px, `repelRangePixel` ≤ 150px.

**1. Match Conditions:**
- Merging happens between sufficiently identical cubes (`sizeRatio >= 0.80`).
- Distance logic relies on `baseDistPixel = a.renderSize + b.renderSize`.

> **Note:** The similarity threshold was reduced from `0.95` to `0.80` to allow more cubes to merge together.

**2. Pre-Spiral Phase (Attraction/Repulsion):**
- **Attraction Range**: `baseDistPixel * 8.0`
- **Safe Distance**: `baseDistPixel * 3.0`
- Cubes gently pull each other until they reach `safeDistancePixel`. If they get closer than `0.9 * safeDistancePixel` prematurely, they gently repel back to the safe distance.
- *CRITICAL RULE*: NO orbital/perpendicular forces are applied in this phase. Centrifugal forces would cause them to separate and prevent the death-spiral from ever initiating.

**3. Third-Cube Repulsion ("The Shield"):**
- If a pair is actively in a death-spiral, they must not be interrupted.
- ANY non-spiraling cube entering a massive `repelRange = max(0.1, (baseDistPixel * 5.0) / width)` is pushed away with extreme force. The spiraling pair also gently drifts away from the intruder.

**4. Mismatched Cubes (`sizeRatio < 0.80`):**
- Repel each other if within `baseDistPixel * 3.5`.

**5. Spiral Initiation:**
- Triggers **instantly** (no proximity timers) when identical cubes get within `safeDistancePixel * 1.5`.
- `totalInitRadius` starts exactly at `distPixel`. This mathematically ensures the spiral orbit begins seamlessly from the cubes' current positions without any instantaneous teleportation jumps.
- Initial radii are mass-weighted based on cube `count` so the pair rotates around a perfect barycenter.

**6. Death-Spiral Collapse ("The Smash"):**
- **Timer Scaling**: The background is driven by a 60-second `AnimationController`. Thus, `dt` represents a fraction of 60 seconds, not real-time seconds. Timers MUST accumulate `dt * 60` to count in real seconds.
- **Duration**: Exactly `4.0` real seconds.
- **Speed**: `spiralSpeed` linearly accelerates from `1.5` to `12.0` over the duration.
- **The "Smash" Radius**: The final target distance between centers is `collisionRadiusPixel = baseDistPixel * 0.2`. Because the cube's physical boundaries extend roughly `0.5 * baseDist`, a target distance of `0.2` guarantees deep visual overlap (a "smash") in the final frames before merging.
- **Shrink Curve**: `spiralRadius` interpolates from `spiralInitialRadius` to `targetRadius` using a squared curve (`collapseProgress * collapseProgress`), causing a sudden snap at the end.
- **Merge Execution**: Triggers precisely at `collapseProgress >= 0.999`. The merge size uses `a.targetSize + b.targetSize` (rather than `renderSize`) to guarantee the cumulative sum is exact regardless of size lerp convergence. The loop MUST iterate over `_entities.toList()` to avoid `ConcurrentModificationError` when removing the original cubes and inserting the merged cube. The newly formed merged cube receives a `mergeCooldown` of 2.0 real seconds to prevent immediate cascading merges.

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

### Gravity Mode

**Core mechanic:**
- A uniform downward acceleration is added to every cube's `vy` each frame (all cubes fall at same rate, real physics):
  ```dart
  vy += 0.005 × realDt × speedMultiplier;
  ```
- **Heavy feel**: Gravity is 2.5× stronger than the previous value, so cubes fall fast and complete their bounce cycles quickly.
- **Physics flow** (varies by mode):
  - **Gravity mode**: perturbation → mouse repulsion → scroll drift → edge repulsion → gravity acceleration → air resistance → speed cap → position update → boundary bounce
  - **Non-gravity modes**: perturbation → mouse repulsion → scroll drift → edge repulsion → **speed cap** (`0.35`) → velocity decay → position update → boundary bounce
- **Bottom soft repulsion disabled**: The bottom-edge soft repulsion zone is skipped in gravity mode, allowing cubes to reach and settle at `y = 1.0` naturally.
- **Physics bounce**: When a cube hits the bottom edge (`y > 1`), it bounces with energy loss: `vy = -vy × (0.35–0.45)` (lose 55–65% energy per bounce). Combined with the stronger gravity, cubes exhibit only 2–3 visible bounces before settling.
- **Scroll drift interaction**: `vy -= scrollDrift × 2.0` runs **before** gravity (and before the speed cap & decay), so scrolling down pushes cubes upward against gravity. When scrolling stops, gravity pulls them back down — creating a "shake loose" effect from the bottom.
- Cubes fall with no size-dependent gravity — all cubes accelerate at the same rate regardless of mass. Perceived weight comes from bounce restitution and friction:
  - Terminal velocity ≈ 0.12–0.14 (reached within ~25 frames / 0.4s)
  - Small and large cubes fall at the same speed, but heavier cubes (larger) lose less energy to air resistance

**Tap interaction:**
- Tapping in gravity mode applies a radial push to nearby cubes with different parameters than other modes:
  - Range: 0.5 (vs 0.35 in other modes — wider catch area)
  - Base force: 0.8 (vs 0.4 — stronger push)
  - The force is scaled by `1 / sizeFactor`, so small cubes (factor 0.5) receive 2× push while large cubes (factor 2.0) receive 0.5× push — bottom-settled cubes of different sizes respond proportionally to their "weight"
- This allows the user to "flick" settled small cubes back into the air while large cubes barely budge, reinforcing the visual weight hierarchy

**Mode dispatch:**
- No additional spatial hash or extra physics runs in the mode dispatch block. Gravity is applied directly inside `_MergeEntity.update()`.

---

## 5. Entity Management

### `FloatingCubeBackgroundController` methods
- `repelAt(Offset?)`: Sets the repel point for mouse hover repulsion (range 0.25, force 0.30). Calling with `null` clears it.
- `burstAt(Offset)`: Explosive force from a point (range 0.65, force 0.60 + extra close-range push). In gravity mode, the close-range push uses a wider range (0.5), stronger force (0.8), and is scaled inversely by `sizeFactor` (1/sizeFactor) — big cubes are hard to push, small cubes fly easily.
- `triggerLogoBurst(Offset)`: Teleports all cubes to near the given center point with strong outward radial velocities. Used for the initial page-load logo explosion animation.
- `trySplit(Offset) -> bool`: Attempts to split a merged cube at the given normalized position. Returns true if a split occurred, false otherwise. The caller should fall back to `burstAt` on false. On split, 40 burst dust particles explode with 3D spherical physics, and the two resulting cubes receive a strong `pushForce = 0.3` away from each other.

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
| `ignoreRepelTimer` | double | Seconds to ignore mouse repulsion |
| `parentCore` | _MergeEntity? | Orbit core reference |
| `orbitRadius/angle/speed/tilt` | double | Orbital parameters |
| `orbiterCount` | int | Count of orbiters (core only) |
| `spiralPartner` | _MergeEntity? | Death-spiral partner |
| `spiralInitialRadius/angle/radius/speed` | double | Spiral parameters |
| `baseIndices` | List\<int\> | Indices into `_baseData` for split |
| `splitLeft` | List\<int\>? | Left half index list from last merge (null if never merged) |
| `splitRight` | List\<int\>? | Right half index list from last merge (null if never merged) |
| `splitLeftLeft` | List\<int\>? | Deeper left-left indices (for 2-level recursive split) |
| `splitLeftRight` | List\<int\>? | Deeper left-right indices (for 2-level recursive split) |
| `splitRightLeft` | List\<int\>? | Deeper right-left indices (for 2-level recursive split) |
| `splitRightRight` | List\<int\>? | Deeper right-right indices (for 2-level recursive split) |

### `_BaseCubeData`
Read-only initial state for each base cube (size, position seed, rotation seed). Used when splitting merged entities back to individual cubes.

### Entity lifecycle
- **Init**: `_generateBaseData()` creates `_baseData` list. `_initFromBase()` creates `_entities` with unique offsets.
- **Merge**: Two entities collapse into one with combined `baseIndices`, summed `renderSize` → `targetSize`, mass-weighted position. Split history fields (`splitLeft`, `splitRight`, etc.) are populated from the merging entities' own split history.
- **Split (mode change)**: On mode change away from merge, `_splitMergedEntities()` reconstructs each base cube from `baseIndices`.
- **Split (tap)**: In merge mode, `_trySplitAt(normalizedPoint)` finds the topmost merged cube under the tap point and calls `_splitEntity(source)`, which removes the merged entity and inserts two new entities reconstructed from the stored split index lists. Both split entities receive `mergeCooldown = 2.0` real seconds plus a strong repulsion velocity (pushForce=0.3) away from each other to prevent immediate re-merge. Additionally, 40 burst dust particles explode with 3D spherical physics (velocity, drag, shrink) at the split location.
- **Free Orbiters**: On mode change away from orbit, `_freeOrbiters()` nulls all `parentCore` references.

### Mode transitions
- `merge → other`: `_splitMergedEntities()` + `_resetMergeState()`.
- `orbit → other`: `_freeOrbiters()`.
- `other → merge`: `_resetMergeState()`.
- Gravity mode transitions to/from any mode without special cleanup — entities retain their positions and velocities naturally.

---

## 6. Rendering Pipeline

### `_CubePainter` (CustomPainter)
- **V2**: Accepts new parameters: `trailPool`, `qualityMode`, `repelPoint` (Offset? for dynamic mouse light source), `isLogoState` (bool).
- **V2 Trails**: In high quality mode, trail/burst dust particles are drawn as small filled **circles** (`canvas.drawCircle`) **in front of** all cubes. Color uses `primaryColor` with opacity × 0.35, creating a subtle branded sparkle effect.
- **V2 Dynamic Lighting**: Face brightness is computed from Lambertian dot product `dot = nx·lx + ny·ly + nz·lz`. The light source (lx, ly, lz) is calculated per entity from `repelPoint` (mouse cursor) when available, falling back to a fixed top-corner position based on layout direction. This provides responsive, real-time shading feedback as the user moves their mouse.
- **V2 Adaptive**: In low quality mode, `strokePaint` is not drawn and trail particles are skipped entirely.
- **V2.1 Rounded Corners (Logo State)**: When `isLogoState` is true (during pre-burst/gathering phases), each cube face is drawn using `cg.buildRoundedQuad` with the unified corner radius `(h * 0.22).clamp(0.3, max(0.3, h * 0.4))` (upper bound protected against `ArgumentError` when `h < 0.75`). When not in logo state (cubes are floating freely), sharp polygon paths are used for maximum performance.
- Entities with NaN/Infinite x, y, or renderSize are skipped (safety guard against WASM Aborted).
- `_drawFace` guards against non-finite coordinates as final safety layer.

### Logo State Angles & Spacing
During `_isPreBurst` and `_isGathering` states, the isometric projection uses:
- `rx = 0.70` (not the previous 0.615) — matches the brand logo's viewing angle
- `gap = 20.0` (reduced from 22.0) — makes the logo look more compact and proportional
- `e.renderSize = 18.0` — consistent cube face size for the 3×3×3 grid

### Color scheme
- **Cube Base**: Light mode `#D8D8D8`, Dark mode `#505050`. Modulated by dynamic brightness.
- **Cube Stroke (Edges)**: Solid `Theme.colorScheme.primary` (No opacity/transparency) for a striking, modern aesthetic that contrasts with the glassmorphic background. Skipped in low quality mode.

---

## 7. V2 Internal Classes

| Class | File Location | Purpose |
|---|---|---|
| `_SpatialHashGrid` | `floating_cube_background.dart` | 11×11 cell grid for O(n) proximity queries |
| `_AdaptiveQuality` | `floating_cube_background.dart` | Tracks frame time, auto-switches to low quality |
| `_TrailParticle` | `floating_cube_background.dart` | Dust particle — x, y, size, opacity, vx, vy |
| `_TrailPool` | `floating_cube_background.dart` | Ring buffer of 500 pre-allocated particles with physics update |
| `_PhysicsPayload` | `floating_cube_background.dart` | Serialized state for isolate (`Float64List`) |
| `_PhysicsResult` | `floating_cube_background.dart` | Force deltas from isolate |
| `_CubePainter` | `floating_cube_background.dart` | V2: trails in front, dynamic mouse light, adaptive quality |

---

## 8. WASM Aborted() & Physics Freeze Issues

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

**4. The Isolate Stale-State Issue:**
- Since `compute()` is fire-and-forget with async `.then()`, there is a potential race where entity indices change between payload build and result application.
- **Mitigation**: Result force-delta length is clamped to current `_entities.length`. Each index `i` applies `forceDeltas[i*2]` and `forceDeltas[i*2+1]` to `_entities[i].vx/_entities[i].vy`. If entities were added/removed, excess or missing indices are silently ignored.
- This guarantees no crash from index-out-of-bounds; at worst, a small force delta is lost.

---

## 9. Key Implementation Details

### Decay system
- Velocity decays toward `_baseVx`/`_baseVy` with factor `1 - 1.5 * dt * 60` each frame.
- Provides natural drift behavior: cubes return to base random movement after being pushed.

### Speed multiplier
- `speed` parameter (1.0 default) scales all velocities, rotation speeds, orbital speeds, and spiral angle advancement.
- Applied as `* widget.speed` in movement and rotation calculations, NOT in velocity decay.

### Scroll Drift (Critical Safety Notes)

**Purpose**: When the user scrolls the page, cubes smoothly drift upward/downward — a subtle parallax-like effect. Implemented via `FloatingCubeBackgroundController.scrollDrift` which is set to `delta / height` on each scroll event.

**Physics pipeline** (executes in this exact order every frame):
```
vy -= scrollDrift × 2.0          // 1. Apply scroll impulse (multiplier = 2.0)
// ... edge repulsion zone ...
speed = sqrt(vx² + vy²)          // 2. Speed cap (non-gravity modes only)
if (speed > 0.35) normalize to 0.35
decay = max(0, 1 - 1.5 × realDt) // 3. Decay toward base velocity
vx = _baseVx + (vx - _baseVx) × decay
vy = _baseVy + (vy - _baseVy) × decay
// ... gravity mode (if applicable) ...
// ... position update ...
```

**Protection layers** (TWO independent safeguards, do NOT remove either):

| Layer | Location | Purpose | Catches scrollDrift > |
|-------|----------|---------|----------------------|
| Clamp | `_updateEntities` L687: `.clamp(-0.08, 0.08)` | Limits raw scroll delta input | ~72px on 900px screen |
| Speed cap | `_MergeEntity.update` L1720: `if (speed > 0.35)` | Caps total velocity after impulse | `scrollDrift × 2.0 > 0.35` → `scrollDrift > 0.175` |

**With both layers intact, a single scroll event can move cubes at most ~11% of the screen height**.

**⚠️ Bug History (DO NOT REPEAT)**:

1. **Commit `bc77e3d`**: Multiplier was increased from `2.0` to `5.0` — a 2.5x change that made the drift feel too aggressive for all normal scrolling.
2. **Lost in refactor**: The original `_Cube` class had a speed cap at `0.35`. When the particle system was rewritten with `_MergeEntity`, this speed cap was **not carried over** to non-gravity modes, removing the second layer of protection.
3. **Result**: With multiplier `5.0` + no speed cap, a 100px mouse scroll produced `scrollDrift × 5.0 = 0.556` velocity, moving cubes **~36% of the screen** per event — far beyond the intended subtle effect.

**Fix applied (commit after investigation)**:
- Reduced multiplier back to `2.0` (original value)
- Added `clamp(-0.08, 0.08)` on the raw scrollDrift read (catches extreme scrolls)
- Restored the `speed > 0.35` cap for non-gravity modes (defence-in-depth)
- Both layers must remain in sync — if one is adjusted, the other may need re-evaluation

**Testing**: After any change to scrollDrift multiplier, clamp bounds, or speed cap value, test with:
- Mouse wheel click (large delta, ~100px): should feel like a gentle nudge, not a jarring jump
- Trackpad smooth scrolling (small continuous deltas): cubes should drift smoothly with no stutter

### Boundary handling
- Soft repulsion zone `0.1` from edges with force `0.04`.
- Hard clamp to `[0, 1]` with bounce factor (`* 0.92`). Applied in `_MergeEntity.update()` for all entities.
- **Top exclusion zone (`topExclusion`)**: A normalized parameter that shifts the effective top boundary downward. Cubes spawn at or below `topExclusion`, soft-repel at `topExclusion + 0.1`, and hard-clamp to `topExclusion`. Used to reserve space for UI elements like the app bar without visual displacement when they appear.
- **Exception (spiral orbit)**: Death-spiral entities explicitly bypass bounds clamping, soft-edge repulsion, and random velocity perturbations in `_MergeEntity.update()` to preserve the clean circular orbit trajectory and prevent centroid wobble. However, the spiral position is explicitly clamped to `[topExclusion, 1]` so no cube center ever exits the visible area during the death-spiral.
- Scroll drift pushes cubes upward when user scrolls down (see "Scroll Drift" subsection). Drift-aware bounce at top/bottom edges amplifies bounce when scrollDrift > 0.001.

### Size lerp
- `renderSize += (targetSize - renderSize) * dt * 180.0` — smooth size transition, reaches ~95% convergence in 1 real second.
- The high factor (180) guarantees the merged cube visually reaches its target sum-size within the 4-second death-spiral window, well before the next merge can occur.

### Random perturbation
- `vx += (random - 0.5) * 0.02` every `0.033` seconds in `update()`.
- In merge mode, additional `(random - 0.5) * 0.01` per frame added to non-spiraling entities.

### Gravity acceleration
- In Gravity mode, `vy += 0.005 × realDt × speedMultiplier` is added each frame **after** velocity decay. Gravity is uniform — all cubes fall at the same rate regardless of size (real physics).
- Applying gravity after decay prevents the decay from weakening the gravitational pull — cubes reach a steady falling speed independent of their random base velocity.
- The bottom-edge soft repulsion is **disabled** in gravity mode so cubes can settle naturally at `y = 1.0`.
- Bottom bounce uses physics-based energy loss: `vy = -vy × (0.35 + random × 0.10)` (55–65% energy lost per bounce). The rest threshold is `|vy| < 0.015` — cubes snap to rest quickly instead of micro-bouncing.
- On settle: strong floor friction (`vx *= max(0, 1 − 0.2 × realDt)`) kills horizontal slide rapidly. On bounce: impact friction `vx *= 0.6` heavily brakes sliding.
- The scroll drift subtraction (`vy -= scrollDrift × 2.0`) runs before gravity (and before the speed cap & decay in non-gravity modes), so scrolling down counteracts the gravitational pull. See the "Scroll Drift" subsection for the full physics pipeline and safety layers.

### Spatial Hash Scratch List Reuse
- `_neighborScratch` is a single `List<int>` allocated once per `_FloatingCubeBackgroundState` instance.
- It is reused across ALL spatial hash queries within a single frame, cleared by `queryNeighbors()` each time.
- This eliminates per-frame list allocations entirely.

### Trail Pool Ring Buffer
- `_writeIndex` wraps modulo `_kTrailPoolSize` (500). Old particles are naturally overwritten.
- No `List.add()` or `List.remove()` calls ever — the pool size is fixed at construction.
- Fade rate is constant per frame regardless of entity count, so densely packed trails fade consistently.
- Burst particles have velocity (vx, vy) that decays by 0.96× per frame, plus shrink rate of 0.12 px/s. Trail particles have zero velocity — they only fade.
- Physics update is batched in a single loop over all 500 particles — O(500) per frame regardless of entity count.

### Particle Size Scaling
- **Trail** size: `(0.5–1.2) × (size / 12).clamp(0.3, 2.5)` — trails are small dots proportional to cube size.
- **Burst** size: `(2.5–6.0 ± 1.5 depth) × (entitySize / 12).clamp(0.3, 2.5)` — burst particles are ~3× larger than trails, with depth-modulated size for 3D spherical illusion.
- Both scale factors use `size / 12.0` as the baseline (12.0 ≈ average base cube renderSize). Clamped to `[0.3, 2.5]` to prevent extreme sizes.

### 3D Spherical Dust Distribution
- Burst particles are distributed uniformly within a sphere volume using:
  - `theta = random × 2π` (azimuthal angle)
  - `phi = acos(2 × random - 1)` (polar angle — uniform on sphere surface)
  - `r = spread × random^(1/3)` (cube root — uniform volume distribution)
- The z-component (`dz`) modulates size and opacity, creating a realistic 3D depth cue: particles closer to the viewer (positive dz) appear larger and brighter.
- Initial velocity is radial from the explosion center, proportional to distance from center (`speed × dist / spread`), creating a convincing blast wave effect.
- Drag (`vx *= 0.96^realDt`) slows particles over ~0.5 seconds, while shrink (`size -= 0.12 × realDt`) and fade (`opacity -= 0.02 × realDt`) remove them gracefully.

### Burst Dust Exclusivity
- Burst dust particles only spawn on `_splitEntity()` (tap-split in Merge mode). General tap explosions (`triggerBurst()`) apply physics force only — no visual dust.
- This ensures burst dust is a meaningful, professional effect tied specifically to the "cube split" action.  
