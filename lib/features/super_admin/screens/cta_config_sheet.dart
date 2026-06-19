import 'package:flutter/material.dart';
import '../../home/models/home_layouts.dart';

class CtaConfigSheet extends StatefulWidget {
  final Map<String, dynamic> config;
  final ValueChanged<Map<String, dynamic>> onSave;

  const CtaConfigSheet({super.key, required this.config, required this.onSave});

  @override
  State<CtaConfigSheet> createState() => _CtaConfigSheetState();
}

class _CtaConfigSheetState extends State<CtaConfigSheet> {
  late CtaLayout _layout;
  late TextEditingController _textController;
  late TextEditingController _buttonTextController;

  @override
  void initState() {
    super.initState();
    final layoutStr = widget.config['layout'] as String? ?? 'centeredGradient';
    _layout = CtaLayout.values.firstWhere((e) => e.name == layoutStr, orElse: () => CtaLayout.centeredGradient);
    _textController = TextEditingController(text: widget.config['text'] as String? ?? '');
    _buttonTextController = TextEditingController(text: widget.config['button_text'] as String? ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    _buttonTextController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave({
      'layout': _layout.name,
      'title': _textController.text,
      'button_text': _buttonTextController.text,
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
              Text('إعدادات قسم الدعوة للإجراء', style: theme.textTheme.titleLarge),
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
            items: CtaLayout.values.map((l) => DropdownMenuItem(value: l.name, child: Text(_layoutName(l)))).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _layout = CtaLayout.values.firstWhere((e) => e.name == v));
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'النص',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _buttonTextController,
            decoration: InputDecoration(
              labelText: 'نص الزر',
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

  String _layoutName(CtaLayout l) {
    return switch (l) {
      CtaLayout.centeredGradient => 'مركز بتدرج لوني',
      CtaLayout.split => 'نص + زر (منقسم)',
      CtaLayout.fullWidthImage => 'صورة كاملة العرض',
    };
  }
}
