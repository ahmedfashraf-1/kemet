import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDatasource {
  fb.User? get currentUser;
  Stream<fb.User?> get authStateChanges;

  Future<fb.UserCredential> signInWithEmail(String email, String password);
  Future<fb.UserCredential> signUpWithEmail(String email, String password);
  Future<fb.UserCredential?> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> sendVerificationEmail(fb.User user);
  Future<void> signOut();
  Duration getRemainingVerificationCooldown(String uid);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final _auth = fb.FirebaseAuth.instance;
  static const _verificationCooldown = Duration(seconds: 60);
  static final Map<String, DateTime> _lastSentAt = {};

  @override
  fb.User? get currentUser => _auth.currentUser;

  @override
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<fb.UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<fb.UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<fb.UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn(scopes: ['email', 'profile']).signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<void> sendVerificationEmail(fb.User user) async {
    final lastSent = _lastSentAt[user.uid];
    if (lastSent != null &&
        DateTime.now().difference(lastSent) < _verificationCooldown) {
      return; // Cooldown active — silently skip
    }
    await user.sendEmailVerification();
    _lastSentAt[user.uid] = DateTime.now();
  }

  @override
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    await GoogleSignIn().signOut();
    await _auth.signOut();
    if (uid != null) _lastSentAt.remove(uid);
  }

  @override
  Duration getRemainingVerificationCooldown(String uid) {
    final last = _lastSentAt[uid];
    if (last == null) return Duration.zero;
    final elapsed = DateTime.now().difference(last);
    return elapsed >= _verificationCooldown
        ? Duration.zero
        : _verificationCooldown - elapsed;
  }

  String _mapError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential': return 'Incorrect email or password.';
      case 'email-already-in-use': return 'This email is already registered.';
      case 'weak-password': return 'Password must be at least 8 characters.';
      case 'invalid-email': return 'Please enter a valid email address.';
      case 'too-many-requests': return 'Too many attempts. Try again later.';
      case 'network-request-failed': return 'Network error. Check your internet connection.';
      default: return e.message ?? 'An error occurred.';
    }
  }
}