import '../entities/auth_session.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  String? get currentSessionId;

  Future<User> signInWithEmail(String email, String password);
  Future<User> signUpWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
  );
  Future<User?> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> sendVerificationEmail();
  Future<bool> checkEmailVerified();
  Future<void> signOut();
  Duration getRemainingVerificationCooldown();

  Stream<List<AuthSession>> watchActiveSessions();
  Future<void> clearOtherSessions();
}