import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/responsive/responsive_utils.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomContactInfoWidget extends StatelessWidget {
  final String title;
  final String? email;
  final String? phone;
  final String? location;
  final String? phoneIcon;
  final String? emailIcon;
  final String? locationIcon;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomContactInfoWidget({
    super.key,
    required this.title,
    this.email,
    this.phone,
    this.location,
    this.phoneIcon,
    this.emailIcon,
    this.locationIcon,
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
                      final activeItems = [
                        if (phone != null && phone!.isNotEmpty)
                          {'icon': _resolveIcon(phoneIcon, Icons.phone_rounded), 'label': "Phone", 'value': phone!},
                        if (email != null && email!.isNotEmpty)
                          {'icon': _resolveIcon(emailIcon, Icons.email_rounded), 'label': "Email", 'value': email!},
                        if (location != null && location!.isNotEmpty)
                          {'icon': _resolveIcon(locationIcon, Icons.location_on_rounded), 'label': "Address", 'value': location!},
                      ];

                      if (activeItems.isEmpty) return const SizedBox.shrink();

                      final int columnCount = ResponsiveUtils.getContentColumns(
                        constraints.maxWidth,
                        desktop: 3,
                        tablet: 2,
                        mobile: 1,
                      );

                      final List<Widget> rows = [];
                      for (int i = 0; i < activeItems.length; i += columnCount) {
                        final rowItems = activeItems.sublist(i, (i + columnCount > activeItems.length) ? activeItems.length : i + columnCount);
                        rows.add(
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(columnCount, (colIndex) {
                              if (colIndex < rowItems.length) {
                                final item = rowItems[colIndex];
                                final isLastInRow = colIndex == columnCount - 1;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(end: isLastInRow ? 0 : (isMobile ? 16.0 : 24.0)),
                                    child: _buildContactCard(
                                      item['icon'] as IconData,
                                      item['label'] as String,
                                      item['value'] as String,
                                      secondaryColor,
                                      textColor,
                                      subTextColor,
                                    ),
                                  ),
                                );
                              } else {
                                return const Expanded(child: SizedBox.shrink());
                              }
                            }),
                          ),
                        );
                        if (i + columnCount < activeItems.length) {
                          rows.add(SizedBox(height: isMobile ? 16 : 24));
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

  Widget _buildContactCard(IconData icon, String label, String value, Color secondary, Color textColor, Color subTextColor) {
    final cleanValue = value.trim();
    final bool isLtr = cleanValue.contains('@') ||
                      RegExp(r'^\+?[0-9\-\s()]+$').hasMatch(cleanValue) ||
                      cleanValue.startsWith('http') ||
                      cleanValue.contains('www.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: subTextColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: subTextColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: secondary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(label, style: AppTypography.caption.copyWith(color: subTextColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTypography.bodyLarge.copyWith(color: textColor, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              textDirection: isLtr ? TextDirection.ltr : null,
            ),
          ),
        ],
      ),
    );
  }

  IconData _resolveIcon(String? iconName, IconData defaultIcon) {
    if (iconName != null && iconName.isNotEmpty) {
      switch (iconName.toLowerCase()) {
        case 'phone': return Icons.phone_rounded;
        case 'mobile': return Icons.phone_iphone_rounded;
        case 'email': return Icons.email_rounded;
        case 'envelope': return Icons.mail_outline_rounded;
        case 'location': return Icons.location_on_rounded;
        case 'map': return Icons.map_rounded;
        case 'whatsapp': return Icons.chat_rounded; // Assuming chat for WhatsApp if font_awesome isn't used
        case 'chat': return Icons.chat_rounded;
      }
    }
    return defaultIcon;
  }
}
