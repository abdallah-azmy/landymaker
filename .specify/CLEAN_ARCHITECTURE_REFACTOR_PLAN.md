# Clean Responsive Architecture Refactoring Plan (V2)

## ⚠️ Critical Architecture Constraints
- **State Preservation**: All controllers and local state variables MUST be hoisted to the parent `StatefulWidget` wrapper. `_Mobile*` and `_Desktop*` subclasses will be `StatelessWidget`s.
- **Incremental Execution**: Changes are pushed in 4 distinct phases.

## 🏁 Progress Tracker

### Phase 1: Global Components
- [x] Refactor `lib/features/home/widgets/home_navbar.dart`
- [x] Refactor `lib/features/home/widgets/home_footer.dart`
- [x] Refactor `lib/features/dashboard/screens/dashboard_shell.dart`

### Phase 2: Core Screens
- [x] Refactor `lib/features/dashboard/screens/dashboard_home_screen.dart`
- [x] Refactor `lib/features/dashboard/screens/settings_screen.dart`
- [x] Refactor `lib/features/home/screens/template_picker_screen.dart`

### Phase 3: Complex Builder & Core Layouts
- [x] Refactor `lib/features/builder/screens/builder_workspace_screen.dart`
- [x] Refactor `lib/core/widgets/organisms/responsive_data_table.dart`

### Phase 4: Builder Sections (Incremental)
- [x] Refactor `CustomHeroWidget`
- [x] Refactor `CustomHeroSaasWidget`
- [x] Refactor `CustomFeaturesWidget`
- [x] Refactor `CustomProductsWidget`
- [x] Refactor `CustomPricingWidget`
- [x] Refactor `CustomFaqWidget`
- [x] Refactor `CustomTestimonialsWidget`
- [x] Refactor `CustomGalleryWidget`
- [x] Refactor `CustomLeadFormWidget`
- [x] Refactor `CustomLeadMagnetWidget`
- [x] Refactor `CustomCtaBannerWidget`
- [x] Refactor `CustomComparisonTableWidget`
- [x] Refactor `CustomVideoEmbedWidget`
- [x] Refactor `CustomLocationMapWidget`
- [x] Refactor `CustomWorkingHoursWidget`
- [x] Refactor `CustomLogoHeaderWidget`
- [x] Refactor `CustomTrustLogosWidget`
- [x] Refactor `CustomAnimatedCounterWidget`
- [x] Refactor `CustomStatisticsGridWidget`
- [x] Refactor `CustomTeamMembersWidget`
- [x] Refactor `CustomServiceStepsWidget`
- [x] Refactor `CustomQrWidget`
- [x] Refactor `CustomSocialQrWidget`
- [x] Refactor `CustomWhatsappWidget`

---

## 🎉 All Phases Complete!

---

## 🛠 Refactoring Standards
- **AI-Friendly**: Every file/class must have `///` documentation explaining its purpose and constraints.
- **Stateless Sub-widgets**: Sub-widgets should be `StatelessWidget` whenever possible.
- **State Hoisting**: Parent `StatefulWidget` manages all controllers and business logic.
- **Factory Pattern**: Section renderers delegate to specific layout classes.
