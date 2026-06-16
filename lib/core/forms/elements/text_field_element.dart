import 'package:flutter/material.dart';
import 'package:landymaker/core/utils/localized_text_parser.dart';
import '../../widgets/atoms/custom_text_field.dart';

class TextFieldElement extends StatelessWidget {
  final Map<String, dynamic> schema;
  final TextEditingController controller;
  final String? errorMessage;
  final ValueChanged<String>? onChanged;

  const TextFieldElement({
    super.key,
    required this.schema,
    required this.controller,
    this.errorMessage,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final String label = LocalizedTextParser.extractText(schema['label'], 'ar');
    final String placeholder = LocalizedTextParser.extractText(
      schema['placeholder'],
      'ar',
    );
    final String fieldType = schema['field_type'] ?? 'text';
    final bool isRequired = schema['is_required'] == true;

    final TextInputType keyboardType;
    if (fieldType == 'email') {
      keyboardType = TextInputType.emailAddress;
    } else if (fieldType == 'phone' || fieldType == 'number') {
      keyboardType = TextInputType.phone;
    } else if (fieldType == 'textarea') {
      keyboardType = TextInputType.multiline;
    } else {
      keyboardType = TextInputType.text;
    }

    final int maxLines = fieldType == 'textarea' ? 4 : 1;
    final TextDirection? textDirection = (fieldType == 'email' || fieldType == 'phone' || fieldType == 'number')
        ? TextDirection.ltr
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            RichText(
              text: TextSpan(
                text: label,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                children: [
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          CustomTextField(
            controller: controller,
            hintText: placeholder.isNotEmpty ? placeholder : null,
            keyboardType: keyboardType,
            maxLines: maxLines,
            errorText: errorMessage,
            onChanged: onChanged,
            textDirection: textDirection,
          ),
        ],
      ),
    );
  }
}
