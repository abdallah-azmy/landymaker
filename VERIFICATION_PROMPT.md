# Verification & QA Prompt for Cube Loader Optimization

## Mission

Run comprehensive verification on the Flutter project at `/Users/abdallahazmy/Projects/landymaker/`. The codebase has undergone 8 optimization/refactoring phases on the cube loader system. Your job is to **verify everything compiles, passes analysis, passes tests, and identify/fix any remaining bugs**.

---

## Context: What Changed

### Files Modified

| File | What Changed |
|---|---|
| `lib/core/widgets/particles/cube_loader.dart` | 6 paint methods → shared `_renderCubeFaces` helper. `Timer.periodic` → `AnimationController` (960ms explode). Preallocated `_faceBuffer` (162 `_FaceData`) + insertion sort `_sortFaces()`. Smooth rotation speed lerp (`_currentSpeed`). Hover layer highlighting (`_hoveredLayer`, `_onHoverMove`). Percentage overlay `Container` with semi-transparent background. **Removed** `success`/`error` states. **Added** `rotatingLayers` state. **Fixed** 6x `(h * 0.22).clamp(0.3, max(0.3, h * 0.4))` clamp upper-bound bug. |
| `lib/core/widgets/particles/floating_cube_background.dart` | Isometric angles (rx 0.615→0.70, gap 22.0→20.0). Added `isLogoState` flag + rounded-corner paths in `_CubePainter`. Added `_realSec()` helper, replaced all 11 `dt * 60` occurrences. **Fixed** `(h * 0.22).clamp(0.3, max(0.3, h * 0.4))` clamp upper-bound bug at line 2096. |
| `lib/core/widgets/particles/core/cube_geometry.dart` | `buildRoundedQuad` optimized to squared distances (1 sqrt per face instead of 4). |
| `lib/core/widgets/particles/loading_logo.dart` | Updated to reflect state changes (removed success/error, added rotatingLayers). |
| `lib/features/home/screens/landymaker_home_screen.dart` | Showcase dialog: removed Legacy/Success/Error cards, added Rotating Layers card, added `Tooltip` wrappers around 6 showcase cards with RTL support. |
| `test/core/widgets/particles/core/cube_geometry_test.dart` | **NEW** — 22 unit tests across 6 groups (computeRotation, rotatePoint, lambertBrightness, buildRoundedQuad, ambientOcclusion, occludedFaces). |
| `docs/` | Multiple doc files updated. |

### Critical Bugs Already Fixed

1. **`clamp(0.3, h * 0.4)` crashes when `h < 0.75`** (ArgumentError: Invalid argument: 0.3) — fixed to `clamp(0.3, max(0.3, h * 0.4))` in all 7 occurrences across `cube_loader.dart` + `floating_cube_background.dart`.
2. **`occludedFaces` test expectations** — corrected bitmask values for edge/face/isolated cube test cases.

---

## Step-by-Step Instructions

### Step 1: Run `flutter pub get`

Ensure all dependencies are resolved.

### Step 2: Run `flutter analyze`

Fix **every** warning and error, from most severe to least. Pay special attention to:
- Unused imports (especially `dart:async` was removed from `cube_loader.dart` — verify no trace remains)
- Dead code (the old `_paintSingle`, `_paintLogo` etc were merged — make sure no orphan methods)
- Type errors — the `_onHoverMove` callback uses `PointerHoverEvent` (from `package:flutter/gestures.dart`), ensure import is accessible

### Step 3: Run `flutter test`

All 22 tests in `test/core/widgets/particles/core/cube_geometry_test.dart` must pass.
Also run existing tests in `test/` to ensure no regression.

Fix any test failures. The `occludedFaces` test expectations were verified manually — double-check them by running the tests.

### Step 4: Run `flutter build apk --debug` (or `flutter build ios --debug`)

Catch any compile-time errors that `analyze` might miss.

### Step 5: Fix Any Remaining Issues

Act like a senior Flutter engineer. If you find:
- **NaN/Infinity risks**: Add guards with `.isFinite` checks
- **Concurrent modification risks**: When modifying lists during iteration, use `.toList()` copies
- **RTL/LTR issues**: Ensure `isRtl` is properly derived from `Directionality.of(context)` or `context.isRtl`
- **Performance issues**: Flag unnecessary rebuilds, missing `RepaintBoundary`, allocation-heavy hot paths

### Step 6: Report

After completion, print a report:
```
## Verification Report

### flutter analyze
- [PASS/FAIL] — list any remaining warnings

### flutter test
- [PASS/FAIL] — number passed / total / any failures

### flutter build
- [PASS/FAIL]

### Issues Found & Fixed
- List each issue with file:line and the fix applied

### Recommendations (if any)
- Optional suggestions for future improvements
```
