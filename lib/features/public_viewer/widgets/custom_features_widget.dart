import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomFeaturesWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String layoutStyle; // 'grid' or 'bento'
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomFeaturesWidget({
    super.key,
    required this.title,
    required this.items,
    this.layoutStyle = 'grid',
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = theme?.background ?? Colors.black;
    final primaryColor = theme?.primary ?? AppColors.primary;
    final secondaryColor = theme?.secondary ?? AppColors.secondary;
    final textColor = theme?.textPrimary ?? Colors.white;
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTypography.h2.copyWith(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: isMobile ? 32 : 64),
                  if (layoutStyle == 'bento' && !isMobile)
                    _buildBentoGrid(context, items, primaryColor, secondaryColor, textColor, subTextColor, bgColor)
                  else
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
                        crossAxisSpacing: isMobile ? 16 : 24,
                        mainAxisSpacing: isMobile ? 16 : 24,
                        childAspectRatio: isMobile ? 1.8 : 1.3,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final String itemTitle = item['title'] ?? '';
                        final String itemDesc = item['description'] ?? '';

                        return _buildFeatureCard(context, itemTitle, itemDesc, index, primaryColor, secondaryColor, textColor, subTextColor, bgColor, isMobile);
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

  Widget _buildBentoGrid(BuildContext context, List<Map<String, dynamic>> items, Color primary, Color secondary, Color textColor, Color subTextColor, Color bgColor) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Bento grid logic: 2 rows, varied column spans
    // Row 1: Item 0 (flex 3), Item 1 (flex 2)
    // Row 2: Item 2 (flex 2), Item 3 (flex 3)
    // Extra items: standard grid
    
    final List<Widget> rows = [];
    
    if (items.length >= 2) {
      rows.add(
        Row(
          children: [
            Expanded(flex: 3, child: _buildFeatureCard(context, items[0]['title'] ?? '', items[0]['description'] ?? '', 0, primary, secondary, textColor, subTextColor, bgColor, false, isBento: true)),
            const SizedBox(width: 24),
            Expanded(flex: 2, child: _buildFeatureCard(context, items[1]['title'] ?? '', items[1]['description'] ?? '', 1, primary, secondary, textColor, subTextColor, bgColor, false, isBento: true)),
          ],
        )
      );
    }
    
    if (items.length >= 4) {
      rows.add(const SizedBox(height: 24));
      rows.add(
        Row(
          children: [
            Expanded(flex: 2, child: _buildFeatureCard(context, items[2]['title'] ?? '', items[2]['description'] ?? '', 2, primary, secondary, textColor, subTextColor, bgColor, false, isBento: true)),
            const SizedBox(width: 24),
            Expanded(flex: 3, child: _buildFeatureCard(context, items[3]['title'] ?? '', items[3]['description'] ?? '', 3, primary, secondary, textColor, subTextColor, bgColor, false, isBento: true)),
          ],
        )
      );
    }

    // Remaining items
    if (items.length > 4) {
      final remaining = items.sublist(4);
      rows.add(const SizedBox(height: 24));
      rows.add(
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: remaining.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) {
            final item = remaining[index];
            return _buildFeatureCard(context, item['title'] ?? '', item['description'] ?? '', index + 4, primary, secondary, textColor, subTextColor, bgColor, false);
          },
        )
      );
    } else if (items.length == 3) {
       rows.add(const SizedBox(height: 24));
       rows.add(_buildFeatureCard(context, items[2]['title'] ?? '', items[2]['description'] ?? '', 2, primary, secondary, textColor, subTextColor, bgColor, false));
    } else if (items.length == 1) {
       rows.add(_buildFeatureCard(context, items[0]['title'] ?? '', items[0]['description'] ?? '', 0, primary, secondary, textColor, subTextColor, bgColor, false));
    }

    return Column(children: rows);
  }

  Widget _buildFeatureCard(BuildContext context, String itemTitle, String itemDesc, int index, Color primary, Color secondary, Color textColor, Color subTextColor, Color bgColor, bool isMobile, {bool isBento = false}) {
    final Color accent = index % 2 == 0 ? secondary : primary;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
        border: Border.all(
          color: subTextColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: isBento ? [
          BoxShadow(
            color: accent.withValues(alpha: 0.03),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getFeatureIcon(index),
              color: accent,
              size: isMobile ? 20 : 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            itemTitle,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 15 : 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            itemDesc,
            style: AppTypography.bodyMedium.copyWith(
              color: subTextColor,
              height: 1.3,
              fontSize: isMobile ? 12 : 14,
            ),
            maxLines: isMobile ? 2 : (isBento ? 4 : 3),
            overflow: TextOverflow.ellipsis,
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
