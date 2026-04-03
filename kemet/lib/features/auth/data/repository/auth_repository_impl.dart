import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._datasource);
  final AuthRemoteDatasource _datasource;

  @override
  domain.User? get currentUser {
    final fbUser = _datasource.currentUser;
    if (fbUser == null) return null;
    return _mapUser(fbUser);
  }

  @override
  Stream<domain.User?> get authStateChanges => _datasource.authStateChanges.map(
    (fbUser) => fbUser != null ? _mapUser(fbUser) : null,
  );

  @override
  String? get currentSessionId => _datasource.currentSessionId;

  @override
  Future<domain.User> signInWithEmail(String email, String password) async {
    final credential = await _datasource.signInWithEmail(email, password);
    final fbUser = credential.user;
    if (fbUser == null) {
      throw const AuthRemoteException('Sign-in succeeded without user data.');
    }
    return _mapUser(fbUser);
  }

  @override
  Future<domain.User> signUpWithEmail(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    final credential = await _datasource.signUpWithEmail(
      email,
      password,
      firstName,
      lastName,
    );
    final fbUser = credential.user;
    if (fbUser == null) {
      throw const AuthRemoteException('Sign-up succeeded without user data.');
    }
    return _mapUser(fbUser);
  }

  @override
  Future<domain.User?> signInWithGoogle() async {
    final credential = await _datasource.signInWithGoogle();
    if (credential == null) return null;
    final fbUser = credential.user;
    if (fbUser == null) {
      throw const AuthRemoteException(
        'Google sign-in succeeded without user data.',
      );
    }
    return _mapUser(fbUser);
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      _datasource.sendPasswordReset(email);

  @override
  Future<void> sendVerificationEmail() async {
    final user = _datasource.currentUser;
    if (user != null) await _datasource.sendVerificationEmail(user);
  }

  @override
  Future<bool> checkEmailVerified() async {
    await _datasource.currentUser?.reload();
    return _datasource.currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Duration getRemainingVerificationCooldown() {
    final uid = _datasource.currentUser?.uid;
    if (uid == null) return Duration.zero;
    return _datasource.getRemainingVerificationCooldown(uid);
  }

  @override
  Stream<List<AuthSession>> watchActiveSessions() {
    final uid = _datasource.currentUser?.uid;
    if (uid == null) return const Stream<List<AuthSession>>.empty();
    return _datasource.watchUserSessions(uid);
  }

  @override
  Future<void> clearOtherSessions() async {
    final uid = _datasource.currentUser?.uid;
    if (uid == null) return;
    await _datasource.clearOtherSessions(uid);
  }

  domain.User _mapUser(fb.User fbUser) => UserModel(
    id: fbUser.uid,
    username: fbUser.displayName ?? _requireEmail(fbUser).split('@').first,
    email: _requireEmail(fbUser),
    createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
  );

  String _requireEmail(fb.User fbUser) {
    final email = fbUser.email;
    if (email == null || email.isEmpty) {
      throw const AuthRemoteException('Authenticated user email is unavailable.');
    }
    return email;
  }
}
