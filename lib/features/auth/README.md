# Auth Feature

Manages user authentication — login, registration, password reset, Google OAuth, and session restoration. Uses a reactive cubit that subscribes to `AuthService` listener.

## File Map

| Path | Role |
|------|------|
| `controllers/auth_cubit.dart` | `AuthCubit` — central auth state machine: `login()`, `register()`, `logout()`, `sendPasswordReset()`, `resetPassword()`, `signInWithGoogle()`, `switchGoogleAccount()`, `confirmGoogleNewUser()` |
| `controllers/auth_state.dart` | `AuthState` — sealed class: `AuthInitial`, `AuthLoading`, `Authenticated(userId, email, role, photoURL)`, `Unauthenticated`, `AuthFailure(message)`, `PasswordResetEmailSent`, `PasswordResetSuccess`, `GoogleNewUserRequiresConsent(pendingEmail)`, `RegistrationSuccess` |
| `screens/login_screen.dart` | Login form — email + password fields, "Forgot Password?" link, Google OAuth button, registration redirect |
| `screens/register_screen.dart` | Registration form — full name + email + password + confirm password fields, Google OAuth, login redirect |
| `screens/forgot_password_screen.dart` | Password reset request — email field, sends reset link via Supabase |
| `screens/reset_password_screen.dart` | Password reset confirmation — new password + confirm fields, parses query token from email link |
| `widgets/auth_layout_wrapper.dart` | Shared layout — centered two-column (brand + form) on desktop, single-column on mobile; built-in language switcher toggle |

## Auth Flow

```
App Start → AuthCubit.checkAuth()
  ├─ Authenticated? → emit Authenticated(userId, email, role)
  │     └─ Dashboard redirect
  └─ Not authenticated? → emit Unauthenticated()
        └─ LoginScreen/RegisterScreen

Login:     email+password → SupabaseService.login → FcmService.requestPermission → Authenticated
Register:  name+email+password → SupabaseService.register → FcmService.requestPermission → Authenticated
Google:    signInWithGoogle → check if new user → consent dialog → Authenticated
Logout:    FcmService.deleteToken → AuthService.logout → ActiveWebsiteCubit.clearSelection → Unauthenticated
Password:  forgot_password → sendPasswordResetEmail → PasswordResetEmailSent
           reset_password → updatePassword → PasswordResetSuccess → redirect to login
```

## State & Services

- `AuthCubit` — factory (`sl.registerFactory`); injected with `AuthService` via constructor
- `AuthService` — singleton; uses `ChangeNotifier` listener pattern; `AuthCubit` subscribes in constructor via `_authService.addListener(checkAuth)`
- `SupabaseService` — handles actual Supabase Auth SDK calls (login, register, logout, OAuth)
- `FcmService` — FCM token sync on successful login/registration
- `ActiveWebsiteCubit` — cleared on logout to reset dashboard context

## ⚠️ AI Warnings

- **`CircularProgressIndicator` is BANNED** in auth screens — replaced with `CubeLoader(size: 14, variant: CubeLoaderVariant.single, showGlow: false)` in both `register_screen.dart` and `create_page_modal.dart`. Do NOT revert to `CircularProgressIndicator`.
- **Never bypass UI validators** — all auth forms validate email format and password length client-side before calling the cubit. Skipping validation leads to confusing Supabase error messages.
- **`AuthCubit.checkAuth()`** runs on every app start via the `AuthService` listener. Do NOT call it manually from screens — it fires automatically when `AuthService` notifies.
- **Google OAuth flow** involves a `GoogleNewUserRequiresConsent` intermediary state for first-time Google users. The login screen must handle this state by showing a consent dialog.
- **Password reset** uses Supabase's built-in email flow with a redirect URL (`/reset-password`). The token is parsed from the URL query parameters in `reset_password_screen.dart`. Do NOT implement custom token handling.
- **`AuthLayoutWrapper`** includes a language switcher toggle — do NOT also add language switchers to individual auth screens; the wrapper covers all four screens.
- **Session restoration** is reactive — `AuthCubit` checks `_authService.isAuthenticated` on construction. Do NOT add manual session restoration logic to screens.
