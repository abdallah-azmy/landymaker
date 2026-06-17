# Service Index - LandyMaker

A directory of global singleton services and their core responsibilities.

| Service Name | Purpose | Key Methods | Dependencies |
| :--- | :--- | :--- | :--- |
| **SupabaseService** | Raw SDK interaction | `register`, `login`, `saveLandingPage` | `supabase_flutter` |
| **DatabaseService** | Business data logic | `getLandingPageById`, `submitLead` | `SupabaseService` |
| **AuthService** | Identity management | `signInWithGoogle`, `logout`, `currentUserId` | `SupabaseService` |
| **TenantRouting** | URL & Domain parsing | `getRouteMode`, `getTenantIdentifier` | `dart:html` |
| **StorageService** | File management | `uploadImage`, `listUserImages`, `deleteImage` | `SupabaseService` |
| **ImageMedia** | External assets | `fetchPixabayImages`, `proxyToImgBB` | `dio` |
| **Subscription** | Tier enforcement | `getMaxPages`, `canAccessPremiumFeatures` | `DatabaseService` |
| **ActionHandler** | Global CTA logic | `executeAction` (handles links, checkout, scrolls) | `url_launcher` |
| **Turnstile** | Anti-spam Captcha | `registerViewFactory`, `getToken` | `dart:js` |
| **PixelEvent** | Visitor tracking | `trackPageView`, `trackLead`, `trackPurchase` | `dart:js` |
| **FcmService** | Push notifications | `initialize`, `requestPermission`, `saveTokenIfPossible`, `deleteToken`, `playNotificationSound` | `firebase_messaging` |

## 💉 Service Locator

All services are registered in `lib/injection_container.dart` using the `get_it` package (aliased as `sl`).

```dart
// Example Usage in Cubit:
final service = sl<DatabaseService>();
```
