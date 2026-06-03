import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomAnimatedCounterWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomAnimatedCounterWidget({
    super.key,
    required this.title,
    required this.items,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = theme?.secondary ?? AppColors.secondary;
    final textColor = theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = theme?.textSecondary ?? AppColors.textSecondary;

    return SectionBackground(
      bgImageUrl: bgImageUrl,
      bgOverlayColor: bgOverlayColor,
      bgOverlayOpacity: bgOverlayOpacity,
      bgBlur: bgBlur,
      theme: theme,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  style: AppTypography.h2.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),
              ],
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 32,
                runSpacing: 48,
                children: items.map((item) {
                  return Container(
                    width: 250,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: double.tryParse(item['value'] ?? '0') ?? 0),
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeOutQuart,
                          builder: (context, value, child) {
                            return Text(
                              '${item['prefix'] ?? ''}${value.toInt()}${item['suffix'] ?? ''}',
                              style: AppTypography.h1.copyWith(
                                color: secondaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 48,
                                height: 1.1,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['label'] ?? '',
                          style: AppTypography.bodyLarge.copyWith(
                            color: subTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
