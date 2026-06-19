import 'package:flutter/material.dart';

class NavbarConfigSheet extends StatefulWidget {
  final Map<String, dynamic> config;
  final ValueChanged<Map<String, dynamic>> onSave;

  const NavbarConfigSheet({super.key, required this.config, required this.onSave});

  @override
  State<NavbarConfigSheet> createState() => _NavbarConfigSheetState();
}

class _NavbarConfigSheetState extends State<NavbarConfigSheet> {
  late TextEditingController _logoTextArController;
  late TextEditingController _logoTextEnController;
  late TextEditingController _ctaTextArController;
  late TextEditingController _ctaTextEnController;
  late TextEditingController _ctaPathController;
  bool _showLogin = true;

  final List<_LinkEntry> _links = [];

  @override
  void initState() {
    super.initState();
    _logoTextArController = TextEditingController(text: widget.config['logo_text_ar'] as String? ?? 'لاندي ميكر');
    _logoTextEnController = TextEditingController(text: widget.config['logo_text_en'] as String? ?? 'LandyMaker');
    _ctaTextArController = TextEditingController(text: widget.config['cta_text_ar'] as String? ?? 'ابدأ مجاناً');
    _ctaTextEnController = TextEditingController(text: widget.config['cta_text_en'] as String? ?? 'Start Free');
    _ctaPathController = TextEditingController(text: widget.config['cta_path'] as String? ?? '/templates');
    _showLogin = widget.config['show_login'] ?? true;

    final primaryLinksAr = (widget.config['primary_links_ar'] as List<dynamic>?) ?? [];
    final primaryLinksEn = (widget.config['primary_links_en'] as List<dynamic>?) ?? [];
    final maxLen = primaryLinksAr.length > primaryLinksEn.length ? primaryLinksAr.length : primaryLinksEn.length;
    for (int i = 0; i < maxLen; i++) {
      final linkAr = i < primaryLinksAr.length ? primaryLinksAr[i] as Map<String, dynamic> : {};
      final linkEn = i < primaryLinksEn.length ? primaryLinksEn[i] as Map<String, dynamic> : {};
      _links.add(_LinkEntry(
        labelAr: linkAr['label'] as String? ?? '',
        labelEn: linkEn['label'] as String? ?? '',
        path: linkEn['path'] as String? ?? linkAr['path'] as String? ?? '',
      ));
    }
  }

  @override
  void dispose() {
    _logoTextArController.dispose();
    _logoTextEnController.dispose();
    _ctaTextArController.dispose();
    _ctaTextEnController.dispose();
    _ctaPathController.dispose();
    for (final l in _links) {
      l.labelArController.dispose();
      l.labelEnController.dispose();
      l.pathController.dispose();
    }
    super.dispose();
  }

  void _addLink() {
    setState(() {
      _links.add(_LinkEntry());
    });
  }

  void _removeLink(int index) {
    setState(() {
      _links[index].labelArController.dispose();
      _links[index].labelEnController.dispose();
      _links[index].pathController.dispose();
      _links.removeAt(index);
    });
  }

  void _save() {
    widget.onSave({
      'logo_text_ar': _logoTextArController.text,
      'logo_text_en': _logoTextEnController.text,
      'primary_links_ar': _links.map((l) => {'label': l.labelArController.text, 'path': l.pathController.text}).toList(),
      'primary_links_en': _links.map((l) => {'label': l.labelEnController.text, 'path': l.pathController.text}).toList(),
      'cta_text_ar': _ctaTextArController.text,
      'cta_text_en': _ctaTextEnController.text,
      'cta_path': _ctaPathController.text,
      'show_login': _showLogin,
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
                Text('إعدادات الشريط العلوي', style: theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 16),
            Text('نص الشعار (عربي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _logoTextArController,
              decoration: InputDecoration(
                hintText: 'لاندي ميكر',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Text('نص الشعار (إنجليزي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _logoTextEnController,
              decoration: InputDecoration(
                hintText: 'LandyMaker',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('الروابط', style: theme.textTheme.titleSmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addLink,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('إضافة رابط'),
                ),
              ],
            ),
            ..._links.asMap().entries.map((entry) {
              final i = entry.key;
              final link = entry.value;
              return Card(
                margin: const EdgeInsetsDirectional.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('رابط ${i + 1}', style: theme.textTheme.labelSmall),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_rounded, size: 18),
                            onPressed: () => _removeLink(i),
                            color: theme.colorScheme.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: link.labelArController,
                        decoration: InputDecoration(
                          labelText: 'النص (عربي)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: link.labelEnController,
                        decoration: InputDecoration(
                          labelText: 'النص (إنجليزي)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: link.pathController,
                        decoration: InputDecoration(
                          labelText: 'المسار',
                          hintText: '/templates',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Text('زر الدعوة للإجراء', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _ctaTextArController,
              decoration: InputDecoration(
                labelText: 'النص (عربي)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ctaTextEnController,
              decoration: InputDecoration(
                labelText: 'النص (إنجليزي)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ctaPathController,
              decoration: InputDecoration(
                labelText: 'مسار الزر',
                hintText: '/templates',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('إظهار زر تسجيل الدخول'),
              value: _showLogin,
              onChanged: (v) => setState(() => _showLogin = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('حفظ')),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _LinkEntry {
  final TextEditingController labelArController;
  final TextEditingController labelEnController;
  final TextEditingController pathController;

  _LinkEntry({
    String labelAr = '',
    String labelEn = '',
    String path = '',
  }) : labelArController = TextEditingController(text: labelAr),
       labelEnController = TextEditingController(text: labelEn),
       pathController = TextEditingController(text: path);
}
