import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../controllers/builder_theme_cubit.dart';
import '../../models/landing_page_theme.dart';

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
