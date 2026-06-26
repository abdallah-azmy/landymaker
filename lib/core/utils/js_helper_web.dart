import 'dart:convert';
import 'dart:js' as js;

void callJs(String functionName) {
  js.context.callMethod(functionName);
}

void callJsWithArg(String functionName, String arg) {
  js.context.callMethod(functionName, [arg]);
}

/// Reads a JSON-stringified JS array variable (e.g., from window._varName).
/// Returns null if the variable doesn't exist or isn't valid JSON.
List<Map<String, dynamic>>? readJsArray(String varName) {
  final val = js.context[varName];
  if (val is String) {
    try {
      final decoded = jsonDecode(val);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
  }
  return null;
}
