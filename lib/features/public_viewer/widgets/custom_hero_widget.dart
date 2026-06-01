import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomHeroWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomHeroWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
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
        final double verticalPadding = isMobile ? 40 : 80;

        return SectionBackground(
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ResponsiveLayout(
                desktop: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildTextContent(context, isRtl, CrossAxisAlignment.start, primaryColor, secondaryColor, textColor, subTextColor, false),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      flex: 5,
                      child: _buildHeroImage(primaryColor, false),
                    ),
                  ],
                ),
                mobile: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTextContent(context, isRtl, CrossAxisAlignment.center, primaryColor, secondaryColor, textColor, subTextColor, true),
                    const SizedBox(height: 32),
                    _buildHeroImage(primaryColor, true),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: secondary,
            foregroundColor: Colors.white,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: isMobile ? 200 : 300,
              color: theme?.textPrimary.withValues(alpha: 0.05) ?? Colors.white10,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            height: 150,
            color: theme?.textPrimary.withValues(alpha: 0.05) ?? Colors.white10,
            child: Icon(Icons.image_not_supported_rounded, color: theme?.textPrimary.withValues(alpha: 0.2) ?? Colors.white24, size: 48),
          ),
        ),
      ),
    );
  }
}
