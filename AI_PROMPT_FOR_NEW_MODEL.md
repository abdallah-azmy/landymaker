# Complete Prompt for AI Model — LandyMaker Cube Building System

> **IMPORTANT**: After completing ALL implementation changes below, you MUST output a report in **Arabic** summarizing exactly what you changed, in which files, and on which lines. The user speaks Arabic and needs to verify your work.

---

## 1. AI Documentation Files You MUST Read First

Before editing ANY code, read these files **in order**. They contain the LATEST specifications after multiple correction rounds:

1. **`docs/ai/FLOATING_CUBE_BACKGROUND.md`** — Full behavioral specification for the V2 cube particle system. Contains building phase rules (~2s parallel bricks, logo fade-out linked to progress), burst animation, grid projection constants, and all state transitions.
2. **`docs/ai/CUBE_ECOSYSTEM.md`** — Explains the TWO cube systems (CubeLoader vs FloatingCubeBackground). Do NOT confuse them. The building/brick code is in `FloatingCubeBackground`.
3. **`docs/plans/unified_brick_building_plan.md`** — Detailed bilingual plan document with the latest corrections: parallel building, JS interop for edge positions, **logo gradual fade** during building, **infinite HTML cube spawning**.

**Also read these source files fully before editing:**

| File | Purpose |
|------|---------|
| `lib/core/widgets/particles/floating_cube_background.dart` | Main cube particle system with building phase |
| `lib/features/home/screens/landymaker_home_screen.dart` | First-load orchestration |
| `web/index.html` | HTML loader, gathering cubes, logo, JS interop |
| `lib/core/utils/js_helper_web.dart` | JS interop (callJs, readJsArray) |
| `lib/core/utils/js_helper_stub.dart` | Stub for non-web platforms |

---

## 2. Complete Requirements (All User Messages Reconstructed)

### 2.1 HTML Side — `web/index.html`

#### 2.1.1 SVG Isometric Cubes
- 3D isometric SVG cubes (top/left/right faces) fly from viewport EDGES toward the logo.
- Cubes disappear **behind** the logo: `#gathering-squares` has `z-index: 1`, logo `<img>` has `z-index: 2`.
- CSS animation: `gather-loop`, `animation-iteration-count: infinite`.

#### 2.1.2 Logo Glow — Pure CSS (No JS Tracking)
- `logo-ramp` animation: 6 seconds, `cubic-bezier(0.4, 0, 0.2, 1) forwards`.
- Start: `brightness(0.6) drop-shadow(0 0 0px rgba(0, 229, 255, 0))`.
- End: `brightness(1.4) drop-shadow(0 0 20px rgba(0, 229, 255, 0.7))`.
- NO JavaScript tracking for glow — entirely CSS.

#### 2.1.3 Continuous Infinite Spawning (CRITICAL CHANGE)
**Current (wrong)**: 27 + 12 + 12 = 51 cubes total, then stops.

**Required**: Cubes spawn **continuously forever** with NO count limit.
- Remove the fixed 51-cube limit from `createGatheringSquares()`.
- Implement a **continuous spawner**: every ~500ms–1s, spawn a new cube from a random edge position.
- **Cleanup**: When a cube's animation loop finishes (~8s later), remove its DOM element so the page doesn't accumulate infinite DOM nodes. Max ~100–200 cubes visible at once.
- Use `setInterval` or recursive `setTimeout` with cleanup logic.
- Each cube still gets a random edge position from `getEdgePosition()`.

#### 2.1.4 81 Edge Positions for Flutter
- Pre-generate 81 edge positions and store as `window._htmlCubeEdgePositions = JSON.stringify(allPositions)`.
- Flutter reads these so its cubes launch from the exact same viewport positions as HTML cubes.

#### 2.1.5 JS Functions to Implement

| Function | Status | Description |
|----------|--------|-------------|
| `buildSvgCube()` | ✅ Exists | Creates SVG isometric cube |
| `getEdgePosition()` | ✅ Exists | Random normalized edge position {x, y} |
| `spawnGatheringCube(dur, delay, pos)` | ✅ Exists | Creates one CSS-animated cube element |
| `createGatheringSquares()` | ❌ **MODIFY** | Remove fixed limit → continuous spawning |
| `transitionToPersistentLogo()` | ✅ Exists | bg → transparent, pointer-events: none |
| `setLogoOpacity(value)` | ❌ **NEW** | Sets logo `<img>` opacity during building |
| `removePersistentLogo()` | ✅ Exists | Fades out + removes `#loading-indicator` (NOT called during first load) |

