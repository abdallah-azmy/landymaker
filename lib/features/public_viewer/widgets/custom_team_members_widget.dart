import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomTeamMembersWidget extends StatelessWidget {
  final Map<String, dynamic> block;
  final LandingPageTheme? theme;

  const CustomTeamMembersWidget({
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
        final bool isMobile = constraints.maxWidth < 768;

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
                  Builder(
                    builder: (context) {
                      if (items.isEmpty) return const SizedBox.shrink();

                      final int columnCount = ResponsiveUtils.getContentColumns(
                        constraints.maxWidth,
                        desktop: items.length >= 3 ? 3 : items.length,
                        tablet: 2,
                        mobile: 1,
                      );

                      final List<Widget> rows = [];
                      for (int i = 0; i < items.length; i += columnCount) {
                        final rowItems = items.sublist(i, (i + columnCount > items.length) ? items.length : i + columnCount);
                        rows.add(
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(columnCount, (colIndex) {
                              if (colIndex < rowItems.length) {
                                final item = rowItems[colIndex];
                                final isLastInRow = colIndex == columnCount - 1;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(end: isLastInRow ? 0 : 32.0),
                                    child: _buildMemberCard(item, accentColor, textColor, subTextColor),
                                  ),
                                );
                              } else {
                                return const Expanded(child: SizedBox.shrink());
                              }
                            }),
                          ),
                        );
                        if (i + columnCount < items.length) {
                          rows.add(const SizedBox(height: 32));
                        }
                      }
                      return Column(children: rows);
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

  Widget _buildMemberCard(Map<String, dynamic> item, Color accent, Color textColor, Color subTextColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CustomNetworkImage(
              imageUrl: item['image_url'] ?? '',
              borderRadius: BorderRadius.circular(20),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          item['name'] ?? '',
          style: AppTypography.h3.copyWith(color: textColor, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          item['role'] ?? '',
          style: AppTypography.bodyMedium.copyWith(color: accent, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (item['bio'] != null && (item['bio'] as String).isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            item['bio'],
            style: AppTypography.caption.copyWith(color: subTextColor),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        _buildSocialLinks(item['socials'], accent),
      ],
    );
  }

  Widget _buildSocialLinks(dynamic socials, Color accent) {
    if (socials == null || socials is! List) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: socials.map<Widget>((s) {
        return IconButton(
          icon: Icon(_getSocialIcon(s['platform']), size: 18),
          color: accent.withValues(alpha: 0.7),
          onPressed: () => _launchUrl(s['url']),
        );
      }).toList(),
    );
  }

  IconData _getSocialIcon(String? platform) {
    switch (platform?.toLowerCase()) {
      case 'twitter':
      case 'x': return Icons.close; // X icon fallback or FontAwesome if available
      case 'linkedin': return Icons.link;
      case 'instagram': return Icons.camera_alt_rounded;
      case 'facebook': return Icons.facebook;
      default: return Icons.language;
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri);
  }
}
