# Task Progress

* [x] Phase 1 — Fix WPA HTML Loading View (logo jump + glow effect)
* [x] Phase 2 — Add Google Photo URL to Auth System & Display in Navbar
* [x] Phase 3 — Desktop Side Menu for Navbar Links
* [x] Phase 4 — Make Cube Explosion More Realistic (3D, full page spread)

---

# Phase 1: Fix WPA HTML Loading View

## Goal
Fix two issues in `web/index.html`:
1. **Logo position jumping**: The logo (`loading-logo`) jumps from center to below-center and back. Remove the transform scale animation and fix layout to keep it perfectly centered.
2. **Glow effect**: Change from repeated pulsing glow to a slow continuous glow that starts gradually and never stops.

## Files Involved
- `web/index.html`

## Risks
- Breaking the loading view appearance
- CSS animation compatibility across browsers

## Validation Steps
- Open the app as WPA / fresh load
- Verify logo stays perfectly centered during entire loading sequence
- Verify glow starts slow and continues steadily (no pulsing off)

## Implementation Details

### Fix 1: Logo Position Jumping
Current problem: 
- `animation: logo-charge 2.0s ... infinite alternate` uses `transform: scale(0.95)` to `scale(1.10)` which shifts the visual center due to transform-origin
- `border-radius: 50%` on the image combined with scaling causes perceived position shift
- Object-fit may compound the issue

Solution:
- Remove `border-radius: 50%` from `.loading-logo` (logo is square, not circular)
- Change animation to NOT use `transform: scale` — use only `filter` properties (brightness + drop-shadow)
- This keeps the image geometrically fixed in the center at all times
- Explicitly center using `display: flex` with `align-items: center; justify-content: center` on parent

### Fix 2: Continuous Glow Effect
Current:
```css
animation: logo-charge 2.0s cubic-bezier(0.4, 0, 0.2, 1) infinite alternate;
```
This loops every 2s, going from dim to bright back to dim.

New approach:
```css
animation: logo-glow 4s cubic-bezier(0.4, 0, 0.2, 1) forwards;
```
- Animation starts with no glow, slowly ramps up to full glow over 4s
- Stays at full glow (no "alternate" / no dimming)
- Uses `forwards` fill mode so it maintains final state

Actually better: Use a slow continuous glow that stays:
```css
@keyframes logo-glow {
  0% {
    filter: brightness(0.8) drop-shadow(0 0 0px rgba(0, 229, 255, 0));
  }
  100% {
    filter: brightness(1.3) drop-shadow(0 0 30px rgba(0, 229, 255, 0.9));
  }
}
```

---

# Phase 2: Add Google Photo URL & User Avatar in Navbar

## Goal
When a user is logged in via Google, show their Google profile picture in a circular avatar in the navbar. Clicking the avatar opens a popup/menu with a "Manage Google Accounts" option that opens Google's account management page.

## Files Involved
- `lib/services/supabase_service.dart`
- `lib/features/auth/controllers/auth_state.dart`
- `lib/features/auth/controllers/auth_cubit.dart`
- `lib/features/home/widgets/home_navbar.dart`
- `lib/core/constants/db_constants.dart` (if needed)

## Risks
- Breaking authentication flow
- Google OAuth user_metadata may not always have photo URL
- Fallback needed for non-Google logins (email/password)

## Validation Steps
- Sign in with Google → verify profile photo appears in navbar
- Sign in with email/password → verify initial-letter avatar shows (fallback)
- Click avatar → verify popup shows with manage accounts option
- Verify the Google accounts page opens in new tab

## Implementation Details

### Step 1: Add photoURL to SupabaseService
In `supabase_service.dart`:
- Add `String? _currentUserPhotoUrl` field
- Extract from `session.user.userMetadata['avatar_url']` when session is available
- Google stores the photo URL in `user_metadata['avatar_url']` via Supabase
- Expose via getter `currentUserPhotoUrl`

### Step 2: Add photoURL to Authenticated state
In `auth_state.dart`:
- Add `String? photoURL` field to `Authenticated` class
- Default to `null` for email/password users

### Step 3: Pass photoURL in AuthCubit
In `auth_cubit.dart`:
- Pass `photoURL: _authService.currentUserPhotoUrl` in all `emit(Authenticated(...))` calls

### Step 4: Update HomeNavbar to use photo
In `home_navbar.dart`:
- Read `photoURL` from `Authenticated` state
- When photoURL is available, use `NetworkImage(photoURL)` in `CircleAvatar` background
- When not available (email/password login), fall back to initial-letter avatar
- In `_UserAvatarMenu`: show profile picture or fallback initial
- When clicking the avatar popup, add "Manage Google Accounts" option that opens `https://myaccount.google.com/` in a new tab (and for non-Google users, just show normal dashboard/logout options)

---

# Phase 3: Desktop Side Menu for Navbar Links

## Goal
On desktop (>= 768px):
- Remove "الرئيسية", "المدونة", "القوالب" from the horizontal navbar links
- Move them (and all other page links) into a beautiful side menu
- Order: لوحة التحكم (if logged in), من نحن, الشروط والأحكام, سياسة الخصوصية, المدونة, تسجيل الدخول (if not logged in), ابدأ مجانا (if not logged in), القوالب, صفحة المكعبات
- Keep the current right-side items in the navbar (theme toggle, language, cube mode, avatar)

## Files Involved
- `lib/features/home/widgets/home_navbar.dart`

## Risks
- Breaking existing responsive behavior
- RTL support in side menu
- Theme compatibility (dark/light)

## Validation Steps
- Desktop view: verify no "الرئيسية", "المدونة", "القوالب" in main navbar
- Desktop view: verify hamburger/side menu button exists
- Click side menu: verify all links appear in correct order
- Verify each link navigates to correct page
- Verify side menu works in RTL and LTR
- Verify dark/light theme compatibility
- Mobile: verify no changes (mobile menu popup stays as is)