#### 2.1.6 `setLogoOpacity(value)` — NEW Function
```js
function setLogoOpacity(value) {
  var logo = document.querySelector('.loading-logo, .logo-persistent');
  if (logo) logo.style.opacity = String(value);
}
```
- `value` ranges from `1.0` (fully visible) to `0.0` (fully transparent).
- Exposed globally: `window.setLogoOpacity = setLogoOpacity;`

---

### 2.2 Logo Fade-Out During Building (CRITICAL CHANGE — Misunderstood Before)

**Previous (wrong)**: "Logo stays visible forever" — User now clarifies:

**Correct behavior**:
- Logo starts **fully visible** (`opacity: 1.0`).
- As Flutter cubes build the 3×3×3 big cube behind it, the logo **gradually fades out**.
- The fade is tied to `_brickRevealProgress / _brickTotalDuration`.
- By the time building completes (`_isBuilding = false`), the logo is **fully transparent** (`opacity: 0`).
- The logo IMAGE element stays in the DOM (never removed), just becomes invisible.
- The fade is **smooth and gradual** (~2 seconds, matching the building duration).
- This is the "transition" the user wants: the logo image slowly dissolves as the 3D Flutter cube solidifies behind it.

**Implementation**:
1. Add `setLogoOpacity(value)` JS function in `web/index.html` (see 2.1.6).
2. In Flutter's `_updateEntities` building loop (in `floating_cube_background.dart`), call `callJs('setLogoOpacity', (1.0 - _brickRevealProgress / _brickTotalDuration).toString())` every frame while `_isBuilding`.
3. You'll need to add a `callJsWithArg` helper in `js_helper_web.dart` / `js_helper_stub.dart` that passes a string argument to the JS function.

---

### 2.3 Flutter Brick Building — `floating_cube_background.dart`

#### 2.3.1 `_startBuildIntoLogo()` Method (line ~802)

Must:
- Set `_isBuilding = true`, `_preBurstValue = false`, `_isGathering = false`.
- Clear `_brickStartX`, `_brickStartY`, `_entityBrickIndex`.
- Reset `_brickRevealProgress = 0.0`.
- Read `window._htmlCubeEdgePositions` via `readJsArray('_htmlCubeEdgePositions')`.
- If HTML positions available (length ≥ `_totalBuildCubes`): use them for cube edge positions.
- Otherwise: fallback to `Random(42)` with viewport edge positions.
- Each cube `i` gets brick assignment: `_entityBrickIndex[i] = i ~/ _bricksPerGroup` (for `i < _totalBuildCubes`).
- Store start positions in `_brickStartX[i]`, `_brickStartY[i]`.
- Set ALL cubes: `renderSize = 0`, `targetSize = 0`.

#### 2.3.2 Constants (near line ~358)

```dart
static const int _bricksPerGroup = 3;
static const int _totalBricks = 27;
static const double _brickTotalDuration = 36.0;  // ~2 seconds
int _totalBuildCubes = _totalBricks * _bricksPerGroup;  // = 81
List<double> _brickStartX = <double>[];
List<double> _brickStartY = <double>[];
List<int> _entityBrickIndex = <int>[];
double _brickRevealProgress = 0.0;
```

**Remove** `_brickPlaced` — it's dead code from the old sequential approach.

#### 2.3.3 Building Loop — Parallel Execution (line ~1000)

All 27 bricks build **simultaneously in parallel** (NOT sequentially).

```dart
if (_isBuilding) {
  _brickRevealProgress += _realSec(dt) * 18.0;
  
  // --- Logo fade: call JS to update logo opacity in sync with building progress ---
  if (kIsWeb) {
    final opacity = (1.0 - (_brickRevealProgress / _brickTotalDuration)).clamp(0.0, 1.0);
    callJsWithArg('setLogoOpacity', opacity.toStringAsFixed(3));
  }
  // -------------------------------------------------------------------------
  
  if (_brickRevealProgress >= _brickTotalDuration) {
    _isBuilding = false;
    _preBurstValue = true;
    widget.controller?.onGatherComplete?.call();
  }
}
```

