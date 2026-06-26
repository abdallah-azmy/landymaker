# Cube Transition & Visual Refinement Plan

This plan details the technical steps required to refine the LandyMaker loading view, improve the transition into "Cube Preview Mode" by reusing floating particles, and resolve a coordinate teleportation/jump bug in the final moments of cube gathering.

---

## Part 1: HTML Loader Refinement (`web/index.html`)

### Objective
1. Increase the visual density of SVG cubes flying toward the logo by **3x** (three times more cubes) while keeping the spacing between spawns small and continuous (no large time gaps).
2. Maintain the **exact same rate of increase** for the logo's size and glow as the previous version (the logo should not grow 3x faster, even though 3x more cubes are arriving).
3. Increase the maximum scale limit of the logo image from **42% to 48%** (max scale `1.48`).

### Technical Details & Formula
- **Cube Spawn Interval Acceleration:**
  Previously, the spawn interval was calculated as `400 - (320 * progress * progress)`.
  To multiply the number of spawned cubes by 3, the spawn interval must be divided by 3:
  $$\text{spawnInterval} = \frac{400 - (320 \times \text{progress}^2)}{3}$$
  This starts the spawning rate at **133ms** and accelerates it down to **26.6ms** over 3.5 seconds, ensuring a highly continuous, dense stream of cubes from the beginning with no large gaps.
- **Logo Size/Glow Calibration:**
  Since cubes arrive 3x more frequently, the progress tracker `cubesGathered` will rise 3x faster. To keep the rate of scale and glow increase identical to before, we must multiply the `totalNeededCubes` by 3:
  $$\text{totalNeededCubes} = 15 \times 3 = 45$$
  This ensures `cubeProgress = Math.min(cubesGathered / 45, 1.0)` advances at the exact same rate as before.
- **Logo Maximum Scale:**
  In `updateLogoFrame()`, update the scale calculation factor to `0.48` for a maximum size of `1.48` (48% increase):
  `var scale = 1.0 + (0.48 * currentProgress);`

---

## Part 2: Seamless Preview Mode Transition (`lib/features/home/screens/landymaker_home_screen.dart` & `lib/core/widgets/particles/floating_cube_background.dart`)

### Objective
When transitioning into Preview Mode (`_isPreviewMode = true`), the cubes already floating on the homepage screen must fly **directly from their current coordinates** to form the logo, rather than abruptly scattering/teleporting to the viewport edges.

### Technical Details
- Locate `_startGatherIntoLogo()` in `floating_cube_background.dart`.
- **Remove the scattering loop** that assigns random viewport edge coordinates to `e.x` and `e.y`.
- Keep the physics velocity reset (`e.vx = 0; e.vy = 0;`) so that the cubes immediately halt their floating physical momentum.
- Since `_isGathering` is set to `true`, the `_updateEntities()` method will naturally ease them from their current `(e.x, e.y)` coordinates toward `(targetX, targetY)` using:
  `e.x += dx * 0.12;`
  `e.y += dy * 0.12;`
  This achieves a smooth, organic flight transition directly from their active floating positions.

---

## Part 3: Fixing the Gathering Coordinate Jump Bug (`lib/core/widgets/particles/floating_cube_background.dart`)

### Root Cause Analysis
During `_isGathering` (Preview Mode gathering):
- The target coordinates are calculated by placing entity index `i` at grid coordinate `i` directly (for `i < 27`):
  `int ix = (i % 3) - 1; int iy = ((i ~/ 3) % 3) - 1; int iz = (i ~/ 9) - 1;`
  This means entities `0..26` are assigned to grid positions `0..26`.
However, as soon as `allArrived` becomes true, the system transitions to `_isPreBurst` state, where it shifts to the brick-building data model:
- Target coordinates are calculated using `_entityBrickIndex[i]` which is initialized as `i ~/ 3` (3 cubes per brick).
- In `_isPreBurst`, only primary cubes where `cubeInBrick == 0` (indices `0, 3, 6, ..., 78`) are visible at grid targets `0..26`, while all other cubes are hidden (size 0).
- This causes a mismatch: Entity `26` (which was at grid position 26 in gathering) is suddenly mapped to grid position `8` with size 0, and Entity `78` (which was hidden at center in gathering) suddenly teleports to grid position `26` with size 19.
- This identity swap causes the sudden visual "jump" or teleportation in the final frames of gathering.

### Solution
In `_updateEntities()` inside the `_isGathering` branch, replace the `i < 27` coordinate mapping with the exact brick-based mapping used by `_isPreBurst` and `_isBuilding`:
- For `i < _totalBuildCubes`:
  - Fetch `brickIndex = _entityBrickIndex[i];` (which is `i ~/ 3`).
  - Fetch `cubeInBrick = i % _bricksPerGroup;`.
  - Calculate grid targets `ix, iy, iz` based on `brickIndex`.
  - Set `targetSize = (cubeInBrick == 0) ? 19.0 : 0.0;`.
  - This ensures that Entity `78` (and other primary indices) are the ones that actually fly to and occupy their correct grid positions during the gathering phase, matching the `_isPreBurst` state perfectly. No teleportation will occur when `allArrived` flips.

---

## Part 4: AI Instructions & Documentation Sync

Once the plan is executed and verified, the implementing model must:
1. **Update `docs/ai/FLOATING_CUBE_BACKGROUND.md`**:
   - Update the timing and spawn constants for the HTML loader (133ms down to 26ms spawning, 45 needed cubes, 48% scale ceiling).
   - Document the seamless preview transition rule (cubes ease from current floating coordinates).
   - Document the correct grid-mapping index logic for `_isGathering` (using `_entityBrickIndex` and `cubeInBrick == 0` check).
2. **Update `docs/ai/CUBE_ECOSYSTEM.md`**:
   - Align any described state or behavior with the new implementation.
3. **Review other files under `docs/ai/`**:
   - Ensure the home screen transition documentation accurately reflects the first-load cross-fade mechanism (`initialPreBurst` and `_logoAnimController` opacity fade) implemented in the previous iteration.
