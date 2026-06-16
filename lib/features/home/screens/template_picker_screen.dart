import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../../services/tenant_routing_service.dart';
import '../../auth/controllers/auth_cubit.dart';
import '../../auth/controllers/auth_state.dart';
import '../../builder/registries/template_registry.dart';

class TemplatePickerScreen extends StatefulWidget {
  const TemplatePickerScreen({super.key});

  @override
  State<TemplatePickerScreen> createState() => _TemplatePickerScreenState();
}

class _TemplatePickerScreenState extends State<TemplatePickerScreen> {
  String? _selectedCategory;

  List<String> get _categories {
    final cats = TemplateRegistry.availableTemplates
        .map((t) => t.category)
        .toSet()
        .toList()
      ..sort();
    return cats;
  }

  List<TemplateMetadata> get _filteredTemplates {
    if (_selectedCategory == null) return TemplateRegistry.availableTemplates;
    return TemplateRegistry.availableTemplates
        .where((t) => t.category == _selectedCategory)
        .toList();
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'general':
        return 'عام';
      case 'technology':
        return 'تقنية';
      case 'ecommerce':
        return 'متاجر';
      case 'creator':
        return 'مبدعون';
      case 'professional_services':
        return 'خدمات مهنية';
      case 'real_estate':
        return 'عقارات';
      case 'education':
        return 'تعليم';
      case 'events':
        return 'مناسبات';
      case 'food':
        return 'مطاعم';
      case 'healthcare':
        return 'صحة';
      case 'beauty':
        return 'تجميل';
      case 'fitness':
        return 'لياقة';
      case 'agency':
        return 'وكالات';
      case 'nonprofit':
        return 'غير ربحي';
      case 'digital_product':
        return 'منتجات رقمية';
      case 'industrial':
        return 'صناعي';
      case 'travel':
        return 'سفر';
      case 'creative':
        return 'إبداعي';
      default:
        return category[0].toUpperCase() + category.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = context.isRtl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.go('/'),
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
          final int crossAxisCount = constraints.maxWidth > 1200
              ? 4
              : (constraints.maxWidth > 800 ? 3 : (isMobile ? 1 : 2));

          final grid = _buildGrid(isMobile, crossAxisCount);
          final warning = _buildWarning();

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSidebar(isRtl),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      warning,
                      Expanded(child: grid),
                    ],
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildMobileFilter(),
              warning,
              Expanded(child: grid),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWarning() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        context.translate('template_warning'),
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildGrid(bool isMobile, int crossAxisCount) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredTemplates.length,
      itemBuilder: (context, index) {
        final template = _filteredTemplates[index];
        return _TemplateCard(template: template);
      },
    );
  }

  Widget _buildSidebar(bool isRtl) {
    return Container(
      width: 220,
      margin: const EdgeInsetsDirectional.only(top: 24, start: 24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          _buildSidebarItem(null, 'الكل'),
          ..._categories.map(
            (cat) => _buildSidebarItem(cat, _categoryLabel(cat)),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String? category, String label) {
    final isSelected = _selectedCategory == category;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = category),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
            top: 12,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondary.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.secondary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isSelected ? AppColors.secondary : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileFilter() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _selectedCategory == null
                  ? 'جميع القوالب'
                  : _categoryLabel(_selectedCategory!),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => _showFilterSheet(),
            icon: const Icon(Icons.filter_list_rounded, size: 18),
            label: const Text('تصفية'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
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
              color: AppColors.cardBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'تصنيف القوالب',
                    style: AppTypography.h3,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildSheetItem(null, 'الكل'),
                      ..._categories.map(
                        (cat) =>
                            _buildSheetItem(cat, _categoryLabel(cat)),
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

  Widget _buildSheetItem(String? category, String label) {
    final isSelected = _selectedCategory == category;
    return ListTile(
      selected: isSelected,
      selectedTileColor: AppColors.secondary.withValues(alpha: 0.1),
      leading: Icon(
        isSelected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_unchecked_rounded,
        color: isSelected ? AppColors.secondary : AppColors.textSecondary,
        size: 20,
      ),
      title: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: isSelected ? AppColors.secondary : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() => _selectedCategory = category);
        Navigator.pop(context);
      },
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

    // Store selected template ID globally
    TenantRoutingService.pendingTemplateId = widget.template.id;

    if (authState is Authenticated) {
      // If logged in, go to dashboard to create a new page with this template
      context.go('/dashboard');
    } else {
      // If not logged in, go to register/login
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
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? AppColors.secondary : AppColors.border,
            width: 2,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.2),
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
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
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.template.description,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
