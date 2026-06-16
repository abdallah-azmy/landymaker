import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/builder/models/landing_page_theme.dart';
import 'custom_network_image.dart';

class SectionBackground extends StatelessWidget {
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;
  final LandingPageTheme? theme;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  final double? overlayOpacityOverride;

  final double? verticalPaddingOverride;

  const SectionBackground({
    super.key,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.overlayOpacityOverride,
    this.verticalPaddingOverride,
    this.bgBlur,
    this.theme,
    this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasGlobalBg = (theme?.globalBgImageUrl?.isNotEmpty ?? false) || 
                             (theme?.globalBgColorHex?.isNotEmpty ?? false);
                             
    final bgColor = hasGlobalBg ? Colors.transparent : (theme?.background ?? Theme.of(context).colorScheme.surface);
    final primaryColor = theme?.primary ?? AppColors.primary;
    final double blurValue = bgBlur ?? 0.0;
    
    final hasBgImage = bgImageUrl != null && bgImageUrl!.trim().isNotEmpty;
    final double overlayOpacity = overlayOpacityOverride ?? bgOverlayOpacity ?? (hasBgImage ? 0.45 : 1.0);

    // Default padding logic
    EdgeInsetsGeometry finalPadding = padding ?? const EdgeInsets.symmetric(vertical: 60, horizontal: 24);
    if (verticalPaddingOverride != null) {
      finalPadding = EdgeInsets.symmetric(vertical: verticalPaddingOverride!, horizontal: 24);
    }

    // Parse overlay color from hex string
    Color overlayColorVal = Colors.black;
    if (bgOverlayColor != null && bgOverlayColor!.isNotEmpty) {
      try {
        final hexStr = bgOverlayColor!.replaceAll('#', '');
        if (hexStr.length == 6) {
          overlayColorVal = Color(int.parse('FF$hexStr', radix: 16));
        } else if (hexStr.length == 8) {
          overlayColorVal = Color(int.parse(hexStr, radix: 16));
        }
      } catch (_) {
        // Fallback to black
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: hasBgImage ? null : bgColor,
      ),
      child: ClipRRect(
        child: Stack(
          children: [
            // Mesh/Texture effect (Subtle)
            if (!hasBgImage)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.5,
                        colors: [primaryColor, Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
            // Layer 1: Background Image
            if (hasBgImage)
              Positioned.fill(
                child: CustomNetworkImage(
                  imageUrl: bgImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

            // Layer 2: Color Overlay
            if (bgOverlayColor != null && bgOverlayColor!.isNotEmpty)
              Positioned.fill(
                child: Container(
                  color: overlayColorVal.withValues(alpha: overlayOpacity),
                ),
              ),

            // Layer 3: Blur
            if (blurValue > 0)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                  child: SizedBox.shrink(),
                ),
              ),

            // Layer 4: Content
            Padding(
              padding: finalPadding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
