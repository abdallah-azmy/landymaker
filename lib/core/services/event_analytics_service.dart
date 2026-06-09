import 'package:flutter/foundation.dart';
import '../../services/database_service.dart';
import '../../injection_container.dart';

class EventAnalyticsService {
  static final DatabaseService _db = sl<DatabaseService>();

  /// Generic log method for backward compatibility
  static Future<void> logEvent({
    required String eventName,
    Map<String, dynamic> parameters = const {},
  }) async {
    // Ensuring debugPrint is used correctly
    debugPrint("ANALYTICS EVENT: $eventName | PARAMS: $parameters");
    // If it matches one of our mission events, we can map it
    if (eventName == 'view') {
      final pageId = parameters['page_id'];
      if (pageId != null) await recordView(pageId);
    }
  }

  static Future<void> recordView(String pageId) async {
    await _db.recordPageEvent(landingPageId: pageId, eventType: 'view');
  }

  static Future<void> recordConversion(String pageId, {Map<String, dynamic> metadata = const {}}) async {
    await _db.recordPageEvent(landingPageId: pageId, eventType: 'conversion', metadata: metadata);
  }

  static Future<void> recordCtaClick(String pageId, {required String buttonText, String? targetUrl, String? blockType}) async {
    await _db.recordPageEvent(
      landingPageId: pageId,
      eventType: 'cta_click',
      metadata: {
        'button_text': buttonText,
        'target_url': targetUrl,
        'block_type': blockType,
      },
    );
  }

  static Future<void> recordWhatsAppOpen(String pageId, {required String phoneNumber, String? message, String? blockType}) async {
    await _db.recordPageEvent(
      landingPageId: pageId,
      eventType: 'whatsapp_open',
      metadata: {
        'phone_number': phoneNumber,
        'message': message,
        'block_type': blockType,
      },
    );
  }

  static Future<void> recordFunnelStart(String pageId, {required String formId, String? blockType}) async {
    await _db.recordPageEvent(
      landingPageId: pageId,
      eventType: 'funnel_start',
      metadata: {
        'form_id': formId,
        'block_type': blockType,
      },
    );
  }

  static Future<void> recordFunnelComplete(String pageId, {required String formId, String? blockType}) async {
    await _db.recordPageEvent(
      landingPageId: pageId,
      eventType: 'funnel_complete',
      metadata: {
        'form_id': formId,
        'block_type': blockType,
      },
    );
  }
}
