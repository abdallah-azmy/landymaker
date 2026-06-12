import 'block_schema.dart';

class AIResponseValidator {
  static Map<String, dynamic>? validate(dynamic designJsonInput) {
    if (designJsonInput == null) return null;

    Map<String, dynamic> designJson;
    if (designJsonInput is List) {
      designJson = {'blocks': designJsonInput};
    } else if (designJsonInput is Map) {
      designJson = Map<String, dynamic>.from(designJsonInput);
    } else {
      return null;
    }

    try {
      // Self-healing mapping for 'sections' -> 'blocks'
      if (designJson.containsKey('sections') &&
          !designJson.containsKey('blocks')) {
        designJson['blocks'] = designJson['sections'];
      }

      if (!designJson.containsKey('blocks') || designJson['blocks'] is! List) {
        return null;
      }

      // Theme Validation
      if (designJson.containsKey('global_theme')) {
        final theme = designJson['global_theme'];
        if (theme is Map) {
          theme.forEach((key, value) {
            if (key.contains('color') ||
                [
                  'primary',
                  'secondary',
                  'background',
                  'textPrimary',
                  'textSecondary',
                ].contains(key)) {
              if (value is String &&
                  value.isNotEmpty &&
                  !value.startsWith('#')) {
                theme[key] = '#$value';
              }
            }
          });
        }
      }

      // Block Validation — delegates to BlockPropertyMapper for full property sanitization
      final List blocks = designJson['blocks'];
      final List<Map<String, dynamic>> validBlocks = [];

      for (var block in blocks) {
        if (block is Map<String, dynamic> && block.containsKey('type')) {
          final type = block['type'] as String;

          // Map old 'visibility' key
          if (block.containsKey('visibility') && !block.containsKey('is_visible')) {
            block['is_visible'] = block['visibility'];
            block.remove('visibility');
          }

          // Full property mapping: strip unknown keys, coerce types, apply defaults
          BlockPropertyMapper.sanitize(block);

          // Skip if block lost its 'items' which is required for its type
          if (type == 'features' || type == 'pricing' || type == 'faq' || type == 'testimonials') {
            if (block['items'] is! List || (block['items'] as List).isEmpty) continue;
          }

          validBlocks.add(block);
        }
      }

      designJson['blocks'] = validBlocks;
      return designJson;
    } catch (e) {
      print('AI Validation Error: $e');
      return null;
    }
  }
}
