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
| `/dashboard/super-admin` | Platform Admin |
| `/dashboard/blog-admin` | Blog Management |

## 🛡️ Route Guards & Redirects

- **Auth Guard**: Unauthenticated users visiting `/dashboard` or `/builder` are redirected to `/login`.
- **Super Admin Guard**: Only users with the `super_admin` role can access `/dashboard/super-admin`.
- **Tenant Resolver**: The root path (`/`) uses `TenantRoutingService` to determine if it should render the platform home or a public landing page based on the current hostname.
