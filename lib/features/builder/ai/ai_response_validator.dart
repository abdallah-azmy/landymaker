class AIResponseValidator {
  static Map<String, dynamic>? validate(Map<String, dynamic>? designJson) {
    if (designJson == null) return null;

    try {
      // 1. Basic Structure
      if (!designJson.containsKey('blocks') || designJson['blocks'] is! List) {
        return null;
      }

      // 2. Theme Validation
      if (designJson.containsKey('global_theme')) {
        final theme = designJson['global_theme'];
        if (theme is Map) {
          // Ensure colors are valid hex strings
          theme.forEach((key, value) {
            if (key.contains('color') || ['primary', 'secondary', 'background', 'textPrimary', 'textSecondary'].contains(key)) {
              if (value is String && !value.startsWith('#')) {
                theme[key] = '#$value'; // Auto-fix missing hash
              }
            }
          });
        }
      }

      // 3. Block Validation
      final List blocks = designJson['blocks'];
      final List<Map<String, dynamic>> validBlocks = [];

      for (var block in blocks) {
        if (block is Map<String, dynamic> && block.containsKey('type')) {
          // Sanitize variant
          if (block.containsKey('variant')) {
            if (block['variant'] is String) {
              block['variant'] = int.tryParse(block['variant']) ?? 0;
            } else if (block['variant'] is! int) {
              block['variant'] = 0;
            }
            // Clamp 0-9
            block['variant'] = (block['variant'] as int).clamp(0, 9);
          }

          // Ensure animation object is correct
          if (block.containsKey('animation') && block['animation'] is! Map) {
            block['animation'] = {'type': 'fadeIn', 'duration': 800, 'delay': 0};
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
