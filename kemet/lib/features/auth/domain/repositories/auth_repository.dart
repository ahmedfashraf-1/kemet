import 'package:kemet/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  String? get currentSessionId;

  Future<User> signInWithEmail(String email, String password);
  Future<User> signUpWithEmail(String email, String password, String firstName, String lastName);
  Future<User?> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> sendVerificationEmail();
  Future<bool> checkEmailVerified();
  Future<void> deleteOtherSessions(String userId);
  Future<void> signOut();
  Future<void> deleteAccount(); // ← جديد
  Duration getRemainingVerificationCooldown();
}