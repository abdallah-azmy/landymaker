import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

/// An adapter that allows Supabase (which uses the 'http' package) to use a 'Dio' instance.
/// This enables the use of Dio features like 'pretty_dio_logger' for all Supabase traffic.
class DioHttpClientAdapter extends http.BaseClient {
  final Dio dio;

  DioHttpClientAdapter(this.dio);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. Determine if we should send a body (avoid bodies for GET/HEAD as per Web constraints)
    final bool canHaveBody = request.method != 'GET' && request.method != 'HEAD';

    // 2. Prepare Dio options based on the http.BaseRequest
    final options = Options(
      method: request.method,
      headers: request.headers,
      // Change to plain so PrettyDioLogger can intercept and log it
      responseType: ResponseType.plain,
      followRedirects: false,
      validateStatus: (status) => true,
    );

    try {
      // 3. Prepare the body data
      dynamic body;
      if (canHaveBody) {
        if (request is http.Request && request.bodyBytes.isNotEmpty) {
          body = request.bodyBytes;
          // Ensure Content-Type is set if missing to avoid Dio warning
          options.headers ??= {};
          
          // Case-insensitive check for content-type
          final hasContentType = options.headers!.keys.any(
            (k) => k.toLowerCase() == 'content-type',
          );
          
          if (!hasContentType) {
            options.headers!['content-type'] = 'application/json; charset=utf-8';
          }
        } else {
          final finalized = await request.finalize().toBytes();
          if (finalized.isNotEmpty) {
            body = finalized;
          }
        }
      }

      // 4. Execute request via Dio
      final response = await dio.requestUri<dynamic>(
        request.url,
        data: body,
        options: options,
      );

      final dynamic responseData = response.data;
      final List<int> bytes;

      if (responseData is String) {
        bytes = utf8.encode(responseData);
      } else if (responseData is List<int>) {
        bytes = responseData;
      } else {
        bytes = [];
      }

      // 5. Convert Dio response back to http.StreamedResponse for Supabase SDK
      return http.StreamedResponse(
        Stream.value(bytes),
        response.statusCode ?? 0,
        contentLength: bytes.length,
        headers: response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
        reasonPhrase: response.statusMessage,
        request: request,
      );
    } on DioException catch (e) {
      // Handle Dio errors by returning an empty or captured response body
      final errorData = e.response?.data;
      final List<int> bytes = errorData is String ? utf8.encode(errorData) : [];

      return http.StreamedResponse(
        Stream.value(bytes),
        e.response?.statusCode ?? 500,
        headers: e.response?.headers.map.map((k, v) => MapEntry(k, v.join(','))) ?? {},
        request: request,
      );
    }
  }
}
