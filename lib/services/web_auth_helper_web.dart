import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> signInWithGoogleWeb({
  required SupabaseClient client,
  bool selectAccount = false,
}) async {
  final queryParams = selectAccount ? {'prompt': 'select_account'} : <String, String>{};
  
  final redirectTo = '${html.window.location.origin}/auth_callback.html';
  debugPrint('Starting Web OAuth Popup flow with redirect: $redirectTo');
  
  final res = await client.auth.getOAuthSignInUrl(
    provider: OAuthProvider.google,
    redirectTo: redirectTo,
    queryParams: queryParams.isNotEmpty ? queryParams : null,
  );
  
  final width = 600;
  final height = 700;
  final left = (html.window.screen?.width ?? 0) / 2 - width / 2;
  final top = (html.window.screen?.height ?? 0) / 2 - height / 2;
  
  final popup = html.window.open(
    res.url,
    'Google Sign In',
    'width=$width,height=$height,left=$left,top=$top,status=no,resizable=yes,scrollbars=yes',
  ) as dynamic;
  
  if (popup == null) {
    throw Exception('Popup blocked! Please allow popups for this site.');
  }
  
  final completer = Completer<bool>();
  StreamSubscription? subscription;
  
  subscription = html.window.onMessage.listen((event) async {
    // Security check: only accept messages from our own origin
    if (event.origin != html.window.location.origin) return;
    
    final data = event.data;
    if (data is Map) {
      if (data['type'] == 'supabase_auth_code') {
        final code = data['code'] as String;
        debugPrint('Received code from popup: $code. Exchanging for session...');
        try {
          await client.auth.exchangeCodeForSession(code);
          debugPrint('Session exchanged successfully.');
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        } catch (e) {
          debugPrint('Error exchanging code for session: $e');
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        } finally {
          subscription?.cancel();
        }
      } else if (data['type'] == 'supabase_auth_implicit') {
        final refreshToken = data['refreshToken'] as String;
        debugPrint('Received implicit tokens from popup. Setting session...');
        try {
          await client.auth.setSession(refreshToken);
          debugPrint('Session set successfully.');
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        } catch (e) {
          debugPrint('Error setting implicit session: $e');
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        } finally {
          subscription?.cancel();
        }
      } else if (data['type'] == 'supabase_auth_error') {
        final error = data['error'] as String;
        debugPrint('Received auth error from popup: $error');
        if (!completer.isCompleted) {
          completer.completeError(AuthException(error));
        }
        subscription?.cancel();
      }
    }
  });
  
  // Monitor if the user manually closes the popup without completing login
  Timer.periodic(const Duration(milliseconds: 500), (timer) {
    if (popup.closed == true) {
      timer.cancel();
      // Allow a brief delay for any final message to arrive
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!completer.isCompleted) {
          debugPrint('Popup closed by user without completing auth.');
          subscription?.cancel();
          completer.complete(false); // Completed but returned false (cancelled)
        }
      });
    }
  });
  
  return completer.future;
}
