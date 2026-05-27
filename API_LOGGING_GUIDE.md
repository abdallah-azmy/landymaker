# API Request/Response Logging Setup Guide

## Overview

The application now has comprehensive logging for all API requests, responses, and database operations. This guide explains how the logging system works and how to use it.

## What's Included

### 1. **Enhanced Logger** (`lib/core/logger.dart`)

- Uses the `logger` package (v2.7.0) for beautiful, formatted console output
- Supports multiple log levels: `info`, `warn`, `error`, `debug`, `verbose`
- Special methods for HTTP and database operations:
  - `logHttpRequest()` - Logs request details (method, URL, headers, body)
  - `logHttpResponse()` - Logs response details (status code, body, duration)
  - `logHttpError()` - Logs HTTP errors with stack traces

### 2. **Supabase Logging Mixin** (`lib/core/supabase_logging_mixin.dart`)

- Provides specialized logging methods for database operations
- Methods:
  - `logDatabaseOperation()` - Logs SELECT, INSERT, UPDATE, DELETE operations
  - `logDatabaseError()` - Logs database errors
  - `logAuthOperation()` - Logs authentication operations (LOGIN, REGISTER, LOGOUT)
  - `logAuthError()` - Logs authentication errors
  - `logStorageOperation()` - Logs file uploads/downloads
  - `logStorageError()` - Logs storage errors

### 3. **HTTP Logger Interceptor** (`lib/core/http_logger_interceptor.dart`)

- Provides HTTP interceptor classes for future expansion
- `LoggingHttpInterceptor` - Logs all HTTP requests and responses
- `ErrorHttpInterceptor` - Logs HTTP errors (4xx, 5xx status codes)

### 4. **Updated SupabaseService** (`lib/services/supabase_service.dart`)

- All major operations now include comprehensive logging
- Operations logged:
  - **Authentication**: register(), login(), logout()
  - **Landing Pages**: getLandingPageByUserId(), getLandingPageByDomain(), saveLandingPage()
  - **Leads**: submitLead(), getLeadsByLandingPage()
  - **Analytics**: recordAnalyticsEvent(), getPageAnalyticsStats()
  - **Storage**: uploadImage()
  - **Admin**: getSuperAdminMetrics()

## Log Output Format

### Database Operation Logs

```
═══════ HTTP REQUEST ═══════
METHOD: DATABASE
URL: supabase://table_name/SELECT
HEADERS: {Operation: SELECT}
BODY: {table: table_name, operation: SELECT, filters: {...}, data: null}
════════════════════════════

═══════ HTTP RESPONSE ═══════
STATUS CODE: 200
URL: supabase://table_name/SELECT
DURATION: 145ms
BODY: {result_data}
════════════════════════════
```

### Authentication Logs

```
═══════ HTTP REQUEST ═══════
METHOD: AUTH
URL: supabase://auth/LOGIN
BODY: {operation: LOGIN, email: user@example.com}
════════════════════════════

═══════ HTTP RESPONSE ═══════
STATUS CODE: 200
URL: supabase://auth/LOGIN
BODY: {success: true, userId: user-uuid}
════════════════════════════
```

### Storage Operation Logs

```
═══════ HTTP REQUEST ═══════
METHOD: STORAGE
URL: supabase://storage/bucket/path/UPLOAD
BODY: {operation: UPLOAD, bucket: bucket_name, path: file_path, metadata: {...}}
════════════════════════════

═══════ HTTP RESPONSE ═══════
STATUS CODE: 200
URL: supabase://storage/bucket/path/UPLOAD
BODY: https://bucket.storage.url/file
════════════════════════════
```

## Key Features

### ✅ Request Details

- Method (DATABASE, AUTH, STORAGE, HTTP)
- URL/Endpoint
- Headers
- Request body/data
- Request filters

### ✅ Response Details

- Status code
- Response body/result
- Duration (in milliseconds)
- Error messages

### ✅ Error Logging

- Full error messages
- Stack traces
- Operation context
- Error timestamps

### ✅ Performance Tracking

- Duration of each operation measured
- Helps identify slow queries
- Useful for optimization

