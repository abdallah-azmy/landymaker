# Master Plan: Cube Loader Performance, Code Quality & UX Polish

> **INSTRUCTION FOR EXECUTING AI AGENT**:
> 1. Read and fully understand the architecture context in `docs/ai/CUBE_ECOSYSTEM.md` and `docs/ai/CUBE_LOADER.md` before starting.
> 2. Execute this plan **phase-by-phase**. Do NOT combine steps or rush.
> 3. After completing each phase:
>    - Mark the phase checkbox as complete `[x]`.
>    - Deliver a brief summary report in Arabic explaining what was modified.
>    - Ask the user explicitly in Arabic: **"هل أنت جاهز لتنفيذ المرحلة التالية من الخطة؟"** and wait for approval before moving to the next phase.
> 4. Ensure you perform strict NaN checks, avoid `ConcurrentModificationError` by duplicating lists when iterating and modifying, and maintain full RTL/LTR compatibility.

---

## Overview

This plan addresses 8 concrete improvements across three dimensions:
- **Performance**: Reduce per-frame allocations and computational overhead in `_CubeLoaderPainter`
- **Code Quality**: Eliminate duplication, modernize animation patterns, add test coverage
- **UX**: Smooth transitions, richer interaction, polished showcase

All optimizations target `cube_loader.dart`, `cube_geometry.dart`, `floating_cube_background.dart`, and `landymaker_home_screen.dart`.

---

## Phase CHECKLIST

- [x] Phase 1: Preallocate `_FaceData` lists with known capacity — eliminate dynamic growth
- [x] Phase 2: Extract shared `_renderCube` helper — eliminate ~60 lines of duplication across 5 paint variants
- [x] Phase 3: Replace `Timer.periodic` with `AnimationController` for explode sequence
- [x] Phase 4: Add `_realSeconds` helper + documentation in `floating_cube_background.dart`
- [x] Phase 5: Smooth rotation speed transitions between CubeLoader states
- [x] Phase 6: Hover layer highlighting in `rotatingLayers` state
- [x] Phase 7: Tooltips and percentage overlay polish in showcase dialog
- [x] Phase 8: Unit tests for `cube_geometry.dart` functions

---

## Phase 1: Preallocate `_FaceData` Lists

### Objective
Eliminate dynamic `List.add()` growth allocations in all `_paint*` methods by preallocating face data lists with known maximum capacity.

### Reference Files
- `lib/core/widgets/particles/cube_loader.dart`

### Implementation Instructions
1. Create a `_FaceDataBuffer` utility class (or reuse pattern) that holds a `List<_FaceData>` of known max size:
   - Logo: 27 cubes × 6 faces = 162 max
   - Single: 1 × 6 = 6
   - Linear: 5 × 6 = 30
   - Circular: 6 × 6 = 36
   - Physics: 3 × 6 = 18
   - Cluster: 3 × 6 = 18
2. Replace `final faces = <_FaceData>[];` with `final faces = List<_FaceData>.filled(capacity, _dummy);` + integer index tracker.
3. After building, slice: `faces.sublist(0, count)` or pass `count` to `_drawFaces`.
4. Ensure `_dummy` is never read — only written before first read.

### Verifiable Outcome
- Zero `List.add()` calls in paint methods.
- No regression in visual output.
- No changes to public API.

---

## Phase 2: Extract Shared `_renderCube` Helper

### Objective
Eliminate the duplicated face-loop pattern present in `_paintSingle`, `_paintLinear`, `_paintCircular`, `_paintPhysics`, and partially in `_paintCluster`.

### Reference Files
- `lib/core/widgets/particles/cube_loader.dart`

### Implementation Instructions
1. Identify the common pattern:
   ```dart
   for (int v = 0; v < 8; v++) {
     cg.rotatePoint([vIn[0]*h, vIn[1]*h, vIn[2]*h], rot, _tv[v]);
     _tv[v][2] += cZ;
   }
   for (int f = 0; f < 6; f++) {
     cg.rotatePoint(n, rot, _nv);
     if (_nv[2] <= 0) continue;
     // compute sumZ, quadPts, buildRoundedQuad
     faces.add(...)
   }
   ```
2. Extract into `_renderCubeFaces(Offset center, double h, double cZ, RotationMatrix rot, ...)` that writes into the preallocated buffer and returns face count.
3. All paint methods call this helper.
4. Unit-test the helper by asserting face count from known rotation angles.

### Verifiable Outcome
- Single source of truth for face rendering.
- All 5 variants call the same helper.
- No visual regression.

---

## Phase 3: Replace `Timer.periodic` with `AnimationController`

### Objective
Modernize the tap-to-explode sequence — `Timer.periodic` is imprecise, doesn't integrate with Flutter's frame scheduler, and creates a potential leak if the widget is disposed mid-sequence.

### Reference Files
- `lib/core/widgets/particles/cube_loader.dart`

