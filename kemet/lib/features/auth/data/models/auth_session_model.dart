import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.id,
    required super.device,
    required super.location,
    required super.lastActive,
    required super.isActive,
    super.deviceToken,
    super.loginAt,
    super.lastActiveAt,
    super.isCurrentSession,
  });

  factory AuthSessionModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final lastActiveAt = _readDateTime(data['lastActiveAt']);
    final lastActiveLegacy = _readDateTime(data['last_active']);
    final lastActiveValue =
        lastActiveAt.year == 1970 ? lastActiveLegacy : lastActiveAt;

    return AuthSessionModel(
      id: (data['sessionId'] as String?) ?? doc.id,
      device: (data['deviceName'] as String?) ?? (data['device'] as String?) ?? 'Unknown device',
      location: (data['location'] as String?) ?? 'Unknown location',
      lastActive: lastActiveValue,
      isActive: (data['isActive'] as bool?) ?? (data['is_active'] as bool?) ?? false,
      deviceToken: data['deviceToken'] as String?,
      loginAt: _readDateTime(data['loginAt']),
      lastActiveAt: lastActiveValue,
      isCurrentSession: data['isCurrentSession'] as bool?,
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
