import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  static String calculateHash(Uint8List bytes) {
    return sha256.convert(bytes).toString();
  }
}
