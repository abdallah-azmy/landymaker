class EnvUtils {
  /// Helper to clean environment strings that might contain quotes
  static String cleanEnv(String value) {
    if ((value.startsWith('"') && value.endsWith('"')) || 
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  /// Safe way to fetch environment variables
  static String get(String key, {String defaultValue = ''}) {
    return cleanEnv(String.fromEnvironment(key, defaultValue: defaultValue));
  }
}
