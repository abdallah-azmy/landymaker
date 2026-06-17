import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
class CustomServiceStepsWidget extends StatelessWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;

  const CustomServiceStepsWidget({
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
    final List items = block['items'] ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;

        final props = _ServiceStepsProps(
          title: title,
          subtitle: subtitle,
          items: items,
          accentColor: accentColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          theme: theme,
          bgImageUrl: block['bg_image_url'],
          bgOverlayColor: block['bg_overlay_color'],
          bgOverlayOpacity: (block['bg_overlay_opacity'] as num?)?.toDouble(),
          bgBlur: (block['bg_blur'] as num?)?.toDouble(),
        );

        return SectionBackground(
          theme: theme,
          bgImageUrl: props.bgImageUrl,
          bgOverlayColor: props.bgOverlayColor,
          bgOverlayOpacity: props.bgOverlayOpacity,
          bgBlur: props.bgBlur,
          padding: EdgeInsetsDirectional.symmetric(vertical: props.isMobile ? 40 : 80, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  if (props.title.isNotEmpty) ...[
                    Text(props.title, style: AppTypography.h2.copyWith(color: props.textColor, fontSize: props.isMobile ? 24 : 32), textAlign: TextAlign.center),
                    SizedBox(height: 12),
                  ],
                  if (props.subtitle.isNotEmpty) ...[
                    Text(props.subtitle, style: AppTypography.bodyLarge.copyWith(color: props.subTextColor, fontSize: props.isMobile ? 16 : 18), textAlign: TextAlign.center),
                    SizedBox(height: 64),
                  ],
                  if (props.isMobile)
                    _MobileServiceStepsLayout(props: props)
                  else
                    _DesktopServiceStepsLayout(props: props),
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
class _ServiceStepsProps {
  final String title;
  final String subtitle;
  final List items;
  final Color accentColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const _ServiceStepsProps({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.accentColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });
}

/// ==========================================
/// 3. DESKTOP LAYOUT
/// ==========================================

/// Desktop version of the Service Steps layout (horizontal timeline).
class _DesktopServiceStepsLayout extends StatelessWidget {
  final _ServiceStepsProps props;
  const _DesktopServiceStepsLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(props.items.length, (index) {
        final item = props.items[index];
        final isLast = index == props.items.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index != 0) Expanded(child: Divider(color: props.accentColor.withValues(alpha: 0.3), thickness: 2)),
                  _StepNumber(index: index, accentColor: props.accentColor),
                  if (!isLast) Expanded(child: Divider(color: props.accentColor.withValues(alpha: 0.3), thickness: 2)),
                ],
              ),
              SizedBox(height: 24),
              Text(item['title'] ?? '', style: AppTypography.h3.copyWith(color: props.textColor, fontSize: 18), textAlign: TextAlign.center),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(item['description'] ?? '', style: AppTypography.bodyMedium.copyWith(color: props.subTextColor), textAlign: TextAlign.center),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// ==========================================
/// 4. MOBILE LAYOUT
/// ==========================================

/// Mobile version of the Service Steps layout (vertical timeline).
class _MobileServiceStepsLayout extends StatelessWidget {
  final _ServiceStepsProps props;
  const _MobileServiceStepsLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(props.items.length, (index) {
        final item = props.items[index];
        final isLast = index == props.items.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  _StepNumber(index: index, accentColor: props.accentColor),
                  if (!isLast)
                    Expanded(child: Container(width: 2, color: props.accentColor.withValues(alpha: 0.3))),
                ],
              ),
              SizedBox(width: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(item['title'] ?? '', style: AppTypography.h3.copyWith(color: props.textColor, fontSize: 18)),
                      SizedBox(height: 8),
                      Text(item['description'] ?? '', style: AppTypography.bodyMedium.copyWith(color: props.subTextColor)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// ==========================================
/// 5. SHARED SUB-WIDGETS
/// ==========================================

/// Shared Step Number circle.
class _StepNumber extends StatelessWidget {
  final int index;
  final Color accentColor;
  const _StepNumber({required this.index, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: accentColor,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Center(
        child: Text('${index + 1}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }
}
