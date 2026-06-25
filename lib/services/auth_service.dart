import 'supabase_service.dart';

class AuthService {
  final SupabaseService _supabase;

  AuthService(this._supabase);

  String? get currentUserId => _supabase.currentUserId;
  String? get currentUserEmail => _supabase.currentUserEmail;
  String get currentUserRole => _supabase.currentUserRole;
  String? get currentUserPhotoUrl => _supabase.currentUserPhotoUrl;
  bool get isAuthenticated => _supabase.isAuthenticated;

  void addListener(void Function() listener) {
    _supabase.addListener(listener);
  }

  void removeListener(void Function() listener) {
    _supabase.removeListener(listener);
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) {
    return _supabase.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  Future<bool> login({required String email, required String password}) {
    return _supabase.login(email: email, password: password);
  }

  Future<void> logout() {
    return _supabase.logout();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _supabase.sendPasswordResetEmail(email);
  }

  Future<void> updatePassword(String newPassword) {
    return _supabase.updatePassword(newPassword);
  }

  Future<void> signInWithGoogle({bool selectAccount = false}) {
    return _supabase.signInWithGoogle(selectAccount: selectAccount);
  }
}
