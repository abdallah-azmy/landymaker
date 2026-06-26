# Splash Logo Animation Enhancement Plan

## Task Progress

* [ ] Phase 1: Fix HTML splash logo position jump during transition
* [ ] Phase 2: Fix 3D cube colors visibility in HTML splash
* [ ] Phase 3: Smooth color transition between splash and main page
* [ ] Phase 4: Enhanced cube gathering animation from screen edges (HTML + Flutter)
* [ ] Phase 5: Real-time Flutter cube building animation behind logo (block by block)
* [ ] Phase 6: Update documentation files

---

## Phase 1: Fix HTML Splash Logo Position Jump

**Goal**: Prevent the logo from shifting position when transitioning between the HTML loader's `loading-logo` class and the `logo-persistent` class, and when the HTML element is ultimately removed.

**Files involved**:
- `web/index.html`
- `lib/features/home/screens/landymaker_home_screen.dart`

**Root Cause Analysis**:
1. `loading-logo` uses `@keyframes logo-glow` (no `transform`, only `filter` + `drop-shadow`)
2. `logo-persistent` uses `@keyframes logo-breathe` (includes `transform: scale(1)` at 0%/100% and `scale(1.04)` at 50%)
3. Switching classes mid-animation causes the browser to initialize the new animation from its 0% keyframe, which has `transform: scale(1)` — this can cause a sub-pixel shift if `drop-shadow` from the previous animation affected the perceived position
4. `removePersistentLogo()` applies `transform: scale(1.2)` via inline style, then removes the DOM element after 2 rAF frames — the sudden removal while scaling can cause a visual "lurch" as Flutter canvas fills the gap

**Fix**:
1. Add `transform: translateZ(0)` and `will-change: transform, opacity, filter` to both `.loading-logo` and `.logo-persistent` for GPU compositing and consistent positioning
2. Ensure `logo-breathe` baseline includes the same `drop-shadow` as the end state of `logo-glow` to prevent shadow-size change on class swap
3. Update `removePersistentLogo()` to use a proper fade-out (scale to 1.05 + opacity 0 → remove) over a smoother easing curve, synced with Flutter's content fade-in

**Risks**:
- Low. Pure CSS/JS changes, no state management impact

**Validation**:
- Manual: Load page, observe logo position during all transition phases
- Manual: Test in Chrome DevTools with slow CPU throttling to see mid-animation states

---

## Phase 2: Fix 3D Cube Colors Visibility in HTML Splash

**Goal**: Make the SVG isometric cubes visibly distinct and vibrant against the dark background.

**Files involved**:
- `web/index.html`

**Root Cause**:
1. SVG cube faces use `opacity: 0.85`, `0.75`, `0.65` — these reduce vibrancy significantly on the dark `#030712` background
2. The `@keyframes gather` animation fades cubes from `opacity: 0.9` → `opacity: 0` over 1.8s — by the time cubes reach the center (logo position), they're nearly invisible
3. The cyan color range (`#00e5ff`, `#00c4e6`, `#0099b3`) is actually bright, but the combined effect of opacity + animation fade makes them hard to see

**Fix**:
1. Increase face opacities: `0.95`, `0.85`, `0.75`
2. Change animation so cubes stay visible at the end: `opacity: 0.9` → `opacity: 0.6` (instead of 0) so they remain visible around the logo
3. Add a subtle glow to each cube face (stroke glow) matching the brand color

**Risks**:
- Low. Pure CSS/SVG changes.

**Validation**:
- Manual: Verify cubes are visible during the gathering animation
- Manual: Check that cubes don't distract from the main logo

---

## Phase 3: Smooth Color Transition Between Splash and Main Page

**Goal**: Eliminate any perceptible color shift between the HTML loader background and the Flutter app background.

**Files involved**:
- `web/index.html`
- `lib/features/home/screens/landymaker_home_screen.dart`

