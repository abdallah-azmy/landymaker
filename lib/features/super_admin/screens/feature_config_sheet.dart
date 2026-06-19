import 'package:flutter/material.dart';
import '../../home/models/home_layouts.dart';

class FeatureConfigSheet extends StatefulWidget {
  final Map<String, dynamic> config;
  final ValueChanged<Map<String, dynamic>> onSave;

  const FeatureConfigSheet({super.key, required this.config, required this.onSave});

  @override
  State<FeatureConfigSheet> createState() => _FeatureConfigSheetState();
}

class _FeatureConfigSheetState extends State<FeatureConfigSheet> {
  late FeatureLayout _layout;
  late TextEditingController _titleArController;
  late TextEditingController _titleEnController;

  @override
  void initState() {
    super.initState();
    final layoutStr = widget.config['layout'] as String? ?? 'bentoGrid';
    _layout = FeatureLayout.values.firstWhere((e) => e.name == layoutStr, orElse: () => FeatureLayout.bentoGrid);
    _titleArController = TextEditingController(text: widget.config['title_ar'] as String? ?? '');
    _titleEnController = TextEditingController(text: widget.config['title_en'] as String? ?? '');
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave({
      'layout': _layout.name,
      'title_ar': _titleArController.text,
      'title_en': _titleEnController.text,
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
              Text('إعدادات المميزات', style: theme.textTheme.titleLarge),
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
            items: FeatureLayout.values.map((l) => DropdownMenuItem(value: l.name, child: Text(_layoutName(l)))).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _layout = FeatureLayout.values.firstWhere((e) => e.name == v));
            },
          ),
          const SizedBox(height: 16),
          Text('العنوان (عربي)', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _titleArController,
            decoration: InputDecoration(
              hintText: 'مميزات لا حصر لها',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Text('العنوان (إنجليزي)', style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _titleEnController,
            decoration: InputDecoration(
              hintText: 'Endless Features',
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

  String _layoutName(FeatureLayout l) {
    return switch (l) {
      FeatureLayout.bentoGrid => 'شبكة بينتو',
      FeatureLayout.threeCols => 'ثلاثة أعمدة',
      FeatureLayout.iconLeft => 'أيقونة على اليسار',
    };
  }
}
