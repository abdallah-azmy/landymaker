import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class DynamicFontService {
  static final Set<String> _loadedFonts = {};
  static final Set<String> _failedFonts = {};

  /// Scans the landing page design JSON recursively to find all custom font families
  /// and their associated weights, then triggers loading for them.
  static Future<void> loadFontsFromDesign(Map<String, dynamic> designJson) async {
    final usedFonts = <String, Set<int>>{};

    // 1. Scan default page font
    final themeJson = designJson['theme'] as Map<String, dynamic>? ?? {};
    final defaultFont = themeJson['defaultFont'] ?? themeJson['font_family'];
    if (defaultFont != null && defaultFont is String && defaultFont.isNotEmpty) {
      usedFonts.putIfAbsent(defaultFont, () => <int>{}).addAll({400, 700}); // Load default weights
    }

    // 2. Scan blocks recursively
    final blocks = designJson['blocks'];
    if (blocks is List) {
      for (final block in blocks) {
        if (block is Map) {
          _scanBlockForFonts(Map<String, dynamic>.from(block), usedFonts);
        }
      }
    }

    // 3. Load identified fonts asynchronously
    for (final entry in usedFonts.entries) {
      final fontName = entry.key;
      final weights = entry.value;
      
      // Cairo and sans-serif are already handled locally or by system
      if (fontName.toLowerCase() == 'cairo' || fontName.toLowerCase() == 'sans-serif') {
        continue;
      }
      
      await loadFont(fontName, weights.toList());
    }
  }

  static void _scanBlockForFonts(Map<String, dynamic> block, Map<String, Set<int>> usedFonts) {
    String? fontFamily;
    int weightVal = 400;

    // Check styleOverrides first
    final overrides = block['styleOverrides'] ?? block['style_overrides'];
    if (overrides is Map) {
      if (overrides.containsKey('fontFamily')) {
        fontFamily = overrides['fontFamily']?.toString();
      } else if (overrides.containsKey('font_family')) {
        fontFamily = overrides['font_family']?.toString();
      }

      if (overrides.containsKey('fontWeight')) {
        final w = overrides['fontWeight']?.toString();
        if (w == 'bold' || w == '700') weightVal = 700;
        else if (w == 'light' || w == '300') weightVal = 300;
        else if (w == 'medium' || w == '500') weightVal = 500;
        else if (w == 'semibold' || w == '600') weightVal = 600;
      }
    }

    // Check direct properties if styling overrides didn't have it
    if (fontFamily == null) {
      if (block.containsKey('fontFamily')) {
        fontFamily = block['fontFamily']?.toString();
      } else if (block.containsKey('font_family')) {
        fontFamily = block['font_family']?.toString();
      }
    }

    if (fontFamily != null && fontFamily.isNotEmpty && fontFamily.toLowerCase() != 'cairo') {
      usedFonts.putIfAbsent(fontFamily, () => <int>{}).add(weightVal);
      // Always load weight 400 as standard fallback to prevent missing weight layout shifts
      usedFonts[fontFamily]!.add(400);
    }

    // Recursively search child maps or lists (e.g. nested lists of buttons, products, tabs)
    block.forEach((key, value) {
      if (value is Map) {
        _scanBlockForFonts(Map<String, dynamic>.from(value), usedFonts);
      } else if (value is List) {
        for (final item in value) {
          if (item is Map) {
            _scanBlockForFonts(Map<String, dynamic>.from(item), usedFonts);
          }
        }
      }
    });
  }

  /// Dynamically loads a Google Font weight collection using standard FontLoader.
  /// Fetches the unified TTFs from Google Fonts CDN without specifying User-Agent.
  static Future<void> loadFont(String fontName, List<int> weights) async {
    final sortedWeights = List<int>.from(weights)..sort();
    final cacheKey = '${fontName}_${sortedWeights.join("_")}';
    
    if (_loadedFonts.contains(cacheKey) || _failedFonts.contains(cacheKey)) {
      return; // Already loaded or failed previously
    }

    try {
      // 1. Get the CSS for the font from Google Fonts CSS API
      final weightString = sortedWeights.join(';');
      final cssUrl = 'https://fonts.googleapis.com/css2?family=${Uri.encodeComponent(fontName)}:wght@$weightString&display=swap';
      
      // http.get automatically follows redirects and defaults to no User-Agent (returns TTF)
      final response = await http.get(Uri.parse(cssUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch font CSS (${response.statusCode})');
      }

      final cssContent = response.body;

      // 2. Parse the Font URLs (supporting TTF, WOFF, WOFF2, and OTF formats)
      final exp = RegExp(r'url\((?:"|\u0027)?(https://[^"\u0027)]+\.(?:ttf|woff2?|otf))(?:"|\u0027)?\)');
      final matches = exp.allMatches(cssContent);
      
      if (matches.isEmpty) {
        throw Exception('No font URLs (TTF/WOFF/WOFF2/OTF) found in CSS response for $fontName');
      }

      // 3. Download and load each TTF
      final fontLoader = FontLoader(fontName);
      int loadedCount = 0;

      for (final match in matches) {
        final url = match.group(1);
        if (url != null) {
          final fontRes = await http.get(Uri.parse(url));
          if (fontRes.statusCode == 200) {
            fontLoader.addFont(Future.value(ByteData.sublistView(fontRes.bodyBytes)));
            loadedCount++;
          }
        }
      }

      if (loadedCount > 0) {
        await fontLoader.load();
        _loadedFonts.add(cacheKey);
        debugPrint('[DynamicFontService] Successfully registered font: $fontName with weights: $sortedWeights');
      }
    } catch (e) {
      _failedFonts.add(cacheKey);
      debugPrint('[DynamicFontService] Error dynamically loading font $fontName: $e');
    }
  }
}