**Root Cause**:
- HTML background: `#030712`
- Flutter dark theme surface: `#060A12` (from `AppColors.darkBackground`)
- The 1-shade difference (#030712 → #060A12) creates a visible flash when the HTML loader is removed
- The Flutter `AnimatedOpacity` `ColoredBox` fades from 1.0 to 0.0 over 800ms, but the final surface background is slightly different

**Fix**:
1. Change HTML background to `#060A12` to match Flutter's dark surface exactly
2. Ensure the `ColoredBox` color in home screen also uses `#060A12`
3. Increase the fade duration of the `_darkBg` overlay to 1000ms for smoother transition

**Risks**:
- Low. Color constant changes only.

**Validation**:
- Manual: Record screen capture, inspect frame-by-frame for any color shift

---

## Phase 4: Enhanced Cube Gathering Animation from Screen Edges

**Goal**: Create a professional animation where small 3D cubes visibly fly in from all corners/sides of the screen to converge on the logo position, staying visible behind the logo.

**Files involved**:
- `web/index.html`
- `lib/core/widgets/particles/floating_cube_background.dart`
- `lib/features/home/screens/landymaker_home_screen.dart`

**Current behavior**: 
- HTML: 27 cubes animate from a circular pattern (radius 80-220px) toward center over 1.8s, fading to invisible
- Flutter: Cubes are already scattered, then `_isGathering` makes them converge into logo formation

**Desired behavior**:
1. HTML cubes should spawn at screen edges (top, bottom, left, right) and fly toward center
2. They should stay visible (not fade out) when they reach the logo position
3. The gathering should feel dynamic — cubes arrive at slightly different times
4. When Flutter takes over, the cubes continue gathering into the logo formation seamlessly
5. The large cubes of the Flutter particle system should also start from outside the viewport and converge

**Implementation**:
1. Rewrite the HTML gathering squares to spawn from viewport edges with staggered delays
2. Keep cubes visible at the end of animation (opacity: 0.6 instead of 0)
3. Send start signal to Flutter via JS bridge to begin its gathering at the right time
4. Remove the circular pattern — use random positions on screen edges

**Risks**:
- Medium. Changes to animation timing could cause visual glitches if Flutter boot time varies
- Need to coordinate HTML and Flutter animations

**Validation**:
- Manual: Check that cubes fly in from edges and form the logo
- Manual: Verify seamless handoff between HTML and Flutter

---

## Phase 5: Real-Time Flutter Cube Building Behind Logo

**Goal**: After cubes gather to form the logo, the Flutter cubes should visibly BUILD the 3x3x3 cube structure one block at a time behind the HTML logo image, so the user sees the big cube growing incrementally.

**Files involved**:
- `lib/core/widgets/particles/floating_cube_background.dart`
- `lib/features/home/screens/landymaker_home_screen.dart`

**Current behavior**:
- Cubes snap into logo formation during `_isGathering`
- During `_isPreBurst`, all 27 cubes hold their positions simultaneously
- The logo appears instantly as a complete cube

**Desired behavior**:
1. Add a "building" phase between gathering and preBurst
2. During building, cubes appear one by one (or layer by layer) at the logo position with a small pop-in animation
3. Start with the back layer (z=1), then middle (z=0), then front (z=-1) — or bottom to top
4. Each cube has a small scale-up + fade-in when it builds
5. The process takes ~1-2 seconds so the user can see it happening
6. The HTML logo image stays on top as a foreground layer during this process

**Implementation**:
1. Add new state `_isBuilding` to `_FloatingCubeBackgroundState`
2. Track building progress with a simple counter/timer
3. Each frame, add a few more cubes to their target positions with scale animation
4. Once all 27 cubes are built, transition to `_isPreBurst = true`
5. Notify home screen when building is complete

**Risks**:
- Medium. New state added to particle system; must not break existing states
- Must ensure backward compatibility with preview mode (gatherIntoLogo → immediate preBurst)

**Validation**:
- Manual: Observe cube building animation on first load
- Manual: Verify cubes appear one by one
- Manual: Check that preview mode still works (skip building phase)

---

## Phase 6: Update Documentation

**Goal**: Keep all AI-facing documentation synchronized with the implementation changes.

**Files involved**:
- `docs/ai/AI_CONTEXT.md`
- `docs/ai/CUBE_ECOSYSTEM.md`
- `docs/ai/FLOATING_CUBE_BACKGROUND.md`
- `docs/ai/AI_DOCUMENTATION_RULES.md`

**Updates needed**:
1. `CUBE_ECOSYSTEM.md`: Update with new building phase state for FloatingCubeBackground
2. `FLOATING_CUBE_BACKGROUND.md`: Document the building phase, new constants, and flow
3. `AI_DOCUMENTATION_RULES.md`: Add any new rules for building phase

**Risks**:
- Low. Documentation only.

**Validation**:
- Read through each doc to verify accuracy
