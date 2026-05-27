import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// DioFactory creates and configures a Dio instance with PrettyDioLogger for API request logging
class DioFactory {
  /// Private constructor - this is a utility class
  DioFactory._();

  static Dio? _dio;

  /// Get or create a singleton Dio instance with interceptors
  static Future<Dio> getDio() async {
    const Duration timeOut = Duration(seconds: 30);

    if (_dio == null) {
      _dio = Dio();
      _dio!
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut;

      _addDioInterceptors();
    }

    return _dio!;
  }

  /// Add interceptors to Dio for request/response logging
  static void _addDioInterceptors() {
    // Add PrettyDioLogger for beautiful console output of all HTTP requests/responses
    if (!kReleaseMode) {
      _dio?.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: false,
          maxWidth: 90,
        ),
      );
    }
  }
}
