import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
class CustomLocationMapWidget extends StatelessWidget {
  final String title;
  final String address;
  final String mapIframeUrl;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomLocationMapWidget({
    super.key,
    required this.title,
    required this.address,
    required this.mapIframeUrl,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = theme?.textSecondary ?? AppColors.textSecondary;
    final secondaryColor = theme?.secondary ?? AppColors.secondary;

    final String viewId = 'map-iframe-${mapIframeUrl.hashCode}';
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => web.HTMLIFrameElement()
        ..src = mapIframeUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        final props = _LocationMapProps(
          title: title,
          address: address,
          viewId: viewId,
          textColor: textColor,
          subTextColor: subTextColor,
          secondaryColor: secondaryColor,
          isMobile: isMobile,
          theme: theme,
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          bgBlur: bgBlur,
        );

        return isMobile
            ? _MobileLocationMapLayout(props: props)
            : _DesktopLocationMapLayout(props: props);
      },
    );
  }
}

/// ==========================================
/// 2. DATA PROPS CLASS
/// ==========================================
class _LocationMapProps {
  final String title;
  final String address;
  final String viewId;
  final Color textColor;
  final Color subTextColor;
  final Color secondaryColor;
  final bool isMobile;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const _LocationMapProps({
    required this.title,
    required this.address,
    required this.viewId,
    required this.textColor,
    required this.subTextColor,
    required this.secondaryColor,
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

/// Desktop version of the Location Map layout.
class _DesktopLocationMapLayout extends StatelessWidget {
  final _LocationMapProps props;
  const _DesktopLocationMapLayout({required this.props});

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
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: props.subTextColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: props.subTextColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(props.title, style: AppTypography.h3.copyWith(color: props.textColor, fontSize: 22)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on_rounded, color: props.secondaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(props.address, style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, fontSize: 15))),
                ],
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(height: 350, width: double.infinity, child: HtmlElementView(viewType: props.viewId)),
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

/// Mobile version of the Location Map layout.
class _MobileLocationMapLayout extends StatelessWidget {
  final _LocationMapProps props;
  const _MobileLocationMapLayout({required this.props});

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
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: props.subTextColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: props.subTextColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(props.title, style: AppTypography.h3.copyWith(color: props.textColor, fontSize: 20)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on_rounded, color: props.secondaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(props.address, style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, fontSize: 14))),
                ],
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(height: 250, width: double.infinity, child: HtmlElementView(viewType: props.viewId)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
