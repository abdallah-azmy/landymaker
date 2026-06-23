import 'package:flutter/material.dart';
import '../../../core/widgets/atoms/cube_spinner.dart';
import '../../../injection_container.dart';
import '../../../services/database_service.dart';
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
  late TextEditingController _titleArController;
  late TextEditingController _titleEnController;
  late TextEditingController _subtitleArController;
  late TextEditingController _subtitleEnController;
  late TextEditingController _ctaTextArController;
  late TextEditingController _ctaTextEnController;
  late TextEditingController _typewriterArController;
  late TextEditingController _typewriterEnController;

  List<Map<String, dynamic>> _allPages = [];
  Set<String> _selectedPageIds = {};
  bool _loadingPages = true;

  @override
  void initState() {
    super.initState();
    final layoutStr = widget.config['layout'] as String? ?? 'split';
    _layout = HeroLayout.values.firstWhere((e) => e.name == layoutStr, orElse: () => HeroLayout.split);
    _titleArController = TextEditingController(text: widget.config['title_ar'] as String? ?? '');
    _titleEnController = TextEditingController(text: widget.config['title_en'] as String? ?? '');
    _subtitleArController = TextEditingController(text: widget.config['subtitle_ar'] as String? ?? '');
    _subtitleEnController = TextEditingController(text: widget.config['subtitle_en'] as String? ?? '');
    _ctaTextArController = TextEditingController(text: widget.config['cta_text_ar'] as String? ?? '');
    _ctaTextEnController = TextEditingController(text: widget.config['cta_text_en'] as String? ?? '');
    final twAr = widget.config['typewriter_texts_ar'];
    _typewriterArController = TextEditingController(text: twAr is List ? (twAr).join('\n') : '');
    final twEn = widget.config['typewriter_texts_en'];
    _typewriterEnController = TextEditingController(text: twEn is List ? (twEn).join('\n') : '');

    final ids = widget.config['preview_page_ids'];
    if (ids is List) {
      _selectedPageIds = ids.map((e) => e.toString()).toSet();
    }

    _loadPages();
  }

  Future<void> _loadPages() async {
    try {
      final pages = await sl<DatabaseService>().fetchAllLandingPages();
      if (mounted) {
        setState(() {
          _allPages = pages;
          _loadingPages = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingPages = false);
      }
    }
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _subtitleArController.dispose();
    _subtitleEnController.dispose();
    _ctaTextArController.dispose();
    _ctaTextEnController.dispose();
    _typewriterArController.dispose();
    _typewriterEnController.dispose();
    super.dispose();
  }

  void _togglePage(String id) {
    setState(() {
      if (_selectedPageIds.contains(id)) {
        _selectedPageIds.remove(id);
      } else {
        _selectedPageIds.add(id);
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
      'cta_text_ar': _ctaTextArController.text,
      'cta_text_en': _ctaTextEnController.text,
      'typewriter_texts_ar': _typewriterArController.text.split('\n').where((l) => l.trim().isNotEmpty).toList(),
      'typewriter_texts_en': _typewriterEnController.text.split('\n').where((l) => l.trim().isNotEmpty).toList(),
      'show_phone_preview': widget.config['show_phone_preview'] ?? true,
      'show_ai_button': widget.config['show_ai_button'] ?? true,
      'preview_page_ids': _selectedPageIds.toList(),
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
                Text('إعدادات القسم الترحيبي', style: theme.textTheme.titleLarge),
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
              items: HeroLayout.values.map((l) => DropdownMenuItem(value: l.name, child: Text(_layoutName(l)))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _layout = HeroLayout.values.firstWhere((e) => e.name == v));
              },
            ),
            const SizedBox(height: 16),
            Text('العنوان (عربي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _titleArController,
              decoration: InputDecoration(
                hintText: 'ابنِ صفحة هبوط احترافية',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Text('العنوان (إنجليزي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _titleEnController,
              decoration: InputDecoration(
                hintText: 'Build a Professional Landing Page',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Text('النص الفرعي (عربي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _subtitleArController,
              decoration: InputDecoration(
                hintText: 'بدون الحاجة لخبرة برمجية',
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
                hintText: 'Without any coding experience needed',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Text('نص الزر (عربي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _ctaTextArController,
              decoration: InputDecoration(
                hintText: 'ابدأ مجاناً',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Text('نص الزر (إنجليزي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _ctaTextEnController,
              decoration: InputDecoration(
                hintText: 'Start Free',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Text('نصوص الكتابة المتحركة (عربي) — سطر لكل نص', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _typewriterArController,
              decoration: InputDecoration(
                hintText: 'منيو مطعم إلكتروني\nمعرض أعمال شخصي',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Text('نصوص الكتابة المتحركة (إنجليزي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _typewriterEnController,
              decoration: InputDecoration(
                hintText: 'Interactive digital menu\nPersonal portfolio',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Text('اختيار صفحات الهبوط للمعاينة', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            if (_loadingPages)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CubeSpinner(
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            else if (_allPages.isEmpty)
              Text('لا توجد صفحات هبوط متاحة في النظام', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))
            else
              ..._allPages.map((p) {
                final id = p['id']?.toString() ?? '';
                final name = p['name'] as String? ?? p['subdomain'] as String? ?? 'بدون اسم';
                final isSelected = _selectedPageIds.contains(id);
                return CheckboxListTile(
                  title: Text(name),
                  value: isSelected,
                  onChanged: (_) => _togglePage(id),
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

  String _layoutName(HeroLayout l) {
    return switch (l) {
      HeroLayout.split => 'نص + صورة (منقسم)',
      HeroLayout.centered => 'مركز بخلفية صورة',
      HeroLayout.gradientOnly => 'تدرج لوني فقط',
      HeroLayout.fullWidthImage => 'صورة كاملة العرض',
    };
  }
}
