import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landymaker/core/widgets/atoms/custom_text_field.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/molecules/status_pill.dart';
import '../../models/landing_page_theme.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../controllers/builder_theme_cubit.dart';
import '../../../../core/services/dynamic_font_service.dart';

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
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                tooltip: loc.translate('add_block'),
              ),
            ],
          ),
        ),
        Expanded(
          child: blocks.isEmpty
              ? _buildEmptyState(context)
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
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
                        color: isSelected
                            ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05)
                            : Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.outline,
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
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isVisible
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isVisible
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                size: 18,
                                color: isVisible
                                    ? Theme.of(context).colorScheme.onSurfaceVariant
                                    : Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () =>
                                  cubit.toggleBlockVisibility(index),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.error,
                              ),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.layers_clear_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "لا توجد أقسام مضافة بعد",
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
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
              Text(
                "سيقوم اختيار قالب باستبدال المحتوى الحالي.",
                style: AppTypography.caption,
              ),
              const SizedBox(height: 24),
              _buildTemplateCard(
                context,
                dynamicState,
                'store',
                "متجر إلكتروني",
                Icons.shopping_cart_rounded,
                "مناسب لبيع المنتجات والسلع.",
              ),
              _buildTemplateCard(
                context,
                dynamicState,
                'personal',
                "موقع شخصي",
                Icons.person_rounded,
                "معرض أعمال وسيرة ذاتية.",
              ),
              _buildTemplateCard(
                context,
                dynamicState,
                'professional',
                "خدمات مهنية",
                Icons.business_center_rounded,
                "للاستشارات والشركات الناشئة.",
              ),
              _buildTemplateCard(
                context,
                dynamicState,
                'restaurant',
                "مطعم / كافيه",
                Icons.restaurant_rounded,
                "منيو إلكتروني وأجواء ترفيهية.",
              ),
              _buildTemplateCard(
                context,
                dynamicState,
                'real_estate',
                "عقارات / Real Estate",
                Icons.home_work_rounded,
                "تسويق شقق وفلل ومجمعات سكنية.",
              ),
              _buildTemplateCard(
                context,
                dynamicState,
                'event',
                "فعالية ومؤتمر / Event",
                Icons.event_rounded,
                "حجز تذاكر، تفاصيل الفعالية، وخرائط الوصول.",
              ),
              _buildTemplateCard(
                context,
                dynamicState,
                'digital_course',
                "دورة تعليمية / Course",
                Icons.school_rounded,
                "تسويق كورسات، دروس، ومناهج تعليمية مع التسجيل.",
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    BuilderLoaded currentState,
    String type,
    String label,
    IconData icon,
    String desc,
  ) {
    final loc = context.read<LocalizationCubit>();
    final isSelected = currentState.websiteType == type;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        ),
        title: Text(
          label,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(desc, style: AppTypography.caption),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.secondary)
            : null,
        onTap: () => _showTemplateConfirmation(context, type, loc),
      ),
    );
  }

  void _showTemplateConfirmation(
    BuildContext context,
    String type,
    LocalizationCubit loc,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(loc.translate('confirm_template')),
        content: Text(loc.translate('confirm_template_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('cancel')),
          ),
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

  const DesignColorsTab({
    super.key,
    required this.loc,
    required this.cubit,
    required this.state,
  });

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
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _tabIndex = 0),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _tabIndex == 0
                      ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    "لوحات الألوان",
                    style: AppTypography.bodyMedium.copyWith(
                      color: _tabIndex == 0
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: _tabIndex == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _tabIndex = 1),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _tabIndex == 1
                      ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    "تخصيص الألوان",
                    style: AppTypography.bodyMedium.copyWith(
                      color: _tabIndex == 1
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: _tabIndex == 1
                          ? FontWeight.bold
                          : FontWeight.normal,
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
                  color: isSelected
                      ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: ListTile(
                  onTap: () {
                    final newTheme = palette.copyWith(
                      defaultFont: state.theme.defaultFont,
                    );
                    context.read<BuilderThemeCubit>().updateTheme(newTheme);
                  },
                  isThreeLine: true,
                  title: Row(
                    children: [
                      Text(
                        palette.name,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (palette.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            palette.category!,
                            style: TextStyle(
                              fontSize: 9,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                        )
                      : null,
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (palette.description != null)
                        Text(
                          palette.description!,
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
            _buildColorPickerItem(
              context,
              context.read<BuilderThemeCubit>(),
              "اللون الأساسي",
              "primary",
              state.theme.primary,
            ),
            _buildColorPickerItem(
              context,
              context.read<BuilderThemeCubit>(),
              "اللون الثانوي",
              "secondary",
              state.theme.secondary,
            ),
            _buildColorPickerItem(
              context,
              context.read<BuilderThemeCubit>(),
              "لون الخلفية",
              "background",
              state.theme.background,
            ),
            _buildColorPickerItem(
              context,
              context.read<BuilderThemeCubit>(),
              "لون النص الرئيسي",
              "textPrimary",
              state.theme.textPrimary,
            ),
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

  const DesignFontsTab({
    super.key,
    required this.loc,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<BuilderThemeCubit>();
    return BlocBuilder<BuilderThemeCubit, LandingPageTheme>(
      builder: (context, theme) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("إعدادات الخط العامة", style: AppTypography.h3),
            const SizedBox(height: 16),
            _buildFontPicker(context, themeCubit, theme),
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

  const DesignTab({
    super.key,
    required this.loc,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MagicImageSwapper(),
          const SizedBox(height: 32),
          Divider(color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 24),
          DesignColorsTab(loc: loc, cubit: cubit, state: state),
          const SizedBox(height: 24),
          Divider(color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 24),
          DesignFontsTab(loc: loc, cubit: cubit, state: state),
        ],
      ),
    );
  }
}

class MagicImageSwapper extends StatefulWidget {
  const MagicImageSwapper({super.key});

  @override
  State<MagicImageSwapper> createState() => _MagicImageSwapperState();
}

class _MagicImageSwapperState extends State<MagicImageSwapper> {
  final TextEditingController _categoryController = TextEditingController();

  final List<String> _presets = [
    'مطاعم',
    'تقنية',
    'عقارات',
    'أزياء',
    'طب',
    'رياضة',
    'أثاث',
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "المبدل السحري للصور",
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "غيّر تخصص كل صور الصفحة بضغطة واحدة من Pixabay.",
          style: AppTypography.caption,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _categoryController,
          hintText: "مثلاً: مقهى، نادي رياضي، برمجة...",
          suffixIcon: IconButton(
            icon: Icon(Icons.send_rounded, color: Theme.of(context).colorScheme.primary),
            onPressed: () => _applyMagic(context),
          ),
          onSubmitted: (_) => _applyMagic(context),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presets
              .map(
                (preset) => InkWell(
                  onTap: () {
                    _categoryController.text = preset;
                    _applyMagic(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Text(
                      preset,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _applyMagic(BuildContext context) {
    if (_categoryController.text.isEmpty) return;

    context.read<LandingPageBuilderCubit>().magicReplaceImages(
      _categoryController.text,
    );
    FocusScope.of(context).unfocus();
  }
}

Widget _colorBox(Color color) {
  return Container(
    width: 20,
    height: 20,
    margin: const EdgeInsetsDirectional.only(start: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.white24),
    ),
  );
}

Widget _buildColorPickerItem(
  BuildContext context,
  BuilderThemeCubit themeCubit,
  String label,
  String key,
  Color color,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: InkWell(
      onTap: () => _showColorPicker(context, themeCubit, key, color),
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
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showColorPicker(
  BuildContext context,
  BuilderThemeCubit themeCubit,
  String key,
  Color currentColor,
) {
  final List<Color> colors = [
    Theme.of(context).colorScheme.primary,
    Theme.of(context).colorScheme.secondary,
    Theme.of(context).colorScheme.primary,
    Colors.green,
    Theme.of(context).colorScheme.error,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.brown,
    Colors.black,
    Colors.white,
    const Color(0xFF1E293B),
    const Color(0xFFF8FAFC),
  ];

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Text("اختر لون"),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: colors
            .map(
              (color) => GestureDetector(
                onTap: () {
                  themeCubit.updateThemeProperty(key, color);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: color == currentColor ? 2 : 0,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ),
  );
}

Widget _buildFontPicker(
  BuildContext context,
  BuilderThemeCubit themeCubit,
  LandingPageTheme theme,
) {
  return Column(
    children: LandingPageTheme.availableFonts.map((font) {
      final family = font['family']!;
      final isSelected = family == (theme.defaultFont ?? 'Cairo');

      if (family.toLowerCase() != 'cairo') {
        DynamicFontService.loadFont(family, [400, 700]);
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ListTile(
          onTap: () {
            themeCubit.updateThemeProperty('defaultFont', family);
          },
          title: Row(
            children: [
              Text(
                family,
                style: TextStyle(
                  fontFamily: family,
                  fontFamilyFallback: const ['Cairo'],
                  fontSize: AppTypography.bodyMedium.fontSize ?? 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  font['category']!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              font['desc']!,
              style: TextStyle(
                fontFamily: family,
                fontFamilyFallback: const ['Cairo'],
                fontSize: AppTypography.caption.fontSize ?? 12,
                color: AppTypography.caption.color,
                height: 1.4,
              ),
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                )
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
              _buildQuickAddButton(
                context,
                cubit,
                'hero',
                "+ ${loc.translate('hero_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'features',
                "+ ${loc.translate('features_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'whatsapp',
                "+ ${loc.translate('whatsapp')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'products',
                "+ ${loc.translate('products_short')}",
              ),
              _buildQuickAddButton(context, cubit, 'qr_code', "+ QR"),
              _buildQuickAddButton(
                context,
                cubit,
                'social_qr',
                "+ ${loc.translate('links_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'pricing',
                "+ ${loc.translate('pricing_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'faq',
                "+ ${loc.translate('faq_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'testimonials',
                "+ ${loc.translate('reviews_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'contact_info',
                "+ ${loc.translate('contact_short')}",
              ),
              _buildQuickAddButton(
                context,
                cubit,
                'gallery',
                "+ ${loc.translate('gallery_short')}",
              ),
            ],
          ),
          const SizedBox(height: 32),
          Divider(color: Theme.of(context).colorScheme.outline),
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
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusPill(
                              label: type.toUpperCase(),
                              color: _getSectionColor(context, type),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 22),
                        onPressed: index > 0
                            ? () => cubit.moveBlock(index, true)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                        ),
                        onPressed: index < blocks.length - 1
                            ? () => cubit.moveBlock(index, false)
                            : null,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 18,
                        ),
                        onPressed: () => onEditBlock(index),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_rounded,
                          color: Theme.of(context).colorScheme.error,
                          size: 18,
                        ),
                        onPressed: () => cubit.deleteBlock(index),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context,
    LandingPageBuilderCubit cubit,
    String type,
    String label,
  ) {
    return Container(
      width: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          elevation: 0,
        ),
        onPressed: () => cubit.addBlock(type),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _getSectionColor(BuildContext context, String type) {
    switch (type) {
      case 'hero':
        return Theme.of(context).colorScheme.secondary;
      case 'features':
        return Theme.of(context).colorScheme.primary;
      case 'products':
        return Colors.green;
      case 'pricing':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
