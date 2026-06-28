# HTML Loading View System

## Overview

The HTML loading view (`web/index.html`) is the FIRST thing the user sees before Flutter boots. It displays the LandyMaker brand logo (`.webp` image) with a cinematic entrance: the logo grows from small to large while cyan glow intensifies, small SVG isometric cubes fly in from screen edges, and the background transitions from pure black to the page's theme color.

Once Flutter is ready, a **1.5s cross-fade transition** occurs: the HTML logo fades out while the Flutter 3D cube formation (in pre-burst state) fades in behind it. If the two look identical at the cross-fade midpoint, the user perceives a single continuous object.

**Source**: `web/index.html` (lines ~180–460 for the loading logic)

---

## 1. Visual Elements

### 0. Loading Indicator Container (`#loading-indicator`)
- **Height**: `height: 100dvh` (Dynamic Viewport Height) with `100vh` fallback via CSS cascade (`height: 100vh; height: 100dvh;`).
- **Why `100dvh`**: On mobile browsers, the browser chrome (address bar, bottom toolbar) reduces the actual viewport. `100vh` includes the chrome area, shifting the logo's geometric center upward relative to Flutter's canvas. `100dvh` uses the dynamic viewport, which excludes chrome, matching Flutter's canvas center exactly.
- Background: `#0F172A` (matches `AppColors.darkSurface`).
- z-index: 99999, `will-change: opacity`, `transition: background-color 0.4s ease`.

### 1a. Logo Image (`loading-logo`)
- HTML: `<img class="loading-logo" src="assets/assets/images/logo.webp">`
- CSS size: 90×90px, `object-fit: contain`
- z-index: 2 (on top of SVG cubes)
- Fallback: `logo_social.webp` if primary fails to load

### 1b. SVG Gathering Cubes (`gathering-squares`)
- Container: `div#gathering-squares` with z-index: 1 (behind logo)
- Each cube: 16×16px isometric SVG rendered as:
  - Top face: `#0ff` (cyan)
  - Left face: `#00c8ff`
  - Right face: `#0088cc`
  - Edge stroke: `#66f0ff`, width 0.5
- 81 pre-computed edge positions stored in `window._htmlCubeEdgePositions` (JSON string) for Flutter to reuse
- Each cube has CSS animation `gather-loop`:
  - 0%: invisible at edge position (scaled 0.3)
  - 15%: visible, flying toward target
  - 90–100%: reaches target near logo center, fades out (scaled 0.7)

### 1c. Background
- Starts at `#000000` (pure black)
- Transitions to detected page background via `prefers-color-scheme`:
  - Dark mode: `#030712`
  - Light mode: `#F8FAFC`
- Driven by time, NOT by cube arrivals: `bgProgress = elapsed / 2200` (2.2s)

---

## 2. Core JS Variables & State

| Variable | Type | Purpose |
|----------|------|---------|
| `_htmlCubesSpawning` | bool | Whether new cubes are being created (set false by `stopHtmlSpawning()`) |
| `cubesGathered` | int | Count of cubes that completed their flight |
| `totalNeededCubes` | int | 81 (max progress when 81 cubes arrive) |
| `currentProgress` | double | Smoothed logo progress (0.0 → 1.0), lerps toward target |
| `targetProgress` | double | Raw target: `cubeProgress × 0.7 + timeProgress × 0.3` |
| `_glowStartTime` | timestamp | When glow first started (`performance.now()`) |
| `_bgTransitionDone` | bool | Background finished transitioning |

---

## 3. Logo Scale & Glow Animation

Driven by `updateLogoFrame()` (rAF loop):

### Logo Scale
- Progress: `currentProgress` (smoothed, 0.0→1.0)
- Formula: `scale = 1.0 + (0.49 × currentProgress)`
- Max: `1.49` (49% increase from 90×90px base)
- Applied via: `logo.style.transform = 'scale(1.49) translateZ(0)'`

