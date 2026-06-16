import 'package:flutter/material.dart';
import '../../../core/services/action_handler_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_background.dart';
import '../../builder/models/landing_page_theme.dart';

/// ==========================================
/// 1. FACTORY WIDGET
/// ==========================================
class CustomWhatsappWidget extends StatelessWidget {
  final String title;
  final String phoneNumber;
  final String message;
  final String buttonText;
  final String pageId;
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
    required this.pageId,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.bgBlur,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = theme?.secondary ?? AppColors.secondary;
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final hasPhone = cleanNumber.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        final props = _WhatsappProps(
          title: title,
          message: message,
          buttonText: buttonText,
          cleanNumber: cleanNumber,
          hasPhone: hasPhone,
          pageId: pageId,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          theme: theme,
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          bgBlur: bgBlur,
        );

        return isMobile
            ? _MobileWhatsappLayout(props: props)
            : _DesktopWhatsappLayout(props: props);
      },
    );
  }
}

/// ==========================================
/// 2. DATA PROPS CLASS
/// ==========================================
class _WhatsappProps {
  final String title;
  final String message;
  final String buttonText;
  final String cleanNumber;
  final bool hasPhone;
  final String pageId;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final double? bgBlur;

  const _WhatsappProps({
    required this.title,
    required this.message,
    required this.buttonText,
    required this.cleanNumber,
    required this.hasPhone,
    required this.pageId,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
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

/// Desktop version of the WhatsApp layout.
class _DesktopWhatsappLayout extends StatelessWidget {
  final _WhatsappProps props;
  const _DesktopWhatsappLayout({required this.props});

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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, color: props.secondaryColor, size: 44),
              SizedBox(height: 16),
              Text(props.title, style: AppTypography.h2.copyWith(color: props.textColor, fontSize: 32), textAlign: TextAlign.center),
              if (props.message.isNotEmpty) ...[
                SizedBox(height: 10),
                Text(props.message, style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, height: 1.6), textAlign: TextAlign.center),
              ],
              SizedBox(height: 24),
              _WhatsappButton(props: props),
            ],
          ),
        ),
      ),
    );
  }
}

/// ==========================================
/// 4. MOBILE LAYOUT
/// ==========================================

/// Mobile version of the WhatsApp layout.
class _MobileWhatsappLayout extends StatelessWidget {
  final _WhatsappProps props;
  const _MobileWhatsappLayout({required this.props});

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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, color: props.secondaryColor, size: 36),
              SizedBox(height: 16),
              Text(props.title, style: AppTypography.h2.copyWith(color: props.textColor, fontSize: 24), textAlign: TextAlign.center),
              if (props.message.isNotEmpty) ...[
                SizedBox(height: 10),
                Text(props.message, style: AppTypography.bodyMedium.copyWith(color: props.subTextColor, height: 1.6), textAlign: TextAlign.center),
              ],
              SizedBox(height: 24),
              _WhatsappButton(props: props),
            ],
          ),
        ),
      ),
    );
  }
}

/// ==========================================
/// 5. SHARED SUB-WIDGETS
/// ==========================================

/// Shared WhatsApp Action Button.
class _WhatsappButton extends StatelessWidget {
  final _WhatsappProps props;
  const _WhatsappButton({required this.props});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: props.hasPhone
          ? () async {
              final encodedMessage = Uri.encodeComponent(props.message);
              final actionValue = 'https://wa.me/${props.cleanNumber}?text=$encodedMessage';
              await ActionHandlerService.executeAction(
                context,
                actionType: 'link',
                actionValue: actionValue,
                pageId: props.pageId,
                buttonText: props.buttonText,
                blockType: 'whatsapp',
              );
            }
          : null,
      icon: Icon(Icons.send_rounded, size: 18),
      label: Text(props.buttonText, overflow: TextOverflow.ellipsis),
      style: ElevatedButton.styleFrom(
        backgroundColor: props.secondaryColor,
        foregroundColor: props.theme?.buttonTextColor ?? Colors.white,
        disabledBackgroundColor: props.subTextColor.withValues(alpha: 0.24),
        disabledForegroundColor: Colors.white70,
        padding: EdgeInsets.symmetric(horizontal: props.isMobile ? 22 : 30, vertical: props.isMobile ? 14 : 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
