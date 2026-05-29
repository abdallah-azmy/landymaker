import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class StockImageService {
  static const String _pexelsApiKey = 'L8G77r3kR8hY3eY7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7Y7'; // Placeholder - replace with actual key
  static const String _baseUrl = 'https://api.pexels.com/v1';

  Future<List<String>> searchImages(String query, {int perPage = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?query=$query&per_page=$perPage'),
        headers: {
          'Authorization': _pexelsApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final photos = data['photos'] as List;
        return photos.map((p) => p['src']['large'] as String).toList();
      } else {
        debugPrint('Pexels API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('StockImageService Exception: $e');
      return [];
    }
  }
}