### Logo CSS Keyframe (`logo-ramp`)
- Applied via `animation: logo-ramp 3.8s ease-out forwards;` on `.loading-logo`
- **Max scale**: `1.35` (increased from `1.25` — an 8% increase)
- **Why**: The CSS keyframe max scale (1.35) determines the HTML logo's independent ramp-up animation. The `updateLogoFrame()` JS function further applies additional scaling via `currentProgress` (up to 1.49×). The keyframe value `1.35` was increased from `1.25` to visually match the enlarged Flutter logo cube (`renderSize = 19.5`) during cross-fade, preventing a size-divergence pop.

### Logo Glow (CSS Filter)
- Brightness: `0.6 + (0.61 × currentProgress)` → max `1.21`
- Shadow blur: `18 × currentProgress` → max `18px`
- Shadow opacity: `0.54 × currentProgress` → max `0.54`
- Shadow color: `rgba(0, 229, 255, ...)` (cyan / #00E5FF)
- Formula: `filter: brightness(1.21) drop-shadow(0 0 18px rgba(0, 229, 255, 0.54))`
- Applied via: `logo.style.filter = '...'`

### Progress Calculation
- 70% driven by cube arrivals: `min(cubesGathered / 81, 1.0)`
- 30% driven by elapsed time: `min(elapsed / 3800, 1.0)`
- Smoothed via: `currentProgress += (targetProgress - currentProgress) × 0.04`
- This ensures the logo always reaches max before the 12s fallback timeout

### Glow Reduction Note
All original glow values were intentionally reduced by 10%:
- Brightness: 1.35 → 1.21
- Shadow: 20px → 18px
- Opacity: 0.60 → 0.54

---

## 4. SVG Cube Spawning System

### Initial Burst
- **8 cubes** spawn immediately on first `spawnLoop()` call
- Prevents empty-screen appearance

### Spawn Parameters
| Parameter | Value |
|-----------|-------|
| Flight duration | 0.5–0.9s (random per cube) |
| Delay range | 0.15s |
| Spawn interval start | 100ms |
| Spawn interval end | 20ms |
| Acceleration window | 1.5s |
| Acceleration curve | Quadratic: `interval = (300 - 240 × progress²) / 3` |

### Spawn Logic (`spawnLoop()`)
1. Initial burst of 8 cubes (first call only)
2. Each subsequent call: spawn 1 cube at `getEdgePosition()`
3. Re-schedule with decreasing interval: quadratic acceleration over 1.5s
4. If `_htmlCubesSpawning` is false, the loop exits

### Edge Position Generation (`getEdgePosition()`)
- Randomly picks one of 4 screen sides (top/bottom/left/right)
- Positions cube outside viewport for fly-in effect
- Normalized to 0–1 range for Flutter compatibility
- 81 positions pre-generated and stored in `window._htmlCubeEdgePositions`

### Cube Cleanup
- Each cube has a `setTimeout` that fires after `(duration + delay) × 1000`ms
- On timeout: DOM node removed from container, `onCubeArrive()` increments counter
- `stopHtmlSpawning()` sets `_htmlCubesSpawning = false` but does NOT clear existing cubes — they finish their flight naturally

---

## 5. Persistent Logo Lifecycle

### 5a. `_forceLogoFinalState()`
Forces the logo to its maximum scale and glow immediately (no animation):
```javascript
logo.style.transform = 'scale(1.49) translateZ(0)';
logo.style.filter = 'brightness(1.21) drop-shadow(0 0 18px rgba(0, 229, 255, 0.54))';
```
- Called in BOTH `transitionToPersistentLogo()` and `removeLoader()`
- Ensures the logo always reaches final state before transitioning out

### 5b. `transitionToPersistentLogo()`
Called when Flutter first frame is ready:
1. `stopHtmlSpawning()` — stops creating new cubes, existing cubes finish flying
2. `_forceLogoFinalState()` — logo jumps to max scale/glow
3. `_bgTransitionDone = true` — stops background color lerping
4. Adds `persistent-mode` class → `pointer-events: none` (clicks pass through to Flutter)
5. Background fades from current color to `transparent` over 0.4s (CSS transition)

**CSS class effect**:
```css
#loading-indicator.persistent-mode { pointer-events: none; }
```

### 5c. `removePersistentLogo()`
Called by Flutter to initiate the 1.5s cross-fade:
1. `stopHtmlSpawning()` — stops new cubes
2. Loader fades to `opacity: 0` over 1.5s (CSS transition `opacity 1.5s ease`)
3. After 1550ms: loader removed from DOM

During this fade:
- Logo image fades out (as part of the loader opacity)
- SVG cubes also fade out (same opacity on parent)
- Flutter cube behind it fades IN (via `_logoAnimController` from 0→1 over 1.5s, driven by `landymaker_home_screen.dart`)

### 5d. `removeLoader()`
Safety fallback (12s timeout or direct call):
1. `stopHtmlSpawning()`
2. Clears cube container (`innerHTML = ''`)
3. `_forceLogoFinalState()`
4. Loader fades to `opacity: 0` over 0.25s
5. After 280ms: removed from DOM

---

## 6. Transition Wire-Up (Flutter Side)

In `lib/features/home/screens/landymaker_home_screen.dart` (lines 90–111):

```dart
if (_isThisTheFirstLoad) {
  _burstTriggered = false;
  _gatheringComplete = true;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _transitionToPersistentLogo();     // step 1: HTML bg → transparent
    _removePersistentLogo();           // step 2: HTML fades out (1.5s)
    _logoAnimController.forward();     // step 3: Flutter fades IN (1.5s)
    _waitForLoadingThenRevealCubes();  // step 4: wait APIs then burst
  });
}
```

Key points:
- `initialPreBurst: true` → Flutter cube starts as fully formed 3×3×3 grid (pre-burst state)
- HTML logo fades OUT and Flutter cube fades IN **simultaneously** over 1.5s
- After APIs load (min 1.5s, max 4s): `triggerLogoBurst(Offset(0.5, 0.5))` → cubes explode
- `_darkBg` (colored box behind everything, `#060A12`) fades out over 1s after burst

---

## 7. Key Parameters Summary (HTML Side)

| Parameter | Value | Location |
|-----------|-------|----------|
| Logo base size | 90×90px | CSS `.loading-logo` |
| Max logo scale | 1.49× (134.1px) | `updateLogoFrame()` |
| Glow max brightness | 1.21 | `updateLogoFrame()` |
| Glow max shadow blur | 18px | `updateLogoFrame()` |
| Glow max shadow opacity | 0.54 | `updateLogoFrame()` |
| Glow color | `rgba(0, 229, 255, ...)` | `updateLogoFrame()` |
| Background start | `#000000` | CSS `#loading-indicator` |
| Background end (dark) | `#030712` | JS `_bgTo` |
| Background end (light) | `#F8FAFC` | JS `_bgTo` |
| Background duration | 2.2s | `_lerpBg()` |
| SVG cube count | 81 (max) | `totalNeededCubes` |
| SVG initial burst | 8 | `spawnLoop()` |
| SVG flight time | 0.5–0.9s | `spawnGatheringCube()` |
| SVG spawn interval | 100ms → 20ms | `spawnLoop()` |
| SVG acceleration | 1.5s, quadratic | `spawnLoop()` |
| Progress weight | 70% cubes + 30% time | `updateLogoFrame()` |
| Progress smooth lerp | 0.04 | `updateLogoFrame()` |
| Persistent bg fade | 0.4s | `transitionToPersistentLogo()` |
| Cross-fade duration | 1.5s | `removePersistentLogo()` + Flutter |
| Safety timeout | 12s | `setTimeout(removeLoader, 12000)` |

---

## 8. Key Parameters Summary (Flutter Side, Pre-Burst State)

| Parameter | Value | Location |
|-----------|-------|----------|
| `gap` | **24.7** | `floating_cube_background.dart:894` |
| `renderSize` / `targetSize` | **19.5** | `floating_cube_background.dart:1069` |
| `strokeWidth` (logo state) | `(h × 0.10).clamp(0.8, 2.0)` | `_drawFace():2464-2465` |
| `strokeWidth` (free state) | `0.8` | `_CubePainter.paint():2222` |
| Stroke color (logo state) | `primaryColor` (theme-dependent, NOT cyan) | `_drawFace():2463` |
| Stroke color (free state) | `Theme.colorScheme.primary` | `_drawFace()` |
| Face color (dark) | `#505050` | `_CubePainter.paint()` |
| Face color (light) | `#D8D8D8` | `_CubePainter.paint()` |
| Lighting | Lambertian, `0.25 + max(0, dot) × 0.75` | `_CubePainter.paint()` |
| Light source | Dynamic (mouse) or fixed top-corner | `_CubePainter.paint()` |
| Glow color | `#00E5FF` (cyan) | `_drawFace()` |
| Glow opacity | 0.72 | `_drawFace()` |
| Glow blur | 7.0 (`MaskFilter`) | `_drawFace()` |
| Glow width | `h × 0.55` | `_drawFace()` |
| Corner radius (logo state) | `(h × 0.25).clamp(0.3, max(0.3, h × 0.40))` | `_drawFace():2435` |

---

## 9. Common Mistakes / Pitfalls

1. **The `.webp` logo is the source of truth** — the Flutter cube must match IT, not the other way around
2. **The cross-fade is 1.5s** — this is fast enough that minor mismatches are noticeable; major mismatches are jarring
3. **HTML uses a single overall drop-shadow**; Flutter uses per-face glow strokes — these produce different visual results and may need a different glow approach on one side or the other
4. **CSS `brightness()` filter** on the HTML logo lightens the entire image — Flutter has no direct equivalent; the glow brightness in Flutter is purely additive via the cyan stroke
5. **`_forceLogoFinalState()`** snaps the logo instantly — there's no gradual approach to final state during transition
6. **`stopHtmlSpawning()` does NOT clear existing cubes** — they finish flying; the 1.5s fade-out naturally takes care of them
7. **The background color detection uses `prefers-color-scheme`** — this only matches the OS preference, NOT the user's Flutter in-app theme choice (because the HTML runs before Flutter bootstraps)
8. **Service Worker Fallback Cache Injection Crash**: If CanvasKit (`canvaskit.js` / `canvaskit.wasm`) or fonts (Roboto) fail to load (due to offline state, local network blocker, etc.), the Service Worker's catch-all fallback block must **NOT** return `/` (which resolves to `index.html`'s HTML content). Returning HTML content for JS/WASM files crashes the dynamic loader of the Flutter Web Engine with a fatal `TypeError: Failed to fetch dynamically imported module`. The service worker must be restricted to only return `/` fallback if the request `Accept` header specifically contains `text/html` (document page routing).
9. **Service Worker Caching in Local Development**: Registering the service worker on `localhost` or `127.0.0.1` during debug runs causes aggressive caching of the JS files (`main.dart.js`, `flutter_bootstrap.js`), preventing Hot Reload/Hot Restart from taking effect and causing persistent white screens when the port or code changes. The service worker registration block in `index.html` must detect if the host is `localhost` or `127.0.0.1`, programmatically unregister any existing service worker, and prevent any new registration.
10. **Logo Image Transparency vs. Bounding Box Glow**: The main loader logo image (`logo.webp`) **must** be transparent on the outside, but keep its inner cube faces completely solid and opaque. If the logo has a solid background (black or dark blue), the CSS `drop-shadow` filter in `index.html` will apply to the rectangular boundaries (bounding box) of the image, causing a blocky, square-shaped glow behind the logo. If it is correctly transparent, the glow will trace the outer edges of the 3D cube shapes, producing a clean, round, organic glowing neon effect.
11. **Why HTML `height: 100dvh` and Flutter `gap: 24.7` / `renderSize: 19.5` must stay in sync**: The HTML logo and Flutter cube are cross-faded over ~1.5 seconds during first load. The HTML `#loading-indicator` uses `100dvh` to center the logo at the same Y-position Flutter considers center. The Flutter `gap` (24.7) and `renderSize` (19.5) produce a 3×3×3 cube grid whose visual extent matches the HTML logo's `logo.webp` bounding-box (843×981px, aspect ratio 1.1637). If any of these diverge — e.g., `height: 100vh` (includes browser chrome) shifts the HTML logo downward, or wrong gap/resize changes the cube size — there is a visible shape-pop or position-jump that breaks the seamless transition illusion.
