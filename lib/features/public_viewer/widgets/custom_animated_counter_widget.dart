import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
class CustomAnimatedCounterWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomAnimatedCounterWidget({
    super.key,
    required this.title,
    required this.items,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = theme?.secondary ?? AppColors.secondary;
    final textColor = theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = theme?.textSecondary ?? AppColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        final props = _AnimatedCounterProps(
          title: title,
          items: items,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          constraintsWidth: constraints.maxWidth,
          theme: theme,
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          bgBlur: bgBlur,
        );

        return isMobile
            ? _MobileAnimatedCounterLayout(props: props)
            : _DesktopAnimatedCounterLayout(props: props);
      },
    );
  }
}

/// ==========================================
/// 2. DATA PROPS CLASS
/// ==========================================
class _AnimatedCounterProps {
  final String title;
  final List<Map<String, dynamic>> items;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final double constraintsWidth;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const _AnimatedCounterProps({
    required this.title,
    required this.items,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    required this.constraintsWidth,
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

/// Desktop version of the Animated Counter layout.
class _DesktopAnimatedCounterLayout extends StatelessWidget {
  final _AnimatedCounterProps props;
  const _DesktopAnimatedCounterLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      bgBlur: props.bgBlur,
      theme: props.theme,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (props.title.isNotEmpty) ...[
                Text(props.title, style: AppTypography.h2.copyWith(color: props.textColor, fontWeight: FontWeight.w800, fontSize: 32), textAlign: TextAlign.center),
                const SizedBox(height: 64),
              ],
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 32,
                runSpacing: 48,
                children: props.items.map((item) => _AnimatedCounterCard(item: item, props: props)).toList(),
              ),
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

/// Mobile version of the Animated Counter layout.
class _MobileAnimatedCounterLayout extends StatelessWidget {
  final _AnimatedCounterProps props;
  const _MobileAnimatedCounterLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      bgBlur: props.bgBlur,
      theme: props.theme,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (props.title.isNotEmpty) ...[
                Text(props.title, style: AppTypography.h2.copyWith(color: props.textColor, fontWeight: FontWeight.w800, fontSize: 24), textAlign: TextAlign.center),
                const SizedBox(height: 40),
              ],
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 24,
                children: props.items.map((item) => _AnimatedCounterCard(item: item, props: props)).toList(),
              ),
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

/// Modular Animated Counter Card.
class _AnimatedCounterCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final _AnimatedCounterProps props;
  const _AnimatedCounterCard({required this.item, required this.props});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: props.isMobile ? props.constraintsWidth : 250,
      padding: EdgeInsets.all(props.isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: props.subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: props.subTextColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: double.tryParse(item['value'] ?? '0') ?? 0),
            duration: const Duration(seconds: 2),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              return Text(
                '${item['prefix'] ?? ''}${value.toInt()}${item['suffix'] ?? ''}',
                style: AppTypography.h1.copyWith(color: props.secondaryColor, fontWeight: FontWeight.w900, fontSize: props.isMobile ? 36 : 48, height: 1.1),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(item['label'] ?? '', style: AppTypography.bodyLarge.copyWith(color: props.subTextColor, fontWeight: FontWeight.bold, fontSize: props.isMobile ? 14 : 16), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
