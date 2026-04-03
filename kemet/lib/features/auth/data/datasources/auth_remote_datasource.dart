import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kemet/core/utils/services/device_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  fb.User? get currentUser;
  Stream<fb.User?> get authStateChanges;
  String? get currentSessionId;

  Future<fb.UserCredential> signInWithEmail(String email, String password);
  Future<fb.UserCredential> signUpWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
  );
  Future<fb.UserCredential?> signInWithGoogle();
  Future<void> saveUserToFirestore(UserModel user);
  Future<void> sendPasswordReset(String email);
  Future<void> sendVerificationEmail(fb.User user);
  Future<void> createUserSession(String userId);
  Future<void> signOut();
  Duration getRemainingVerificationCooldown(String uid);

  Stream<List<AuthSessionModel>> watchUserSessions(String userId);
  Future<void> clearOtherSessions(String userId);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  AuthRemoteDatasourceImpl({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    required SharedPreferences sharedPreferences,
    DeviceService? deviceService,
  }) : _auth = auth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: _googleScopes),
       _sharedPreferences = sharedPreferences,
       _deviceService = deviceService ?? DeviceService();

  static const _verificationCooldown = Duration(seconds: 60);
  static const List<String> _googleScopes = ['email', 'profile'];
  static const _usersCollection = 'users';
  static const _sessionsCollection = 'sessions';
  static const _currentSessionKey = 'current_session_id';
  static const _defaultLocation = 'Egypt';
  static final Map<String, DateTime> _lastSentAt = {};

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final SharedPreferences _sharedPreferences;
  final DeviceService _deviceService;

  @override
  fb.User? get currentUser => _auth.currentUser;

  @override
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  @override
  String? get currentSessionId => _sharedPreferences.getString(_currentSessionKey);

  @override
  Future<fb.UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        await createUserSession(uid);
      }

      return credential;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<fb.UserCredential> signUpWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final fullName = '${firstName.trim()} ${lastName.trim()}';
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final createdUser = credential.user;
      if (createdUser == null) {
        throw const AuthRemoteException('User account was created without user data.');
      }

      final userModel = UserModel(
        id: createdUser.uid,
        username: fullName,
        email: createdUser.email ?? email.trim(),
        createdAt: DateTime.now(),
      );

      await saveUserToFirestore(userModel);
      await createUserSession(createdUser.uid);
      return credential;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } on FirebaseException catch (e) {
      throw _mapFirestoreError(e);
    } on AuthRemoteException {
      rethrow;
    } catch (_) {
      throw const AuthRemoteException('Failed to complete sign up.');
    }
  }

  @override
  Future<fb.UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final docRef = _firestore.collection(_usersCollection).doc(user.uid);
        final doc = await docRef.get();

        if (!doc.exists) {
          await docRef.set({
            'id': user.uid,
            'email': user.email,
            'fullName': user.displayName ?? '',
            'createdAt': DateTime.now().toIso8601String(),
          });
        }

        await createUserSession(user.uid);
      }

      return userCredential;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } on FirebaseException catch (e) {
      throw _mapFirestoreError(e);
    } catch (_) {
      throw const AuthRemoteException('Failed to complete Google sign in.');
    }
  }

  @override
  Future<void> saveUserToFirestore(UserModel user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      throw _mapFirestoreError(e);
    } catch (_) {
      throw const AuthRemoteException('Failed to save user profile.');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  @override
  Future<void> sendVerificationEmail(fb.User user) async {
    final now = DateTime.now();
    final lastSent = _lastSentAt[user.uid];
    if (lastSent != null && now.difference(lastSent) < _verificationCooldown) {
      return;
    }
    await user.sendEmailVerification();
    _lastSentAt[user.uid] = now;
  }

  @override
  Future<void> signOut() async {
    final uid = _auth.currentUser?.uid;
    await _markCurrentSessionInactive(uid);
    await _googleSignIn.signOut();
    await _auth.signOut();
    if (uid != null) _lastSentAt.remove(uid);
    await _sharedPreferences.remove(_currentSessionKey);
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

  @override
  Stream<List<AuthSessionModel>> watchUserSessions(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_sessionsCollection)
        .orderBy('last_active', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(AuthSessionModel.fromFirestore)
              .where((session) => session.isActive)
              .toList();
        });
  }

  @override
  Future<void> clearOtherSessions(String userId) async {
    final current = currentSessionId;
    if (current == null || current.isEmpty) return;

    final sessionDocs = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_sessionsCollection)
        .where('is_active', isEqualTo: true)
        .get();

    if (sessionDocs.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in sessionDocs.docs) {
      if (doc.id == current) continue;
      batch.update(doc.reference, {
        'is_active': false,
        'last_active': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> createUserSession(String userId) async {
    try {
      final sessionRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_sessionsCollection)
          .doc();

      final deviceName = await _deviceService.getDeviceName();

      await sessionRef.set({
        'device': deviceName,
        'location': _defaultLocation,
        'last_active': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
        'is_active': true,
      });

      await _sharedPreferences.setString(_currentSessionKey, sessionRef.id);
      developer.log(
        'Session created for user $userId with id ${sessionRef.id}',
        name: 'AuthRemoteDatasource',
      );
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'Failed to create session for user $userId: ${e.message}',
        name: 'AuthRemoteDatasource',
        error: e,
        stackTrace: stackTrace,
      );
      throw _mapFirestoreError(e);
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error while creating session for user $userId: $e',
        name: 'AuthRemoteDatasource',
        error: e,
        stackTrace: stackTrace,
      );
      throw const AuthRemoteException('Failed to create user session.');
    }
  }

  Future<void> _markCurrentSessionInactive(String? userId) async {
    if (userId == null) return;
    final sessionId = currentSessionId;
    if (sessionId == null || sessionId.isEmpty) return;

    final ref = _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_sessionsCollection)
        .doc(sessionId);

    final snapshot = await ref.get();
    if (!snapshot.exists) return;

    await ref.update({
      'is_active': false,
      'last_active': FieldValue.serverTimestamp(),
    });
  }

  AuthRemoteException _mapError(fb.FirebaseAuthException e) {
    return _mapAuthError(e);
  }

  AuthRemoteException _mapAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthRemoteException('No account found for this email.');
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthRemoteException('Incorrect email or password.');
      case 'email-already-in-use':
        return const AuthRemoteException('This email is already registered.');
      case 'weak-password':
        return const AuthRemoteException('Password must be at least 8 characters.');
      case 'invalid-email':
        return const AuthRemoteException('Please enter a valid email address.');
      case 'too-many-requests':
        return const AuthRemoteException('Too many attempts. Try again later.');
      case 'network-request-failed':
        return const AuthRemoteException('Network error. Check your internet connection.');
      default:
        return AuthRemoteException(e.message ?? 'An error occurred.');
    }
  }

  AuthRemoteException _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const AuthRemoteException('Permission denied while saving user data.');
      case 'unavailable':
        return const AuthRemoteException('Firestore service is currently unavailable.');
      default:
        return AuthRemoteException(e.message ?? 'Failed to save user data.');
    }
  }
}

class AuthRemoteException implements Exception {
  const AuthRemoteException(this.message);

  final String message;

  @override
  String toString() => message;
}