import 'package:flutter/material.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
class CustomLogoHeaderWidget extends StatelessWidget {
  final String title;
  final String? logoUrl;
  final double logoHeight;
  final String alignment;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomLogoHeaderWidget({
    super.key,
    required this.title,
    this.logoUrl,
    this.logoHeight = 40.0,
    this.alignment = 'center',
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final borderColor = textColor.withValues(alpha: 0.1);

    MainAxisAlignment mainAxisAlignment;
    switch (alignment) {
      case 'left':
        mainAxisAlignment = isRtl ? MainAxisAlignment.end : MainAxisAlignment.start;
        break;
      case 'right':
        mainAxisAlignment = isRtl ? MainAxisAlignment.start : MainAxisAlignment.end;
        break;
      default:
        mainAxisAlignment = MainAxisAlignment.center;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        final props = _LogoHeaderProps(
          title: title,
          logoUrl: logoUrl,
          logoHeight: logoHeight,
          mainAxisAlignment: mainAxisAlignment,
          textColor: textColor,
          borderColor: borderColor,
          isMobile: isMobile,
          theme: theme,
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          bgBlur: bgBlur,
        );

        return isMobile
            ? _MobileLogoHeaderLayout(props: props)
            : _DesktopLogoHeaderLayout(props: props);
      },
    );
  }
}

/// ==========================================
/// 2. DATA PROPS CLASS
/// ==========================================
class _LogoHeaderProps {
  final String title;
  final String? logoUrl;
  final double logoHeight;
  final MainAxisAlignment mainAxisAlignment;
  final Color textColor;
  final Color borderColor;
  final bool isMobile;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const _LogoHeaderProps({
    required this.title,
    this.logoUrl,
    required this.logoHeight,
    required this.mainAxisAlignment,
    required this.textColor,
    required this.borderColor,
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

/// Desktop version of the Logo Header layout.
class _DesktopLogoHeaderLayout extends StatelessWidget {
  final _LogoHeaderProps props;
  const _DesktopLogoHeaderLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      theme: props.theme,
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      bgBlur: props.bgBlur,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 20, horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: props.borderColor, width: 0.5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: props.mainAxisAlignment,
              children: [
                if (props.logoUrl != null && props.logoUrl!.isNotEmpty)
                  CustomNetworkImage(imageUrl: props.logoUrl!, height: props.logoHeight),
                if (props.logoUrl != null && props.logoUrl!.isNotEmpty && props.title.isNotEmpty)
                  SizedBox(width: 12),
                if (props.title.isNotEmpty)
                  Text(props.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: props.textColor)),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// ==========================================
/// 4. MOBILE LAYOUT
/// ==========================================

/// Mobile version of the Logo Header layout.
class _MobileLogoHeaderLayout extends StatelessWidget {
  final _LogoHeaderProps props;
  const _MobileLogoHeaderLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      theme: props.theme,
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      bgBlur: props.bgBlur,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: props.borderColor, width: 0.5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: props.mainAxisAlignment,
              children: [
                if (props.logoUrl != null && props.logoUrl!.isNotEmpty)
                  CustomNetworkImage(imageUrl: props.logoUrl!, height: (props.logoHeight * 0.8).clamp(24.0, 60.0)),
                if (props.logoUrl != null && props.logoUrl!.isNotEmpty && props.title.isNotEmpty)
                  SizedBox(width: 12),
                if (props.title.isNotEmpty)
                  Text(props.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: props.textColor)),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
