import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomTestimonialsWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomTestimonialsWidget({
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
        final bool isMobile = constraints.maxWidth < 768;
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
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  Text(
                    title,
                    style: AppTypography.h2.copyWith(color: textColor, fontSize: isMobile ? 24 : 32),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 32 : 64),
                  Builder(
                    builder: (context) {
                      if (items.isEmpty) return const SizedBox.shrink();

                      final int columnCount = ResponsiveUtils.getContentColumns(
                        constraints.maxWidth,
                        desktop: 3,
                        tablet: 2,
                        mobile: 1,
                      );

                      final List<List<Map<String, dynamic>>> columns = List.generate(columnCount, (_) => []);
                      for (int i = 0; i < items.length; i++) {
                        columns[i % columnCount].add(items[i]);
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(columnCount, (colIndex) {
                          final isLastColumn = colIndex == columnCount - 1;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(end: isLastColumn ? 0 : 20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: columns[colIndex].asMap().entries.map((entry) {
                                  final isLastItem = entry.key == columns[colIndex].length - 1;
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: isLastItem ? 0 : 20.0),
                                    child: _buildTestimonialCard(entry.value, secondaryColor, textColor, subTextColor, isMobile),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }),
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

  Widget _buildTestimonialCard(Map<String, dynamic> item, Color secondary, Color textColor, Color subTextColor, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: subTextColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) => Icon(Icons.star_rounded, color: secondary, size: isMobile ? 14 : 16)),
          ),
          const SizedBox(height: 12),
          Text(
            item['quote'] ?? 'Testimonial quote goes here.',
            style: AppTypography.bodyMedium.copyWith(color: subTextColor, fontStyle: FontStyle.italic, fontSize: isMobile ? 12 : 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: isMobile ? 32 : 40,
                  height: isMobile ? 32 : 40,
                  decoration: BoxDecoration(
                    color: secondary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: item['image_url'] != null && (item['image_url'] as String).isNotEmpty
                    ? CustomNetworkImage(
                        imageUrl: item['image_url'],
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Text(
                          (item['author'] ?? 'A')[0].toUpperCase(),
                          style: TextStyle(color: secondary, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14),
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['author'] ?? 'Author Name', 
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: textColor, fontSize: isMobile ? 13 : 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item['role'] ?? 'Position', 
                      style: AppTypography.caption.copyWith(color: subTextColor, fontSize: isMobile ? 10 : 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
