# 🚀 API Request/Response Logging Guide & Reference

This guide serves as the single source of truth for the LandyMaker API Logging system. It contains both a **Quick Start Cheat-Sheet** and a **Detailed Architectural Overview**.

---

## ⚡ 1. Quick Start & Reference

The logging system is built on the `logger` package (`v2.7.0`) and provides structured, colored console outputs with emojis.

### Console Output Format
When an API or Database operation runs, it prints a clean box tracking request parameters, response body, and duration:

```text
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

### Logging Methods Reference
Use the static `Logger` class for general logs, or implement `SupabaseLoggingMixin` for database-facing services:

```dart
// General Logging Levels
Logger.verbose('Detailed trace log');
Logger.debug('Variable status or state trace');
Logger.info('General operational message');
Logger.warn('Warning: potential issue');
Logger.error('Action failed!', error, stackTrace); // Automatically prints full stack trace

// Manually Logging Network Requests
Logger.logHttpRequest(method: 'GET', url: 'https://api.site.com');
Logger.logHttpResponse(statusCode: 200, url: 'https://api.site.com', durationMs: 120);
```

### DB & Storage Operations Logging
If your service extends or mixes in `SupabaseLoggingMixin`, you can log specific database interactions:

```dart
// Logs database query parameters and results
logDatabaseOperation(
  operation: 'SELECT',
  table: 'landing_pages',
  filters: {'id': pageId},
  result: resultData,
);

// Logs authentication changes (excluding passwords)
logAuthOperation(
  operation: 'LOGIN',
  data: {'email': email},
  result: sessionResult,
);

// Logs file upload details
logStorageOperation(
  operation: 'UPLOAD',
  bucket: 'landing-assets',
  path: filePath,
  result: publicUrl,
);
```

---

## 🛠️ 2. Architectural Overview

The logging framework resides under two main directories:
- **[logger.dart](./lib/core/logger.dart)**: Core logger wrapper using `PrettyPrinter` configuration.
- **[supabase_logging_mixin.dart](./lib/core/supabase_logging_mixin.dart)**: Utility mixin providing specialized database hooks.

### Performance Control (Debug vs Release Mode)
To ensure production performance is unaffected and sensitive logs are never printed to production app consoles, the logger evaluates the build mode automatically:

```dart
// Configured inside logger.dart
level: kDebugMode ? logger_pkg.Level.debug : logger_pkg.Level.info
```
- **Debug Mode:** Fully verbose logs, colorized formatting, active mixins.
- **Release Mode:** Completely disabled logging (zero CPU/memory footprint).

### Privacy & Security
- **No Passwords:** Authentication log methods explicitly omit password hashes or raw values.
- **Filter-focused:** Sensitive keys should be omitted or masked before calling logging functions.

---

## 🔌 3. External Monitoring Integration

The logging methods can be easily extended to forward exceptions or warning logs directly to production APM suites (e.g., Sentry, Firebase Crashlytics):

```dart
// In lib/core/logger.dart:
static Future<void> _sendToMonitoring(String level, String message, [dynamic error, StackTrace? stackTrace]) async {
  if (level == 'ERROR') {
    await FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: message);
  } else {
    await FirebaseCrashlytics.instance.log('[$level] $message');
  }
}
```

---

## 🔍 4. Troubleshooting

### Logs Not Showing in Console?
1. **Verify Build Mode:** Ensure you run the application in **Debug Mode** (`flutter run`). Release builds do not write logs.
2. **IDE Console Selection:** If using VS Code, check the **Debug Console** tab rather than the Terminal tab. If using Android Studio, look at the **Logcat** window filtered for "flutter".
3. **Suppress/Increase Noise:** You can adjust the default level in `logger.dart` by modifying `logger_pkg.Level.debug` to higher/lower levels depending on debugging requirements.
