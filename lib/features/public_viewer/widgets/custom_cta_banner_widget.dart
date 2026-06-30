import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
class CustomCtaBannerWidget extends StatelessWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;

  const CustomCtaBannerWidget({
    super.key,
    required this.block,
    this.theme,
  });

  String get _layoutStyle => block['layout_style'] as String? ?? 'centeredGradient';

  @override
  Widget build(BuildContext context) {
    final accentColor = theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final title = block['title'] ?? '';
    final subtitle = block['subtitle'] ?? '';
    final buttonText = block['button_text'] ?? '';
    final buttonUrl = block['button_url'] ?? '';
    final secondaryButtonText = block['secondary_button_text'] ?? '';
    final secondaryButtonUrl = block['secondary_button_url'] ?? '';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double paddingValue = (block['vertical_padding'] as num?)?.toDouble() ?? (isMobile ? 40 : 80);

        final props = _CtaBannerProps(
          title: title,
          subtitle: subtitle,
          buttonText: buttonText,
          buttonUrl: buttonUrl,
          secondaryButtonText: secondaryButtonText,
          secondaryButtonUrl: secondaryButtonUrl,
          accentColor: accentColor,
          isMobile: isMobile,
          theme: theme,
          bgImageUrl: block['bg_image_url'],
          bgOverlayColor: block['bg_overlay_color'],
          bgOverlayOpacity: (block['bg_overlay_opacity'] as num?)?.toDouble() ?? 0.0,
          backgroundColorHex: block['bg_color'] ?? block['background_color'],
          verticalPadding: (block['vertical_padding'] as num?)?.toDouble(),
          bgBlur: (block['bg_blur'] as num?)?.toDouble(),
        );

        if (_layoutStyle == 'split') {
          return isMobile
              ? _MobileCtaSplitLayout(props: props)
              : _DesktopCtaSplitLayout(props: props);
        }

        return isMobile
            ? _MobileCtaCenteredGradientLayout(props: props, paddingValue: paddingValue)
            : _DesktopCtaCenteredGradientLayout(props: props, paddingValue: paddingValue);
      },
    );
  }
}

/// ==========================================
/// 2. DATA PROPS CLASS
/// ==========================================
class _CtaBannerProps {
  final String title;
  final String subtitle;
  final String buttonText;
  final String buttonUrl;
  final String secondaryButtonText;
  final String secondaryButtonUrl;
  final Color accentColor;
  final bool isMobile;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;

  const _CtaBannerProps({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.buttonUrl,
    required this.secondaryButtonText,
    required this.secondaryButtonUrl,
    required this.accentColor,
    required this.isMobile,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    required this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
  });
}

/// ==========================================
/// 3. DESKTOP LAYOUTS
/// ==========================================

/// Desktop version of the Centered Gradient CTA layout.
class _DesktopCtaCenteredGradientLayout extends StatelessWidget {
  final _CtaBannerProps props;
  final double paddingValue;
  const _DesktopCtaCenteredGradientLayout({required this.props, required this.paddingValue});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      theme: props.theme,
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      backgroundColorHex: props.backgroundColorHex,
      verticalPaddingOverride: props.verticalPadding,
      bgBlur: props.bgBlur,
      padding: EdgeInsetsDirectional.symmetric(vertical: paddingValue, horizontal: 24),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsetsDirectional.all(64),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                props.accentColor,
                props.accentColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: props.accentColor.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                props.title,
                style: AppTypography.h2.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (props.subtitle.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  props.subtitle,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 40),
              _CtaButtonRow(props: props),
            ],
          ),
        ),
      ),
    );
  }
}

/// ==========================================
/// 4. MOBILE LAYOUTS
/// ==========================================

/// Mobile version of the Centered Gradient CTA layout.
class _MobileCtaCenteredGradientLayout extends StatelessWidget {
  final _CtaBannerProps props;
  final double paddingValue;
  const _MobileCtaCenteredGradientLayout({required this.props, required this.paddingValue});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      theme: props.theme,
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      backgroundColorHex: props.backgroundColorHex,
      verticalPaddingOverride: props.verticalPadding,
      bgBlur: props.bgBlur,
      padding: EdgeInsetsDirectional.symmetric(vertical: paddingValue, horizontal: 24),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsetsDirectional.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                props.accentColor,
                props.accentColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: props.accentColor.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                props.title,
                style: AppTypography.h2.copyWith(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (props.subtitle.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  props.subtitle,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 40),
              _CtaButtonRow(props: props),
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop version of the Split CTA layout.
class _DesktopCtaSplitLayout extends StatelessWidget {
  final _CtaBannerProps props;
  const _DesktopCtaSplitLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      theme: props.theme,
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      backgroundColorHex: props.backgroundColorHex,
      verticalPaddingOverride: props.verticalPadding,
      bgBlur: props.bgBlur,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsetsDirectional.all(56),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                props.accentColor,
                props.accentColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: props.accentColor.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(props.title, style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900), maxLines: 3, overflow: TextOverflow.ellipsis),
                    if (props.subtitle.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Text(props.subtitle, style: AppTypography.bodyLarge.copyWith(color: Colors.white.withValues(alpha: 0.9)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 40),
              _CtaButtonRow(props: props),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mobile version of the Split CTA layout.
class _MobileCtaSplitLayout extends StatelessWidget {
  final _CtaBannerProps props;
  const _MobileCtaSplitLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      theme: props.theme,
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      backgroundColorHex: props.backgroundColorHex,
      verticalPaddingOverride: props.verticalPadding,
      bgBlur: props.bgBlur,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsetsDirectional.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                props.accentColor,
                props.accentColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: props.accentColor.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(props.title, style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
              if (props.subtitle.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(props.subtitle, style: AppTypography.bodyLarge.copyWith(color: Colors.white.withValues(alpha: 0.9)), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              SizedBox(height: 32),
              _CtaButtonRow(props: props),
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

/// Shared CTA Button Row used by all layouts.
class _CtaButtonRow extends StatelessWidget {
  final _CtaBannerProps props;
  const _CtaButtonRow({required this.props});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        ElevatedButton(
          onPressed: () => _launchUrl(props.buttonUrl),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: props.accentColor,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(props.buttonText, style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        if (props.secondaryButtonText.isNotEmpty)
          OutlinedButton(
            onPressed: () => _launchUrl(props.secondaryButtonUrl),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white24, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(props.secondaryButtonText, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
