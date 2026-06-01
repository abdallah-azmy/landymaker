import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/molecules/status_pill.dart';
import '../../models/landing_page_theme.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../organisms/advanced_settings_panel.dart';
import 'package:google_fonts/google_fonts.dart';

import '../molecules/element_property_editor.dart';

class OutlineTab extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final LocalizationCubit loc;
  final List<Map<String, dynamic>> blocks;
  final Function(int) onEditBlock;
  final Function(BuildContext, LandingPageBuilderCubit) onAddBlock;
  final int? selectedIndex;

  const OutlineTab({
    super.key,
    required this.cubit,
    required this.loc,
    required this.blocks,
    required this.onEditBlock,
    required this.onAddBlock,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.translate('added_sections'), style: AppTypography.h3),
              IconButton(
                onPressed: () => onAddBlock(context, cubit),
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.secondary),
                tooltip: loc.translate('add_block'),
              ),
            ],
          ),
        ),
        Expanded(
          child: blocks.isEmpty
              ? _buildEmptyState()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  itemCount: blocks.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;
                    cubit.reorderBlocks(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final block = blocks[index];
                    final String type = block['type'] ?? '';
                    final String title = block['title'] ?? 'Section';
                    final bool isVisible = block['is_visible'] ?? true;
                    final bool isSelected = selectedIndex == index;

                    return Container(
                      key: ValueKey("outline_$index"),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.secondary.withOpacity(0.05) : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.secondary : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          cubit.selectSection(index);
                          onEditBlock(index);
                        },
                        leading: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_indicator_rounded, color: AppColors.textSecondary, size: 20),
                        ),
                        title: Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isVisible ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(type.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.secondary, letterSpacing: 0.5)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                size: 18,
                                color: isVisible ? AppColors.textSecondary : AppColors.dangerRed,
                              ),
                              onPressed: () => cubit.toggleBlockVisibility(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.dangerRed),
                              onPressed: () => cubit.deleteBlock(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers_clear_rounded, size: 48, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text("لا توجد أقسام مضافة بعد", style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class TemplatesTab extends StatelessWidget {
  final LandingPageBuilderCubit cubit;

  final BuilderLoaded state;

  const TemplatesTab({super.key, required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: BlocBuilder<LandingPageBuilderCubit, BuilderState>(
        builder: (context, dynamicState) {
          if (dynamicState is! BuilderLoaded) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("اختر قالب جاهز", style: AppTypography.h3),
              const SizedBox(height: 8),
              Text("سيقوم اختيار قالب باستبدال المحتوى الحالي.", style: AppTypography.caption),
              const SizedBox(height: 24),
              _buildTemplateCard(context, dynamicState, 'store', "متجر إلكتروني", Icons.shopping_cart_rounded, "مناسب لبيع المنتجات والسلع."),
              _buildTemplateCard(context, dynamicState, 'personal', "موقع شخصي", Icons.person_rounded, "معرض أعمال وسيرة ذاتية."),
              _buildTemplateCard(context, dynamicState, 'professional', "خدمات مهنية", Icons.business_center_rounded, "للاستشارات والشركات الناشئة."),
              _buildTemplateCard(context, dynamicState, 'tv_bar', "مطعم / كافيه", Icons.restaurant_rounded, "منيو إلكتروني وأجواء ترفيهية."),
              _buildTemplateCard(context, dynamicState, 'real_estate', "عقارات / Real Estate", Icons.home_work_rounded, "تسويق شقق وفلل ومجمعات سكنية."),
              _buildTemplateCard(context, dynamicState, 'event', "فعالية ومؤتمر / Event", Icons.event_rounded, "حجز تذاكر، تفاصيل الفعالية، وخرائط الوصول."),
              _buildTemplateCard(context, dynamicState, 'digital_course', "دورة تعليمية / Course", Icons.school_rounded, "تسويق كورسات، دروس، ومناهج تعليمية مع التسجيل."),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, BuilderLoaded currentState, String type, String label, IconData icon, String desc) {
    final loc = context.read<LocalizationCubit>();
    final isSelected = currentState.websiteType == type;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary.withValues(alpha: 0.1) : AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.secondary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.secondary),
        ),
        title: Text(label, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: AppTypography.caption),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.secondary)
            : null,
        onTap: () => _showTemplateConfirmation(context, type, loc),
      ),
    );
  }

  void _showTemplateConfirmation(BuildContext context, String type, LocalizationCubit loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(loc.translate('confirm_template')),
        content: Text(loc.translate('confirm_template_msg')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.translate('cancel'))),
          PrimaryButton(
            text: loc.translate('apply'),
            width: 100,
            onPressed: () {
              cubit.applyTemplate(type);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class DesignColorsTab extends StatefulWidget {
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;

  const DesignColorsTab({super.key, required this.loc, required this.cubit, required this.state});

  @override
  State<DesignColorsTab> createState() => _DesignColorsTabState();
}

class _DesignColorsTabState extends State<DesignColorsTab> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          _buildSegmentedControl(),
          const SizedBox(height: 24),
          if (_tabIndex == 0) _buildPalettesList(),
          if (_tabIndex == 1) _buildCustomColorsList(),
        ],
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _tabIndex = 0),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _tabIndex == 0 ? AppColors.secondary.withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                ),
                child: Center(
                  child: Text(
                    "لوحات الألوان",
                    style: AppTypography.bodyMedium.copyWith(
                      color: _tabIndex == 0 ? AppColors.secondary : AppColors.textSecondary,
                      fontWeight: _tabIndex == 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _tabIndex = 1),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _tabIndex == 1 ? AppColors.secondary.withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                ),
                child: Center(
                  child: Text(
                    "تخصيص الألوان",
                    style: AppTypography.bodyMedium.copyWith(
                      color: _tabIndex == 1 ? AppColors.secondary : AppColors.textSecondary,
                      fontWeight: _tabIndex == 1 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalettesList() {
    return BlocBuilder<LandingPageBuilderCubit, BuilderState>(
      builder: (context, state) {
        if (state is! BuilderLoaded) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              ...LandingPageTheme.palettes.map((palette) {
                final isSelected = state.theme.name == palette.name;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondary.withValues(alpha: 0.1) : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.secondary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: ListTile(
                    onTap: () {
                      final newTheme = palette.copyWith(
                        defaultFont: state.theme.defaultFont,
                      );
                      widget.cubit.updateTheme(newTheme);
                    },
                isThreeLine: true,
                title: Row(
                  children: [
                    Text(palette.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    if (palette.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(palette.category!, style: const TextStyle(fontSize: 9, color: AppColors.secondary)),
                      ),
                  ],
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.secondary)
                    : null,
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (palette.description != null)
                    Text(palette.description!, style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _colorBox(palette.primary),
                      _colorBox(palette.secondary),
                      _colorBox(palette.background),
                    ],
                  ),
                ],
              ),
            ),
            );
          }).toList(),
        ],
        );
      },
    );
  }

  Widget _buildCustomColorsList() {
    return BlocBuilder<LandingPageBuilderCubit, BuilderState>(
      builder: (context, state) {
        if (state is! BuilderLoaded) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildColorPickerItem(context, widget.cubit, "اللون الأساسي", "primary", state.theme.primary),
            _buildColorPickerItem(context, widget.cubit, "اللون الثانوي", "secondary", state.theme.secondary),
            _buildColorPickerItem(context, widget.cubit, "لون الخلفية", "background", state.theme.background),
            _buildColorPickerItem(context, widget.cubit, "لون النص الرئيسي", "textPrimary", state.theme.textPrimary),
          ],
        );
      },
    );
  }
}

