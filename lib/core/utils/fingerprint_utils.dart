import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

// Use conditional imports to avoid dart:html on non-web platforms
import 'fingerprint_utils_web.dart' if (dart.library.io) 'fingerprint_utils_stub.dart';

class FingerprintUtils {
  /// Generates a SHA-256 fingerprint hash client-side based on
  /// User-Agent, Screen Resolution, Timezone, and Language.
  static String getFingerprint() {
    try {
      final String rawData = getRawFingerprintData();
      final bytes = utf8.encode(rawData);
      final digest = sha256.convert(bytes);

      return digest.toString();
    } catch (e) {
      // Fallback if anything fails
      return 'unknown_fingerprint_\${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}
