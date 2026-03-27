import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class OtpRemoteDatasource {
  OtpRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const otpValidity = Duration(minutes: 10);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _otpCollection =>
      _firestore.collection('email_otps');

  String _docId(String email) => email.trim().toLowerCase();

  String generateOtp() => (Random.secure().nextInt(900000) + 100000).toString();

  Future<String> createAndSendOtp(String email) async {
    final normalized = email.trim().toLowerCase();
    final code = generateOtp();
    final now = DateTime.now().toUtc();

    await _otpCollection.doc(_docId(normalized)).set({
      'email': normalized,
      'code': code,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(now.add(otpValidity)),
      'used': false,
      'attempts': 0,
    });

    await _firestore.collection('mail').add({
      'to': normalized,
      'message': {
        'subject': 'Kemet verification code',
        'text': 'Your Kemet verification code is $code. It expires in 10 minutes.',
      },
    });

    return code;
  }

  Future<bool> verifyOtp({required String email, required String code}) async {
    final ref = _otpCollection.doc(_docId(email));
    final snapshot = await ref.get();
    if (!snapshot.exists) return false;

    final data = snapshot.data()!;
    final isUsed = data['used'] == true;
    final savedCode = data['code']?.toString() ?? '';
    final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
    final isExpired = expiresAt == null || expiresAt.isBefore(DateTime.now().toUtc());

    if (isUsed || isExpired) return false;

    if (savedCode != code.trim()) {
      await ref.update({'attempts': FieldValue.increment(1)});
      return false;
    }

    await ref.update({'used': true, 'verifiedAt': Timestamp.fromDate(DateTime.now().toUtc())});
    return true;
  }
}