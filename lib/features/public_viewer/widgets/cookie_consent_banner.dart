import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../../core/services/pixel_bootstrap_service.dart';
import '../../../core/services/pixel_event_service.dart';

class CookieConsentBanner extends StatefulWidget {
  final Map<String, dynamic> designJson;
  final LandingPageTheme? theme;
  const CookieConsentBanner({
    super.key,
    required this.designJson,
    this.theme,
  });

  @override
  State<CookieConsentBanner> createState() => _CookieConsentBannerState();
}

class _CookieConsentBannerState extends State<CookieConsentBanner> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  void _checkConsent() {
    // Check if the user has disabled the banner in the builder settings
    final bool isEnabled = widget.designJson['show_cookie_banner'] ?? true;
    if (!isEnabled) {
      setState(() {
        _isVisible = false;
      });
      // If disabled, we might want to auto-initialize pixels or respect decision.
      // Usually, if disabled, we assume the owner doesn't want the prompt.
      return;
    }

    // Only show if consent has not been decided yet
    final consent = html.window.localStorage['cookie_consent_status'];
    if (consent == null) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  void _setConsent(bool accepted) {
    html.window.localStorage['cookie_consent_status'] = accepted ? 'accepted' : 'rejected';
    setState(() {
      _isVisible = false;
    });

    if (accepted) {
      PixelBootstrapService.initialize(widget.designJson);
      PixelEventService.trackPageView();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return SizedBox.shrink();

    final secondaryColor = widget.theme?.secondary ?? Theme.of(context).colorScheme.secondary;
    final textColor = widget.theme?.textPrimary ?? Theme.of(context).colorScheme.onSurface;
    final subTextColor = widget.theme?.textSecondary ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final bgColor = widget.theme?.background ?? Theme.of(context).colorScheme.surfaceContainerHigh;

    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.translate('cookie_consent_title'),
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                context.translate('cookie_consent_message'),
                style: AppTypography.bodyMedium.copyWith(
                  color: subTextColor,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _setConsent(false),
                    child: Text(
                      context.translate('reject'),
                      style: TextStyle(color: subTextColor),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _setConsent(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(context.translate('accept')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
