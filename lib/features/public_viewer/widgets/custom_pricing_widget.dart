import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomPricingWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomPricingWidget({
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
              child: Column(
                children: [
                  Text(
                    title,
                    style: AppTypography.h2.copyWith(color: textColor, fontSize: isMobile ? 24 : 32),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 32 : 64),
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
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: isMobile ? 1.1 : 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildPricingCard(item, primaryColor, secondaryColor, textColor, subTextColor, isMobile);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPricingCard(Map<String, dynamic> item, Color primary, Color secondary, Color textColor, Color subTextColor, bool isMobile) {
    final bool isPopular = item['is_popular'] ?? false;
    final String name = item['name'] ?? 'Plan';
    final String price = item['price'] ?? '0.00';
    final List features = item['features'] ?? [];
    final String buttonText = item['button_text'] ?? 'Get Started';

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular ? secondary : subTextColor.withValues(alpha: 0.1),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Most Popular",
                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          Text(name, style: AppTypography.h3.copyWith(color: textColor, fontSize: isMobile ? 18 : 22)),
          const SizedBox(height: 8),
          Text(price, style: AppTypography.h1.copyWith(color: secondary, fontSize: isMobile ? 28 : 36)),
          SizedBox(height: isMobile ? 16 : 24),
          ...features.take(isMobile ? 2 : 5).map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: secondary, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(f.toString(), style: TextStyle(color: subTextColor, fontSize: isMobile ? 12 : 14))),
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
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(buttonText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
            ),
          ),
        ],
      ),
    );
  }
}
