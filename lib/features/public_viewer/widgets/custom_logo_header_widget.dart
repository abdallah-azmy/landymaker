import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_background.dart';
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
    TextAlign textAlign;

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    switch (alignment) {
      case 'left':
        mainAxisAlignment = isRtl
            ? MainAxisAlignment.end
            : MainAxisAlignment.start;
        crossAxisAlignment = isRtl
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start;
        textAlign = TextAlign.left;
        break;
      case 'right':
        mainAxisAlignment = isRtl
            ? MainAxisAlignment.start
            : MainAxisAlignment.end;
        crossAxisAlignment = isRtl
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end;
        textAlign = TextAlign.right;
        break;
      default:
        mainAxisAlignment = MainAxisAlignment.center;
        crossAxisAlignment = CrossAxisAlignment.center;
        textAlign = TextAlign.center;
    }

    final textColor = theme?.textPrimary ?? AppColors.textPrimary;
    final borderColor = textColor.withValues(alpha: 0.1);

    return SectionBackground(
      theme: theme,
      bgImageUrl: bgImageUrl,
      bgOverlayColor: bgOverlayColor,
      bgOverlayOpacity: bgOverlayOpacity,
      bgBlur: bgBlur,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Row(
              mainAxisAlignment: mainAxisAlignment,
              children: [
                if (logoUrl != null && logoUrl!.isNotEmpty)
                  Image.network(
                    logoUrl!,
                    height: logoHeight,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  ),
                if (logoUrl != null && logoUrl!.isNotEmpty && title.isNotEmpty)
                  const SizedBox(width: 12),
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
