import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;

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

    // Register the iframe view for Flutter Web
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
        final double verticalPadding = isMobile ? 40 : 80;

        return SectionBackground(
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsetsDirectional.symmetric(
            vertical: verticalPadding,
            horizontal: 24,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: subTextColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: subTextColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h3.copyWith(
                      color: textColor,
                      fontSize: isMobile ? 20 : 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: secondaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          style: AppTypography.bodyMedium.copyWith(
                            color: subTextColor,
                            fontSize: isMobile ? 14 : 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: isMobile ? 250 : 350,
                      width: double.infinity,
                      child: HtmlElementView(viewType: viewId),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
