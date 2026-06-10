import 'dart:html' as html;

String getRawFingerprintData() {
  final String userAgent = html.window.navigator.userAgent;
  final String screenRes = '${html.window.screen?.width}x${html.window.screen?.height}';
  final String timezone = DateTime.now().timeZoneName;
  final String language = html.window.navigator.language;

  return '$userAgent|$screenRes|$timezone|$language';
}
