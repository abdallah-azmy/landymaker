import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/tenant_routing_service.dart';

class CustomQrWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final double qrSize;

  const CustomQrWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.qrSize = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    final String? subdomain = TenantRoutingService.getTenantIdentifier();
    final String baseUrl = Uri.base.origin;
    // Construct the live URL based on current routing (mylandy.com/subdomain)
    final String liveUrl = subdomain != null ? '$baseUrl/$subdomain' : baseUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withValues(alpha: 0.2),
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.05)),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              title,
              style: AppTypography.h2.copyWith(fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Premium QR View
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: PrettyQrView.data(
                data: liveUrl,
                decoration: PrettyQrDecoration(
                  shape: PrettyQrSmoothSymbol(
                    color: AppColors.background, // QR pixels in dark background color
                    roundPoints: true,
                  ),
                  image: const PrettyQrDecorationImage(
                    image: AssetImage('assets/logo.png'), // Placeholder or fallback
                    position: PrettyQrDecorationImagePosition.embedded,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            Text(
              liveUrl.replaceFirst('https://', '').replaceFirst('http://', ''),
              style: AppTypography.caption.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
