import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomServiceStepsWidget extends StatelessWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;

  const CustomServiceStepsWidget({
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
                    const SizedBox(height: 64),
                  ],
                  if (isMobile)
                    _buildVerticalTimeline(items, accentColor, textColor, subTextColor)
                  else
                    _buildHorizontalTimeline(items, accentColor, textColor, subTextColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalTimeline(List items, Color accent, Color textColor, Color subTextColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isLast = index == items.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index != 0) Expanded(child: Divider(color: accent.withValues(alpha: 0.3), thickness: 2)),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                  if (!isLast) Expanded(child: Divider(color: accent.withValues(alpha: 0.3), thickness: 2)),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                item['title'] ?? '',
                style: AppTypography.h3.copyWith(color: textColor, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  item['description'] ?? '',
                  style: AppTypography.bodyMedium.copyWith(color: subTextColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildVerticalTimeline(List items, Color accent, Color textColor, Color subTextColor) {
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isLast = index == items.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 100,
                    color: accent.withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? '',
                      style: AppTypography.h3.copyWith(color: textColor, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['description'] ?? '',
                      style: AppTypography.bodyMedium.copyWith(color: subTextColor),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
