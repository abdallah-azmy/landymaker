import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomTrustLogosWidget extends StatelessWidget {
  final String title;
  final List<String> logoUrls;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomTrustLogosWidget({
    super.key,
    required this.title,
    required this.logoUrls,
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

    return SectionBackground(
      bgImageUrl: bgImageUrl,
      bgOverlayColor: bgOverlayColor,
      bgOverlayOpacity: bgOverlayOpacity,
      bgBlur: bgBlur,
      theme: theme,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: subTextColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 48,
                runSpacing: 32,
                children: logoUrls.map((url) {
                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      textColor.withValues(alpha: 0.5),
                      BlendMode.srcIn,
                    ),
                    child: Image.network(
                      url,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.verified_rounded,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
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
