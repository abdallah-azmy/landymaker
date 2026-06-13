import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomWorkingHoursWidget extends StatelessWidget {
  final Map<String, dynamic> blockData;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomWorkingHoursWidget({
    super.key,
    required this.blockData,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });

  @override
  Widget build(BuildContext context) {
    final title = blockData['title'] ?? 'مواعيد العمل';
    final schedule = blockData['schedule'] as Map<String, dynamic>? ?? {};

    final textColor = theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = theme?.textSecondary ?? AppColors.textSecondary;
    
    // Quick logic to check if open (10 AM to 11 PM)
    final now = DateTime.now();
    final currentHour = now.hour;
    final isOpen = currentHour >= 10 && currentHour < 23;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
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
              padding: EdgeInsets.all(isMobile ? 20 : 32),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.h3.copyWith(
                            color: textColor,
                            fontSize: isMobile ? 20 : 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(isOpen),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...schedule.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: AppTypography.bodyLarge.copyWith(
                              color: subTextColor,
                              fontSize: isMobile ? 15 : 17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: isMobile ? 15 : 17,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isOpen ? AppColors.activeGreen : AppColors.dangerRed).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOpen ? AppColors.activeGreen : AppColors.dangerRed),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: isOpen ? AppColors.activeGreen : AppColors.dangerRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOpen ? "مفتوح الآن" : "مغلق الآن",
            style: AppTypography.caption.copyWith(
              color: isOpen ? AppColors.activeGreen : AppColors.dangerRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
