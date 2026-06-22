import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/atoms/cube_spinner.dart';
import '../../../injection_container.dart';
import '../../../services/database_service.dart';

class SectionRendererConfigSheet extends StatefulWidget {
  final Map<String, dynamic> config;
  final ValueChanged<Map<String, dynamic>> onSave;

  const SectionRendererConfigSheet({super.key, required this.config, required this.onSave});

  @override
  State<SectionRendererConfigSheet> createState() => _SectionRendererConfigSheetState();
}

class _SectionRendererConfigSheetState extends State<SectionRendererConfigSheet> {
  late TextEditingController _displayArController;
  late TextEditingController _displayEnController;
  String? _selectedPageId;
  List<Map<String, dynamic>> _allPages = [];
  bool _loadingPages = true;

  @override
  void initState() {
    super.initState();
    _displayArController = TextEditingController(text: widget.config['display_ar'] as String? ?? '');
    _displayEnController = TextEditingController(text: widget.config['display_en'] as String? ?? '');
    _selectedPageId = widget.config['landing_page_id'] as String? ?? '';
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
      if (mounted) setState(() => _loadingPages = false);
    }
  }

  @override
  void dispose() {
    _displayArController.dispose();
    _displayEnController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave({
      'landing_page_id': _selectedPageId ?? '',
      'display_ar': _displayArController.text,
      'display_en': _displayEnController.text,
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
                Text('إعدادات قسم صفحة هبوط', style: theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 16),
            Text('اختر صفحة الهبوط', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            if (_loadingPages)
              Center(child: Padding(
                padding: const EdgeInsets.all(16),
                child: CubeSpinner(
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ))
            else if (_allPages.isEmpty)
              Text('لا توجد صفحات هبوط متاحة', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedPageId != null && _allPages.any((p) => p['id'].toString() == _selectedPageId)
                    ? _selectedPageId
                    : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                hint: Text('اختر صفحة هبوط'),
                items: _allPages.map((p) {
                  final id = p['id'].toString();
                  final name = p['name'] as String? ?? id;
                  return DropdownMenuItem(value: id, child: Text(name));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedPageId = v);
                },
              ),
            if (_selectedPageId != null && _selectedPageId!.isNotEmpty)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/builder/$_selectedPageId');
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('فتح في المحرر'),
                ),
              ),
            const SizedBox(height: 16),
            Text('عنوان القسم (عربي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _displayArController,
              decoration: InputDecoration(
                hintText: 'قسم مخصص',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Text('عنوان القسم (إنجليزي)', style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            TextField(
              controller: _displayEnController,
              decoration: InputDecoration(
                hintText: 'Custom Section',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
