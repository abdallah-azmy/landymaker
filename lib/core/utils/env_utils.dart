class EnvUtils {
  /// Helper to clean environment strings that might contain quotes
  static String cleanEnv(String value) {
    if ((value.startsWith('"') && value.endsWith('"')) || 
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  /// Safe getters for all environment variables used in the project.
  /// Note: String.fromEnvironment MUST be used with 'const' and a string literal.
  
  static String get supabaseUrl => cleanEnv(const String.fromEnvironment('SUPABASE_URL'));
  static String get supabaseAnonKey => cleanEnv(const String.fromEnvironment('SUPABASE_ANON_KEY'));
  static String get imgbbApiKey => cleanEnv(const String.fromEnvironment('IMGBB_API_KEY'));
  static String get pixabayApiKey => cleanEnv(const String.fromEnvironment('PIXABAY_API_KEY'));
  static String get turnstileSiteKey => cleanEnv(const String.fromEnvironment('TURNSTILE_SITE_KEY'));
  
  // Firebase
  static String get firebaseApiKey => cleanEnv(const String.fromEnvironment('FIREBASE_API_KEY'));
  static String get firebaseAuthDomain => cleanEnv(const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'));
  static String get firebaseProjectId => cleanEnv(const String.fromEnvironment('FIREBASE_PROJECT_ID'));
  static String get firebaseStorageBucket => cleanEnv(const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'));
  static String get firebaseMessagingSenderId => cleanEnv(const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'));
  static String get firebaseAppId => cleanEnv(const String.fromEnvironment('FIREBASE_APP_ID'));
  static String get firebaseMeasurementId => cleanEnv(const String.fromEnvironment('FIREBASE_MEASUREMENT_ID'));
  static String get firebaseVapidKey => cleanEnv(const String.fromEnvironment('FIREBASE_VAPID_KEY'));
}
