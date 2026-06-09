import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/block_animation_wrapper.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomStatisticsGridWidget extends StatelessWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;

  const CustomStatisticsGridWidget({
    super.key,
    required this.block,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = theme?.textSecondary ?? AppColors.textSecondary;
    final accentColor = theme?.secondary ?? AppColors.secondary;
    
    final title = block['title'] ?? '';
    final subtitle = block['subtitle'] ?? '';
    final List items = block['items'] ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return SectionBackground(
          theme: theme,
          bgImageUrl: block['bg_image_url'],
          bgOverlayColor: block['bg_overlay_color'],
          bgOverlayOpacity: (block['bg_overlay_opacity'] as num?)?.toDouble(),
          bgBlur: (block['bg_blur'] as num?)?.toDouble(),
          padding: EdgeInsetsDirectional.symmetric(vertical: isMobile ? 40 : 80, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  if (title.isNotEmpty) ...[
                    Text(
                      title,
                      style: AppTypography.h2.copyWith(color: textColor, fontSize: isMobile ? 24 : 32),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (subtitle.isNotEmpty) ...[
                    Text(
                      subtitle,
                      style: AppTypography.bodyLarge.copyWith(color: subTextColor, fontSize: isMobile ? 16 : 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                  ],
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(
                        context,
                        desktop: items.length >= 4 ? 4 : (items.length >= 3 ? 3 : items.length),
                        tablet: 2,
                        mobile: 1,
                        width: constraints.maxWidth,
                      ),
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: isMobile ? 1.5 : 1.1,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return BlockAnimationWrapper(
                        settings: BlockAnimationSettings(
                          type: BlockAnimationType.fadeIn,
                          duration: const Duration(milliseconds: 600),
                          delay: Duration(milliseconds: index * 150),
                        ),
                        child: _buildStatCard(item, accentColor, textColor, subTextColor, isMobile),
                      );
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

  Widget _buildStatCard(Map<String, dynamic> item, Color accent, Color textColor, Color subTextColor, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: textColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item['icon'] != null) ...[
             Icon(_getIconData(item['icon']), color: accent, size: 32),
             const SizedBox(height: 12),
          ],
          Text(
            item['value'] ?? '0',
            style: AppTypography.h1.copyWith(
              color: accent,
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['label'] ?? '',
            style: AppTypography.bodyMedium.copyWith(
              color: subTextColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'people': return Icons.people_rounded;
      case 'star': return Icons.star_rounded;
      case 'check': return Icons.check_circle_rounded;
      case 'trending': return Icons.trending_up_rounded;
      case 'business': return Icons.business_center_rounded;
      case 'thumb_up': return Icons.thumb_up_rounded;
      case 'public': return Icons.public_rounded;
      case 'speed': return Icons.speed_rounded;
      case 'favorite': return Icons.favorite_rounded;
      default: return Icons.bar_chart_rounded;
    }
  }
}
