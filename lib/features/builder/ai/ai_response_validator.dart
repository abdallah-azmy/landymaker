class AIResponseValidator {
  static final Map<String, List<String>> _requiredFields = {
    'hero': ['title'],
    'hero_saas': ['title'],
    'features': ['items'],
    'pricing': ['items'],
    'faq': ['items'],
    'testimonials': ['items'],
  };

  static Map<String, dynamic>? validate(dynamic designJsonInput) {
    if (designJsonInput == null) return null;

    Map<String, dynamic> designJson;
    if (designJsonInput is List) {
      // If the AI returns a list of blocks directly instead of a map, wrap it.
      designJson = {'blocks': designJsonInput};
    } else if (designJsonInput is Map) {
      // Convert to Map<String, dynamic> if needed
      designJson = Map<String, dynamic>.from(designJsonInput);
    } else {
      return null;
    }

    try {
      // 1. Basic Structure (Self-healing mapping for 'sections' -> 'blocks')
      if (designJson.containsKey('sections') &&
          !designJson.containsKey('blocks')) {
        designJson['blocks'] = designJson['sections'];
      }

      if (!designJson.containsKey('blocks') || designJson['blocks'] is! List) {
        return null;
      }

      // 2. Theme Validation
      if (designJson.containsKey('global_theme')) {
        final theme = designJson['global_theme'];
        if (theme is Map) {
          // Ensure colors are valid hex strings
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
          final type = block['type'] as String;

          // Schema check: Ensure minimum required keys exist and have correct formats
          if (_requiredFields.containsKey(type)) {
            final requiredKeys = _requiredFields[type]!;
            bool isValid = true;
            for (var key in requiredKeys) {
              if (!block.containsKey(key) || block[key] == null) {
                isValid = false;
                break;
              }
              if (key == 'items' && block[key] is! List) {
                isValid = false;
                break;
              }
            }
            if (!isValid) continue; // Skip corrupted block
          }

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
            block['animation'] = {
              'type': 'fadeIn',
              'duration': 800,
              'delay': 0,
            };
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
