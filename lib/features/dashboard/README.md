# Dashboard Feature

The authenticated user hub — site management, analytics, leads, media gallery, domain configuration, notifications, and settings. Uses a `StatefulShellRoute` with a side navigation sidebar.

## File Map

| Path | Role |
|------|------|
| `screens/dashboard_shell.dart` | Layout container — `StatefulShellRoute` with `SidebarNavigation`, desktop/mobile responsive shell |
| `screens/dashboard_home_screen.dart` | Home tab — analytics overview widget, trend chart, data cards |
| `screens/analytics_screen.dart` | Full analytics — visitor metrics, conversion tracking, page stats |
| `screens/leads_tracker_screen.dart` | Lead management — table with search, filters, export |
| `screens/media_gallery_screen.dart` | Media library — user-uploaded image grid with delete |
| `screens/domain_settings_screen.dart` | Domain config — custom domain + subdomain setup |
| `screens/product_feed_screen.dart` | Product feed sync — Facebook/Google catalog integration |
| `screens/notifications_screen.dart` | In-app notification inbox — read, archive, dismiss |
| `screens/settings_screen.dart` | User settings — language toggle, account info |
| `controllers/active_website_cubit.dart` | `ActiveWebsiteCubit` — tracks the user's currently selected site across dashboard tabs |
| `controllers/landing_pages_cubit.dart` | `LandingPagesCubit` — loads user's landing page list with search |
| `controllers/landing_pages_state.dart` | `LandingPagesState` — loading/loaded/failure states |
| `controllers/leads_analytics_cubit.dart` | `LeadsAnalyticsCubit` — analytics data fetching with date range |
| `controllers/leads_analytics_state.dart` | `LeadsAnalyticsState` — loading/loaded/failure states |
| `controllers/media_gallery_cubit.dart` | `MediaGalleryCubit` — image asset management |
| `controllers/media_gallery_state.dart` | `MediaGalleryState` — loading/loaded/failure states |
| `controllers/notification_cubit.dart` | `NotificationCubit` — in-app inbox with Supabase Realtime (broadcast) |
| `controllers/notification_state.dart` | `NotificationState` — loading/loaded/unread count |
| `widgets/create_page_modal.dart` | New landing page creation dialog — template selection + naming |
| `widgets/domain_setup_widget.dart` | Domain configuration form with DNS instructions |
| `widgets/analytics_overview_widget.dart` | Dashboard home analytics cards (views, leads, conversion rate) |
| `widgets/empty_workspace_state.dart` | Empty state placeholder (no sites yet) |
| `widgets/notification_inbox_modal.dart` | Notification list modal — read/unread status, mark-as-read |

## State & Services

- `ActiveWebsiteCubit` — singleton; tracks the focused site across all dashboard tabs. Cleared on logout.
- `LandingPagesCubit` — factory; calls `DatabaseService.getLandingPages()` with debounced search.
- `LeadsAnalyticsCubit` — factory; calls `DatabaseService.getAnalytics()` for date-range metrics.
- `MediaGalleryCubit` — factory; uses `StorageService` for image list/delete.
- `NotificationCubit` — singleton; uses Supabase Realtime broadcast for instant delivery.
- All cubits are registered in `injection_container.dart` and consumed via `BlocProvider`.

## ⚠️ AI Warnings

- **`ActiveWebsiteCubit`** is the single source of truth for the user's active site. Do NOT query `landing_pages` table directly when you need the current page — always read from `ActiveWebsiteCubit.state`.
- **Dashboard shell uses `StatefulShellRoute.indexedStack`** — child screens are preserved in memory. Do NOT add `Navigator.push` inside dashboard tabs; use `StatefulShellRoute` navigation instead.
- **`create_page_modal.dart`** uses `CubeLoader` for loading state — do NOT replace with `CircularProgressIndicator`.
- **`settings_screen.dart`** has the language toggle **only** in the Settings screen. Do NOT add language switchers to the sidebar or top bar.
- **`AnimatedThemeToggle`** is fully removed — dark mode is forced. Do NOT re-add theme toggle UI.
- **`NotificationCubit`** uses Supabase Realtime (broadcast channel). If Supabase Realtime is unavailable, notifications degrade silently — do NOT add polling fallback without architectural review.
- **`ResponsiveDataTable`** (shared widget) is used by leads, analytics, and super admin tables. Its `mobileCardBuilder` prop must be provided for mobile layouts — do NOT leave it null.
