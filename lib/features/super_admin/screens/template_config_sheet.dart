import 'package:flutter/material.dart';
import '../../../core/widgets/atoms/cube_spinner.dart';
import '../../../injection_container.dart';
import '../../../services/database_service.dart';
import '../../home/models/home_layouts.dart';

class TemplateConfigSheet extends StatefulWidget {
  final Map<String, dynamic> config;
  final ValueChanged<Map<String, dynamic>> onSave;

  const TemplateConfigSheet({super.key, required this.config, required this.onSave});

  @override
  State<TemplateConfigSheet> createState() => _TemplateConfigSheetState();
}

class _TemplateConfigSheetState extends State<TemplateConfigSheet> {
  late TemplateSliderLayout _layout;
  late TextEditingController _titleArController;
  late TextEditingController _titleEnController;
  late TextEditingController _subtitleArController;
  late TextEditingController _subtitleEnController;
  late TextEditingController _maxToShowController;

  List<Map<String, dynamic>> _allTemplates = [];
  Set<String> _selectedIds = {};
  bool _loadingTemplates = true;

  @override
  void initState() {
    super.initState();
    final layoutStr = widget.config['layout'] as String? ?? 'horizontalSlider';
    _layout = TemplateSliderLayout.values.firstWhere((e) => e.name == layoutStr, orElse: () => TemplateSliderLayout.horizontalSlider);
    _titleArController = TextEditingController(text: widget.config['title_ar'] as String? ?? '');
    _titleEnController = TextEditingController(text: widget.config['title_en'] as String? ?? '');
    _subtitleArController = TextEditingController(text: widget.config['subtitle_ar'] as String? ?? '');
    _subtitleEnController = TextEditingController(text: widget.config['subtitle_en'] as String? ?? '');
    _maxToShowController = TextEditingController(text: (widget.config['max_to_show'] ?? 6).toString());

    final ids = widget.config['template_ids'];
    if (ids is List) {
      _selectedIds = ids.map((e) => e.toString()).toSet();
    }

    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await sl<DatabaseService>().fetchFeaturedTemplates();
      if (mounted) {
        setState(() {
          _allTemplates = templates;
          _loadingTemplates = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingTemplates = false);
      }
    }
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _subtitleArController.dispose();
    _subtitleEnController.dispose();
    _maxToShowController.dispose();
    super.dispose();
  }

  void _toggleTemplate(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _save() {
    widget.onSave({
      'layout': _layout.name,
      'title_ar': _titleArController.text,
      'title_en': _titleEnController.text,
      'subtitle_ar': _subtitleArController.text,
      'subtitle_en': _subtitleEnController.text,
      'max_to_show': int.tryParse(_maxToShowController.text) ?? 6,
      'template_ids': _selectedIds.toList(),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('إعدادات السلايدر', style: theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 16),
            Text('نوع التخطيط', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _layout.name,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: TemplateSliderLayout.values.map((l) => DropdownMenuItem(value: l.name, child: Text(_layoutName(l)))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _layout = TemplateSliderLayout.values.firstWhere((e) => e.name == v));
              },
            ),
            const SizedBox(height: 16),
            Text('العنوان (عربي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _titleArController,
              decoration: InputDecoration(
                hintText: 'قوالب احترافية جاهزة',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Text('العنوان (إنجليزي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _titleEnController,
              decoration: InputDecoration(
                hintText: 'Ready Professional Templates',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Text('النص الفرعي (عربي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _subtitleArController,
              decoration: InputDecoration(
                hintText: 'اختر من بين مئات القوالب',
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
                hintText: 'Choose from hundreds of templates',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _maxToShowController,
              decoration: InputDecoration(
                labelText: 'الحد الأقصى للعرض',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text('اختيار القوالب', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            if (_loadingTemplates)
              Center(child: Padding(
                padding: const EdgeInsets.all(16),
                child: CubeSpinner(
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ))
            else if (_allTemplates.isEmpty)
              Text('لا توجد قوالب متاحة', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))
            else
              ..._allTemplates.map((t) {
                final id = t['id']?.toString() ?? '';
                final name = t['name'] as String? ?? '';
                final isSelected = _selectedIds.contains(id);
                return CheckboxListTile(
                  title: Text(name),
                  value: isSelected,
                  onChanged: (_) => _toggleTemplate(id),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('حفظ')),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _layoutName(TemplateSliderLayout l) {
    return switch (l) {
      TemplateSliderLayout.horizontalSlider => 'سلايدر أفقي',
      TemplateSliderLayout.masonryGrid => 'شبكة ماسونية',
      TemplateSliderLayout.twoColsGrid => 'شبكة عمودين',
    };
  }
}
