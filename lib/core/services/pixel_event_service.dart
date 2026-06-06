import 'dart:html' as html;
import 'dart:js' as js;

class PixelEventService {
  static bool get _hasConsent {
    final consent = html.window.localStorage['cookie_consent_status'];
    return consent == 'accepted';
  }

  static void trackPageView() {
    if (!_hasConsent) return;

    try {
      if (js.context['fbq'] != null) {
        js.context.callMethod('fbq', ['track', 'PageView']);
      }
      if (js.context['ttq'] != null) {
        js.context.callMethod('ttq', ['page']);
      }
      if (js.context['snaptr'] != null) {
        js.context.callMethod('snaptr', ['track', 'PAGE_VIEW']);
      }
    } catch (e) {
      print('PixelEventService Error (PageView): $e');
    }
  }

  static void trackLead() {
    if (!_hasConsent) return;

    try {
      if (js.context['fbq'] != null) {
        js.context.callMethod('fbq', ['track', 'Lead']);
      }
      if (js.context['ttq'] != null) {
        js.context.callMethod('ttq', ['track', 'SubmitForm']);
      }
      if (js.context['snaptr'] != null) {
        js.context.callMethod('snaptr', ['track', 'SIGN_UP']);
      }
    } catch (e) {
      print('PixelEventService Error (Lead): $e');
    }
  }

  static void trackPurchase(double value, String currency) {
    if (!_hasConsent) return;

    try {
      if (js.context['fbq'] != null) {
        final params = js.JsObject.jsify({
          'value': value,
          'currency': currency,
        });
        js.context.callMethod('fbq', ['track', 'Purchase', params]);
      }
      if (js.context['ttq'] != null) {
        final params = js.JsObject.jsify({
          'value': value,
          'currency': currency,
        });
        js.context.callMethod('ttq', ['track', 'CompletePayment', params]);
      }
      if (js.context['snaptr'] != null) {
        final params = js.JsObject.jsify({
          'price': value,
          'currency': currency,
        });
        js.context.callMethod('snaptr', ['track', 'PURCHASE', params]);
      }
    } catch (e) {
      print('PixelEventService Error (Purchase): $e');
    }
  }
}