class DesignFontsTab extends StatelessWidget {
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;

  const DesignFontsTab({super.key, required this.loc, required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingPageBuilderCubit, BuilderState>(
      builder: (context, dynamicState) {
        if (dynamicState is! BuilderLoaded) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("إعدادات الخط العامة", style: AppTypography.h3),
            const SizedBox(height: 16),
            _buildFontPicker(context, cubit, dynamicState),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class DesignTab extends StatelessWidget {
  final LocalizationCubit loc;
  final LandingPageBuilderCubit cubit;
  final BuilderLoaded state;

  const DesignTab({super.key, required this.loc, required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesignColorsTab(loc: loc, cubit: cubit, state: state),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),
          const SizedBox(height: 24),
          DesignFontsTab(loc: loc, cubit: cubit, state: state),
        ],
      ),
    );
  }
}

  Widget _colorBox(Color color) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24),
      ),
    );
  }

  Widget _buildColorPickerItem(BuildContext context, LandingPageBuilderCubit cubit, String label, String key, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showColorPicker(context, cubit, key, color),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMedium),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, LandingPageBuilderCubit cubit, String key, Color currentColor) {
    final List<Color> colors = [
      AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.activeGreen, AppColors.dangerRed,
      Colors.blue, Colors.green, Colors.red, Colors.purple, Colors.orange, Colors.teal, Colors.brown,
      Colors.black, Colors.white, const Color(0xFF1E293B), const Color(0xFFF8FAFC),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text("اختر لون"),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) => GestureDetector(
            onTap: () {
              cubit.updateThemeProperty(key, color);
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: color == currentColor ? 2 : 0),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildFontPicker(BuildContext context, LandingPageBuilderCubit cubit, BuilderLoaded currentState) {
    return Column(
      children: LandingPageTheme.availableFonts.map((font) {
        final family = font['family']!;
        final isSelected = family == (currentState.theme.defaultFont ?? 'Cairo');
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary.withValues(alpha: 0.1) : AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: ListTile(
            onTap: () {
              cubit.updateThemeProperty('defaultFont', family);
            },
            title: Row(
              children: [
                Text(family, style: GoogleFonts.getFont(family).copyWith(
                  fontSize: AppTypography.bodyMedium.fontSize ?? 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                )),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(font['category']!, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(font['desc']!, style: GoogleFonts.getFont(family).copyWith(
                fontSize: AppTypography.caption.fontSize ?? 12,
                color: AppTypography.caption.color,
                height: 1.4,
              )),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle_rounded, color: AppColors.secondary)
                : null,
          ),
        );
      }).toList(),
    );
  }


class ContentTab extends StatelessWidget {
  final LandingPageBuilderCubit cubit;
  final LocalizationCubit loc;
  final List<Map<String, dynamic>> blocks;
  final Function(int) onEditBlock;
  final Function(BuildContext, LandingPageBuilderCubit) onAddBlock;

  const ContentTab({
    super.key,
    required this.cubit,
    required this.loc,
    required this.blocks,
    required this.onEditBlock,
    required this.onAddBlock,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.translate('add_block'), style: AppTypography.h3),
              TextButton.icon(
                onPressed: () => onAddBlock(context, cubit),
                icon: const Icon(Icons.grid_view_rounded, size: 16),
                label: Text(loc.translate('all_blocks')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildQuickAddButton(cubit, 'hero', "+ ${loc.translate('hero_short')}"),
              _buildQuickAddButton(cubit, 'features', "+ ${loc.translate('features_short')}"),
              _buildQuickAddButton(cubit, 'whatsapp', "+ ${loc.translate('whatsapp')}"),
              _buildQuickAddButton(cubit, 'products', "+ ${loc.translate('products_short')}"),
              _buildQuickAddButton(cubit, 'qr_code', "+ QR"),
              _buildQuickAddButton(cubit, 'social_qr', "+ ${loc.translate('links_short')}"),
              _buildQuickAddButton(cubit, 'pricing', "+ ${loc.translate('pricing_short')}"),
              _buildQuickAddButton(cubit, 'faq', "+ ${loc.translate('faq_short')}"),
              _buildQuickAddButton(cubit, 'testimonials', "+ ${loc.translate('reviews_short')}"),
              _buildQuickAddButton(cubit, 'contact_info', "+ ${loc.translate('contact_short')}"),
              _buildQuickAddButton(cubit, 'gallery', "+ ${loc.translate('gallery_short')}"),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.border),
          const SizedBox(height: 32),
          Text(loc.translate('added_sections'), style: AppTypography.h3),
          const SizedBox(height: 16),
          if (blocks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text("لا توجد أقسام بعد.")),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blocks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final block = blocks[index];
                final String type = block['type'] ?? '';
                final String title = block['title'] ?? 'Section';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusPill(
                              label: type.toUpperCase(),
                              color: _getSectionColor(type),
                            ),
                            const SizedBox(height: 8),
                            Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.arrow_upward_rounded, size: 18), onPressed: index > 0 ? () => cubit.moveBlock(index, true) : null),
                      IconButton(icon: const Icon(Icons.arrow_downward_rounded, size: 18), onPressed: index < blocks.length - 1 ? () => cubit.moveBlock(index, false) : null),
                      IconButton(icon: const Icon(Icons.edit_rounded, color: AppColors.secondary, size: 18), onPressed: () => onEditBlock(index)),
                      IconButton(icon: const Icon(Icons.delete_rounded, color: AppColors.dangerRed, size: 18), onPressed: () => cubit.deleteBlock(index)),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(LandingPageBuilderCubit cubit, String type, String label) {
    return Container(
      width: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardBg,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 0,
        ),
        onPressed: () => cubit.addBlock(type),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getSectionColor(String type) {
    switch (type) {
      case 'hero': return AppColors.secondary;
      case 'features': return AppColors.primary;
      case 'products': return AppColors.activeGreen;
      case 'pricing': return AppColors.warningOrange;
      default: return AppColors.accent;
    }
  }
}
