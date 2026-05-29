import 'dart:async';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

/// An adapter that allows Supabase (which uses the 'http' package) to use a 'Dio' instance.
/// This enables the use of Dio features like 'pretty_dio_logger' for all Supabase traffic.
class DioHttpClientAdapter extends http.BaseClient {
  final Dio dio;

  DioHttpClientAdapter(this.dio);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. Prepare Dio options based on the http.BaseRequest
    final options = Options(
      method: request.method,
      headers: request.headers,
      responseType: ResponseType.stream,
      // We let Supabase handle redirects
      followRedirects: false,
      // Do not throw on status code errors; let the SDK handle them
      validateStatus: (status) => true, 
    );

    try {
      // 2. Finalize the request body if it exists
      dynamic body;
      if (request is http.Request && request.bodyBytes.isNotEmpty) {
        body = Stream.value(request.bodyBytes);
      } else {
        body = request.finalize();
      }

      // 3. Execute request via Dio
      final response = await dio.requestUri<ResponseBody>(
        request.url,
        data: body,
        options: options,
      );

      final dioStream = response.data!;

      // 4. Convert Dio response back to http.StreamedResponse for Supabase SDK
      return http.StreamedResponse(
        dioStream.stream,
        response.statusCode ?? 0,
        contentLength: response.headers.value('content-length') != null 
            ? int.tryParse(response.headers.value('content-length')!) 
            : null,
        headers: response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
        reasonPhrase: response.statusMessage,
        request: request,
      );
    } on DioException catch (e) {
      // If Dio throws an error, we try to wrap its response or rethrow
      if (e.response != null && e.response!.data is ResponseBody) {
        final dioStream = e.response!.data as ResponseBody;
        return http.StreamedResponse(
          dioStream.stream,
          e.response!.statusCode ?? 0,
          headers: e.response!.headers.map.map((k, v) => MapEntry(k, v.join(','))),
          request: request,
        );
      }
      rethrow;
    }
  }
}
