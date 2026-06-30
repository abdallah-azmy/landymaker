import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

Map<String, dynamic> _decodeDesignString(String json) {
  return Map<String, dynamic>.from(jsonDecode(json));
}

/// Runs a computation in a background isolate on native platforms,
/// or directly on the main thread on the web.
Future<R> runWebSafeIsolate<R>(FutureOr<R> Function() computation) async {
  if (kIsWeb) {
    return computation();
  } else {
    return Isolate.run(computation);
  }
}

Future<Map<String, dynamic>> parseJsonDesign(dynamic rawDesign) async {
  if (rawDesign is String) {
    return runWebSafeIsolate(() => _decodeDesignString(rawDesign));
  } else if (rawDesign is Map) {
    return Map<String, dynamic>.from(rawDesign as Map);
  }
  return {'blocks': []};
}

