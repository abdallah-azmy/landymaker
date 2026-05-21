import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial()) {
    checkAuth();
  }

  void checkAuth() {
    if (_authService.isAuthenticated) {
      emit(Authenticated(
        userId: _authService.currentUserId!,
        email: _authService.currentUserEmail!,
        role: _authService.currentUserRole,
      ));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final success = await _authService.login(
        email: email,
        password: password,
      );
      if (success) {
        emit(Authenticated(
          userId: _authService.currentUserId!,
          email: _authService.currentUserEmail!,
          role: _authService.currentUserRole,
        ));
      } else {
        emit(AuthFailure("Login failed"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String role = 'user',
  }) async {
    emit(AuthLoading());
    try {
      final success = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      if (success) {
        emit(Authenticated(
          userId: _authService.currentUserId!,
          email: _authService.currentUserEmail!,
          role: _authService.currentUserRole,
        ));
      } else {
        emit(AuthFailure("Registration failed"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
