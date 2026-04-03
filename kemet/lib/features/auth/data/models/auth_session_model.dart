import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.id,
    required super.device,
    required super.location,
    required super.lastActive,
    required super.isActive,
  });

  factory AuthSessionModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return AuthSessionModel(
      id: doc.id,
      device: (data['device'] as String?) ?? 'Unknown device',
      location: (data['location'] as String?) ?? 'Unknown location',
      lastActive: _readDateTime(data['last_active']),
      isActive: (data['is_active'] as bool?) ?? false,
    );
  }

  static DateTime _readDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

