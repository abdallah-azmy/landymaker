import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomComparisonTableWidget extends StatelessWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;

  const CustomComparisonTableWidget({
    super.key,
    required this.block,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = theme?.textSecondary ?? AppColors.textSecondary;
    final accentColor = theme?.secondary ?? AppColors.secondary;
    
    final title = block['title'] ?? '';
    final subtitle = block['subtitle'] ?? '';
    final List plans = block['plans'] ?? [];
    final List features = block['features'] ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;

        return SectionBackground(
          theme: theme,
          bgImageUrl: block['bg_image_url'],
          bgOverlayColor: block['bg_overlay_color'],
          bgOverlayOpacity: (block['bg_overlay_opacity'] as num?)?.toDouble(),
          bgBlur: (block['bg_blur'] as num?)?.toDouble(),
          padding: EdgeInsetsDirectional.symmetric(vertical: isMobile ? 40 : 80, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  if (title.isNotEmpty) ...[
                    Text(
                      title,
                      style: AppTypography.h2.copyWith(color: textColor, fontSize: isMobile ? 24 : 32),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (subtitle.isNotEmpty) ...[
                    Text(
                      subtitle,
                      style: AppTypography.bodyLarge.copyWith(color: subTextColor, fontSize: isMobile ? 16 : 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                  ],
                  if (isMobile)
                    _buildMobileComparison(plans, features, accentColor, textColor, subTextColor)
                  else
                    _buildDesktopTable(plans, features, accentColor, textColor, subTextColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(List plans, List features, Color accent, Color textColor, Color subTextColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: {
          0: const FlexColumnWidth(2),
          ...Map.fromIterable(
            List.generate(plans.length, (i) => i + 1),
            key: (i) => i,
            value: (_) => const FlexColumnWidth(1),
          ),
        },
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(color: textColor.withValues(alpha: 0.05)),
            children: [
              const TableCell(child: SizedBox(height: 80)),
              ...plans.map((plan) => TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        plan['name'] ?? '',
                        style: AppTypography.h3.copyWith(color: textColor, fontSize: 18),
                      ),
                      if (plan['price'] != null)
                        Text(
                          plan['price'],
                          style: AppTypography.bodyMedium.copyWith(color: accent, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              )),
            ],
          ),
          // Feature Rows
          ...features.map((feature) {
            final featureName = feature['name'] ?? '';
            final values = feature['values'] ?? [];

            return TableRow(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
              ),
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 24, vertical: 20),
                    child: Text(featureName, style: AppTypography.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                ...List.generate(plans.length, (index) {
                  final value = index < values.length ? values[index] : null;
                  return TableCell(
                    child: Center(
                      child: _buildFeatureValue(value, accent, subTextColor),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMobileComparison(List plans, List features, Color accent, Color textColor, Color subTextColor) {
    return Column(
      children: plans.map((plan) {
        final planIndex = plans.indexOf(plan);
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan['name'] ?? '', style: AppTypography.h3.copyWith(color: accent)),
              const SizedBox(height: 16),
              ...features.map((feature) {
                final values = feature['values'] ?? [];
                final value = planIndex < values.length ? values[planIndex] : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(feature['name'] ?? '', style: AppTypography.bodySmall.copyWith(color: subTextColor)),
                      _buildFeatureValue(value, accent, subTextColor),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureValue(dynamic value, Color accent, Color subTextColor) {
    if (value is bool) {
      return Icon(
        value ? Icons.check_circle_rounded : Icons.cancel_rounded,
        color: value ? accent : AppColors.textMuted.withValues(alpha: 0.5),
        size: 20,
      );
    }
    return Text(
      value?.toString() ?? '-',
      style: AppTypography.bodyMedium.copyWith(color: subTextColor),
    );
  }
}
