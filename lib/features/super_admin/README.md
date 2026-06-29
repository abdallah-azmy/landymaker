# Super Admin Feature

Provides the platform administration panel — user management, plan configuration, analytics, templates, homepage sections, security limits, broadcast notifications, payments, and audit logs.

## File Map

| Path | Role |
|------|------|
| `controllers/super_admin_cubit.dart` | `SuperAdminCubit` — loads all admin data; provides `loadAllData()`, template CRUD, plan management, broadcast, SEO settings |
| `controllers/super_admin_state.dart` | `SuperAdminState` — `SuperAdminLoaded` with 12+ fields (users, pages, plans, security limits, audit logs, templates, etc.) |
| `controllers/homepage_editor_cubit.dart` | `HomepageEditorCubit` — manages homepage section visibility and content |
| `controllers/homepage_editor_state.dart` | `HomepageEditorState` — loading/loaded/failure states for homepage editor |
| `controllers/user_profile_cubit.dart` | `UserProfileCubit` — fetches/updates individual user profiles |
| `controllers/user_profile_state.dart` | `UserProfileState` — profile loading/loaded/failure states |
| `screens/super_admin_panel_screen.dart` | Shell screen — `TabController` + `TabBar` routing to 10+ tab widgets. **Do NOT add content here.** |
| `screens/homepage_editor_screen.dart` | Homepage section editor — configure visibility and content of landing page sections |
| `screens/platform_seo_screen.dart` | Platform-level SEO settings for static routes (/, /pricing, /templates, etc.) |
| `screens/user_profile_screen.dart` | Individual user profile viewer/editor |
| `screens/hero_config_sheet.dart` | Bottom sheet: homepage hero section configuration |
| `screens/feature_config_sheet.dart` | Bottom sheet: homepage features section configuration |
| `screens/cta_config_sheet.dart` | Bottom sheet: homepage CTA section configuration |
| `screens/footer_config_sheet.dart` | Bottom sheet: homepage footer configuration |
| `screens/navbar_config_sheet.dart` | Bottom sheet: homepage navbar configuration |
| `screens/template_config_sheet.dart` | Bottom sheet: template editing dialog |
| `screens/desktop_preview_config_sheet.dart` | Bottom sheet: desktop preview section configuration |
| `widgets/super_admin_users_tab.dart` | Users tab — table, search, bulk actions |
| `widgets/super_admin_plans_tab.dart` | Plans tab — plan cards + edit dialog |
| `widgets/super_admin_security_tab.dart` | Security tab — rate limits, boundaries |
| `widgets/super_admin_audit_tab.dart` | Audit log table |
| `widgets/super_admin_stats_tab.dart` | Global statistics cards + recent logs |
| `widgets/super_admin_payments_tab.dart` | Payment requests table |
| `widgets/super_admin_affiliates_tab.dart` | Affiliates table |
| `widgets/super_admin_templates_tab.dart` | Template CRUD — list, create, edit, delete |
| `widgets/super_admin_broadcast_tab.dart` | Broadcast notification form |
| `widgets/super_admin_page_tabs.dart` | Homepage + Home Previews + Landing Pages tabs |
| `widgets/home_previews_tab.dart` | Previews management for homepage |
| `widgets/homepage_section_card.dart` | Reusable card for homepage sections |
| `widgets/bulk_action_bar.dart` | Bulk action bar for users tab |

## State Management

- `SuperAdminCubit` — main cubit; all tab widgets read from it via `context.watch<SuperAdminCubit>().state`
- `HomepageEditorCubit` — standalone cubit for homepage section editing
- `UserProfileCubit` — standalone cubit for individual user profile

## ⚠️ AI Warnings

- **NEVER merge tab widgets back into `super_admin_panel_screen.dart`**. The shell was deliberately split from 1868→158 lines to keep it lightweight. Each tab widget reads state independently via `context.watch`.
- **`SuperAdminCubit.loadAllData()`** fetches all admin data in one call. Do NOT add new data sources without adding them to this method.
- **Broadcast notifications** use `_client!.rpc('broadcast_notification', ...)`. Ensure the RPC function exists before modifying parameters.
- **Template CRUD** in `super_admin_templates_tab.dart` manages the `templates` table (not `template_registry.dart` assets). These are DB-stored templates, not the built-in registry templates.
- **Config sheets** (`hero_config_sheet.dart`, etc.) are bottom-sheet dialogs that read/write to `homepage_sections` table. Do NOT make them full-screen routes.
