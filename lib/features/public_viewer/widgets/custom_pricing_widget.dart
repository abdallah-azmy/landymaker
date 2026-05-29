import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomPricingWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final LandingPageTheme? theme;

  const CustomPricingWidget({
    super.key,
    required this.title,
    required this.items,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = theme?.background ?? AppColors.background;
    final primaryColor = theme?.primary ?? AppColors.primary;
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
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildPricingCard(item, primaryColor, secondaryColor, textColor, subTextColor);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard(Map<String, dynamic> item, Color primary, Color secondary, Color textColor, Color subTextColor) {
    final bool isPopular = item['is_popular'] ?? false;
    final String name = item['name'] ?? 'Plan';
    final String price = item['price'] ?? '0.00';
    final List features = item['features'] ?? [];
    final String buttonText = item['button_text'] ?? 'Get Started';

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: subTextColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular ? secondary : subTextColor.withOpacity(0.1),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Most Popular",
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 16),
          Text(name, style: AppTypography.h3.copyWith(color: textColor)),
          const SizedBox(height: 12),
          Text(price, style: AppTypography.h1.copyWith(color: secondary, fontSize: 36)),
          const SizedBox(height: 32),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: secondary, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(f.toString(), style: TextStyle(color: subTextColor))),
              ],
            ),
          )).toList(),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? secondary : Colors.transparent,
                foregroundColor: isPopular ? Colors.white : secondary,
                side: isPopular ? null : BorderSide(color: secondary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
