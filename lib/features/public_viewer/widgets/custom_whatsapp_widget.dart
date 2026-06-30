import 'package:flutter/material.dart';
import '../../../core/services/action_handler_service.dart';
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
  final String? backgroundColorHex;
  final double? verticalPadding;
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
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final textColor = theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final hasPhone = cleanNumber.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double paddingValue = verticalPadding ?? (isMobile ? 40 : 80);

        final props = _WhatsappProps(
          title: title,
          phoneNumber: phoneNumber,
          message: message,
          buttonText: buttonText,
          pageId: pageId,
          secondaryColor: secondaryColor,
          textColor: textColor,
          subTextColor: subTextColor,
          isMobile: isMobile,
          hasPhone: hasPhone,
          cleanNumber: cleanNumber,
          theme: theme,
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          backgroundColorHex: backgroundColorHex,
          verticalPadding: verticalPadding,
          bgBlur: bgBlur,
        );

        return SectionBackground(
          bgImageUrl: bgImageUrl,
          bgOverlayColor: bgOverlayColor,
          bgOverlayOpacity: bgOverlayOpacity,
          backgroundColorHex: backgroundColorHex,
          verticalPaddingOverride: verticalPadding,
          bgBlur: bgBlur,
          theme: theme,
          padding: EdgeInsetsDirectional.symmetric(vertical: paddingValue, horizontal: 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: isMobile ? _MobileWhatsappLayout(props: props) : _DesktopWhatsappLayout(props: props),
            ),
          ),
        );
      },
    );
  }
}

/// ==========================================
/// 2. DATA PROPS CLASS
/// ==========================================
class _WhatsappProps {
  final String title;
  final String phoneNumber;
  final String message;
  final String buttonText;
  final String pageId;
  final Color secondaryColor;
  final Color textColor;
  final Color subTextColor;
  final bool isMobile;
  final bool hasPhone;
  final String cleanNumber;
  final LandingPageTheme? theme;
  final String? bgImageUrl;
  final String? bgOverlayColor;
  final double? bgOverlayOpacity;
  final String? backgroundColorHex;
  final double? verticalPadding;
  final double? bgBlur;

  const _WhatsappProps({
    required this.title,
    required this.phoneNumber,
    required this.message,
    required this.buttonText,
    required this.pageId,
    required this.secondaryColor,
    required this.textColor,
    required this.subTextColor,
    required this.isMobile,
    required this.hasPhone,
    required this.cleanNumber,
    this.theme,
    this.bgImageUrl,
    this.bgOverlayColor,
    this.bgOverlayOpacity,
    this.backgroundColorHex,
    this.verticalPadding,
    this.bgBlur,
  });
}

/// ==========================================
/// 3. DESKTOP LAYOUT
/// ==========================================

/// Desktop version of the Whatsapp layout.
class _DesktopWhatsappLayout extends StatelessWidget {
  final _WhatsappProps props;
  const _DesktopWhatsappLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return _WhatsappContent(props: props);
  }
}

/// ==========================================
/// 4. MOBILE LAYOUT
/// ==========================================

/// Mobile version of the Whatsapp layout.
class _MobileWhatsappLayout extends StatelessWidget {
  final _WhatsappProps props;
  const _MobileWhatsappLayout({required this.props});

  @override
  Widget build(BuildContext context) {
    return _WhatsappContent(props: props);
  }
}

/// ==========================================
/// 5. SHARED SUB-WIDGETS
/// ==========================================

/// Shared Whatsapp Content.
class _WhatsappContent extends StatelessWidget {
  final _WhatsappProps props;
  const _WhatsappContent({required this.props});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(props.title, style: AppTypography.h2.copyWith(fontSize: props.isMobile ? 24 : 32, color: props.textColor), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 24),
        _WhatsappButton(props: props),
      ],
    );
  }
}

/// Modular Whatsapp Button.
class _WhatsappButton extends StatelessWidget {
  final _WhatsappProps props;
  const _WhatsappButton({required this.props});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: props.hasPhone ? () => ActionHandlerService.openWhatsApp(phoneNumber: props.cleanNumber, message: props.message, pageId: props.pageId, blockType: 'whatsapp') : null,
      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 24),
      label: Text(props.buttonText, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }
}
