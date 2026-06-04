import 'package:flutter/material.dart';
import 'package:landymaker/core/utils/localized_text_parser.dart';

class DropdownElement extends StatelessWidget {
  final Map<String, dynamic> schema;
  final String? currentValue;
  final ValueChanged<String> onChanged;
  final String? errorMessage;

  const DropdownElement({
    super.key,
    required this.schema,
    required this.currentValue,
    required this.onChanged,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final String label = LocalizedTextParser.extractText(schema['label'], 'ar');
    final String placeholder = LocalizedTextParser.extractText(
      schema['placeholder'],
      'ar',
    );
    final bool isRequired = schema['is_required'] == true;
    final List<dynamic> options = schema['options'] ?? [];

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
          DropdownButtonFormField<String>(
            initialValue: (currentValue != null && currentValue!.isNotEmpty)
                ? currentValue
                : null,
            decoration: InputDecoration(
              hintText: placeholder.isNotEmpty ? placeholder : null,
              errorText: errorMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: options
                .map((opt) {
                  if (opt is! Map) return null;
                  final String optValue = opt['value']?.toString() ?? '';
                  final String optLabel = LocalizedTextParser.extractText(
                    opt['label'],
                    'ar',
                  );
                  return DropdownMenuItem<String>(
                    value: optValue,
                    child: Text(optLabel),
                  );
                })
                .whereType<DropdownMenuItem<String>>()
                .toList(),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ],
      ),
    );
  }
}
