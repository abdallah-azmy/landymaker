sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String userId;
  final String email;
  final String role;

  Authenticated({
    required this.userId,
    required this.email,
    required this.role,
  });
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

class RegistrationSuccess extends AuthState {
  final String message;

  RegistrationSuccess(this.message);
}

class PasswordResetEmailSent extends AuthState {
  final String message;

  PasswordResetEmailSent(this.message);
}

class PasswordResetSuccess extends AuthState {
  final String message;

  PasswordResetSuccess(this.message);
}
