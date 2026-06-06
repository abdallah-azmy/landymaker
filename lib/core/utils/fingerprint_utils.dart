import 'dart:convert';
import 'dart:html' as html;
import 'package:crypto/crypto.dart';

class FingerprintUtils {
  /// Generates a SHA-256 fingerprint hash client-side based on
  /// User-Agent, Screen Resolution, Timezone, and Language.
  static String getFingerprint() {
    try {
      final String userAgent = html.window.navigator.userAgent;
      final String screenRes = '\${html.window.screen?.width}x\${html.window.screen?.height}';
      final String timezone = DateTime.now().timeZoneName;
      final String language = html.window.navigator.language;

      final String rawData = '\$userAgent|\$screenRes|\$timezone|\$language';
      final bytes = utf8.encode(rawData);
      final digest = sha256.convert(bytes);

      return digest.toString();
    } catch (e) {
      // Fallback if anything fails
      return 'unknown_fingerprint_\${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}
