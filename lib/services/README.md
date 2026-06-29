# Global Services (Infrastructure Adaptors)

Singleton service classes that abstract infrastructure and external integrations. All registered in `injection_container.dart` via GetIt (`sl`).

## File Map

| Path | Role |
|------|------|
| `supabase_service.dart` | **Main entry** (450 lines) — Singleton `SupabaseService` with `ChangeNotifier`. Fields, getters, `initialize()`, super-admin ops, templates, homepage sections, platform SEO, notifications, bulk ops. Mixes in 3 part mixins. |
| `supabase/supabase_auth.dart` | **Part file** (108 lines) — `SupabaseServiceAuth` mixin: `register`, `login`, `logout`, `sendPasswordResetEmail`, `signInWithGoogle` |
| `supabase/supabase_pages.dart` | **Part file** (306 lines) — `SupabaseServicePages` mixin: landing page CRUD, leads submission, analytics events |
| `supabase/supabase_storage.dart` | **Part file** (166 lines) — `SupabaseServiceStorage` mixin: image upload with quota enforcement, list, delete, asset registration |
| `auth_service.dart` | `AuthService` — wraps `SupabaseService` for user session management; exposes `isAuthenticated`, `currentUserId`, `currentUserRole`; listener-based pattern for reactive auth checks |
| `database_service.dart` | `DatabaseService` — high-level business queries: `getLandingPageById`, `submitLead`, `getAnalytics`, `getHomepageSections`, `getBlogPosts` |
| `storage_service.dart` | `StorageService` — binary file upload/download to Supabase Storage buckets |
| `image_media_service.dart` | `ImageMediaService` — Pixabay stock image search + ImgBB proxy upload |
| `subscription_service.dart` | `SubscriptionService` — tier limit enforcement: `getMaxPages`, `canAccessPremium`, `upgradePlan` |
| `tenant_routing_service.dart` | `TenantRoutingService` — resolves subdomains, custom domains, and path-based tenants at startup |
| `web_auth_helper.dart` | Web OAuth helper (platform dispatcher) |
| `web_auth_helper_web.dart` | Web implementation — Google Sign-In via `supabase_flutter` web flow |
| `web_auth_helper_stub.dart` | Stub for non-web platforms |

## Architecture: Sharded SupabaseService (Mixin Pattern)

`SupabaseService` uses Dart `part` files with mixins to split a 1649-line file into 4 manageable chunks:

```dart
class SupabaseService extends ChangeNotifier
    with SupabaseServiceAuth, SupabaseServicePages, SupabaseServiceStorage {
  // Main file: singleton boilerplate, getters, initialize(),
  // super-admin ops, templates, homepage, SEO, notifications, bulk ops
}
```

Each mixin accesses private fields (`_client`, `_currentUserId`, etc.) via abstract property declarations — no public API breakage.

## State & Services

- All services are **singletons** (registered with `sl.registerSingleton`), except for feature cubits which use `sl.registerFactory`.
- Registration order in `initDependencies()` is strict: Supabase → child services → global cubits → feature cubits.
- `SupabaseService` extends `ChangeNotifier` — listeners are notified on auth state changes.
- `AuthService` uses `ChangeNotifier` + listener pattern: `AuthCubit` subscribes in its constructor.

## ⚠️ AI Warnings

- **Do NOT merge part files** — the `supabase/supabase_*.dart` split is deliberate for AI readability. Each file stays under 306 lines.
- **`SupabaseService` is the ONLY class** that directly calls `SupabaseClient`. `DatabaseService` must go through `SupabaseService` — never access `SupabaseClient` directly from features.
- **`initialize()` must be called once** before any other service. It's called in `injection_container.dart` before registering child services.
- **`TenantRoutingService`** uses `dart:html` for URL resolution — web-only. Do NOT import it in non-web code without a stub.
- **`StorageService.uploadImage`** enforces a quota check — do NOT bypass it by calling Supabase Storage APIs directly.
- **`SubscriptionService`** reads from `user_tiers` and `subscription_requests` tables. Do NOT hardcode tier limits — always go through `SubscriptionService.getMaxPages()`.
- **`AuthService`** is a thin wrapper — auth state machine logic belongs in `AuthCubit`, not here.
- **Edge Function proxy** is mandatory for lead submissions (`DatabaseService.submitLead` → `lead-submit` Edge Function) — do NOT call `supabase.from('leads').insert()` from any service or feature.