## Implementation Details

### New _DesktopSideMenu widget
Create a slide-out side drawer/menu for desktop:
- Icon button in the navbar that opens the side menu
- The side menu is a beautiful glassmorphism panel (matching site design)
- Contains ordered links:
  1. لوحة التحكم (only if logged in) → `/dashboard`
  2. من نحن → `/about`
  3. الشروط والأحكام → `/terms`
  4. سياسة الخصوصية → `/privacy-policy`
  5. المدونة → `/blog`
  6. تسجيل الدخول (only if NOT logged in) → `/login`
  7. ابدأ مجانا (only if NOT logged in) → `/register`
  8. القوالب → `/templates`
  9. صفحة المكعبات → `/cubes` (or wherever cubes are shown)

### Modifications to _DesktopNavbar
- Remove the `parsedLinks` section (the middle Row with links)
- Replace with a side menu icon button (hamburger) next to the logo
- Keep all right-side items unchanged
- When side menu icon is clicked, show the side menu drawer/overlay

### The side menu implementation options:
- Option A: Use an `EndDrawer` or custom overlay
- Option B: Use a flyout panel anchored to the left side of the navbar

I'll go with a custom overlay panel (like a popup) that slides down from the navbar, similar to how the mobile menu works but positioned without the PopupMenuButton limitations.

Actually, let me reconsider. The better approach for desktop is a slide-out drawer that overlays the content from the left side. This is more professional and matches what the user described as "قائمة جانبية" (side menu).

I'll implement it as:
- An `AnimatedContainer`/`AnimatedSlide` that comes from the left side of the navbar
- Glassmorphism design matching the site theme
- Proper links with icons
- Overlay backdrop when open

---

# Phase 4: Make Cube Explosion More Realistic

## Goal
Enhance the logo burst/explosion effect when the home page loads:
- Small cubes should fly out realistically in various directions across the entire page
- The 27 logo cubes + the extra cubes (index >= 27) should all participate in the explosion
- Extra cubes should initially be positioned behind the logo and also explode
- Create a 3D-feeling explosion with proper physics (rotation, spread, depth)
- Maintain smooth 60fps performance

## Files Involved
- `lib/core/widgets/particles/floating_cube_background.dart`

## Risks
- Performance regression (more cubes = more draw calls)
- Breaking the pre-burst/gather animation
- WASM NaN issues (need proper guards)

## Validation Steps
- Load home page → verify explosion looks realistic and 3D
- Verify all 27 logo cubes + extra cubes explode outward
- Verify extra cubes start behind the logo and explode too
- Verify no performance stutter
- Verify on mobile the effect still works smoothly

## Implementation Details

### Current State
- `_triggerLogoBurst()` currently sets velocities for ALL entities (0 to `_entities.length`)
- Lines 377-425: all entities get radial outward velocity (0.8-1.6 force)
- Extra cubes (>=27) are at the center with the logo cubes during pre-burst
- Only linear velocity is applied; rotation is NOT randomized

### Enhancement Plan

1. **Extra cubes behind the logo**:
   - In `_initFromBase()` with `_isPreBurst == true`: 
     - First 27 cubes form the 3x3x3 isometric logo at center (already done)
     - Extra cubes (i >= 27) should be positioned slightly behind the logo (z-depth) with slight random offsets so they form a "halo" or "cluster" behind the main cube
   - Currently extra cubes are at (0.5, 0.5) with zero velocity — this works but they overlap perfectly. We need to offset them slightly behind.

2. **3D rotational explosion**:
   - When the burst triggers, assign each cube:
     - Radial outward velocity (already done) but with **varying force** based on distance from center
     - **Add random rotational velocity** (`vrx`, `vry`, `vrz`) so cubes tumble as they fly
     - **Add slight z-velocity variation** — cubes that were behind (extra cubes) get initially slower velocity creating a delayed/staggered effect

3. **Realistic spread**:
   - Use a wider force range: 0.5 to 2.5 instead of 0.8 to 1.6
   - Some cubes fly fast (far), some slow (near) — creates depth
   - Add slight vertical bias so cubes don't all fly in a perfect circle
   - Extra cubes should have slightly randomized directions (not purely radial from center)

4. **Trail particle enhancement**:
   - Current: 150 flash particles at burst
   - Add: each cube should spawn trail particles as it flies (already exists in physics loop — `spawn()` triggered by speed > 0.15)

5. **Performance safety**:
   - Ensure NaN guards are in place
   - Use same spatial hash for entity management
   - Keep within the existing 50-150 cube count limits

### Specific Code Changes

In `_triggerLogoBurst()`:
- Randomize `e.rx`, `e.ry`, `e.rz` with random delta from current rotation
- Assign `e.vrx`, `e.vry`, `e.vrz` (rotational velocity) 
- Vary force by entity: `force = 0.5 + (i % 5) * 0.4 + random * 0.6`
- For extra cubes (i >= 27): use staggered initial velocity (slightly delayed by offset)
- Add slight upward/downward bias to vy for vertical spread

In `_initFromBase()` (pre-burst state):
- For extra cubes (i >= 27): position them in a 3D halo behind the logo
- Use `rx += 0.3` to tilt them slightly differently
- Randomize positions within a small cloud behind the center

In `_updateEntities()` / `_MergeEntity.update()`:
- Ensure rotational velocity (`vrx`, `vry`, `vrz`) is applied in the physics loop (add if not present)
- Add angular drag so rotation slows realistically

---

# Completion Report (Arabic)

سيتم تقديم تقرير الإنجاز بعد كل مرحلة.
