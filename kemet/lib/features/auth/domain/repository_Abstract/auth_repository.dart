import '../entities/user.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;

  Future<User> signInWithEmail(String email, String password);
  Future<User> signUpWithEmail(String email, String password);
  Future<User?> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> sendVerificationEmail();
  Future<bool> checkEmailVerified();
  Future<void> signOut();
  Duration getRemainingVerificationCooldown();
}