import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class PwaInstallService {
  static bool _initialized = false;

  static bool get canInstall {
    if (!kIsWeb || !_initialized) return false;
    try {
      return js.context['landyPwaIsInstallAvailable'] == true;
    } catch (_) {
      return false;
    }
  }

  static void init() {
    if (!kIsWeb) return;
    _initialized = true;
  }

  static void promptInstall() {
    if (!kIsWeb || !canInstall) return;
    try {
      js.context.callMethod('landyPwaInstall');
    } catch (e) {
      debugPrint('PWA: Error triggering install prompt: $e');
    }
  }
}
