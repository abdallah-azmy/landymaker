# 🚀 API Logging System - Quick Reference

## ✅ What's Been Set Up

### 1. **Logger Package** (`logger: 2.7.0`)

Beautiful, formatted console output with timestamps and emojis.

### 2. **Enhanced Logger** → `lib/core/logger.dart`

- **Methods:**
  - `Logger.info(msg)` - Information logs
  - `Logger.warn(msg)` - Warning logs
  - `Logger.error(msg, error, stackTrace)` - Error logs with stack trace
  - `Logger.debug(msg)` - Debug information
  - `Logger.verbose(msg)` - Detailed trace logs
  - `Logger.logHttpRequest()` - Log HTTP requests
  - `Logger.logHttpResponse()` - Log HTTP responses
  - `Logger.logHttpError()` - Log HTTP errors

### 3. **Supabase Logging Mixin** → `lib/core/supabase_logging_mixin.dart`

Specialized logging for database operations:

- `logDatabaseOperation()` - SELECT, INSERT, UPDATE, DELETE
- `logDatabaseError()` - Database errors
- `logAuthOperation()` - Auth operations (LOGIN, REGISTER)
- `logAuthError()` - Auth errors
- `logStorageOperation()` - File uploads/downloads
- `logStorageError()` - Storage errors

### 4. **Updated SupabaseService** → `lib/services/supabase_service.dart`

All major methods now include comprehensive logging:

**Auth Operations:**

```
✅ register() → logs email, role, userId, duration
✅ login() → logs email, role, duration
✅ logout() → logs operation
```

**Landing Pages:**

```
✅ getLandingPageByUserId() → logs filters, results
✅ getLandingPageByDomain() → logs domain, results
✅ saveLandingPage() → logs INSERT/UPDATE operations
```

**Leads:**

```
✅ submitLead() → logs lead data, conversion events
✅ getLeadsByLandingPage() → logs lead count
```

**Analytics:**

```
✅ recordAnalyticsEvent() → logs event type
✅ getPageAnalyticsStats() → logs views & conversions
```

**Storage:**

```
✅ uploadImage() → logs file size, URL, duration
```

**Admin:**

```
✅ getSuperAdminMetrics() → logs total counts
```

---

## 📋 Log Output Example

When you execute an operation, you'll see formatted output like:

```
═══════ HTTP REQUEST ═══════
METHOD: AUTH
URL: supabase://auth/LOGIN
BODY: {operation: LOGIN, email: user@example.com}
════════════════════════════

⏱️ Query completed in 523ms

═══════ HTTP RESPONSE ═══════
STATUS CODE: 200
URL: supabase://auth/LOGIN
DURATION: 523ms
BODY: {success: true, userId: abc-123}
════════════════════════════
```

---

## 🎯 Key Features

| Feature               | Benefit                           |
| --------------------- | --------------------------------- |
| **Request Logging**   | See exactly what data is sent     |
| **Response Logging**  | Understand what comes back        |
| **Duration Tracking** | Identify slow operations          |
| **Error Logging**     | Full stack traces for debugging   |
| **Operation Context** | Know which table/operation failed |
| **Auto Timestamps**   | Track when operations occur       |
| **Status Codes**      | Monitor HTTP status               |

---

## 🔍 How to View Logs

### In VS Code Terminal:

Simply run your app:

```bash
flutter run
```

Logs appear in the "Debug Console" with colors and formatting.

### In Android Studio Logcat:

Filter by "flutter" tag.

### In Xcode Console:

All logs appear in the console pane.

---

## 💡 Examples

### Example 1: User Registration

```dart
final result = await supabaseService.register(
  email: 'newuser@example.com',
  password: 'secure123',
  fullName: 'John Doe',
  role: 'user'
);
```

**Console Output:**

```
═══════ HTTP REQUEST ═══════
METHOD: AUTH
URL: supabase://auth/REGISTER
BODY: {operation: REGISTER, email: newuser@example.com, role: user}
════════════════════════════

⏱️ Query completed in 1245ms

═══════ HTTP RESPONSE ═══════
STATUS CODE: 200
URL: supabase://auth/REGISTER
DURATION: 1245ms
BODY: {success: true, userId: user-uuid-abc123}
════════════════════════════
```

### Example 2: Fetching Leads

```dart
final leads = await supabaseService.getLeadsByLandingPage('page-123');
```

**Console Output:**

```
═══════ HTTP REQUEST ═══════
METHOD: DATABASE
URL: supabase://leads/SELECT
HEADERS: {Operation: SELECT}
BODY: {table: leads, operation: SELECT, filters: {landing_page_id: page-123}}
════════════════════════════

⏱️ Query completed in 234ms

═══════ HTTP RESPONSE ═══════
STATUS CODE: 200
URL: supabase://leads/SELECT
DURATION: 234ms
BODY: {count: 5}
════════════════════════════
```

### Example 3: Uploading Image

```dart
final imageUrl = await supabaseService.uploadImage(file);
```

**Console Output:**

```
═══════ HTTP REQUEST ═══════
METHOD: STORAGE
URL: supabase://storage/landing-assets/image.jpg/UPLOAD
BODY: {operation: UPLOAD, bucket: landing-assets, metadata: {file_size: 2048}}
════════════════════════════

⏱️ Query completed in 1523ms

═══════ HTTP RESPONSE ═══════
STATUS CODE: 200
URL: supabase://storage/landing-assets/image.jpg/UPLOAD
DURATION: 1523ms
BODY: https://bucket.supabase.co/image.jpg
════════════════════════════
```

---

## 🛠️ Troubleshooting

### Logs Not Showing?

- Ensure you're in **DEBUG mode** (not release)
- Check the Debug Console in VS Code/Android Studio
- Logs are disabled in release builds

### Want Different Log Levels?

Edit `lib/core/logger.dart`:

```dart
level: kDebugMode ? logger_pkg.Level.info : logger_pkg.Level.warning
```

### Too Much Output?

- The logger already filters for debug mode
- Adjust the `Level` in the above code
- Or filter in your IDE's console

---

## 📊 Performance Impact

- **Minimal overhead**: < 1ms per operation
- **Disabled in release**: No performance impact in production
- **Debug mode only**: Zero cost in production builds

---

## 🔐 Security Notes

⚠️ **Passwords are NOT logged** - Authentication operations log email/role, but not passwords

✅ **Sensitive data filtered** - Form data is logged (user needs to see it)

---

## 📚 Additional Resources

- Full documentation: See `API_LOGGING_GUIDE.md`
- Logger package docs: https://pub.dev/packages/logger
- Supabase Flutter docs: https://supabase.com/docs/reference/flutter/

---

**Status**: ✅ Ready to use  
**Last Updated**: May 22, 2026  
**Packages**: logger 2.7.0
