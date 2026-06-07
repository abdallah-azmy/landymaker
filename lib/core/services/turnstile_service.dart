import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui;

import 'package:landymaker/core/utils/env_utils.dart';

class TurnstileService {
  static final Map<String, String> _tokens = {};

  /// Registers the HTML view factory for Turnstile
  static void registerViewFactory(
    String viewId,
    Function(String) onTokenReceived,
  ) {
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewIdNum) {
      final container = html.DivElement()
        ..id = 'turnstile-container-\$viewId'
        ..style.width = '100%'
        ..style.height = '100%';

      // Delay execution to ensure the script is loaded and DOM is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (js.context.hasProperty('turnstile')) {
          var siteKey = EnvUtils.turnstileSiteKey;

          js.context['turnstile'].callMethod('render', [
            '#turnstile-container-\$viewId',
            js.JsObject.jsify({
              'sitekey': siteKey,
              'callback': (String token) {
                _tokens[viewId] = token;
                onTokenReceived(token);
              },
              'theme': 'light',
            }),
          ]);
        }
      });

      return container;
    });
  }

  static String? getToken(String viewId) => _tokens[viewId];

  static void reset(String viewId) {
    _tokens.remove(viewId);
    if (js.context.hasProperty('turnstile')) {
      js.context['turnstile'].callMethod('reset', [
        '#turnstile-container-\$viewId',
      ]);
    }
  }
}
