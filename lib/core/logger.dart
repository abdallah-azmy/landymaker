import 'package:flutter/foundation.dart';

class Logger {
  static void _log(String level, String message) {
    if (kDebugMode) {
      // Prefix with level and timestamp for easier debugging
      final timestamp = DateTime.now().toIso8601String();
      // Using print ensures logs appear in console during development
      print('[$timestamp] [$level] $message');
    }
  }

  static void info(String message) => _log('INFO', message);
  static void warn(String message) => _log('WARN', message);
  static void error(String message) => _log('ERROR', message);
}
