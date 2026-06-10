import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../../core/widgets/custom_network_image.dart';
import '../../builder/models/landing_page_theme.dart';

import '../../../core/services/action_handler_service.dart';

class CustomHeroSaasWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl;
  final String pageId;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;
  final String? buttonUrl;
  final double? verticalPadding;

  const CustomHeroSaasWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
    required this.pageId,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
    this.buttonUrl,
    this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = theme?.primary ?? AppColors.primary;
    final secondaryColor = theme?.secondary ?? AppColors.secondary;
    final textColor = theme?.textPrimary ?? AppColors.textPrimary;
    final subTextColor = theme?.textSecondary ?? AppColors.textSecondary;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return SectionBackground(
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          verticalPaddingOverride: verticalPadding,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsetsDirectional.only(
            top: isMobile ? 60 : 100,
            bottom: isMobile ? 40 : 60,
            start: 24,
            end: 24,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: secondaryColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  isRtl ? "🔥 تحديث جديد متاح الآن" : "🔥 New Update Available",
                  style: AppTypography.caption.copyWith(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTypography.h1.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: isMobile ? 32 : 56,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  subtitle,
                  style: AppTypography.bodyLarge.copyWith(
                    color: subTextColor,
                    fontSize: isMobile ? 16 : 20,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (buttonUrl != null && buttonUrl!.isNotEmpty) {
                        await ActionHandlerService.executeAction(
                          context,
                          actionType: 'link',
                          actionValue: buttonUrl!,
                          pageId: pageId,
                          buttonText: buttonText,
                          blockType: 'hero_saas',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: theme?.buttonTextColor ?? Colors.white,
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: isMobile ? 24 : 32,
                        vertical: isMobile ? 16 : 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      buttonText,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
