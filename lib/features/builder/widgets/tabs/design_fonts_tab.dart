import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/localization_cubit.dart';
import '../../../../core/services/dynamic_font_service.dart';
import '../../controllers/builder_cubit.dart';
import '../../controllers/builder_state.dart';
import '../../controllers/builder_theme_cubit.dart';
import '../../models/landing_page_theme.dart';

/// Font family picker tab for the builder sidebar.
///
/// Uses `BlocBuilder<BuilderThemeCubit, LandingPageTheme>` per Rule #34.
/// Pre-loads non-Cairo fonts via `DynamicFontService` for instant preview.
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
