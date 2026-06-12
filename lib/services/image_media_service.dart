import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../core/http_client.dart';
import '../core/utils/env_utils.dart';

class PixabayImageModel {
  final String id;
  final String previewUrl;
  final String webformatUrl;
  final String largeImageUrl;
  final String fullHdUrl;
  final String tags;
  final String? imageType;
  final int imageWidth;
  final int imageHeight;

  PixabayImageModel({
    required this.id,
    required this.previewUrl,
    required this.webformatUrl,
    required this.largeImageUrl,
    required this.fullHdUrl,
    required this.tags,
    this.imageType,
    this.imageWidth = 0,
    this.imageHeight = 0,
  });

  factory PixabayImageModel.fromJson(Map<String, dynamic> json) {
    return PixabayImageModel(
      id: json['id'].toString(),
      previewUrl: json['previewURL'] ?? '',
      webformatUrl: json['webformatURL'] ?? '',
      largeImageUrl: json['largeImageURL'] ?? '',
      fullHdUrl: json['fullHDURL'] ?? '',
      tags: json['tags'] ?? '',
      imageType: json['type'],
      imageWidth: json['imageWidth'] ?? 0,
      imageHeight: json['imageHeight'] ?? 0,
    );
  }
}

class ImageMediaService {
  // Best Practice: Fetch API Keys via Dart Environment variables at compile/run time.
  // E.g., flutter run --dart-define-from-file=.env.local
  static final String _pixabayApiKey = EnvUtils.pixabayApiKey;
  static final String _imgbbApiKey = EnvUtils.imgbbApiKey;

  /// Searches Pixabay for images based on the query.
  Future<List<PixabayImageModel>> fetchPixabayImages(
    String query, {
    int page = 1,
    String imageType = 'photo',
    String? orientation,
  }) async {
    if (_pixabayApiKey.isEmpty) {
      throw Exception(
        'Pixabay API Key is missing. Ensure it is defined in the environment.',
      );
    }

    final dio = await DioFactory.getDio();
    final url = 'https://pixabay.com/api/';

    try {
      final queryParams = <String, dynamic>{
        'key': _pixabayApiKey,
        'q': query,
        'image_type': imageType,
        'per_page': 30,
        'page': page,
        'safesearch': true,
      };
      if (orientation != null) queryParams['orientation'] = orientation;

      final response = await dio.get(url, queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List hits = response.data['hits'] ?? [];
        return hits.map((hit) => PixabayImageModel.fromJson(hit)).toList();
      } else if (response.statusCode == 429) {
        throw Exception(
          'عفواً، تم تجاوز الحد المسموح للبحث عن الصور. يرجى المحاولة لاحقاً.',
        );
      } else {
        throw Exception('Failed to fetch from Pixabay: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception(
          'عفواً، تم تجاوز الحد المسموح للبحث عن الصور. يرجى المحاولة لاحقاً.',
        );
      }
      throw Exception('Pixabay Search Error: ${e.message}');
    } catch (e) {
      throw Exception('Pixabay Search Error: $e');
    }
  }

  /// Downloads an image from Pixabay (or any URL) into memory,
  /// and immediately uploads it to ImgBB.
  /// This ensures we do not hotlink Pixabay images permanently.
  /// Downloads raw bytes of an image from a URL.
  Future<Uint8List> downloadImageBytes(
    String url, {
    CancelToken? cancelToken,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
        cancelToken: cancelToken,
      );

      if (response.data == null) {
        throw Exception('Failed to download image data.');
      }

      return Uint8List.fromList(response.data!);
    } catch (e) {
      throw Exception('Download Error: $e');
    }
  }

  /// Uploads raw image bytes to ImgBB.
  Future<String> uploadImageBytesToImgBB(
    Uint8List bytes,
    String filename,
    Function(int sent, int total) onSendProgress, {
    CancelToken? cancelToken,
  }) async {
    if (_imgbbApiKey.isEmpty) {
      throw Exception(
        'ImgBB API Key is missing. Ensure it is defined in the environment.',
      );
    }

    final dio = await DioFactory.getDio();
    final url = 'https://api.imgbb.com/1/upload';

    try {
      final formData = FormData.fromMap({
        'key': _imgbbApiKey,
        'image': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await dio.post(
        url,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null && data['url'] != null) {
          return data['url'];
        }
      }
      throw Exception('ImgBB upload failed: Invalid response structure.');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        throw Exception('تم إلغاء الرفع بواسطة المستخدم');
      }
      throw Exception('ImgBB Upload Error: ${e.message}');
    } catch (e) {
      throw Exception('ImgBB Upload Error: $e');
    }
  }
}
