import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomFaqWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomFaqWidget({
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
          padding: EdgeInsetsDirectional.symmetric(vertical: verticalPadding, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  Text(
                    title,
                    style: AppTypography.h2.copyWith(color: textColor, fontSize: isMobile ? 24 : 32),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 24 : 48),
                  ...items.map((item) => _buildFaqItem(item, secondaryColor, textColor, subTextColor, isMobile)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> item, Color secondary, Color textColor, Color subTextColor, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: subTextColor.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 4 : 8),
        title: Text(
          item['question'] ?? 'Question',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold, 
            color: textColor,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        iconColor: secondary,
        collapsedIconColor: subTextColor,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isMobile ? 12 : 16, 0, isMobile ? 12 : 16, isMobile ? 12 : 16),
            child: Text(
              item['answer'] ?? 'Answer goes here.',
              style: AppTypography.bodyMedium.copyWith(color: subTextColor, height: 1.4, fontSize: isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }
}
