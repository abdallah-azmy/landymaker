import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../services/supabase_service.dart';

class FcmService {
  static bool _isInitialized = false;

  /// Helper to clean environment strings that might contain quotes
  static String _cleanEnv(String value) {
    if ((value.startsWith('"') && value.endsWith('"')) || 
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  /// Initialize Firebase and FCM
  static Future<void> initialize() async {
    if (!kIsWeb) return;

    try {
      final String apiKey = _cleanEnv(const String.fromEnvironment('FIREBASE_API_KEY'));
      
      // Safety Guard: If API Key is missing from environment, don't try to initialize Firebase
      if (apiKey.isEmpty) {
        debugPrint('FCM: FIREBASE_API_KEY is missing from environment. Initialization aborted.');
        return;
      }

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: apiKey,
            authDomain: _cleanEnv(const String.fromEnvironment('FIREBASE_AUTH_DOMAIN')),
            projectId: _cleanEnv(const String.fromEnvironment('FIREBASE_PROJECT_ID')),
            storageBucket: _cleanEnv(const String.fromEnvironment('FIREBASE_STORAGE_BUCKET')),
            messagingSenderId: _cleanEnv(const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID')),
            appId: _cleanEnv(const String.fromEnvironment('FIREBASE_APP_ID')),
            measurementId: _cleanEnv(const String.fromEnvironment('FIREBASE_MEASUREMENT_ID')),
          ),
        );
      }

      _isInitialized = true;
      final messaging = FirebaseMessaging.instance;

      // Request permission
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await saveTokenIfPossible();
      }

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM: Received foreground message: ${message.notification?.title}');
      });

      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) {
        _saveTokenToDatabase(newToken);
      });
      
    } catch (e) {
      debugPrint('FCM Error during initialization: $e');
    }
  }

  /// Attempts to fetch the token and save it to the database if the user is authenticated
  static Future<void> saveTokenIfPossible() async {
    if (!kIsWeb || !_isInitialized) return;
    
    try {
      final vapidKey = _cleanEnv(const String.fromEnvironment('FIREBASE_VAPID_KEY'));
      
      if (vapidKey.isEmpty) {
        debugPrint('FCM: FIREBASE_VAPID_KEY is missing. Token fetch aborted.');
        return;
      }
      
      final token = await FirebaseMessaging.instance.getToken(
        vapidKey: vapidKey,
      );

      if (token != null) {
        await _saveTokenToDatabase(token);
      }
    } catch (e) {
      debugPrint('FCM Error fetching token: $e');
    }
  }

  static Future<void> _saveTokenToDatabase(String token) async {
    final supabase = SupabaseService.instance;
    if (supabase.isAuthenticated) {
      try {
        await supabase.client.from('user_fcm_tokens').upsert({
          'user_id': supabase.currentUserId,
          'fcm_token': token,
          'updated_at': DateTime.now().toIso8601String(),
        });
        debugPrint('FCM: Token successfully synced with Supabase.');
      } catch (e) {
        debugPrint('FCM: Error syncing token with Supabase: $e');
      }
    } else {
      debugPrint('FCM: Token received but user not authenticated. Sync postponed.');
    }
  }
}
