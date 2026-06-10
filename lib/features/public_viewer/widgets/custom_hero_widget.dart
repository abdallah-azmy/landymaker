import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';

import '../../../core/services/action_handler_service.dart';

class CustomHeroWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl;
  final String pageId;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;
  final String? buttonUrl;
  final double? verticalPadding;
  final int variant;

  const CustomHeroWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
    required this.pageId,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
    this.buttonUrl,
    this.verticalPadding,
    this.variant = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final primaryColor = theme?.primary ?? AppColors.primary;
    final secondaryColor = theme?.secondary ?? AppColors.secondary;
    final textColor = theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = theme?.textSecondary ?? AppColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double defaultPadding = theme?.globalBgImageUrl != null ? 40 : (isMobile ? 40 : 80);

        return SectionBackground(
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          verticalPaddingOverride: verticalPadding,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsetsDirectional.symmetric(vertical: defaultPadding, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: _buildVariant(context, constraints, isRtl, isMobile, primaryColor, secondaryColor, textColor, subTextColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVariant(BuildContext context, BoxConstraints constraints, bool isRtl, bool isMobile, Color primary, Color secondary, Color textColor, Color subTextColor) {
    switch (variant) {
      case 1: // Split
        return _buildSplitVariant(context, isRtl, isMobile, primary, secondary, textColor, subTextColor);
      case 2: // Centered
        return _buildCenteredVariant(context, isRtl, isMobile, primary, secondary, textColor, subTextColor);
      case 3: // Glassmorphism / Card
        return _buildGlassVariant(context, isRtl, isMobile, primary, secondary, textColor, subTextColor);
      case 4: // Full Width BG
        return _buildFullWidthBGVariant(context, isRtl, isMobile, primary, secondary, textColor, subTextColor);
      case 5: // Reverse
        return _buildReverseVariant(context, isRtl, isMobile, primary, secondary, textColor, subTextColor);
      case 8: // Minimal
        return _buildTextContent(context, isRtl, CrossAxisAlignment.center, primary, secondary, textColor, subTextColor, isMobile);
      default: // Standard
        return ResponsiveLayout(
          desktop: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: _buildTextContent(context, isRtl, CrossAxisAlignment.start, primary, secondary, textColor, subTextColor, false),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 5,
                child: _buildHeroImage(primary, false),
              ),
            ],
          ),
          mobile: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTextContent(context, isRtl, CrossAxisAlignment.center, primary, secondary, textColor, subTextColor, true),
              const SizedBox(height: 32),
              _buildHeroImage(primary, true),
            ],
          ),
        );
    }
  }

  Widget _buildSplitVariant(BuildContext context, bool isRtl, bool isMobile, Color primary, Color secondary, Color textColor, Color subTextColor) {
    return ResponsiveLayout(
      desktop: Row(
        children: [
          Expanded(child: _buildHeroImage(primary, false)),
          const SizedBox(width: 48),
          Expanded(child: _buildTextContent(context, isRtl, CrossAxisAlignment.start, primary, secondary, textColor, subTextColor, false)),
        ],
      ),
      mobile: Column(
        children: [
          _buildHeroImage(primary, true),
          const SizedBox(height: 32),
          _buildTextContent(context, isRtl, CrossAxisAlignment.center, primary, secondary, textColor, subTextColor, true),
        ],
      ),
    );
  }

  Widget _buildReverseVariant(BuildContext context, bool isRtl, bool isMobile, Color primary, Color secondary, Color textColor, Color subTextColor) {
     return ResponsiveLayout(
      desktop: Row(
        children: [
          Expanded(child: _buildHeroImage(primary, false)),
          const SizedBox(width: 48),
          Expanded(child: _buildTextContent(context, isRtl, CrossAxisAlignment.start, primary, secondary, textColor, subTextColor, false)),
        ],
      ),
      mobile: Column(
        children: [
          _buildHeroImage(primary, true),
          const SizedBox(height: 32),
          _buildTextContent(context, isRtl, CrossAxisAlignment.center, primary, secondary, textColor, subTextColor, true),
        ],
      ),
    );
  }

  Widget _buildCenteredVariant(BuildContext context, bool isRtl, bool isMobile, Color primary, Color secondary, Color textColor, Color subTextColor) {
    return Column(
      children: [
        _buildTextContent(context, isRtl, CrossAxisAlignment.center, primary, secondary, textColor, subTextColor, isMobile),
        const SizedBox(height: 48),
        _buildHeroImage(primary, isMobile),
      ],
    );
  }

  Widget _buildGlassVariant(BuildContext context, bool isRtl, bool isMobile, Color primary, Color secondary, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: _buildCenteredVariant(context, isRtl, isMobile, primary, secondary, textColor, subTextColor),
    );
  }

  Widget _buildFullWidthBGVariant(BuildContext context, bool isRtl, bool isMobile, Color primary, Color secondary, Color textColor, Color subTextColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.3,
          child: _buildHeroImage(primary, isMobile),
        ),
        _buildTextContent(context, isRtl, CrossAxisAlignment.center, primary, secondary, textColor, subTextColor, isMobile),
      ],
    );
  }

  Widget _buildTextContent(BuildContext context, bool isRtl, CrossAxisAlignment alignment, Color primary, Color secondary, Color textColor, Color subTextColor, bool isMobile) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        // Premium accent tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: secondary.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(
            isRtl ? "شريك نجاحك الرقمي" : "Your Digital Partner",
            style: AppTypography.caption.copyWith(
              color: secondary,
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 10 : 12,
              letterSpacing: isRtl ? 0 : 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: AppTypography.h1.copyWith(
            height: 1.1,
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
          textAlign: alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: AppTypography.bodyLarge.copyWith(
            color: subTextColor,
            fontSize: isMobile ? 14 : 18,
            height: 1.5,
          ),
          textAlign: alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            if (buttonUrl != null && buttonUrl!.isNotEmpty) {
              await ActionHandlerService.executeAction(
                context,
                actionType: 'link',
                actionValue: buttonUrl!,
                pageId: pageId,
                buttonText: buttonText,
                blockType: 'hero',
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: secondary,
            foregroundColor: theme?.buttonTextColor ?? Colors.white,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 32, vertical: isMobile ? 14 : 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  buttonText,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isRtl ? Icons.arrow_back : Icons.arrow_forward,
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage(Color primary, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CustomNetworkImage(
        imageUrl: imageUrl,
        borderRadius: BorderRadius.circular(20),
        fit: BoxFit.cover,
        height: isMobile ? 300 : null,
      ),
    );
  }
}
