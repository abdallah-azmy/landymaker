# Floating Cube Engine V2 Blueprint

**TARGET FILE:** `lib/core/widgets/particles/floating_cube_background.dart`

## Objective
Upgrade the physics engine with high-performance algorithms (Spatial Hashing, Isolates) and advanced visual mechanics (Parallax, Magnetic Hover, Trails, Adaptive Rendering) without breaking the existing CanvasKit WebGL architecture or the 60s `AnimationController` loop.

---

## Phase 1: Core Performance Upgrades

### 1. Spatial Hashing (O(n) Collision Detection)
**Context:** Currently, `_updateEntities` uses O(n^2) loops for `applyRepulsionFrom` and merge proximity checks. This will crash the browser at higher cube counts.
**Implementation Rules:**
- Create a `SpatialHashGrid` class with a predefined cell size (e.g., `0.1` normalized units).
- At the start of `_updateEntities`, clear the grid and insert all entities based on their `x, y` coordinates.
- During collision/proximity checks (Standard mode repulsion, Merge mode attraction, Orbit mode gravity), only check entities residing in the same cell and immediately adjacent cells (9 cells total).
- **CRITICAL:** Do not allocate new lists per frame. Pre-allocate cell lists or use flat index arrays to prevent Dart Garbage Collection stutters.

### 2. Isolate/WebWorker Offloading
**Context:** Math-heavy updates must not block the UI thread.
**Implementation Rules:**
- Extract the math logic of `_updateEntities` into a static, pure function.
- Use `compute(physicsUpdateLoop, PhysicsPayload)` from `package:flutter/foundation.dart`.
- **CRITICAL:** Dart objects like `_MergeEntity` cannot be easily sent across isolates without overhead. Extract the state of all cubes into raw arrays (`Float64List` or `Float32List`) for X, Y, RX, RY, RZ, Velocities, and Sizes.
- The UI thread should only pass the `Float32List` array to the Isolate, and the Isolate returns the updated array. The `CustomPainter` reads directly from this flat data buffer.
- *Fallback:* If full flat-array rewrite breaks the highly-coupled logic, at minimum, move the O(n^2) proximity search logic to the isolate and return a list of "collision events".

### 3. Adaptive Rendering (Auto FPS Balancing)
**Context:** CanvasKit performs differently on mobile vs desktop.
**Implementation Rules:**
- Track `dt` inside the animation loop.
- If `dt > 0.033` (sub-30 FPS) for 15 consecutive frames, trigger `QualityMode.low`.
- In `QualityMode.low`:
  1. Skip drawing `strokePaint` in `_CubePainter`.
  2. Disable the new Trail/Dust particles.
  3. Merge identical small cubes aggressively to reduce entity count.

---

## Phase 2: Visual & Interaction Upgrades

### 4. Trail & Dust Particles
**Context:** Fast-moving cubes should leave kinetic trails.
**Implementation Rules:**
- Add a lightweight `_TrailParticle` class (X, Y, size, opacity, color).
- Inside `_updateEntities`, if an entity's speed `sqrt(vx*vx + vy*vy) > 0.1`, spawn 1-2 dust particles at its current `x, y`.
- Draw these particles as simple filled rectangles in `_CubePainter` (behind the cubes).
- They must fade out (`opacity -= dt * 60 * 0.05`) and be removed when `opacity <= 0`.
- **CRITICAL:** Pre-allocate a fixed pool of particles (e.g., `List<_TrailParticle>.filled(500)`) and use a Ring Buffer index to spawn new ones. Never use `.add()` or `.remove()` on arrays every frame!

### 5. Magnetic Hover Mechanics
**Context:** Interaction should feel tactile, not just purely repulsive.
**Implementation Rules:**
- Modify `_MergeEntity.update` interaction with `repelPoint`.
- Define two zones based on distance to `repelPoint`:
  - **Zone 1 (Attract):** Distance between `0.15` and `0.35`. Apply a gentle positive pull (attraction) towards the cursor.
  - **Zone 2 (Repel):** Distance `< 0.15`. Apply an explosive repulsive force.
- This creates a "snap and bounce" magnetic effect.

### 6. 3D Camera Parallax
**Context:** The entire background should react to mouse movement to simulate a 3D box.
**Implementation Rules:**
- In `LandyMakerHomeScreen` (or via `repelPoint`), track the normalized mouse position `(mx, my)`. Calculate offsets from center: `dx = mx - 0.5`, `dy = my - 0.5`.
- Pass these offsets to `_CubePainter`.
- In `_CubePainter`, apply a global `canvas.transform()` or modify the projection math to tilt the entire coordinate system by `dx * 15 degrees` and `dy * 15 degrees` before drawing the cubes.
- **CRITICAL:** Use `Transform` matrices in Canvas rather than modifying every single vertex manually, to save CPU cycles.

---

## Strict Execution Directives
1. **Never Break CanvasKit:** If X, Y, or Size becomes `NaN` or `Infinity`, WebGL crashes instantly. Guard every mathematical operation (`/`, `sqrt`).
2. **Never Break AnimationController:** The 60s timer scales by `dt * 60`. Do not change this core architecture.
3. **No ConcurrentModificationError:** Never use `.add()` or `.remove()` on iterating lists. Use Ring Buffers or `.toList()`.
