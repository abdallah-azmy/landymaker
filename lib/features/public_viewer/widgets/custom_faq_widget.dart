import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomFaqWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final LandingPageTheme? theme;

  const CustomFaqWidget({
    super.key,
    required this.title,
    required this.items,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = theme?.background ?? AppColors.background;
    final secondaryColor = theme?.secondary ?? AppColors.secondary;
    final textColor = theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = theme?.textSecondary ?? AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: bgColor,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Text(
                title,
                style: AppTypography.h2.copyWith(color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ...items.map((item) => _buildFaqItem(item, secondaryColor, textColor, subTextColor)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> item, Color secondary, Color textColor, Color subTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: subTextColor.withValues(alpha: 0.1)),
      ),
      child: ExpansionTile(
        title: Text(
          item['question'] ?? 'Question',
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: textColor),
        ),
        iconColor: secondary,
        collapsedIconColor: subTextColor,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              item['answer'] ?? 'Answer goes here.',
              style: AppTypography.bodyMedium.copyWith(color: subTextColor, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
