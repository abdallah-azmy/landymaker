import 'package:flutter/material.dart';
import 'package:landymaker/core/utils/localized_text_parser.dart';

class RadioElement extends StatelessWidget {
  final Map<String, dynamic> schema;
  final String? currentValue;
  final ValueChanged<String> onChanged;
  final String? errorMessage;

  const RadioElement({
    super.key,
    required this.schema,
    required this.currentValue,
    required this.onChanged,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final String label = LocalizedTextParser.extractText(schema['label'], 'ar');
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
          ...options.map((opt) {
            if (opt is! Map) return const SizedBox.shrink();
            final String optValue = opt['value']?.toString() ?? '';
            final String optLabel = LocalizedTextParser.extractText(
              opt['label'],
              'ar',
            );
            return RadioListTile<String>(
              title: Text(optLabel),
              value: optValue,
              groupValue: currentValue,
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
              contentPadding: EdgeInsets.zero,
              activeColor: Theme.of(context).primaryColor,
            );
          }),
          if (errorMessage != null && errorMessage!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 8.0, left: 8.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
