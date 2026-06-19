import 'package:flutter/material.dart';
import '../../home/models/home_layouts.dart';

class HeroConfigSheet extends StatefulWidget {
  final Map<String, dynamic> config;
  final ValueChanged<Map<String, dynamic>> onSave;

  const HeroConfigSheet({super.key, required this.config, required this.onSave});

  @override
  State<HeroConfigSheet> createState() => _HeroConfigSheetState();
}

class _HeroConfigSheetState extends State<HeroConfigSheet> {
  late HeroLayout _layout;
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;

  @override
  void initState() {
    super.initState();
    final layoutStr = widget.config['layout'] as String? ?? 'split';
    _layout = HeroLayout.values.firstWhere((e) => e.name == layoutStr, orElse: () => HeroLayout.split);
    _titleController = TextEditingController(text: widget.config['title'] as String? ?? '');
    _subtitleController = TextEditingController(text: widget.config['subtitle'] as String? ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave({
      'layout': _layout.name,
      'title': _titleController.text,
      'subtitle': _subtitleController.text,
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
              Text('إعدادات القسم الترحيبي', style: theme.textTheme.titleLarge),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 16),
          Text('نوع التخطيط', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _layout.name,
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            items: HeroLayout.values.map((l) => DropdownMenuItem(value: l.name, child: Text(_layoutName(l)))).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _layout = HeroLayout.values.firstWhere((e) => e.name == v));
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'العنوان',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtitleController,
            decoration: InputDecoration(
              labelText: 'النص الفرعي',
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

  String _layoutName(HeroLayout l) {
    return switch (l) {
      HeroLayout.split => 'نص + صورة (منقسم)',
      HeroLayout.centered => 'مركز بخلفية صورة',
      HeroLayout.gradientOnly => 'تدرج لوني فقط',
      HeroLayout.fullWidthImage => 'صورة كاملة العرض',
    };
  }
}
