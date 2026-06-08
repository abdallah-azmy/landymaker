import 'package:flutter/material.dart';

import '../../../core/services/action_handler_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomWhatsappWidget extends StatelessWidget {
  final String title;
  final String phoneNumber;
  final String message;
  final String buttonText;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomWhatsappWidget({
    super.key,
    required this.title,
    required this.phoneNumber,
    required this.message,
    required this.buttonText,
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
        final bool isMobile = constraints.maxWidth < 600;
        final String cleanNumber = phoneNumber.replaceAll(
          RegExp(r'[^0-9+]'),
          '',
        );
        final bool hasPhone = cleanNumber.isNotEmpty;

        return SectionBackground(
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 40 : 72,
            horizontal: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: secondaryColor,
                    size: isMobile ? 36 : 44,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: AppTypography.h2.copyWith(
                      color: textColor,
                      fontSize: isMobile ? 24 : 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      message,
                      style: AppTypography.bodyMedium.copyWith(
                        color: subTextColor,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: hasPhone
                        ? () async {
                            final encodedMessage = Uri.encodeComponent(message);
                            final actionValue =
                                'https://wa.me/$cleanNumber?text=$encodedMessage';
                            await ActionHandlerService.executeAction(
                              context,
                              actionType: 'link',
                              actionValue: actionValue,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: Text(buttonText, overflow: TextOverflow.ellipsis),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: subTextColor.withValues(
                        alpha: 0.24,
                      ),
                      disabledForegroundColor: Colors.white70,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 22 : 30,
                        vertical: isMobile ? 14 : 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
