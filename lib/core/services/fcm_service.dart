import 'dart:html' as html;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../services/supabase_service.dart';
import '../utils/env_utils.dart';

class FcmService {
  static bool _isInitialized = false;

  static bool _notificationsEnabled = true;

  static bool get notificationsEnabled => _notificationsEnabled;

  /// Load preference from localStorage
  static void _loadPreference() {
    if (!kIsWeb) return;
    try {
      final val = html.window.localStorage['fcm_notifications_enabled'];
      _notificationsEnabled = val != 'false';
    } catch (_) {
      _notificationsEnabled = true;
    }
  }

  /// Save preference to localStorage
  static void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    if (!kIsWeb) return;
    try {
      html.window.localStorage['fcm_notifications_enabled'] =
          value.toString();
    } catch (_) {}
  }

  static bool get isPermissionGranted {
    if (!kIsWeb || !_isInitialized) return false;
    try {
      return html.window.localStorage['fcm_permission_granted'] == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Initialize Firebase app only — does NOT request permission
  static Future<void> init() async {
    if (!kIsWeb) return;

    try {
      final String apiKey = EnvUtils.firebaseApiKey;

      if (apiKey.isEmpty) {
        debugPrint(
          'FCM: FIREBASE_API_KEY is missing from environment. Initialization aborted.',
        );
        return;
      }

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: apiKey,
            authDomain: EnvUtils.firebaseAuthDomain,
            projectId: EnvUtils.firebaseProjectId,
            storageBucket: EnvUtils.firebaseStorageBucket,
            messagingSenderId: EnvUtils.firebaseMessagingSenderId,
            appId: EnvUtils.firebaseAppId,
            measurementId: EnvUtils.firebaseMeasurementId,
          ),
        );
      }

      _isInitialized = true;
      _loadPreference();

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          'FCM: Received foreground message: ${message.notification?.title}',
        );
      });

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _saveTokenToDatabase(newToken);
      });
    } catch (e) {
      debugPrint('FCM Error during initialization: $e');
    }
  }

  /// Request notification permission and save token if granted
  static Future<bool> requestPermission() async {
    if (!kIsWeb || !_isInitialized) return false;

    if (!_notificationsEnabled) {
      debugPrint('FCM: Notifications disabled by user preference.');
      return false;
    }

    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      if (granted) {
        try {
          html.window.localStorage['fcm_permission_granted'] = 'true';
        } catch (_) {}

        await saveTokenIfPossible();
      }

      return granted;
    } catch (e) {
      debugPrint('FCM Error requesting permission: $e');
      return false;
    }
  }

  /// Attempts to fetch the token and save it to the database if the user is authenticated
  static Future<void> saveTokenIfPossible() async {
    if (!kIsWeb || !_isInitialized) return;

    try {
      final vapidKey = EnvUtils.firebaseVapidKey;

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
      debugPrint(
        'FCM: Token received but user not authenticated. Sync postponed.',
      );
    }
  }
}
