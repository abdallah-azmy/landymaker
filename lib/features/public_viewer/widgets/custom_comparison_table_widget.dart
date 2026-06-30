import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
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
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final accentColor = theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final title = block['title'] ?? '';
    final subtitle = block['subtitle'] ?? '';
    final List plans = block['plans'] ?? [];
    final List features = block['features'] ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;
        final double paddingValue = (block['vertical_padding'] as num?)?.toDouble() ?? (isMobile ? 40 : 80);

        final props = _ComparisonTableProps(
          title: title,
          subtitle: subtitle,
          plans: plans,
          features: features,
          accentColor: accentColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          theme: theme,
          bgImageUrl: block['bg_image_url'],
          bgOverlayColor: block['bg_overlay_color'],
          bgOverlayOpacity: (block['bg_overlay_opacity'] as num?)?.toDouble(),
          backgroundColorHex: block['bg_color'] ?? block['background_color'],
          verticalPadding: (block['vertical_padding'] as num?)?.toDouble(),
          bgBlur: (block['bg_blur'] as num?)?.toDouble(),
        );

        return SectionBackground(
          theme: theme,
          bgImageUrl: props.bgImageUrl,
          bgOverlayColor: props.bgOverlayColor,
          bgOverlayOpacity: props.bgOverlayOpacity,
          backgroundColorHex: props.backgroundColorHex,
          verticalPaddingOverride: props.verticalPadding,
          bgBlur: props.bgBlur,
          padding: EdgeInsetsDirectional.symmetric(vertical: paddingValue, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  if (props.title.isNotEmpty) ...[
                    Text(
                      props.title,
                      style: AppTypography.h2.copyWith(color: props.textColor, fontSize: props.isMobile ? 24 : 32),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                  ],
                  if (props.subtitle.isNotEmpty) ...[
                    Text(
                      props.subtitle,
                      style: AppTypography.bodyLarge.copyWith(color: props.subTextColor, fontSize: props.isMobile ? 16 : 18),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 48),
                  ],
                  if (props.isMobile)
                    _MobileComparisonTableLayout(props: props)
                  else
                    _DesktopComparisonTableLayout(props: props),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ==========================================
/// 2. DATA PROPS CLASS
/// ==========================================
class _ComparisonTableProps {
  final String title;
  final String subtitle;
  final List plans;
  final List features;
  final Color accentColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;

  const _ComparisonTableProps({
    required this.title,
    required this.subtitle,
    required this.plans,
    required this.features,
    required this.accentColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
  });
}

/// ==========================================
/// 3. DESKTOP LAYOUT
/// ==========================================

/// Desktop version of the Comparison Table layout.
class _DesktopComparisonTableLayout extends StatelessWidget {
  final _ComparisonTableProps props;
  const _DesktopComparisonTableLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: {
          0: const FlexColumnWidth(2),
          ...Map.fromIterable(
            List.generate(props.plans.length, (i) => i + 1),
            key: (i) => i,
            value: (_) => const FlexColumnWidth(1),
          ),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: props.textColor.withValues(alpha: 0.05)),
            children: [
              const TableCell(child: SizedBox(height: 80)),
              ...props.plans.map((plan) => TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        plan['name'] ?? '',
                        style: AppTypography.h3.copyWith(color: props.textColor, fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (plan['price'] != null)
                        Text(
                          plan['price'],
                          style: AppTypography.bodyMedium.copyWith(color: props.accentColor, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              )),
            ],
          ),
          ...props.features.map((feature) {
            final featureName = feature['name'] ?? '';
            final values = feature['values'] ?? [];

            return TableRow(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5))),
              ),
              children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 24, vertical: 20),
                    child: Text(featureName, style: AppTypography.bodyMedium.copyWith(color: props.textColor, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ),
                ...List.generate(props.plans.length, (index) {
                  final value = index < values.length ? values[index] : null;
                  return TableCell(
                    child: Center(
                      child: _ComparisonFeatureValue(value: value, accentColor: props.accentColor, subTextColor: props.subTextColor),
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
}

/// ==========================================
/// 4. MOBILE LAYOUT
/// ==========================================

/// Mobile version of the Comparison Table layout.
class _MobileComparisonTableLayout extends StatelessWidget {
  final _ComparisonTableProps props;
  const _MobileComparisonTableLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(props.plans.length, (planIndex) {
        final plan = props.plans[planIndex];
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan['name'] ?? '', style: AppTypography.h3.copyWith(color: props.accentColor), maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: 16),
              ...props.features.map((feature) {
                final values = feature['values'] ?? [];
                final value = planIndex < values.length ? values[planIndex] : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(feature['name'] ?? '', style: AppTypography.bodySmall.copyWith(color: props.subTextColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                      _ComparisonFeatureValue(value: value, accentColor: props.accentColor, subTextColor: props.subTextColor),
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
}

/// ==========================================
/// 5. SHARED SUB-WIDGETS
/// ==========================================

/// Shared Comparison Feature Value (checkmark, cross, or text).
class _ComparisonFeatureValue extends StatelessWidget {
  final dynamic value;
  final Color accentColor;
  final Color subTextColor;

  const _ComparisonFeatureValue({
    required this.value,
    required this.accentColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    if (value is bool) {
      return Icon(
        value ? Icons.check_circle_rounded : Icons.cancel_rounded,
        color: value ? accentColor : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5).withValues(alpha: 0.5),
        size: 20,
      );
    }
    return Text(
      value?.toString() ?? '-',
      style: AppTypography.bodyMedium.copyWith(color: subTextColor),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
