// ignore_for_file: unused_element
part of '../supabase_service.dart';


// ----------------------------------------------------
// AUTHENTICATION OPERATIONS
// ----------------------------------------------------

mixin SupabaseServiceAuth on ChangeNotifier {
  SupabaseClient? get _client;
  set _client(SupabaseClient? val);

  String? get _currentUserId;
  set _currentUserId(String? val);

  String? get _currentUserEmail;
  set _currentUserEmail(String? val);

  String get _currentUserRole;
  set _currentUserRole(String val);

  String get _currentUserTier;
  set _currentUserTier(String val);

  String? get _currentUserPhotoUrl;
  set _currentUserPhotoUrl(String? val);

  Future<void> _fetchUserRole(String userId);
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': 'user'},
      );
      if (response.user != null) {
        _currentUserId = response.user!.id;
        _currentUserEmail = response.user!.email;
        _currentUserRole = 'user';
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Register exception: $e');
      rethrow;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _currentUserId = response.user!.id;
        _currentUserEmail = response.user!.email;
        await _fetchUserRole(response.user!.id);
        notifyListeners();
        return true;
      }
      debugPrint('Login failed: no user returned');
      return false;
    } catch (e) {
      debugPrint('Login exception: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _client!.auth.signOut();
    _currentUserId = null;
    _currentUserEmail = null;
    _currentUserRole = 'user';
    _currentUserPhotoUrl = null;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final redirectTo = '${Uri.base.origin}/reset-password';
      await _client!.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
    } catch (e) {
      debugPrint('Reset password email exception: $e');
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client!.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      debugPrint('Update password exception: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle({bool selectAccount = false}) async {
    try {
      if (kIsWeb) {
        final success = await signInWithGoogleWeb(
          client: _client!,
          selectAccount: selectAccount,
        );
        if (!success) {
          debugPrint('Google Sign In web flow completed without authentication (cancelled).');
        }
      } else {
        final queryParams = selectAccount ? {'prompt': 'select_account'} : null;
        await _client!.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'com.landymaker.app://login-callback',
          queryParams: queryParams,
        );
      }
    } catch (e) {
      debugPrint('Google Sign In exception: $e');
      rethrow;
    }
  }
}

