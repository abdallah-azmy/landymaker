# Flutter Web `ConcurrentModificationError` & CanvasKit Crashes

## Problem Overview
When working with particle systems, physics loops, or iterative physics updates in Flutter (specifically `FloatingCubeBackground`), you may encounter a bug where entities get "stuck" in a certain state (like infinite rotation) without completing their intended action (like merging).

This is often accompanied by a seemingly unrelated **CanvasKit WebGL crash** in the browser console:
```
RuntimeError: Aborted(). Build with -sASSERTIONS for more info.
canvaskit.js ... PictureRecorder
```

## Root Cause
The root cause is attempting to modify a List or Iterable while actively iterating over it. 
For example:
```dart
for (final a in _entities) {
  if (shouldMerge) {
    _entities.add(newEntity);
    _entities.remove(a); // <--- THROWS ConcurrentModificationError
  }
}
```

In Dart, this instantly throws a `ConcurrentModificationError`. 
Because this happens inside a critical physics update loop (like `_updateEntities` inside a `Ticker`), the exception aborts the current frame's physics step midway.

### Why it causes infinite loops / getting stuck:
Because the physics frame aborts, the entity is never actually removed from the list, and the merge never completes. On the very next frame, the engine tries to merge them again, throwing the error again. This results in the visual effect of the cubes reaching 99.9% completion and then freezing in that state infinitely.

### Why it causes CanvasKit to crash:
If a frame update aborts halfway through updating positions, the rendering pipeline (like `CustomPainter`) might try to read corrupted, partially-updated, or `NaN` (Not a Number) coordinates. Sending `NaN` or `Infinity` to `canvas.translate` or `canvas.drawPath` causes the underlying WebAssembly CanvasKit engine to fatally crash.

## The Solution
Always iterate over a copy of the list when you need to add or remove elements during the loop. Using `.toList()` creates a shallow copy of the list, allowing you to safely modify the original list.

**Incorrect:**
```dart
for (final e in _entities) { ... }
```

**Correct:**
```dart
for (final e in _entities.toList()) { ... }
```

## AI Rule
When implementing or modifying physics systems, collision detection, or entity life-cycles (merging, exploding, destroying), **ALWAYS check if `_entities.add` or `_entities.remove` is called inside a `for-in` loop**. If it is, ensure the loop is iterating over `.toList()`.
