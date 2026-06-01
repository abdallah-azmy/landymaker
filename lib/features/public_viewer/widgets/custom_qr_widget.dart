import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/tenant_routing_service.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

class CustomQrWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final double qrSize;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const CustomQrWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.qrSize = 200.0,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });

  @override
  Widget build(BuildContext context) {
    final String? subdomain = TenantRoutingService.getTenantIdentifier();
    final String baseUrl = Uri.base.origin;
    // Construct the live URL based on current routing (landymaker.com/subdomain)
    final String liveUrl = subdomain != null ? '$baseUrl/$subdomain' : baseUrl;

    final bgColor = theme?.background ?? AppColors.background;
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
            child: Column(
              children: [
                Text(
                  title,
                  style: AppTypography.h2.copyWith(fontSize: isMobile ? 24 : 28, color: textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium.copyWith(color: subTextColor, fontSize: isMobile ? 12 : 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 32 : 48),
                
                // Premium QR View
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isMobile ? 20 : 32),
                    boxShadow: [
                      BoxShadow(
                        color: secondaryColor.withValues(alpha: 0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: isMobile ? 160 : qrSize,
                    height: isMobile ? 160 : qrSize,
                    child: PrettyQrView.data(
                      data: liveUrl,
                      decoration: const PrettyQrDecoration(
                        shape: PrettyQrSmoothSymbol(
                          color: Colors.black87, // Fixed dark color for standard scannability
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: isMobile ? 24 : 40),
                Text(
                  liveUrl.replaceFirst('https://', '').replaceFirst('http://', ''),
                  style: AppTypography.caption.copyWith(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    fontSize: isMobile ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
