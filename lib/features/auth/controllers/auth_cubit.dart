import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/auth_service.dart';
import '../../dashboard/controllers/active_website_cubit.dart';
import '../../../../injection_container.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../services/supabase_service.dart';
import '../../../core/services/fcm_service.dart';
import '../../../../core/logger.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  bool _pendingGoogleConsent = false;
  String? _pendingGoogleEmail;
  String? _pendingGoogleUserId;

  AuthCubit(this._authService) : super(AuthInitial()) {
    _authService.addListener(checkAuth);
    checkAuth();
  }

  Future<void> checkAuth() async {
    if (isClosed) return;
    if (_authService.isAuthenticated) {
      if (_pendingGoogleConsent) {
        _pendingGoogleConsent = false;
        final userId = _authService.currentUserId;
        final isNew = userId != null ? await _isNewGoogleUser(userId) : false;
        if (isNew) {
          _pendingGoogleEmail = _authService.currentUserEmail;
          _pendingGoogleUserId = userId;
          emit(GoogleNewUserRequiresConsent(
            _authService.currentUserEmail ?? '',
          ));
          return;
        }
      }
      // Trigger token sync if they are already authenticated at startup
      // (permission already granted on first login)
      FcmService.saveTokenIfPossible();
      
      emit(Authenticated(
        userId: _authService.currentUserId!,
        email: _authService.currentUserEmail!,
        role: _authService.currentUserRole,
        photoURL: _authService.currentUserPhotoUrl,
      ));
    } else {
      if (state is! Unauthenticated) {
        emit(Unauthenticated());
      }
    }
  }

  Future<bool> _isNewGoogleUser(String userId) async {
    try {
      final response = await sl<SupabaseService>().client
          .from(DbConstants.profilesTable)
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      return response == null;
    } catch (_) {
      return false;
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
          photoURL: _authService.currentUserPhotoUrl,
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
          photoURL: _authService.currentUserPhotoUrl,
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
      await FcmService.deleteToken();
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
      _pendingGoogleConsent = true;
      await _authService.signInWithGoogle();
    } catch (e) {
      _pendingGoogleConsent = false;
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> switchGoogleAccount() async {
    try {
      await _authService.signInWithGoogle(selectAccount: true);
    } catch (e, stack) {
      Logger.error("Failed to switch Google account", e, stack);
    }
  }

  Future<void> confirmGoogleNewUser() async {
    if (_pendingGoogleEmail != null && _pendingGoogleUserId != null) {
      await FcmService.saveTokenIfPossible();
      emit(Authenticated(
        userId: _pendingGoogleUserId!,
        email: _pendingGoogleEmail!,
        role: _authService.currentUserRole,
        photoURL: _authService.currentUserPhotoUrl,
      ));
      _pendingGoogleEmail = null;
      _pendingGoogleUserId = null;
    }
  }

  Future<void> cancelGoogleSignIn() async {
    _pendingGoogleEmail = null;
    _pendingGoogleUserId = null;
    await _authService.logout();
    emit(AuthInitial());
  }
}
