import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailOtpService {
  EmailOtpService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const Duration otpValidity = Duration(minutes: 10);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _otpCollection =>
      _firestore.collection('email_otps');

  User? get currentUser => _auth.currentUser;

  String _docIdFromEmail(String email) => email.trim().toLowerCase();

  String generateOtp() {
    final value = Random.secure().nextInt(900000) + 100000;
    return value.toString();
  }

  Future<String> createAndSendOtp(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final code = generateOtp();
    final now = DateTime.now().toUtc();
    final expiresAt = now.add(otpValidity);

    await _otpCollection.doc(_docIdFromEmail(normalizedEmail)).set({
      'email': normalizedEmail,
      'code': code,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'used': false,
      'attempts': 0,
    });

    await _enqueueOtpEmail(email: normalizedEmail, code: code);
    return code;
  }

  /// Sends Firebase's built-in verification email to the signed-in user.
  Future<void> sendVerificationEmail({User? user}) async {
    final targetUser = user ?? currentUser;
    if (targetUser == null) {
      throw 'No signed-in user found.';
    }
    if (!targetUser.emailVerified) {
      await targetUser.sendEmailVerification();
    }
  }

  /// Intent-revealing resend helper used by the verify email view.
  Future<void> resendVerificationEmail() => sendVerificationEmail();

  Future<User?> reloadUser() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser;
  }

  Future<bool> checkEmailVerified({bool forceReload = true}) async {
    if (forceReload) {
      await reloadUser();
    }
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> _enqueueOtpEmail({
    required String email,
    required String code,
  }) async {
    // Works with Firebase "Trigger Email" extension using the `mail` collection.
    await _firestore.collection('mail').add({
      'to': email,
      'message': {
        'subject': 'Kemet verification code',
        'text':
            'Your Kemet verification code is $code. It expires in 10 minutes.',
        'html':
            '<p>Your Kemet verification code is <b>$code</b>.</p><p>This code expires in 10 minutes.</p>',
      },
    });
  }

  Future<bool> verifyOtp({required String email, required String code}) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedCode = code.trim();

    final ref = _otpCollection.doc(_docIdFromEmail(normalizedEmail));
    final snapshot = await ref.get();

    if (!snapshot.exists) return false;

    final data = snapshot.data();
    if (data == null) return false;

    final isUsed = data['used'] == true;
    final savedCode = (data['code'] ?? '').toString();
    final expiresAt = data['expiresAt'] as Timestamp?;
    final isExpired =
        expiresAt == null ||
        expiresAt.toDate().isBefore(DateTime.now().toUtc());

    if (isUsed || isExpired) return false;

    if (savedCode != normalizedCode) {
      await ref.update({'attempts': FieldValue.increment(1)});
      return false;
    }

    await ref.update({
      'used': true,
      'verifiedAt': Timestamp.fromDate(DateTime.now().toUtc()),
    });

    return true;
  }
}
