import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';

class CustomFeaturesWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const CustomFeaturesWidget({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: Colors.black,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTypography.h2.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
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
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final String itemTitle = item['title'] ?? '';
                  final String itemDesc = item['description'] ?? '';

                  return _buildFeatureCard(context, itemTitle, itemDesc, index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String itemTitle, String itemDesc, int index) {
    // Unique accent icon colors based on index
    final List<Color> accentColors = [
      AppColors.secondary,
      AppColors.primary,
      AppColors.accent,
    ];
    final Color accent = accentColors[index % accentColors.length];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getFeatureIcon(index),
              color: accent,
              size: 24,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            itemTitle,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              itemDesc,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFeatureIcon(int index) {
    switch (index % 4) {
      case 0:
        return Icons.bolt_rounded;
      case 1:
        return Icons.auto_graph_rounded;
      case 2:
        return Icons.security_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}
