import 'package:flutter/material.dart';

class FooterConfigSheet extends StatefulWidget {
  final Map<String, dynamic> config;
  final ValueChanged<Map<String, dynamic>> onSave;

  const FooterConfigSheet({super.key, required this.config, required this.onSave});

  @override
  State<FooterConfigSheet> createState() => _FooterConfigSheetState();
}

class _FooterConfigSheetState extends State<FooterConfigSheet> {
  late TextEditingController _copyrightArController;
  late TextEditingController _copyrightEnController;

  @override
  void initState() {
    super.initState();
    _copyrightArController = TextEditingController(text: widget.config['copyright_text_ar'] as String? ?? '');
    _copyrightEnController = TextEditingController(text: widget.config['copyright_text_en'] as String? ?? '');
  }

  @override
  void dispose() {
    _copyrightArController.dispose();
    _copyrightEnController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave({
      'copyright_text_ar': _copyrightArController.text,
      'copyright_text_en': _copyrightEnController.text,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24, start: 24, end: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('إعدادات الـ Footer', style: theme.textTheme.titleLarge),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 16),
          Text('نص حقوق النشر (عربي)', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _copyrightArController,
            decoration: InputDecoration(
              hintText: '© 2026 LandyMaker. جميع الحقوق محفوظة.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Text('نص حقوق النشر (إنجليزي)', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _copyrightEnController,
            decoration: InputDecoration(
              hintText: '© 2026 LandyMaker. All rights reserved.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('حفظ')),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
