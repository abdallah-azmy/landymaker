import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'event_analytics_service.dart';

class ActionHandlerService {
  /// Handles abstract actions defined by JSON blocks (pricing, heroes, etc)
  static Future<void> executeAction(
    BuildContext context, {
    required String actionType,
    required String actionValue,
    required String pageId,
    String? buttonText,
    String? blockType,
    Map<String, dynamic>? metadata,
  }) async {
    // 1. Record Analytics
    if (actionType == 'link') {
      if (actionValue.contains('wa.me')) {
        // Special case for WhatsApp
        final uri = Uri.tryParse(actionValue);
        final phone = uri?.path.replaceAll('/', '') ?? '';
        final msg = uri?.queryParameters['text'] ?? '';
        await EventAnalyticsService.recordWhatsAppOpen(
          pageId,
          phoneNumber: phone,
          message: msg,
          blockType: blockType,
        );
      } else {
        await EventAnalyticsService.recordCtaClick(
          pageId,
          buttonText: buttonText ?? 'Click',
          targetUrl: actionValue,
          blockType: blockType,
        );
      }
    }

    // 2. Execute Logic
    switch (actionType) {
      case 'link':
        if (actionValue.isNotEmpty) {
          final uri = Uri.tryParse(actionValue);
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
        break;

      case 'checkout':
        debugPrint("TRIGGER CHECKOUT: $actionValue");
        break;

      case 'scroll_to_section':
        debugPrint("SCROLL TO SECTION: $actionValue");
        break;

      case 'open_modal':
        debugPrint("OPEN MODAL: $actionValue");
        break;

      default:
        debugPrint("UNSUPPORTED ACTION TYPE: $actionType");
    }
  }

  static Future<void> openWhatsApp({
    required String phoneNumber,
    required String message,
    required String pageId,
    String? blockType,
  }) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanNumber.isEmpty) return;

    final encodedMessage = Uri.encodeComponent(message);
    final url = 'https://wa.me/$cleanNumber?text=$encodedMessage';

    await EventAnalyticsService.recordWhatsAppOpen(
      pageId,
      phoneNumber: cleanNumber,
      message: message,
      blockType: blockType,
    );

    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
