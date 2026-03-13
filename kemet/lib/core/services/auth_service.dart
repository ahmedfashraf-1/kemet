import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  

  //  Email / Password 
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  //  Google Sign-In 
Future<UserCredential?> signInWithGoogle() async {
  try {
    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  } on FirebaseAuthException catch (e) {
    throw _handleAuthError(e);
  } catch (e) {
    throw 'Google Sign-In failed: $e';
  }
}

  // ── Password Reset ────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );
    await googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Helpers ───────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':        return 'No account found for this email.';
      case 'wrong-password':        return 'Incorrect password.';
      case 'email-already-in-use':  return 'This email is already registered.';
      case 'weak-password':         return 'Password must be at least 6 characters.';
      case 'invalid-email':         return 'Please enter a valid email address.';
      case 'too-many-requests':     return 'Too many attempts. Try again later.';
      default:                      return e.message ?? 'An error occurred.';
    }
  }
}