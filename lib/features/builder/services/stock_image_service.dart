import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class StockImageService {
  // TODO: ضع مفتاح Pixabay API الخاص بك هنا
  // يمكنك الحصول عليه مجاناً من https://pixabay.com/api/docs/
  static const String _pixabayApiKey = 'YOUR_PIXABAY_API_KEY_HERE'; 
  static const String _baseUrl = 'https://pixabay.com/api/';

  Future<List<String>> searchImages(String query, {int perPage = 20}) async {
    if (_pixabayApiKey == 'YOUR_PIXABAY_API_KEY_HERE' || _pixabayApiKey.isEmpty) {
      debugPrint('Pixabay API Key is missing. Please add it to StockImageService.');
      // Return some fallback images if key is missing so the UI doesn't look broken
      return [
        'https://images.unsplash.com/photo-1542744094-3a31f103e35f?w=800',
        'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800',
        'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=800',
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
      ];
    }

    try {
      final encodedQuery = Uri.encodeComponent(query.isEmpty ? 'background' : query);
      final url = '$_baseUrl?key=$_pixabayApiKey&q=$encodedQuery&image_type=photo&orientation=horizontal&per_page=$perPage';
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hits = data['hits'] as List;
        return hits.map((p) => p['largeImageURL'] as String).toList();
      } else {
        debugPrint('Pixabay API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('StockImageService Exception: $e');
      return [];
    }
  }
}