For each entity `i` where `i < _totalBuildCubes`:
- `brickIndex = _entityBrickIndex[i]`
- Compute 3×3×3 isometric grid target from `brickIndex` (same rotation math as pre-burst).
- `cubeInBrick = i % _bricksPerGroup` (0, 1, or 2).
- `cubeOffset = cubeInBrick * 0.33` (stagger within brick).
- `raw = _brickRevealProgress - cubeOffset`.

Three states:
1. **`raw <= 0`**: Hidden at edge (`_brickStartX[i]`, `_brickStartY[i]`), `renderSize = 0`.
2. **`0 < raw < 1.5`**: Flying edge→target with `cubic ease-out(1.0 - pow(1.0 - t, 3))` and pop-in overshoot scale. Primary cube (0) = `19.0 * popScale`, others = `8.0 * popScale`.
3. **`raw >= 1.5`**: Arrived. Primary cube = visible brick with snap pop-in (overshoot 1.3x → settle). Others = `renderSize = 0` (absorbed).

Extra cubes (`i >= _totalBuildCubes`): Drift toward center, hidden during building.

#### 2.3.4 Pre-Burst State
Primary cube (0) of each brick visible at grid position (`renderSize = 19.0`). Others absorbed. Extra cubes form staggered cluster behind grid.

---

### 2.4 Home Screen First-Load Flow — `landymaker_home_screen.dart` (line ~90-111)

```dart
if (_isThisTheFirstLoad) {
  _burstTriggered = false;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _transitionToPersistentLogo();     // HTML bg → transparent, logo visible
    _cubeController.buildIntoLogo();   // Flutter starts building bricks (logo fades here)
    _waitForLoadingThenRevealCubes();  // Wait for APIs + building done → burst
  });
}
```

**`_removePersistentLogo()` is NEVER called in first-load flow.** The logo element stays in the DOM. It fades via `setLogoOpacity()` from the Flutter building loop instead.

---

### 2.5 JS Interop Helpers

**`js_helper_web.dart`**: Must add `callJsWithArg(String name, String arg)`:
```dart
void callJs(String functionName) {
  js.context.callMethod(functionName);
}

void callJsWithArg(String functionName, String arg) {
  js.context.callMethod(functionName, [arg]);
}

List<Map<String, dynamic>>? readJsArray(String varName) {
  final val = js.context[varName];
  if (val is String) {
    try {
      final decoded = jsonDecode(val);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
  }
  return null;
}
```

**`js_helper_stub.dart`**: Add stub:
```dart
void callJs(String functionName) {}
void callJsWithArg(String functionName, String arg) {}
List<Map<String, dynamic>>? readJsArray(String varName) => null;
```

---

### 2.6 `removePersistentLogo()` HTML Function — Exists, NOT Called

The function at `web/index.html` line ~507-517 fades out `#loading-indicator` over 1500ms and removes it from DOM. This function:
- ✅ EXISTS
- ❌ **NOT called** during first-load building flow
- It's kept in the codebase for potential non-first-load scenarios

---

## 3. Implementation Checklist

### 3.1 HTML Changes (`web/index.html`)

- [ ] **Replace fixed spawning with continuous infinite spawning**: Instead of creating 51 cubes and stopping, implement a spawn loop that creates 1 new cube every ~500ms-1s forever.
- [ ] **Add DOM cleanup**: When a cube's animation finishes, remove its element to prevent infinite DOM growth. Target ~100-200 max visible.
- [ ] **Add `setLogoOpacity(value)` function** — sets `opacity` on `.loading-logo` element.
- [ ] **Expose `setLogoOpacity` globally**: `window.setLogoOpacity = setLogoOpacity;`
- [ ] **Keep all existing functions**: `buildSvgCube()`, `getEdgePosition()`, `spawnGatheringCube()`, `transitionToPersistentLogo()`, `removePersistentLogo()`.
- [ ] **Keep 81 edge positions**: `window._htmlCubeEdgePositions` generation.

### 3.2 Flutter Changes (`floating_cube_background.dart`)

