class LocalizedTextParser {
  /// Extracts the appropriate localized string from a dynamic value.
  /// If [value] is a String (legacy), it returns it.
  /// If [value] is a Map (bilingual), it tries to find [lang], fallback to 'en', then 'ar', then first available.
  static String extractText(dynamic value, String lang) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      if (value.containsKey(lang) && value[lang] != null && value[lang].toString().isNotEmpty) {
        return value[lang].toString();
      }
      if (value.containsKey('en') && value['en'] != null && value['en'].toString().isNotEmpty) {
        return value['en'].toString();
      }
      if (value.containsKey('ar') && value['ar'] != null && value['ar'].toString().isNotEmpty) {
        return value['ar'].toString();
      }
      if (value.isNotEmpty) {
        return value.values.first.toString();
      }
    }
    return '';
  }
}
