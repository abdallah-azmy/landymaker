import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/particles/loading_logo.dart';
import '../../../injection_container.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';
import '../../builder/registries/template_registry.dart';
import '../../../core/logger.dart';
import '../../../core/localization/localization_cubit.dart';

class HomePreviewsTab extends StatefulWidget {
  const HomePreviewsTab({super.key});

  @override
  State<HomePreviewsTab> createState() => _HomePreviewsTabState();
}

class _HomePreviewsTabState extends State<HomePreviewsTab> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _previewPages = [];
  List<Map<String, dynamic>> _userPages = [];
  Map<String, dynamic>? _heroSection;
  List<String> _selectedPreviewIds = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dbService = sl<DatabaseService>();
      final authService = sl<AuthService>();
      final userId = authService.currentUserId;

      // 1. Fetch preview type pages
      final previewPages = await dbService.getHomepagePreviewPages();

      // 2. Fetch admin user standard pages if logged in
      List<Map<String, dynamic>> userPages = [];
      if (userId != null) {
        final pages = await dbService.getLandingPagesByUserId(userId);
        userPages = pages.where((p) => p['website_type'] != 'homepage_preview').toList();
      }

      // 3. Fetch homepage sections to get current hero configuration
      final sections = await dbService.getHomepageSections();
      final hero = sections.where((s) => s['section_key'] == 'hero').firstOrNull;

      List<String> selectedIds = [];
      if (hero != null) {
        final ids = hero['config']?['preview_page_ids'];
        if (ids is List) {
          selectedIds = ids.map((e) => e.toString()).toList();
        }
      }

      if (mounted) {
        setState(() {
          _previewPages = previewPages;
          _userPages = userPages;
          _heroSection = hero;
          _selectedPreviewIds = selectedIds;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      Logger.error("Failed to load home previews tab data", e, stack);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePreviewVisibility(String pageId, bool show) async {
    if (_heroSection == null) return;
    try {
      final updatedIds = List<String>.from(_selectedPreviewIds);
      if (show) {
        if (!updatedIds.contains(pageId)) updatedIds.add(pageId);
      } else {
        updatedIds.remove(pageId);
      }

      final currentConfig = Map<String, dynamic>.from(_heroSection!['config'] ?? {});
      currentConfig['preview_page_ids'] = updatedIds;

      await sl<DatabaseService>().updateHomepageSection(_heroSection!['id'], {'config': currentConfig});
      
      setState(() {
        _selectedPreviewIds = updatedIds;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث حالة عرض الصفحة بنجاح!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      Logger.error("Failed to toggle preview visibility", e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحديث: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleCloneToPreview(Map<String, dynamic> userPage) async {
    final slugController = TextEditingController(text: '${userPage['subdomain']}-preview');
    final formKey = GlobalKey<FormState>();
    final loc = context.read<LocalizationCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.isRtl ? 'نسخ الصفحة للمعاينة' : 'Clone Page for Preview'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.isRtl
                    ? 'سيتم إنشاء نسخة منفصلة من هذه الصفحة لاستخدامها في المعاينة بالصفحة الرئيسية.'
                    : 'A separate clone of this page will be created for homepage preview mockup.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: slugController,
                decoration: InputDecoration(
                  labelText: loc.isRtl ? 'رابط الصفحة الجديد' : 'New Page Slug',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'مطلوب';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.translate('cancel'))),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              
              setState(() => _isLoading = true);
              try {
                final authService = sl<AuthService>();
                final userId = authService.currentUserId!;
                
                final clonedId = await sl<DatabaseService>().cloneLandingPage(
                  sourcePageId: userPage['id'],
                  newSubdomain: slugController.text.trim(),
                  websiteType: 'homepage_preview',
                  userId: userId,
                );

                if (clonedId != null) {
                  await _togglePreviewVisibility(clonedId, true);
                  await _loadData();
                }
              } catch (e) {
                Logger.error("Failed to clone page", e);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل النسخ: $e'), backgroundColor: Colors.red),
                  );
                  setState(() => _isLoading = false);
                }
              }
            },
            child: Text(loc.isRtl ? 'نسخ وتفعيل' : 'Clone & Activate'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateNewPreview() async {
    final slugController = TextEditingController();
    String selectedTemplate = 'saas_startup';
    final formKey = GlobalKey<FormState>();
    final loc = context.read<LocalizationCubit>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(loc.isRtl ? 'إنشاء صفحة معاينة جديدة' : 'Create New Preview Page'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: slugController,
                    decoration: InputDecoration(
                      labelText: loc.isRtl ? 'رابط الصفحة (Slug)' : 'Page Slug',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'مطلوب';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.isRtl ? 'اختر القالب الهيكلي الأساسي:' : 'Choose template base:',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTemplate,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    items: TemplateRegistry.availableTemplates
                        .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedTemplate = val);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.translate('cancel'))),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);

                setState(() => _isLoading = true);
                try {
                  final authService = sl<AuthService>();
                  final userId = authService.currentUserId!;

                  // 1. Get template layout JSON
                  final designMap = TemplateRegistry.getTemplateDesign(selectedTemplate);
                  final theme = TemplateRegistry.getTemplateTheme(selectedTemplate);
                  designMap['theme'] = theme.toJson();

                  // 2. Save new page with type homepage_preview
                  final newId = await sl<DatabaseService>().saveLandingPage(
                    userId: userId,
                    subdomain: slugController.text.trim(),
                    designMap: designMap,
                    isPublished: false,
                    websiteType: 'homepage_preview',
                  );

                  if (newId != null) {
                    await _togglePreviewVisibility(newId, true);
                    await _loadData();
                  }
                } catch (e) {
                  Logger.error("Failed to create preview page", e);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('فشل الإنشاء: $e'), backgroundColor: Colors.red),
                    );
                    setState(() => _isLoading = false);
                  }
                }
              },
              child: Text(loc.isRtl ? 'إنشاء وتفعيل' : 'Create & Activate'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.read<LocalizationCubit>().isRtl;

    if (_isLoading) {
      return const Center(child: LoadingLogo());
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: CustomScrollView(
        slivers: [
          // Header Actions
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'إدارة صفحات معاينة الهواتف بالرئيسية' : 'Manage Homepage Preview Pages',
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic
                          ? 'تحكم في صفحات الهبوط المخصصة التي تظهر للمستخدمين عند معاينة الهاتف بالرئيسية.'
                          : 'Configure landing pages displayed in the homepage preview mobile simulator mockup.',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: isArabic ? 'تحديث البيانات' : 'Refresh Data',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                      ),
                      onPressed: _loadData,
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _handleCreateNewPreview,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(isArabic ? 'إنشاء صفحة معاينة جديدة' : 'Create New Preview'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // SECTION 1: Active Preview Pages list
          SliverToBoxAdapter(
            child: Text(
              isArabic ? 'صفحات المعاينة النشطة بالرئيسية' : 'Active Home Preview Templates',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          
          if (_previewPages.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.mobile_off_rounded, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        isArabic
                            ? 'لا توجد صفحات معاينة مصممة حتى الآن. أنشئ صفحة جديدة أو انسخ إحدى صفحاتك.'
                            : 'No preview templates created yet. Create one or clone from standard user designs.',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final page = _previewPages[index];
                  final id = page['id'] as String;
                  final subdomain = page['subdomain'] as String? ?? 'unnamed';
                  final name = page['name'] as String? ?? subdomain;
                  final isShowingOnHome = _selectedPreviewIds.contains(id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isShowingOnHome
                            ? theme.colorScheme.primary.withValues(alpha: 0.5)
                            : theme.colorScheme.outlineVariant,
                        width: isShowingOnHome ? 1.5 : 1.0,
                      ),
                    ),
                    elevation: isShowingOnHome ? 4 : 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: (isShowingOnHome ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest)
                                .withValues(alpha: 0.12),
                            child: Icon(
                              Icons.phone_android_rounded,
                              color: isShowingOnHome ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(
                                  '/${subdomain}',
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              Text(
                                isShowingOnHome
                                    ? (isArabic ? 'معروضة بالرئيسية' : 'Shown on Home')
                                    : (isArabic ? 'مخفية' : 'Hidden'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isShowingOnHome ? Colors.green : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: isShowingOnHome,
                                onChanged: (val) => _togglePreviewVisibility(id, val),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          FilledButton.tonalIcon(
                            onPressed: () => context.go('/builder/$id'),
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: Text(isArabic ? 'تعديل التصميم' : 'Edit Design'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _previewPages.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // SECTION 2: Cloneable User standard pages list
          SliverToBoxAdapter(
            child: Text(
              isArabic ? 'صفحاتي الشخصية كمستخدم (قابلة للنسخ)' : 'Personal User Designs (Cloneable)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          if (_userPages.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    isArabic
                        ? 'لم تقم بإنشاء أي صفحات هبوط شخصية في حسابك بعد.'
                        : 'No standard user landing pages found in your account.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final page = _userPages[index];
                  final subdomain = page['subdomain'] as String? ?? 'unnamed';
                  final name = page['name'] as String? ?? subdomain;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: theme.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.web_asset_rounded, color: theme.colorScheme.onSurfaceVariant),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('/$subdomain', style: const TextStyle(fontSize: 12)),
                      trailing: ElevatedButton.icon(
                        onPressed: () => _handleCloneToPreview(page),
                        icon: const Icon(Icons.copy_rounded, size: 14),
                        label: Text(isArabic ? 'نسخ للمعاينة' : 'Clone for Preview'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          elevation: 0,
                        ),
                      ),
                    ),
                  );
                },
                childCount: _userPages.length,
              ),
            ),
        ],
      ),
    );
  }
}
