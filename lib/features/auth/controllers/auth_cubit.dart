import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/auth_service.dart';
import '../../dashboard/controllers/active_website_cubit.dart';
import '../../../../injection_container.dart';
import '../../../core/services/fcm_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial()) {
    _authService.addListener(checkAuth);
    checkAuth();
  }

  void checkAuth() {
    if (isClosed) return;
    if (_authService.isAuthenticated) {
      // Trigger token sync if they are already authenticated at startup
      // (permission already granted on first login)
      FcmService.saveTokenIfPossible();
      
      emit(Authenticated(
        userId: _authService.currentUserId!,
        email: _authService.currentUserEmail!,
        role: _authService.currentUserRole,
      ));
    } else {
      if (state is! Unauthenticated) {
        emit(Unauthenticated());
      }
    }
  }

  @override
  Future<void> close() {
    _authService.removeListener(checkAuth);
    return super.close();
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final success = await _authService.login(
        email: email,
        password: password,
      );
      if (success) {
        // Request notification permission and sync FCM token upon login
        await FcmService.requestPermission();

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
  }) async {
    emit(AuthLoading());
    try {
      final success = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (success) {
        // Request notification permission and sync FCM token upon registration
        await FcmService.requestPermission();

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

  Future<void> sendPasswordReset(String email) async {
    emit(AuthLoading());
    try {
      await _authService.sendPasswordResetEmail(email);
      emit(PasswordResetEmailSent("Password reset link sent to your email."));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> resetPassword(String newPassword) async {
    emit(AuthLoading());
    try {
      await _authService.updatePassword(newPassword);
      emit(PasswordResetSuccess("Password updated successfully."));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      // Clear active website selection on logout
      sl<ActiveWebsiteCubit>().clearSelection();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      await _authService.signInWithGoogle();
      // OAuth flow handles the navigation via redirects/listeners
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
