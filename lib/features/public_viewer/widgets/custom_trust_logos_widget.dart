import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
class CustomTrustLogosWidget extends StatelessWidget {
  final String title;
  final List<String> logoUrls;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;

  const CustomTrustLogosWidget({
    super.key,
    required this.title,
    required this.logoUrls,
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
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double paddingValue = verticalPadding ?? (isMobile ? 40 : 80);

        final props = _TrustLogosProps(
          title: title,
          logoUrls: logoUrls,
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
            ? _MobileTrustLogosLayout(props: props)
            : _DesktopTrustLogosLayout(props: props);
      },
    );
  }
}

/// ==========================================
/// 2. DATA PROPS CLASS
/// ==========================================
class _TrustLogosProps {
  final String title;
  final List<String> logoUrls;
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

  const _TrustLogosProps({
    required this.title,
    required this.logoUrls,
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

/// Desktop version of the Trust Logos layout.
class _DesktopTrustLogosLayout extends StatelessWidget {
  final _TrustLogosProps props;
  const _DesktopTrustLogosLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      bgBlur: props.bgBlur,
      backgroundColorHex: props.backgroundColorHex,
      verticalPaddingOverride: props.verticalPadding,
      theme: props.theme,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (props.title.isNotEmpty) ...[
                Text(props.title, style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14), textAlign: TextAlign.center),
                SizedBox(height: 32),
              ],
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 48,
                runSpacing: 32,
                children: props.logoUrls.map((url) {
                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(props.textColor.withValues(alpha: 0.5), BlendMode.srcIn),
                    child: CustomNetworkImage(imageUrl: url, height: 40, fit: BoxFit.contain),
                  );
                }).toList(),
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

/// Mobile version of the Trust Logos layout.
class _MobileTrustLogosLayout extends StatelessWidget {
  final _TrustLogosProps props;
  const _MobileTrustLogosLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      bgBlur: props.bgBlur,
      backgroundColorHex: props.backgroundColorHex,
      verticalPaddingOverride: props.verticalPadding,
      theme: props.theme,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (props.title.isNotEmpty) ...[
                Text(props.title, style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12), textAlign: TextAlign.center),
                SizedBox(height: 24),
              ],
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 16,
                children: props.logoUrls.map((url) {
                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(props.textColor.withValues(alpha: 0.5), BlendMode.srcIn),
                    child: CustomNetworkImage(imageUrl: url, height: 32, fit: BoxFit.contain),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
