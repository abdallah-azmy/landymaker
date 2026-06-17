import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/tenant_routing_service.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
class CustomQrWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? qrPayload;
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
    this.qrPayload,
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
    final String liveUrl = subdomain != null ? '$baseUrl/$subdomain' : baseUrl;
    final String finalPayload = (qrPayload != null && qrPayload!.isNotEmpty) ? qrPayload! : liveUrl;

    final secondaryColor = theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        final props = _QrProps(
          title: title,
          subtitle: subtitle,
          finalPayload: finalPayload,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          qrSize: qrSize,
          theme: theme,
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          bgBlur: bgBlur,
        );

        return isMobile
            ? _MobileQrLayout(props: props)
            : _DesktopQrLayout(props: props);
      },
    );
  }
}

/// ==========================================
/// 2. DATA PROPS CLASS
/// ==========================================
class _QrProps {
  final String title;
  final String subtitle;
  final String finalPayload;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final double qrSize;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const _QrProps({
    required this.title,
    required this.subtitle,
    required this.finalPayload,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    required this.qrSize,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });
}

/// ==========================================
/// 3. DESKTOP LAYOUT
/// ==========================================

/// Desktop version of the QR layout.
class _DesktopQrLayout extends StatelessWidget {
  final _QrProps props;
  const _DesktopQrLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      bgBlur: props.bgBlur,
      theme: props.theme,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Text(props.title, style: AppTypography.h2.copyWith(fontSize: 28, color: props.textColor), textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text(props.subtitle, style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, fontSize: 14), textAlign: TextAlign.center),
            SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: props.secondaryColor.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 10))],
              ),
              child: SizedBox(
                width: props.qrSize,
                height: props.qrSize,
                child: PrettyQrView.data(
                  data: props.finalPayload,
                  decoration: const PrettyQrDecoration(shape: PrettyQrSmoothSymbol(color: Colors.black87)),
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              props.finalPayload.replaceFirst('https://', '').replaceFirst('http://', ''),
              style: AppTypography.caption.copyWith(color: props.secondaryColor, fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 12),
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}

/// ==========================================
/// 4. MOBILE LAYOUT
/// ==========================================

/// Mobile version of the QR layout.
class _MobileQrLayout extends StatelessWidget {
  final _QrProps props;
  const _MobileQrLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return SectionBackground(
      bgImageUrl: props.bgImageUrl,
      bgOverlayColor: props.bgOverlayColor,
      bgOverlayOpacity: props.bgOverlayOpacity,
      bgBlur: props.bgBlur,
      theme: props.theme,
      padding: const EdgeInsetsDirectional.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Text(props.title, style: AppTypography.h2.copyWith(fontSize: 24, color: props.textColor), textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text(props.subtitle, style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, fontSize: 12), textAlign: TextAlign.center),
            SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: props.secondaryColor.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 10))],
              ),
              child: SizedBox(
                width: 160,
                height: 160,
                child: PrettyQrView.data(
                  data: props.finalPayload,
                  decoration: const PrettyQrDecoration(shape: PrettyQrSmoothSymbol(color: Colors.black87)),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              props.finalPayload.replaceFirst('https://', '').replaceFirst('http://', ''),
              style: AppTypography.caption.copyWith(color: props.secondaryColor, fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 10),
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}
