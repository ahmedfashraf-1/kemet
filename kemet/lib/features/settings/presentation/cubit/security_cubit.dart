import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecuritySession extends Equatable {
  const SecuritySession({
    required this.id,
    required this.location,
    required this.device,
    required this.lastActive,
    required this.isActive,
    required this.isCurrent,
  });

  final String id;
  final String device;
  final String location; 
  final DateTime lastActive;
  final bool isActive;
  final bool isCurrent;

  @override
  List<Object> get props => [id, device, lastActive, isActive, isCurrent];
}

class SecurityState extends Equatable {
  const SecurityState({
    required this.sessions,
    this.isClearingSessions = false,
  });

  final bool isClearingSessions;
  final List<SecuritySession> sessions;

  SecurityState copyWith({
    bool? isClearingSessions,
    List<SecuritySession>? sessions,
  }) {
    return SecurityState(
      sessions: sessions ?? this.sessions,
      isClearingSessions: isClearingSessions ?? this.isClearingSessions,
    );
  }

  @override
  List<Object> get props => [isClearingSessions, sessions];
}

class SecurityCubit extends Cubit<SecurityState> {
  SecurityCubit()
      : _firestore = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance,
        super(const SecurityState(sessions: [])) {
    _subscribeToSessions();
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription<QuerySnapshot>? _sessionsSubscription;

  // ── جيب الـ current session id من الـ auth datasource
  String? get _currentUid => _auth.currentUser?.uid;

  Future<void> clearOtherSessions() async {
    emit(state.copyWith(isClearingSessions: true));
    try {
      final uid = _currentUid;
      if (uid == null) return;

      // جيب كل الـ sessions عدا الحالية
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .where('isActive', isEqualTo: true)
          .get();

      // عدّل كلهم isActive = false
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isActive': false});
      }
      await batch.commit();
    } finally {
      emit(state.copyWith(isClearingSessions: false));
    }
  }

  void _subscribeToSessions() {
    final uid = _currentUid;
    if (uid == null) return;

    _sessionsSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      final sessions = snapshot.docs.map((doc) {
        final data = doc.data();
        return SecuritySession(
          id: doc.id,
          location: data['location'] ?? '', 
          device: data['device'] ?? 'Unknown Device',
          lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isActive: data['isActive'] ?? false,
          isCurrent: doc.id == _getCurrentSessionId(uid),
        );
      }).toList();

      emit(state.copyWith(sessions: sessions));
    });
  }

  
  String _getCurrentSessionId(String uid) {
    // بنرجع الـ device id اللي اتحفظ وقت الـ login
    // في الوقت الحالي بنقارن بالـ sessions الموجودة
    return uid; 
  }

  @override
  Future<void> close() async {
    await _sessionsSubscription?.cancel();
    return super.close();
  }
}