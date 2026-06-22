# Master Plan: 3D Cube Loading & Logo Alignment Improvements

> **INSTRUCTION FOR EXECUTING AI AGENT**:
> 1. Read and fully understand the project context, file architecture, and rules before starting. Refer to [docs/ai/SYSTEM_MAP.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/SYSTEM_MAP.md) and [docs/ai/CUBE_ECOSYSTEM.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/CUBE_ECOSYSTEM.md).
> 2. Execute this plan **phase-by-phase**. Do NOT combine steps or rush.
> 3. After completing each phase:
>    - Mark the phase checkbox as complete `[x]`.
>    - Deliver a brief summary report in Arabic explaining what was modified.
>    - Ask the user explicitly in Arabic: **"هل أنت جاهز لتنفيذ الجزء التالي من الخطة ؟"** and wait for approval before moving to the next phase.
> 4. Ensure you perform strict NaN checks, avoid `ConcurrentModificationError` by duplicating lists when iterating and modifying, and maintain full RTL/LTR compatibility.

---

## Code Quality & Performance Suggestions (To Implement During Plan)

Upon a thorough review of the current codebase, the following performance optimizations and code quality improvements have been identified. You MUST implement these optimizations during the respective phases:

### 1. Optimize `cg.buildRoundedQuad` (Trig & Square Root Elimination)
- **Current Issue**: Inside `cube_geometry.dart:buildRoundedQuad()`, the helper calculates `.distance` 4 times per face to clamp `minEdge` bounds:
  ```dart
  for (int i = 0; i < 4; i++) {
    final j = (i + 1) % 4;
    minEdge = min(minEdge, (points[i] - points[j]).distance);
  }
  ```
  Calling `distance` invokes `sqrt()` 4 times per face. For the 3D logo with 81 visible faces, this is 324 square roots per frame.
- **Optimization**: Rewrite this function to compute **squared distances** (`(points[i] - points[j]).distanceSquared` or custom `dx*dx + dy*dy`) inside the loop, find the minimum squared distance, and then call `sqrt()` **only once** on that minimum value. This will eliminate 75% of the square root calculations.

### 2. Scratch Buffer Safety (Multi-Widget Concurrency)
- **Current Issue**: `_CubeLoaderPainter` uses static final lists for vertices/points scratch pads:
  ```dart
  static final List<List<double>> _tv = List.generate(8, (_) => [0.0, 0.0, 0.0]);
  static final List<Offset> _quadPts = List.filled(4, Offset.zero);
  ```
  Since `static` variables are shared across the class definition, if multiple `CubeLoader` widgets are painted concurrently in the same frame (such as in the showcase dialog with multiple active spinners), they will write to the same shared buffers, causing coordinates to overwrite each other and leading to visual glitches.
- **Optimization**: Move `_tv` and `_quadPts` to be instance variables of the painter class `_CubeLoaderPainter` (or pass them down from the widget state). This prevents concurrency bugs across multiple active loaders.

---

## Phase CHECKLIST

- [x] Phase 1: Corner Rounding Alignment & Success/Error Cleanup
- [x] Phase 2: Rotating Layers Animation Integration
- [x] Phase 3: Brand Logo Alignment in `FloatingCubeBackground`
- [x] Phase 4: Route Transitions & Unified Loader Audit
- [x] Phase 5: Documentation Update & Cleanup

---

## Phase 1: Corner Rounding Alignment & Success/Error Cleanup

### Objective
Standardize the corner rounding of all cube-based loaders to match the brand specifications and remove the legacy success/error states to maintain design consistency.

### Reference Files
- [cube_loader.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/widgets/particles/cube_loader.dart)
- [loading_logo.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/widgets/particles/loading_logo.dart)
- [landymaker_home_screen.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/home/screens/landymaker_home_screen.dart)

### Implementation Instructions
1. **Modify Corner Rounding**:
   - In `cube_loader.dart`, change `cornerRadius` calculation in all painter methods (`_paintLogo`, `_paintCluster`, `_paintLinear`, `_paintCircular`, `_paintPhysics`) to use the factor `0.22` of the face half-width `h`.
   - The unified formula should be: `final cornerRadius = (h * 0.22).clamp(0.3, h * 0.4);` (where `h` is the half-size of the cube face).
2. **Remove Success and Error States**:
   - Delete `success` and `error` states from the `CubeLoaderState` enum in `cube_loader.dart`.
   - Delete `success` and `error` states from `LoadingLogoState` enum in `loading_logo.dart`.
   - Remove their respective rotation speed coefficients in `_accumulateAngles()` inside `_CubeLoaderState`.
   - Remove success/error tinting, brightness additions, and stroke color override logic in `_CubeLoaderPainter._drawFaces()` and `_strokeColor()`.
3. **Update Showcase Dialog**:
   - In `landymaker_home_screen.dart`, locate `_showLogoTestDialog()`.
   - Remove the `Success` and `Error` items from the `_buildStateItem` row in the states preview section. Do NOT delete the other states (Idle, Breathing, Loading).

---

## Phase 2: Rotating Layers Animation Integration

### Objective
Incorporate the horizontal layers rotation effect from the legacy logo into `CubeLoader` to expand dynamic loading animations.

### Reference Files
- [cube_loader.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/widgets/particles/cube_loader.dart)
- [loading_logo.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/widgets/particles/loading_logo.dart)
- [landymaker_home_screen.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/home/screens/landymaker_home_screen.dart)
- [loading_logo_original.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/widgets/particles/loading_logo_original.dart) (Reference only)

