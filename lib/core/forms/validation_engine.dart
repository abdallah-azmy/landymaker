class ValidationEngine {
  /// Validates a single step or form given its fields schema and the current data payload.
  /// Returns a Map of field_id -> Error Message. Empty map means all valid.
  static Map<String, String> validate(
      List<dynamic> fieldsSchema, Map<String, dynamic> dataPayload) {
    final Map<String, String> errors = {};

    for (final field in fieldsSchema) {
      if (field is! Map<String, dynamic>) continue;

      final fieldId = field['field_id'] as String?;
      if (fieldId == null) continue;

      final isRequired = field['is_required'] == true;
      final value = dataPayload[fieldId];
      final String stringValue = (value ?? '').toString().trim();

      // Check required
      if (isRequired && stringValue.isEmpty) {
        errors[fieldId] = 'هذا الحقل مطلوب'; // This field is required
        continue;
      }

      // If empty and not required, skip further validations
      if (stringValue.isEmpty) continue;

      // Check specific validations
      final validation = field['validation'];
      if (validation is Map<String, dynamic>) {
        // Min Length
        if (validation.containsKey('min_length')) {
          final int min = validation['min_length'] is int
              ? validation['min_length']
              : int.tryParse(validation['min_length'].toString()) ?? 0;
          if (stringValue.length < min) {
            errors[fieldId] = 'يجب ألا يقل عن $min أحرف';
            continue;
          }
        }

        // Max Length
        if (validation.containsKey('max_length')) {
          final int max = validation['max_length'] is int
              ? validation['max_length']
              : int.tryParse(validation['max_length'].toString()) ?? 9999;
          if (stringValue.length > max) {
            errors[fieldId] = 'يجب ألا يزيد عن $max أحرف';
            continue;
          }
        }

        // Regex Pattern
        if (validation.containsKey('pattern')) {
          final String patternStr = validation['pattern'].toString();
          if (patternStr.isNotEmpty) {
            try {
              final regex = RegExp(patternStr);
              if (!regex.hasMatch(stringValue)) {
                errors[fieldId] = 'صيغة غير صحيحة';
                continue;
              }
            } catch (_) {
              // Ignore invalid regex from builder
            }
          }
        }
      }

      // Built-in email validation if field_type is email
      if (field['field_type'] == 'email') {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(stringValue)) {
          errors[fieldId] = 'يرجى إدخال بريد إلكتروني صحيح';
          continue;
        }
      }
    }

    return errors;
  }
}
