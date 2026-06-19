import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
class CustomWorkingHoursWidget extends StatelessWidget {
  final Map<String, dynamic> blockData;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;

  const CustomWorkingHoursWidget({
    super.key,
    required this.blockData,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
  });

  @override
  Widget build(BuildContext context) {
    final title = blockData['title'] ?? 'مواعيد العمل';
    final schedule = blockData['schedule'] as Map<String, dynamic>? ?? {};
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    final now = DateTime.now();
    final currentHour = now.hour;
    final isOpen = currentHour >= 10 && currentHour < 23;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        final double paddingValue = verticalPadding ?? (isMobile ? 40 : 80);

        final props = _WorkingHoursProps(
          title: title,
          schedule: schedule,
          isOpen: isOpen,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          theme: theme,
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          backgroundColorHex: backgroundColorHex,
          verticalPadding: verticalPadding,
          bgBlur: bgBlur,
        );

        return isMobile
            ? _MobileWorkingHoursLayout(props: props)
            : _DesktopWorkingHoursLayout(props: props);
      },
    );
  }
}

/// ==========================================
/// 2. DATA PROPS CLASS
/// ==========================================
class _WorkingHoursProps {
  final String title;
  final Map<String, dynamic> schedule;
  final bool isOpen;
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

  const _WorkingHoursProps({
    required this.title,
    required this.schedule,
    required this.isOpen,
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

/// Desktop version of the Working Hours layout.
class _DesktopWorkingHoursLayout extends StatelessWidget {
  final _WorkingHoursProps props;
  const _DesktopWorkingHoursLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      backgroundColorHex: props.backgroundColorHex,
      verticalPaddingOverride: props.verticalPadding,
      bgBlur: props.bgBlur,
      theme: props.theme,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: props.subTextColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: props.subTextColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(props.title, style: AppTypography.h3.copyWith(color: props.textColor, fontSize: 24))),
                  SizedBox(width: 8),
                  _WorkingHoursStatusBadge(isOpen: props.isOpen),
                ],
              ),
              SizedBox(height: 24),
              ...props.schedule.entries.map((entry) {
                final valStr = entry.value.toString();
                final bool isNumeric = RegExp(r'[0-9]').hasMatch(valStr);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(entry.key, style: AppTypography.bodyLarge.copyWith(color: props.subTextColor, fontSize: 17))),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          valStr,
                          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: props.textColor, fontSize: 17),
                          textAlign: TextAlign.end,
                          textDirection: isNumeric ? TextDirection.ltr : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// ==========================================
/// 4. MOBILE LAYOUT
/// ==========================================

/// Mobile version of the Working Hours layout.
class _MobileWorkingHoursLayout extends StatelessWidget {
  final _WorkingHoursProps props;
  const _MobileWorkingHoursLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      backgroundColorHex: props.backgroundColorHex,
      verticalPaddingOverride: props.verticalPadding,
      bgBlur: props.bgBlur,
      theme: props.theme,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: props.subTextColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: props.subTextColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(props.title, style: AppTypography.h3.copyWith(color: props.textColor, fontSize: 20))),
                  SizedBox(width: 8),
                  _WorkingHoursStatusBadge(isOpen: props.isOpen),
                ],
              ),
              SizedBox(height: 24),
              ...props.schedule.entries.map((entry) {
                final valStr = entry.value.toString();
                final bool isNumeric = RegExp(r'[0-9]').hasMatch(valStr);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(entry.key, style: AppTypography.bodyLarge.copyWith(color: props.subTextColor, fontSize: 15))),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          valStr,
                          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: props.textColor, fontSize: 15),
                          textAlign: TextAlign.end,
                          textDirection: isNumeric ? TextDirection.ltr : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// ==========================================
/// 5. SHARED SUB-WIDGETS
/// ==========================================

/// Shared Open/Closed status badge.
class _WorkingHoursStatusBadge extends StatelessWidget {
  final bool isOpen;
  const _WorkingHoursStatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isOpen ? Colors.green : Theme.of(context).colorScheme.error).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOpen ? Colors.green : Theme.of(context).colorScheme.error),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: isOpen ? Colors.green : Theme.of(context).colorScheme.error, shape: BoxShape.circle)),
          SizedBox(width: 8),
          Text(isOpen ? "مفتوح الآن" : "مغلق الآن", style: AppTypography.caption.copyWith(color: isOpen ? Colors.green : Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
