import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomTestimonialsWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final LandingPageTheme? theme;

  const CustomTestimonialsWidget({
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
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                title,
                style: AppTypography.h2.copyWith(color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(
                    context,
                    desktop: 3,
                    tablet: 2,
                    mobile: 1,
                  ),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildTestimonialCard(item, secondaryColor, textColor, subTextColor);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> item, Color secondary, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: subTextColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) => Icon(Icons.star_rounded, color: secondary, size: 16)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              item['quote'] ?? 'Testimonial quote goes here.',
              style: AppTypography.bodyMedium.copyWith(color: subTextColor, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: secondary.withValues(alpha: 0.2),
                child: Text(
                  (item['author'] ?? 'A')[0].toUpperCase(),
                  style: TextStyle(color: secondary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['author'] ?? 'Author Name', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: textColor)),
                  Text(item['role'] ?? 'Position', style: AppTypography.caption.copyWith(color: subTextColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