### Implementation Instructions
1. **Add Enum States**:
   - Add `rotatingLayers` to `CubeLoaderState` in `cube_loader.dart` and `LoadingLogoState` in `loading_logo.dart`.
   - Update `LoadingLogo._mapState` to map `LoadingLogoState.rotatingLayers` to `CubeLoaderState.rotatingLayers`.
2. **Implement Layer Rotation inside `_paintLogo`**:
   - In `_paintLogo()` inside `cube_loader.dart`, check if `state == CubeLoaderState.rotatingLayers`.
   - Identify horizontal layers of the 3x3x3 grid based on the Y-axis coordinate slice index `j` (which goes from `-1` to `1`).
   - For each horizontal layer `j`, compute a layer-specific rotation angle:
     - `j == -1`: `layerRot = rotationAngle;`
     - `j == 0`: `layerRot = -rotationAngle * 0.5;`
     - `j == 1`: `layerRot = rotationAngle * 1.5;`
   - Rotate the small cube centers `cX` and `cZ` about the Y-axis using the computed `layerRot` *before* the general isometric rotation of the entire cluster.
   - Use standard trig rotation:
     ```dart
     final lc = cos(layerRot);
     final ls = sin(layerRot);
     final nx = cX * lc + cZ * ls;
     final nz = -cX * ls + cZ * lc;
     cX = nx;
     cZ = nz;
     ```
3. **Showcase Integration**:
   - In `landymaker_home_screen.dart`, add a new preview card showing the brand logo in the `rotatingLayers` state to `_showLogoTestDialog`.
   - Update the description of the dialog showcase to introduce this new animation effect.

---

## Phase 3: Brand Logo Alignment in `FloatingCubeBackground`

### Objective
Update the pre-burst logo and gathering animation in `FloatingCubeBackground` to align perfectly with the brand logo's geometry and perspectives, using rounded corners *only* while in logo state to preserve particle runtime performance.

### Reference Files
- [floating_cube_background.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/widgets/particles/floating_cube_background.dart)
- [cube_geometry.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/widgets/particles/core/cube_geometry.dart)

### Implementation Instructions
1. **Adjust Rotation and Spacing**:
   - In `floating_cube_background.dart`, inside `_updateEntities()`, locate the `_isPreBurst` and `_isGathering` conditions.
   - Update the isometric pitch angle `rx` from `0.615` to `0.70` to match the logo.
   - Change the logo spacing `gap` from `22.0` to `20.0` (with `e.renderSize = 18.0`) to make the logo look compact and proportional.
2. **Implement rounded corners in background painter**:
   - Pass `isPreBurst` and `isGathering` flags from the state to `_CubePainter`.
   - In `_CubePainter._drawFace`, if `isPreBurst` or `isGathering` is true, draw the face using `cg.buildRoundedQuad` with `cornerRadius = (h * 0.22).clamp(0.3, h * 0.4)` (where `h = cubeData.size * 0.5`).
   - If not in logo state (meaning the cubes have exploded and are floating), fall back to standard sharp polygon paths for speed and performance.

---

## Phase 4: Route Transitions & Unified Loader Audit

### Objective
Ensure that returning to the home screen `/` from `/login` correctly resolves and displays the updated transition loader, and verify that all full-page loading indicators use the correct loader state.

### Reference Files
- [app_router.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/router/app_router.dart)
- [landymaker_home_screen.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/features/home/screens/landymaker_home_screen.dart)
- All pages referencing `LoadingLogo()` (e.g. templates screen, dashboard screen, user profile screen, media library screen).

### Implementation Instructions
1. **Audit Loader Placements**:
   - Ensure all occurrences of page-level loaders (found in `DashboardHomeScreen`, `TemplatePickerScreen`, `LeadsTrackerScreen`, `MediaGalleryScreen`, `PlatformSeoScreen`, `UserProfileScreen`, etc.) use the updated, brand-aligned `LoadingLogo()` wrapper.
2. **Verify Route Transitions**:
   - Audit the back navigation transitions from `LoginScreen` to the main home screen. Ensure no visual glitches occur and that the `FloatingCubeBackground` initializes and transitions cleanly with the updated isometric pre-burst logo.

---

## Phase 5: Documentation Update & Cleanup

### Objective
Document the updated parameters, constants, and assets, and clean up deprecated files.

### Reference Files
- [CUBE_ECOSYSTEM.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/CUBE_ECOSYSTEM.md)
- [CUBE_LOADER.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/CUBE_LOADER.md)
- [FLOATING_CUBE_BACKGROUND.md](file:///Users/abdallahazmy/Projects/landymaker/docs/ai/FLOATING_CUBE_BACKGROUND.md)
- [loading_logo_original.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/widgets/particles/loading_logo_original.dart)

### Implementation Instructions
1. **Remove Legacy Files**:
   - Safely delete `loading_logo_original.dart` once its rotating layer and breathing effects have been fully integrated into `CubeLoader` and all showcase features have been migrated.
2. **Update AI Documentation Guides**:
   - In `CUBE_ECOSYSTEM.md`, update Section 10c (Corner Rounding) and 10b (Angles) to reflect the standardized `0.22` rounding factor and aligned transition projection angles.
   - Update `CUBE_LOADER.md` with the new enums and properties.
   - Update `FLOATING_CUBE_BACKGROUND.md` to document the rounded-corner rendering optimization.
