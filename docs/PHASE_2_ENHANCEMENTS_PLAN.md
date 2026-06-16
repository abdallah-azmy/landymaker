# 🚀 LandyMaker — Phase 2: Architecture & UX Enhancements

This plan is based on the recent architectural and UX improvement suggestions.
This plan must be executed **PART BY PART**. Do NOT proceed to the next part without the user's explicit approval.

---

## 📦 PART 1: High-Priority UI & Layout Fixes
**Objective:** Integrate the newly created layouts into the picker and fix critical mobile UI issues.

- [ ] **Task 1.1:** Integrate `HeroLayout.fullWidthImage` and `CtaLayout.fullWidthImage` into the `LayoutPickerPanel` to allow users to select these new options.
- [ ] **Task 1.2:** Fix the template picker sidebar on mobile screens. Convert it into a `DraggableScrollableSheet` (Bottom Sheet) or a Collapsible Panel when the screen width is `< 900px`.
- [ ] **Task 1.3:** Add `loadingBuilder` and `errorBuilder` states to the `fullWidthImage` layouts using `CustomNetworkImage` features, preventing empty spaces on slow connections.

---

## 📦 PART 2: Animation & Responsive Refactoring
**Objective:** Reduce code duplication (boilerplate) and standardize responsive breakpoints across the app.

- [ ] **Task 2.1:** Create a `ResponsiveBreakpoint` helper or a `ResponsiveLayout` widget to unify the screen check logic instead of repeating `isMobile = constraints.maxWidth < 900` across 7 different sections.
- [ ] **Task 2.2:** Create an `AnimationMixin` or a `FadeSlideAnimation` helper widget to reduce the repetitive animation code (`AnimationController`, `CurvedAnimation`, `Interval`, and `dispose`). Apply this mixin/helper to at least two sections to prove it works effectively.
- [ ] **Task 2.3:** Refactor `_TypewriterText` to use `ConstrainedBox(minHeight: ...)` instead of a fixed `SizedBox(height: 50)` to prevent text overflow if the text gets longer than expected.

---

## 📦 PART 3: Scroll Detection & Accessibility Polish
**Objective:** Improve code maintainability, accessibility (A11y), and add professional touches.

- [ ] **Task 3.1:** Refactor scroll detection in `landymaker_home_screen.dart`. Instead of relying on hardcoded scroll offsets in `_checkAndReveal`, use a better pattern (like the `VisibilityDetector` package if available, or a clean observer system) so the code doesn't break when sections are reordered.
- [ ] **Task 3.2:** Add `Semantics` properties to decorative images (like `PhonePreview` and the template gallery) to improve support for Screen Readers.
- [ ] **Task 3.3:** Make the dark overlay `alpha` value in the `fullWidthImage` layout customizable (e.g., by adding a parameter like `double overlayOpacity = 0.55`) to better support both light and dark images.
