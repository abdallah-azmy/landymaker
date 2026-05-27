import 'package:flutter/foundation.dart';

class Logger {
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️  INFO: $message');
    }
  }

  static void warn(String message) {
    if (kDebugMode) {
      print('⚠️  WARN: $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) print('   Error: $error');
      if (stackTrace != null) print('   StackTrace: $stackTrace');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      print('🐛 DEBUG: $message');
    }
  }

  static void verbose(String message) {
    if (kDebugMode) {
      print('📝 VERBOSE: $message');
    }
  }
}