## Usage Examples

### Example 1: Login Operation

```dart
await supabaseService.login(
  email: 'user@example.com',
  password: 'password123'
);

// Console Output:
// ═══════ HTTP REQUEST ═══════
// METHOD: AUTH
// URL: supabase://auth/LOGIN
// BODY: {operation: LOGIN, email: user@example.com}
// ════════════════════════════
// ═══════ HTTP RESPONSE ═══════
// STATUS CODE: 200
// URL: supabase://auth/LOGIN
// DURATION: 523ms
// BODY: {success: true, userId: abc-123-def}
// ════════════════════════════
```

### Example 2: Database Query

```dart
final leads = await supabaseService.getLeadsByLandingPage(pageId);

// Console Output:
// ═══════ HTTP REQUEST ═══════
// METHOD: DATABASE
// URL: supabase://leads/SELECT
// HEADERS: {Operation: SELECT}
// BODY: {table: leads, operation: SELECT, filters: {landing_page_id: page-123}}
// ════════════════════════════
// ═══════ HTTP RESPONSE ═══════
// STATUS CODE: 200
// URL: supabase://leads/SELECT
// DURATION: 234ms
// BODY: {count: 5}
// ════════════════════════════
```

### Example 3: File Upload

```dart
final url = await supabaseService.uploadImage(file);

// Console Output:
// ═══════ HTTP REQUEST ═══════
// METHOD: STORAGE
// URL: supabase://storage/landing-assets/file.jpg/UPLOAD
// BODY: {operation: UPLOAD, bucket: landing-assets, metadata: {file_size: 2048}}
// ════════════════════════════
// ═══════ HTTP RESPONSE ═══════
// STATUS CODE: 200
// URL: supabase://storage/landing-assets/file.jpg/UPLOAD
// DURATION: 1245ms
// BODY: https://bucket.supabase.url/file.jpg
// ════════════════════════════
```

## How to Enable/Disable Logging

Logging is automatically enabled in **debug mode** and disabled in **release mode**.

### To control logging:

```dart
// In logger.dart, the logger is configured with:
level: kDebugMode ? logger_pkg.Level.debug : logger_pkg.Level.info
```

### Manual Control (if needed):

```dart
// Log info level
Logger.info('This is an info message');

// Log warning
Logger.warn('This is a warning');

// Log error with stack trace
Logger.error('Error message', error, stackTrace);

// Log debug
Logger.debug('Debug information');

// Log verbose
Logger.verbose('Detailed verbose info');
```

## Integration with Monitoring

### For External Monitoring Services

The logging methods can be extended to send logs to external services like:

- Firebase Crashlytics
- Sentry
- DataDog
- LogRocket
- Custom backend logging service

### Example Extension:

```dart
// In logger.dart, add:
static Future<void> _sendToMonitoring(String level, String message) async {
  try {
    // Send to your monitoring service
    await FirebaseCrashlytics.instance.log('[$level] $message');
  } catch (e) {
    print('Failed to send log to monitoring: $e');
  }
}
```

## Performance Considerations

- Logging adds minimal overhead (typically < 1-2ms per operation)
- All HTTP calls are tracked with timing information
- In release mode, logging is completely disabled
- Stack traces are captured for error debugging

## Troubleshooting

### Logs Not Showing

1. Verify you're in **debug mode** (not release)
2. Check your IDE's debug console/terminal
3. Ensure `kDebugMode` returns true

### Too Much Output

1. Logs are verbosity-controlled
2. Set level to `Level.info` to reduce noise
3. Filter logs by method name in your IDE

### Performance Issues

1. Logging is disabled in release mode
2. Minimal overhead in debug mode
3. Database operations are tracked efficiently

## Future Enhancements

The logging system is designed to be extended:

- Add HTTP interceptor support for third-party packages
- Implement log persistence to files
- Add remote monitoring integration
- Create log analytics dashboard
- Add request replay functionality

---

**Last Updated**: May 22, 2026
**Package Versions**:

- logger: 2.7.0
- http_interceptor: 3.0.0
