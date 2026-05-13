import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthRepositoryImpl(this._datasource);

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
  Future<void> deleteOtherSessions(String userId) {
    return _datasource.deleteOtherSessions(userId);
  }
  
  @override
  Future<void> signOut() async {
    await _datasource.signOut();
  }

  @override
  Duration getRemainingVerificationCooldown() {
    final uid = _datasource.currentUser?.uid;
    if (uid == null) return Duration.zero;
    return _datasource.getRemainingVerificationCooldown(uid);
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


  Future<void> _recordNewSession(String uid) async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceName = "Unknown Device";
    String? deviceId;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceName = "${androidInfo.manufacturer} ${androidInfo.model}";
      deviceId = androidInfo.id; 
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.name;
      deviceId = iosInfo.identifierForVendor;
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .doc(deviceId ?? DateTime.now().millisecondsSinceEpoch.toString())
        .set({
      'device': deviceName,
      'lastActive': FieldValue.serverTimestamp(),
      'isActive': true,
      'platform': Platform.operatingSystem,
    });
  }

@override
Future<void> deleteAccount() async {
  final user = _datasource.currentUser;
  final uid = user?.uid;
  
  if (uid == null || user == null) {
    throw const AuthRemoteException('No user logged in.');
  }

  try {
    final providerData = user.providerData;
    final isGoogle = providerData.any((p) => p.providerId == 'google.com');

    if (isGoogle) {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw const AuthRemoteException('Re-authentication cancelled.');
      
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
    } else {
      
      throw const AuthRemoteException('NEEDS_REAUTH');
    }

    final sessions = await _firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .get();
    for (final doc in sessions.docs) {
      await doc.reference.delete();
    }

    
    await _firestore.collection('users').doc(uid).delete();

    
    await user.delete();
    
  } catch (e) {
    print('🔴 ERROR in deleteAccount: $e');
    rethrow;
  }
}
}
