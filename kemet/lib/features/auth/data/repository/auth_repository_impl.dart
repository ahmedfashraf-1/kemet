import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/user.dart' as domain;
import '../../domain/repository_Abstract/auth_repository.dart';
import '../data_source/auth_remote_datasource.dart';
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
  Stream<domain.User?> get authStateChanges =>
      _datasource.authStateChanges.map(
        (fbUser) => fbUser != null ? _mapUser(fbUser) : null,
      );

  @override
  Future<domain.User> signInWithEmail(String email, String password) async {
    final credential = await _datasource.signInWithEmail(email, password);
    return _mapUser(credential.user!);
  }

  @override
  Future<domain.User> signUpWithEmail(String email, String password) async {
    final credential = await _datasource.signUpWithEmail(email, password);
    return _mapUser(credential.user!);
  }

  @override
  Future<domain.User?> signInWithGoogle() async {
    final credential = await _datasource.signInWithGoogle();
    if (credential?.user == null) return null;
    return _mapUser(credential!.user!);
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

  domain.User _mapUser(fb.User fbUser) => UserModel(
        id: fbUser.uid,
        username: fbUser.displayName ?? fbUser.email!.split('@').first,
        email: fbUser.email!,
        createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
      );
}