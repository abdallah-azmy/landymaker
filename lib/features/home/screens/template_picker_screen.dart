import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/router_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../core/widgets/particles/loading_logo_modified.dart';
import '../../../services/database_service.dart';
import '../../../services/tenant_routing_service.dart';
import '../../../injection_container.dart';
import '../../auth/controllers/auth_cubit.dart';
import '../../auth/controllers/auth_state.dart';
import '../../builder/registries/template_registry.dart';

/// ======================================================
/// FEATURE: Template Picker Screen
/// PURPOSE: Allows users to browse and select landing page templates by category.
/// ARCHITECTURE: State is hoisted to [TemplatePickerScreen]. 
/// Renders [_TemplatePickerDesktop] or [_TemplatePickerMobile] based on width.
/// ======================================================
class TemplatePickerScreen extends StatefulWidget {
  const TemplatePickerScreen({super.key});

  @override
  State<TemplatePickerScreen> createState() => _TemplatePickerScreenState();
}

class _TemplatePickerScreenState extends State<TemplatePickerScreen> {
  String? _selectedCategory;
  List<TemplateMetadata> _templates = [];
  bool _isLoading = true;

  List<String> get _categories {
    final cats = _templates
        .map((t) => t.category)
        .toSet()
        .toList()
      ..sort();
    return cats;
  }

  List<TemplateMetadata> get _filteredTemplates {
    if (_selectedCategory == null) return _templates;
    return _templates
        .where((t) => t.category == _selectedCategory)
        .toList();
  }

  void _onCategorySelected(String? category) {
    setState(() => _selectedCategory = category);
  }

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final db = sl<DatabaseService>();
      final publicTemplates = await db.fetchPublicTemplates();
      if (publicTemplates.isNotEmpty) {
        final mapped = publicTemplates.map((t) => TemplateMetadata(
          id: t['id'] ?? '',
          name: t['name'] ?? '',
          description: t['description'] ?? '',
          imageUrl: t['image_url'] ?? '',
          category: t['category'] ?? 'general',
          recommendedSections: (t['recommended_sections'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
          aiPromptHint: t['ai_prompt_hint'] ?? '',
        )).toList();
        if (mounted) setState(() { _templates = mapped; _isLoading = false; });
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _templates = TemplateRegistry.availableTemplates;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: LoadingLogo()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => context.safePop(fallbackPath: '/'),
        ),
        title: Text(
          context.translate('choose_template'),
          style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;
          final bool isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return _TemplatePickerDesktop(
              categories: _categories,
              selectedCategory: _selectedCategory,
              filteredTemplates: _filteredTemplates,
              onCategorySelected: _onCategorySelected,
            );
          }

          return _TemplatePickerMobile(
            categories: _categories,
            selectedCategory: _selectedCategory,
            filteredTemplates: _filteredTemplates,
            onCategorySelected: _onCategorySelected,
            isMobile: isMobile,
          );
        },
      ),
    );
  }
}

