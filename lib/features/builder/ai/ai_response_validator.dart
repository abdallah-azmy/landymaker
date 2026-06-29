import 'block_schema.dart';

class AIResponseValidator {
  static Map<String, dynamic>? validate(dynamic designJsonInput, {bool isEdit = false, List? currentBlocks}) {
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

      // Theme Validation — fix hex prefixes for both `theme` and `global_theme` keys
      for (final themeKey in ['theme', 'global_theme']) {
        if (designJson.containsKey(themeKey)) {
          final theme = designJson[themeKey];
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
      }

      // Block Validation — delegates to BlockPropertyMapper for full property sanitization
      final List blocks = designJson['blocks'];
      final List<Map<String, dynamic>> validBlocks = [];

      for (var rawBlock in blocks) {
        if (rawBlock is Map<String, dynamic>) {
          final block = Map<String, dynamic>.from(rawBlock);
          String? type = block['type'] as String?;
          final int? index = block['_index'] as int?;

          // Resolve type if missing but _index is present (for partial edits)
          if (type == null && index != null && currentBlocks != null) {
            if (index >= 0 && index < currentBlocks.length) {
              final existingBlock = currentBlocks[index];
              if (existingBlock is Map && existingBlock.containsKey('type')) {
                type = existingBlock['type'] as String?;
                block['type'] = type;
              }
            }
          }

          if (type != null) {
            // Map old 'visibility' key
            if (block.containsKey('visibility') && !block.containsKey('is_visible')) {
              block['is_visible'] = block['visibility'];
              block.remove('visibility');
            }

            // Full property mapping: strip unknown keys, coerce types, apply defaults
            BlockPropertyMapper.sanitize(block, isEdit: isEdit);

            // Skip if block lost its 'items' which is required for its type
            if (type == 'features' || type == 'pricing' || type == 'faq' || type == 'testimonials') {
              final hasItems = block.containsKey('items');
              if (!isEdit && (!hasItems || block['items'] is! List || (block['items'] as List).isEmpty)) {
                continue;
              }
              if (isEdit && hasItems && (block['items'] is! List || (block['items'] as List).isEmpty)) {
                continue;
              }
            }

            validBlocks.add(block);
          }
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
