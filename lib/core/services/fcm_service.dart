import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../services/supabase_service.dart';
import '../utils/env_utils.dart';

class FcmService {
  static bool _isInitialized = false;

  /// Initialize Firebase and FCM
  static Future<void> initialize() async {
    if (!kIsWeb) return;

    try {
      final String apiKey = EnvUtils.get('FIREBASE_API_KEY');
      
      // Safety Guard: If API Key is missing from environment, don't try to initialize Firebase
      if (apiKey.isEmpty) {
        debugPrint('FCM: FIREBASE_API_KEY is missing from environment. Initialization aborted.');
        return;
      }

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: apiKey,
            authDomain: EnvUtils.get('FIREBASE_AUTH_DOMAIN'),
            projectId: EnvUtils.get('FIREBASE_PROJECT_ID'),
            storageBucket: EnvUtils.get('FIREBASE_STORAGE_BUCKET'),
            messagingSenderId: EnvUtils.get('FIREBASE_MESSAGING_SENDER_ID'),
            appId: EnvUtils.get('FIREBASE_APP_ID'),
            measurementId: EnvUtils.get('FIREBASE_MEASUREMENT_ID'),
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
      final vapidKey = EnvUtils.get('FIREBASE_VAPID_KEY');
      
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