/// Desktop version of the Template Picker.
class _TemplatePickerDesktop extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final List<TemplateMetadata> filteredTemplates;
  final Function(String?) onCategorySelected;

  const _TemplatePickerDesktop({
    required this.categories,
    required this.selectedCategory,
    required this.filteredTemplates,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Sidebar(
          categories: categories,
          selectedCategory: selectedCategory,
          onCategorySelected: onCategorySelected,
        ),
        SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              const _WarningText(),
              Expanded(
                child: _TemplateGrid(
                  templates: filteredTemplates,
                  crossAxisCount: 4,
                  isMobile: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mobile/Tablet version of the Template Picker.
class _TemplatePickerMobile extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final List<TemplateMetadata> filteredTemplates;
  final Function(String?) onCategorySelected;
  final bool isMobile;

  const _TemplatePickerMobile({
    required this.categories,
    required this.selectedCategory,
    required this.filteredTemplates,
    required this.onCategorySelected,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MobileFilterBar(
          selectedCategory: selectedCategory,
          categories: categories,
          onCategorySelected: onCategorySelected,
        ),
        const _WarningText(),
        Expanded(
          child: _TemplateGrid(
            templates: filteredTemplates,
            crossAxisCount: isMobile ? 1 : 2,
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }
}

/// Shared Sidebar for Desktop.
class _Sidebar extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const _Sidebar({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsetsDirectional.only(top: 24, start: 24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 8),
            child: Text(
              'التصنيفات',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.outlineVariant, height: 1),
          _SidebarItem(
            category: null,
            label: 'الكل',
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          ...categories.map(
            (cat) => _SidebarItem(
              category: cat,
              label: _getCategoryLabel(cat),
              isSelected: selectedCategory == cat,
              onTap: () => onCategorySelected(cat),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared Sidebar Item.
class _SidebarItem extends StatelessWidget {
  final String? category;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.category,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 12, bottom: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared Mobile Filter Bar.
class _MobileFilterBar extends StatelessWidget {
  final String? selectedCategory;
  final List<String> categories;
  final Function(String?) onCategorySelected;

  const _MobileFilterBar({
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectedCategory == null ? 'جميع القوالب' : _getCategoryLabel(selectedCategory!),
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton.icon(
            onPressed: () => _showFilterSheet(context),
            icon: Icon(Icons.filter_list_rounded, size: 18),
            label: const Text('تصفية'),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                _Handle(),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('تصنيف القوالب', style: AppTypography.h3),
                ),
                SizedBox(height: 16),
                Divider(color: Theme.of(context).colorScheme.outlineVariant, height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _SheetItem(
                        label: 'الكل',
                        isSelected: selectedCategory == null,
                        onTap: () {
                          onCategorySelected(null);
                          Navigator.pop(context);
                        },
                      ),
                      ...categories.map(
                        (cat) => _SheetItem(
                          label: _getCategoryLabel(cat),
                          isSelected: selectedCategory == cat,
                          onTap: () {
                            onCategorySelected(cat);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Shared Sheet Item.
class _SheetItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SheetItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
      leading: Icon(
        isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
        color: isSelected ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.onSurfaceVariant,
        size: 20,
      ),
      title: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}

/// Shared Template Grid.
class _TemplateGrid extends StatelessWidget {
  final List<TemplateMetadata> templates;
  final int crossAxisCount;
  final bool isMobile;

  const _TemplateGrid({
    required this.templates,
    required this.crossAxisCount,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return _TemplateCard(template: templates[index]);
      },
    );
  }
}

/// Shared Warning Text.
class _WarningText extends StatelessWidget {
  const _WarningText();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        context.translate('template_warning'),
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// Bottom Sheet Drag Handle.
class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _TemplateCard extends StatefulWidget {
  final TemplateMetadata template;
  const _TemplateCard({required this.template});

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _isHovered = false;

  void _onTemplateSelected(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    TenantRoutingService.pendingTemplateId = widget.template.id;

    if (authState is Authenticated) {
      context.go('/dashboard');
    } else {
      context.go('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.outlineVariant,
            width: 2,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  children: [
                    CustomNetworkImage(
                      imageUrl: widget.template.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    if (_isHovered)
                      Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () => _onTemplateSelected(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(context.translate('apply')),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.template.name,
                      style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.template.description,
                      style: AppTypography.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getCategoryLabel(String category) {
  switch (category) {
    case 'general': return 'عام';
    case 'technology': return 'تقنية';
    case 'ecommerce': return 'متاجر';
    case 'creator': return 'مبدعون';
    case 'professional_services': return 'خدمات مهنية';
    case 'real_estate': return 'عقارات';
    case 'education': return 'تعليم';
    case 'events': return 'مناسبات';
    case 'food': return 'مطاعم';
    case 'healthcare': return 'صحة';
    case 'beauty': return 'تجميل';
    case 'fitness': return 'لياقة';
    case 'agency': return 'وكالات';
    case 'nonprofit': return 'غير ربحي';
    case 'digital_product': return 'منتجات رقمية';
    case 'industrial': return 'صناعي';
    case 'travel': return 'سفر';
    case 'creative': return 'إبداعي';
    default: return category[0].toUpperCase() + category.substring(1);
  }
}
