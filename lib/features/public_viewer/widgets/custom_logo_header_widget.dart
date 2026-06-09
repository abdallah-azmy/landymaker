import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';

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
    MainAxisAlignment mainAxisAlignment;
    CrossAxisAlignment crossAxisAlignment;

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    switch (alignment) {
      case 'left':
        mainAxisAlignment = isRtl ? MainAxisAlignment.end : MainAxisAlignment.start;
        crossAxisAlignment = isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start;
        break;
      case 'right':
        mainAxisAlignment = isRtl ? MainAxisAlignment.start : MainAxisAlignment.end;
        crossAxisAlignment = isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.end;
        break;
      default:
        mainAxisAlignment = MainAxisAlignment.center;
        crossAxisAlignment = CrossAxisAlignment.center;
    }

    final textColor = theme?.textPrimary ?? AppColors.textPrimary;
    final borderColor = textColor.withValues(alpha: 0.1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return SectionBackground(
          theme: theme,
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          bgBlur: bgBlur,
          padding: EdgeInsetsDirectional.symmetric(
            vertical: isMobile ? 12 : 20,
            horizontal: 24,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: mainAxisAlignment,
                  children: [
                    if (logoUrl != null && logoUrl!.isNotEmpty)
                      CustomNetworkImage(
                        imageUrl: logoUrl!,
                        height: isMobile ? (logoHeight * 0.8).clamp(24.0, 60.0) : logoHeight,
                      ),
                    if (logoUrl != null && logoUrl!.isNotEmpty && title.isNotEmpty)
                      const SizedBox(width: 12),
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
