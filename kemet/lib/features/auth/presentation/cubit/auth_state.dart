import '../../domain/entities/user.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final User user;
}

class AuthNeedsEmailVerification extends AuthState {
  const AuthNeedsEmailVerification();
}

class AuthEmailVerified extends AuthState {
  const AuthEmailVerified();
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}