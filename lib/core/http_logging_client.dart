import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

/// An [http.Client] wrapper that logs all Supabase HTTP requests and responses
/// in a clean, organized format similar to PrettyDioLogger.
///
/// This is the **correct** way to log Supabase SDK traffic because:
/// - The SDK uses the `http` package internally, not Dio
/// - It captures actual HTTP request headers, body, and response
/// - It works for both Postgrest (DB) and Gotrue (Auth) calls
class LoggingHttpClient extends BaseClient {
  LoggingHttpClient(this._inner);

  final Client _inner;

  // Pretty box-drawing characters to match pretty_dio_logger style
  static const _topLeft = '┌';
  static const _bottomRight = '└';
  static const _horizontal = '─';
  static const _vertical = '│';
  static const _divider = '├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄';
  static const _prefix = '[SUPABASE]';
  static const _maxWidth = 120;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    if (!kDebugMode) {
      return _inner.send(request);
    }

    final method = request.method;
    final url = request.url;
    final path = url.path;

    // --- Request Logging ---
    _printBoxTop();

    // Determine what to show based on the path
    if (path.contains('auth/v1/token')) {
      // Auth login — show method + path, mark password as hidden
      _logLine('$method $path');
      _printDivider();
      _logLine('Headers: ${_compactHeaders(request.headers)}');
      _logLine('Body: {"email":"...","password":"***"}');
    } else if (path.contains('/rest/v1/')) {
      // Postgrest DB query
      final table = path.split('/rest/v1/').last;
      _logLine('$method $table');
      _printDivider();
      _logLine('Headers: ${_compactHeaders(request.headers)}');
      if (request is Request && request.body.isNotEmpty) {
        final body = _tryPrettyJson(request.body);
        _logLine('Body: $body');
      }
    } else {
      // Other Supabase API calls
      _logLine('$method $path');
      _printDivider();
      if (request is Request && request.body.isNotEmpty) {
        _logLine('Body: ${_tryPrettyJson(request.body)}');
      }
    }

    _printBoxBottom();

    // --- Execute request ---
    final sw = Stopwatch()..start();
    try {
      final response = await _inner.send(request);

      sw.stop();
      final status = response.statusCode;
      final elapsed = sw.elapsedMilliseconds;

      // --- Response Logging ---
      _printBoxTop();
      _logLine('$status $path (${elapsed}ms)');
      _printDivider();

      // Read the response body
      final bodyBytes = await response.stream.toBytes();
      final bodyStr = String.fromCharCodes(bodyBytes);

      if (bodyStr.isNotEmpty) {
        final formatted = _tryPrettyJson(bodyStr);
        _logLine(
          formatted.length > _maxWidth
              ? '${formatted.substring(0, _maxWidth)}...'
              : formatted,
        );
      }

      _printBoxBottom();

      // Return a new response with the same body bytes
      return StreamedResponse(
        Stream.value(bodyBytes),
        status,
        reasonPhrase: response.reasonPhrase,
        headers: response.headers,
        contentLength: response.contentLength,
        request: response.request,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
      );
    } catch (e) {
      sw.stop();
      _printBoxTop();
      _logLine('$method $path ERROR (${sw.elapsedMilliseconds}ms)');
      _printDivider();
      _logLine('$e');
      _printBoxBottom();
      rethrow;
    }
  }

  // --- Formatting helpers ---

  void _printBoxTop() {
    debugPrint('$_prefix $_topLeft${_horizontal * (_maxWidth ~/ 2)}');
  }

  void _printDivider() {
    debugPrint('$_prefix $_divider');
  }

  void _printBoxBottom() {
    debugPrint('$_prefix $_bottomRight${_horizontal * (_maxWidth ~/ 2)}');
  }

  void _logLine(String message) {
    debugPrint('$_prefix $_vertical $message');
  }

  /// Compact headers into a single line
  String _compactHeaders(Map<String, String> headers) {
    // Filter out the verbose ones
    final relevant = <String>[];
    if (headers.containsKey('Authorization')) {
      relevant.add(
        'Authorization: ${headers['Authorization']!.substring(0, 40)}...',
      );
    }
    if (headers.containsKey('apikey')) {
      relevant.add('apikey: ${headers['apikey']!.substring(0, 8)}...');
    }
    if (headers.containsKey('Content-Type')) {
      relevant.add('Content-Type: ${headers['Content-Type']}');
    }
    if (headers.containsKey('Prefer')) {
      relevant.add('Prefer: ${headers['Prefer']}');
    }
    return relevant.join(', ');
  }

  /// Try to JSON-format a string; fallback to raw string
  String _tryPrettyJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return raw.length > 200 ? '${raw.substring(0, 200)}...' : raw;
    }
  }
}