- [ ] **Update comment** at building section (line ~1000-1004): Change "~139ms" to "~2 seconds".
- [ ] **Add `callJsWithArg('setLogoOpacity', ...)` call** in building loop every frame.
- [ ] **Remove `_brickPlaced`** dead code (declaration and initialization).
- [ ] **Verify `_brickTotalDuration = 36.0`** is correct.
- [ ] **Verify all cube states** (hidden/flying/arrived) work correctly during parallel building.

### 3.3 Home Screen (`landymaker_home_screen.dart`)

- [ ] **Verify `_removePersistentLogo()` is NOT called** in `addPostFrameCallback`.
- [ ] **Check `_persistentLogoRemoved` flag**: Either remove or only set if logo was actually removed.
- [ ] **Verify `_waitForLoadingThenRevealCubes()`** waits for both sections loaded AND building complete before triggering burst.

### 3.4 JS Interop (`js_helper_web.dart` + `js_helper_stub.dart`)

- [ ] **Add `callJsWithArg(String name, String arg)`** in both web and stub files.

### 3.5 Doc Files

- [ ] **`docs/ai/FLOATING_CUBE_BACKGROUND.md`**: Already updated — verify it's consistent with code changes.
- [ ] **`docs/ai/CUBE_ECOSYSTEM.md`**: Already updated — verify.
- [ ] **`docs/plans/unified_brick_building_plan.md`**: Already updated — verify.

---

## 4. Expected Final Behavior (Step by Step)

1. **Page loads**: HTML loader appears with LandyMaker logo image + CSS glow animation (6s ramp).
2. **Immediately**: SVG cubes start flying from viewport edges toward the logo.
3. **Cubes spawn continuously**: Every ~500ms-1s, a new cube appears from a random edge. No limit. Old cubes are cleaned up after ~8-10s.
4. **Cubes disappear behind logo**: `z-index: 1` (cubes) vs `z-index: 2` (logo), plus CSS animation fades them out at target.
5. **HTML gathering continues forever**: Cubes keep flying and spawning infinitely as long as the page is open.
6. **Flutter first frame**: `transitionToPersistentLogo()` makes the HTML background transparent so Flutter content shows through. Logo stays visible.
7. **`buildIntoLogo()` starts**: 81 Flutter cubes appear at the same edge positions as the HTML cubes (read from `window._htmlCubeEdgePositions`).
8. **Flutter cubes fly toward grid**: All 27 bricks build simultaneously in parallel. Cubes fly from viewport edges → isometric grid positions behind the logo.
9. **Logo gradually fades**: As `_brickRevealProgress` increases from 0 to 36, `setLogoOpacity()` decreases from 1.0 to 0.0. The logo image slowly dissolves over ~2 seconds.
10. **Building completes**: Big 3×3×3 cube is fully formed. Logo is fully transparent (still in DOM, just invisible). `_isPreBurst = true`.
11. **APIs respond**: Sections loaded + building complete → `triggerLogoBurst()` fires.
12. **Cubes explode outward**: Burst animation scatters cubes, content fades in.

---

## 5. Implementation Instructions

1. Read ALL doc files listed in Section 1 first.
2. Read ALL source files listed in Section 1 fully.
3. Implement each item in Section 3 checklist.
4. Keep all comments and doc files in sync — if you change a constant or behavior in code, update the corresponding `.md` files.
5. Follow existing code conventions (same import patterns, same variable naming, same formatting).
6. Do NOT add new files unless absolutely necessary.
7. Do NOT add emoji to any files.
8. Do NOT change the CubeLoader system — only modify FloatingCubeBackground, home screen, HTML, and JS helpers.

---

## 6. Final Deliverable

After completing ALL changes, output a **report in Arabic** that lists:

```
📋 تقرير التعديلات:
1. [اسم الملف:رقم السطر] — [وصف التغيير]
2. ...
```

List **every file modified**, the **line numbers**, and **exactly what changed**. Be specific:
- "غيرت _brickTotalDuration من 2.5 إلى 36.0 في floating_cube_background.dart:365"
- "أزلت _brickPlaced dead code في floating_cube_background.dart:370"
- "أضفت setLogoOpacity(value) في web/index.html:515"
- "غيرت createGatheringSquares() من 51 cube محدود إلى توليد مستمر في web/index.html:437"
- "أضفت callJsWithArg في js_helper_web.dart:8"
- إلخ
