class NumericParser {
  /// Safely parses a dynamic value into a double.
  /// Handles String numbers, string numbers with units (e.g. "18px", "100%"),
  /// integers, and nulls.
  static double? tryParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      final double val = value.toDouble();
      return val.isFinite ? val : null;
    }
    if (value is String) {
      if (value.toLowerCase() == 'infinity' || value == 'double.infinity') {
        return double.infinity;
      }
      // Strip non-numeric characters except decimals and negative sign
      final clean = value.replaceAll(RegExp(r'[^0-9.-]'), '');
      if (clean.isEmpty) return null;
      final val = double.tryParse(clean);
      if (val != null && val.isFinite) return val;
    }
    return null;
  }

  /// Safely parses a dynamic value into a double, with a default fallback.
  static double parseDouble(dynamic value, double fallback) {
    final parsed = tryParseDouble(value);
    if (parsed == null || !parsed.isFinite) return fallback;
    return parsed;
  }

  /// Safely parses a dynamic value into an int.
  static int? tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) {
      final clean = value.replaceAll(RegExp(r'[^0-9-]'), '');
      if (clean.isEmpty) return null;
      return int.tryParse(clean);
    }
    return null;
  }

  /// Safely parses a dynamic value into an int, with a default fallback.
  static int parseInt(dynamic value, int fallback) {
    return tryParseInt(value) ?? fallback;
  }
}