### Implementation Instructions
1. Add a second `AnimationController` for the explode animation (0–60 frames ≈ 960ms duration).
2. Replace `_startExplodeSequence()` with `_controller2.forward()`.
3. Listen to `_controller2` in `_accumulateExplode()` which reads the controller value (0→60) and computes `_explodeProgress` and `_tapRotation`.
4. Use the existing `AnimatedBuilder` to rebuild — or add a second listener.
5. Cancel/reset the controller in `dispose()`.
6. Remove `_startExplodeSequence()` and the `Timer.periodic` call.

### Verifiable Outcome
- No `Timer` usage in `_CubeLoaderState`.
- Explode animation driven by the frame scheduler.
- Automatic disposal on widget teardown.

---

## Phase 4: Add `_realSeconds` Helper in Floating Background

### Objective
Prevent the recurring `dt * 60` time-scaling bug documented in `FLOATING_CUBE_BACKGROUND.md` §8.3 by adding an explicit named helper.

### Reference Files
- `lib/core/widgets/particles/floating_cube_background.dart`

### Implementation Instructions
1. Add a top-level or private method `double _realSeconds(double dt)` that returns `dt * 60`.
2. Replace all `dt * 60` expressions in timer accumulations and velocity applications with `_realSeconds(dt)`.
3. Add a doc comment on the helper referencing the `AnimationController` duration.

### Verifiable Outcome
- All `dt * 60` occurrences use the named helper.
- No behavioral change (pure refactor + documentation).

---

## Phase 5: Smooth Rotation Speed Transitions

### Objective
When `CubeLoader.initialState` changes, the rotation speed should lerp rather than jump instantly, avoiding a visual stutter.

### Reference Files
- `lib/core/widgets/particles/cube_loader.dart`

### Implementation Instructions
1. In `_accumulateAngles()`, when `_currentState` changes, instead of switching the speed immediately, lerp the speed toward the target over ~0.5s.
2. Track `_targetSpeed` and `_currentSpeed` as state fields.
3. Each frame: `_currentSpeed += (_targetSpeed - _currentSpeed) * 0.1` (exponential ease).
4. Use `_currentSpeed` in the rotation accumulation, not a direct `switch`.
5. Reset `_currentSpeed` in `initState` and `didUpdateWidget`.

### Verifiable Outcome
- Speed changes are smooth (verified by watching the showcase dialog).
- No new fields exposed to public API.

---

## Phase 6: Hover Layer Highlighting in `rotatingLayers`

### Objective
When `interactive: true` and the user hovers over the logo in `rotatingLayers` state, highlight (accelerate) the layer nearest the cursor.

### Reference Files
- `lib/core/widgets/particles/cube_loader.dart`

### Implementation Instructions
1. Wrap the `GestureDetector` in `MouseRegion` with `onHover` callback capturing local position.
2. Compute which horizontal layer index `j` (‑1, 0, 1) the cursor Y maps to.
3. Pass `hoveredLayer` (int?) to `_CubeLoaderPainter`.
4. In `_paintLogo`, when `hoveredLayer == j`, multiply that layer's rotation speed by 2.0×.
5. Use `repaintNotifier` to trigger repaints on hover move (not just the animation tick).

### Verifiable Outcome
- Hovering over the top/middle/bottom layer accelerates it.
- `rotatingLayers` with `interactive: true` responds gracefully.

---

## Phase 7: Tooltips & Percentage Overlay Polish

### Objective
Improve the user-facing showcase dialog (`_showLogoTestDialog`) and the percentage overlay in `CubeLoader`.

### Reference Files
- `lib/features/home/screens/landymaker_home_screen.dart`
- `lib/core/widgets/particles/cube_loader.dart`

### Implementation Instructions
1. **Showcase tooltips**: Add `Tooltip` widgets to each `_buildShowcaseCard` in `_showLogoTestDialog` showing the variant name, cube count, and state.
2. **Percentage overlay**: Add a subtle semi-transparent background behind the percentage text in `CubeLoader.build()` so it's readable on light backgrounds.
3. RTL: Ensure tooltip messages use `context.isRtl` to display Arabic or English.

### Verifiable Outcome
- Every card in the showcase has a tooltip.
- Percentage text is readable on any background.
- RTL-aware messages.

---

## Phase 8: Unit Tests for `cube_geometry.dart`

### Objective
Add regression-proof unit tests for the shared geometry math to prevent silent breakage during future refactors.

### Reference Files
- `lib/core/widgets/particles/core/cube_geometry.dart`

### Implementation Instructions
1. Create `test/core/widgets/particles/core/cube_geometry_test.dart`.
2. Test `computeRotation` returns correct trig values.
3. Test `rotatePoint` on a known vector (e.g., [1,0,0] rotated 90° should give [0,0,1], etc.).
4. Test `lambertBrightness` returns expected range.
5. Test `buildRoundedQuad` produces a valid `Path` with expected number of verbs.
6. Test `ambientOcclusion` for center (6 neighbors → 0.65) and corner (3 neighbors → 1.0).
7. Test `occludedFaces` returns correct bitmask for center cube.

### Verifiable Outcome
- All geometry functions have test coverage.
- Tests pass on `flutter test`.
