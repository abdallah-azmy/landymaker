import 'package:flutter/material.dart';

class DesktopPreviewConfigSheet extends StatefulWidget {
  final Map<String, dynamic> config;
  final ValueChanged<Map<String, dynamic>> onSave;

  const DesktopPreviewConfigSheet({super.key, required this.config, required this.onSave});

  @override
  State<DesktopPreviewConfigSheet> createState() => _DesktopPreviewConfigSheetState();
}

class _DesktopPreviewConfigSheetState extends State<DesktopPreviewConfigSheet> {
  late TextEditingController _titleArController;
  late TextEditingController _titleEnController;
  late TextEditingController _subtitleArController;
  late TextEditingController _subtitleEnController;
  late TextEditingController _descriptionArController;
  late TextEditingController _descriptionEnController;

  @override
  void initState() {
    super.initState();
    _titleArController = TextEditingController(text: widget.config['title_ar'] as String? ?? '');
    _titleEnController = TextEditingController(text: widget.config['title_en'] as String? ?? '');
    _subtitleArController = TextEditingController(text: widget.config['subtitle_ar'] as String? ?? '');
    _subtitleEnController = TextEditingController(text: widget.config['subtitle_en'] as String? ?? '');
    _descriptionArController = TextEditingController(text: widget.config['description_ar'] as String? ?? '');
    _descriptionEnController = TextEditingController(text: widget.config['description_en'] as String? ?? '');
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _subtitleArController.dispose();
    _subtitleEnController.dispose();
    _descriptionArController.dispose();
    _descriptionEnController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave({
      'title_ar': _titleArController.text,
      'title_en': _titleEnController.text,
      'subtitle_ar': _subtitleArController.text,
      'subtitle_en': _subtitleEnController.text,
      'description_ar': _descriptionArController.text,
      'description_en': _descriptionEnController.text,
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
              Text('إعدادات معاينة الديسكتوب', style: theme.textTheme.titleLarge),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 16),
          Text('العنوان (عربي)', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _titleArController,
            decoration: InputDecoration(
              hintText: 'شاهد كيف سيبدو موقعك',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Text('العنوان (إنجليزي)', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _titleEnController,
            decoration: InputDecoration(
              hintText: 'See How Your Site Will Look',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Text('النص الفرعي (عربي)', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _subtitleArController,
            decoration: InputDecoration(
              hintText: 'معاينة حية لتصميم موقعك قبل النشر',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Text('النص الفرعي (إنجليزي)', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _subtitleEnController,
            decoration: InputDecoration(
              hintText: 'Live preview of your site design before publishing',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Text('الوصف (عربي)', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _descriptionArController,
            decoration: InputDecoration(
              hintText: 'احصل على معاينة كاملة لصفحة الهبوط الخاصة بك',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Text('الوصف (إنجليزي)', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _descriptionEnController,
            decoration: InputDecoration(
              hintText: 'Get a full preview of your landing page',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('حفظ')),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
