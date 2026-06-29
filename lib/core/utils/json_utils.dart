import 'dart:convert';
import 'dart:isolate';

Map<String, dynamic> _decodeDesignString(String json) {
  return Map<String, dynamic>.from(jsonDecode(json));
}

Future<Map<String, dynamic>> parseJsonDesign(dynamic rawDesign) async {
  if (rawDesign is String) {
    return Isolate.run(() => _decodeDesignString(rawDesign));
  } else if (rawDesign is Map) {
    return Map<String, dynamic>.from(rawDesign as Map);
  }
  return {'blocks': []};
}
