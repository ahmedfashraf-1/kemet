import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum VerificationEmailSendStatus {
  sent,
  skippedAlreadyVerified,
  skippedCooldown,
  skippedUnsupportedProvider,
}

class SignInVerificationResult {
  const SignInVerificationResult({
    required this.user,
    required this.isVerified,
    required this.verificationEmailStatus,
  });

  final User user;
  final bool isVerified;
  final VerificationEmailSendStatus verificationEmailStatus;

  bool get verificationEmailSent =>
      verificationEmailStatus == VerificationEmailSendStatus.sent;
}

class AuthService {
  final _auth = FirebaseAuth.instance;
  static const String _googleProviderId = 'google.com';
  static const String _passwordProviderId = 'password';
  static bool _allowVerifyEntryFromAuthFlow = false;
  static final Map<String, DateTime> _lastVerificationEmailSentAtByUid = {};
  static bool _isSendingVerificationEmail = false;

  static const Duration _verificationEmailCooldown = Duration(seconds: 60);

  static void _debugLog(String message) {
    debugPrint('[AuthService] $message');
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  void markVerifyEntryFromAuthFlow() {
    _allowVerifyEntryFromAuthFlow = true;
  }

  bool consumeVerifyEntryFromAuthFlow() {
    final allowed = _allowVerifyEntryFromAuthFlow;
    _allowVerifyEntryFromAuthFlow = false;
    return allowed;
  }

  // Backward-compatible aliases.
  void markVerifyEntryFromLogin() => markVerifyEntryFromAuthFlow();

  bool consumeVerifyEntryFromLogin() => consumeVerifyEntryFromAuthFlow();

  Duration get verificationEmailCooldown => _verificationEmailCooldown;

  Duration getRemainingVerificationCooldown({User? user}) {
    final targetUser = user ?? _auth.currentUser;
    if (targetUser == null) return Duration.zero;

    final lastSentAt = _lastVerificationEmailSentAtByUid[targetUser.uid];
    if (lastSentAt == null) return Duration.zero;

    final elapsed = DateTime.now().difference(lastSentAt);
    if (elapsed >= _verificationEmailCooldown) return Duration.zero;
    return _verificationEmailCooldown - elapsed;
  }

  bool _hasProvider(User user, String providerId) {
    return user.providerData.any((provider) => provider.providerId == providerId);
  }

  bool _isGoogleProvider(User user) => _hasProvider(user, _googleProviderId);

  bool _requiresEmailVerification(User user) {
    if (_isGoogleProvider(user)) {
      return false;
    }
    return _hasProvider(user, _passwordProviderId) || user.providerData.isEmpty;
  }

  // Email / Password
  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserCredential> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Backward-compatible aliases used by existing views.
  Future<UserCredential> signInWithEmail(String email, String password) {
    return login(email, password);
  }

  Future<UserCredential> registerWithEmail(String email, String password) {
    return register(email, password);
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

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

  // Email Verification
  Future<VerificationEmailSendStatus> sendVerificationEmail({
    User? user,
    bool forceReload = true,
    bool respectCooldown = true,
  }) async {
    if (_isSendingVerificationEmail) {
      _debugLog('Skipping verification email send: another send is in progress.');
      return VerificationEmailSendStatus.skippedCooldown;
    }

    _isSendingVerificationEmail = true;

    try {
      User? targetUser = user ?? _auth.currentUser;
      _debugLog(
        'sendVerificationEmail() triggered. forceReload=$forceReload, respectCooldown=$respectCooldown, hasUser=${targetUser != null}',
      );

      if (targetUser == null) {
        throw 'No signed-in user found.';
      }

      if (forceReload) {
        await targetUser.reload();
        targetUser = _auth.currentUser;
      }

      if (targetUser == null) {
        throw 'No signed-in user found.';
      }

      _debugLog(
        'Resolved user for verification send: uid=${targetUser.uid}, email=${targetUser.email}, verified=${targetUser.emailVerified}',
      );

      if (!_requiresEmailVerification(targetUser)) {
        _debugLog(
          'Skipping verification email send: provider does not require verification.',
        );
        return VerificationEmailSendStatus.skippedUnsupportedProvider;
      }

      if (targetUser.emailVerified) {
        _debugLog('Skipping verification email send: email already verified.');
        return VerificationEmailSendStatus.skippedAlreadyVerified;
      }

      final remainingCooldown = getRemainingVerificationCooldown(user: targetUser);
      if (respectCooldown && remainingCooldown > Duration.zero) {
        _debugLog(
          'Skipping verification email send: cooldown active (${remainingCooldown.inSeconds}s remaining).',
        );
        return VerificationEmailSendStatus.skippedCooldown;
      }

      _debugLog('Calling Firebase sendEmailVerification() for ${targetUser.email}.');
      await targetUser.sendEmailVerification();
      _lastVerificationEmailSentAtByUid[targetUser.uid] = DateTime.now();
      _debugLog('Verification email sent successfully to ${targetUser.email}.');
      return VerificationEmailSendStatus.sent;
    } on FirebaseAuthException catch (e) {
      _debugLog(
        'FirebaseAuthException while sending verification email: code=${e.code}, message=${e.message}',
      );
      throw _handleAuthError(e);
    } catch (e) {
      _debugLog('Unexpected error while sending verification email: $e');
      rethrow;
    } finally {
      _isSendingVerificationEmail = false;
    }
  }

  // Backward-compatible alias.
  Future<VerificationEmailSendStatus> sendEmailVerification() =>
      sendVerificationEmail();

  Future<User?> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      await user.reload();
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<bool> checkEmailVerified({bool forceReload = true}) async {
    try {
      if (forceReload) {
        await reloadUser();
      }
      return _auth.currentUser?.emailVerified ?? false;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<SignInVerificationResult> resolveSignInVerification({
    User? signedInUser,
  }) async {
    final initialUser = signedInUser ?? _auth.currentUser;
    _debugLog(
      'resolveSignInVerification() called. hasInitialUser=${initialUser != null}',
    );
    if (initialUser == null) {
      throw 'Unable to read current user. Please sign in again.';
    }

    try {
      await initialUser.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        throw 'User session lost. Please login again.';
      }

      _debugLog(
        'Refreshed user during sign-in verification: uid=${refreshedUser.uid}, email=${refreshedUser.email}, verified=${refreshedUser.emailVerified}',
      );

      if (!_requiresEmailVerification(refreshedUser)) {
        _debugLog('Sign-in user does not require email verification.');
        return SignInVerificationResult(
          user: refreshedUser,
          isVerified: true,
          verificationEmailStatus:
              VerificationEmailSendStatus.skippedUnsupportedProvider,
        );
      }

      if (refreshedUser.emailVerified) {
        _debugLog('Sign-in user is already email-verified.');
        return SignInVerificationResult(
          user: refreshedUser,
          isVerified: true,
          verificationEmailStatus:
              VerificationEmailSendStatus.skippedAlreadyVerified,
        );
      }

      final status = await sendVerificationEmail(
        user: refreshedUser,
        forceReload: false,
        respectCooldown: true,
      );
      _debugLog('Verification email send result after sign-in: $status');

      return SignInVerificationResult(
        user: refreshedUser,
        isVerified: false,
        verificationEmailStatus: status,
      );
    } on FirebaseAuthException catch (e) {
      _debugLog(
        'FirebaseAuthException in resolveSignInVerification(): code=${e.code}, message=${e.message}',
      );
      throw _handleAuthError(e);
    }
  }

  // Password Reset
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    final signedInUid = _auth.currentUser?.uid;
    final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    await googleSignIn.signOut();
    await _auth.signOut();

    if (signedInUid != null) {
      _lastVerificationEmailSentAtByUid.remove(signedInUid);
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return e.message ?? 'An error occurred.';
    }
  }
}
