# Route Index - LandyMaker

The application uses `go_router` for centralized navigation. All routes are defined in `lib/core/router/app_router.dart`.

## 📍 Platform Routes

| Path | Purpose | Guarded? | Entry Widget |
| :--- | :--- | :--- | :--- |
| `/` | Multi-mode entry (Home or Public) | No | `LandyMakerHomeScreen` or `PublicLandingPage` |
| `/login` | Auth entry | No | `LoginScreen` |
| `/register` | User signup | No | `RegisterScreen` |
| `/dashboard` | User dashboard hub | **Yes** | `DashboardHomeScreen` |
| `/builder/:id` | Site editor workspace | **Yes** | `BuilderWorkspaceScreen` |
| `/templates` | Preset picker | No | `TemplatePickerScreen` |
| `/:pageName` | Catch-all for landing pages | No | `PublicLandingPage` |

## 📊 Dashboard Tabs (Stateful Shell)

These routes share the `DashboardShell` layout (Sidebar + Header).

| Path | Tab Name |
| :--- | :--- |
| `/dashboard` | Sites / Home |
| `/dashboard/analytics` | Analytics |
| `/dashboard/leads` | Leads |
| `/dashboard/gallery` | Media |
| `/dashboard/domain` | Domains |
| `/dashboard/feed` | Feeds |
| `/dashboard/notifications` | Notifications |
| `/dashboard/super-admin` | Platform Admin (with tab query: ?tab=users\|plans\|templates\|broadcast\|stats) |
| `/dashboard/super-admin/users/:userId` | User Profile |
| `/dashboard/homepage-editor` | Homepage Editor (super admin) |
| `/dashboard/blog-admin` | Blog Management |
| `/dashboard/platform-seo` | Platform SEO Editor |

## 🛡️ Route Guards & Redirects

- **Auth Guard**: Unauthenticated users visiting `/dashboard` or `/builder` are redirected to `/login`.
- **Super Admin Guard**: Only users with the `super_admin` role can access `/dashboard/super-admin`.
- **Tenant Resolver**: The root path (`/`) uses `TenantRoutingService` to determine if it should render the platform home or a public landing page based on the current hostname.

## ↩️ Safe Back Navigation

To prevent infinite loading loops, race conditions, or loading screens that hang on back navigation, **never** hardcode raw routing links (like `context.go('/')` or `context.go('/login')`) inside page-level back buttons.

Always use the custom `context.safePop(fallbackPath: '...')` extension method:
- Defined in [localization_cubit.dart](file:///Users/abdallahazmy/Projects/landymaker/lib/core/localization/localization_cubit.dart) (which is automatically exposed via `app_localizations.dart`).
- It checks if the GoRouter stack can pop first using GoRouter's O(1) inherited-widget-lookup (`this.canPop()`); if so, it pops the current screen (`this.pop()`) instantly to preserve the routing state machine. If not, it falls back to the provided path using `this.go(fallbackPath)`. This avoids the O(depth) ancestor-search performance latency of Flutter's native Navigator.

**Usage Example:**
```dart
leading: IconButton(
  icon: const Icon(Icons.arrow_back_rounded),
  onPressed: () => context.safePop(fallbackPath: '/login'),
),
```

