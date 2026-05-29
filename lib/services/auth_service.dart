import 'supabase_service.dart';

class AuthService {
  final SupabaseService _supabase;

  AuthService(this._supabase);

  String? get currentUserId => _supabase.currentUserId;
  String? get currentUserEmail => _supabase.currentUserEmail;
  String get currentUserRole => _supabase.currentUserRole;
  bool get isAuthenticated => _supabase.isAuthenticated;

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String role = 'user',
  }) {
    return _supabase.register(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }

  Future<bool> login({required String email, required String password}) {
    return _supabase.login(email: email, password: password);
  }

  Future<void> logout() {
    return _supabase.logout();
  }
}
