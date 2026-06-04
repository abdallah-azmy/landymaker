import 'package:flutter/material.dart';
import 'text_field_element.dart';
import 'radio_element.dart';
import 'dropdown_element.dart';

class FieldRenderer {
  /// Renders the appropriate form element based on the `field_type`.
  static Widget render({
    required Map<String, dynamic> schema,
    required TextEditingController controller, // Used for text-based inputs
    required String? currentValue,           // Used for radio/dropdown
    required ValueChanged<String> onChanged,
    String? errorMessage,
  }) {
    final String type = schema['field_type'] ?? 'text';

    switch (type) {
      case 'radio':
        return RadioElement(
          schema: schema,
          currentValue: currentValue,
          onChanged: onChanged,
          errorMessage: errorMessage,
        );
      case 'dropdown':
        return DropdownElement(
          schema: schema,
          currentValue: currentValue,
          onChanged: onChanged,
          errorMessage: errorMessage,
        );
      case 'text':
      case 'email':
      case 'phone':
      case 'number':
      case 'textarea':
      default:
        // Text based inputs
        return TextFieldElement(
          schema: schema,
          controller: controller,
          errorMessage: errorMessage,
          onChanged: onChanged,
        );
    }
  }
}
