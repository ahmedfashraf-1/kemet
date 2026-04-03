import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/features/auth/domain/entities/auth_session.dart';
import 'package:kemet/features/auth/domain/repositories/auth_repository.dart';

class SecuritySession extends Equatable {
  const SecuritySession({
    required this.id,
    required this.device,
    required this.location,
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
  List<Object> get props => [id, device, location, lastActive, isActive, isCurrent];
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
  SecurityCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const SecurityState(sessions: [])) {
    _subscribeToSessions();
  }

  final AuthRepository _authRepository;
  StreamSubscription<List<AuthSession>>? _sessionsSubscription;

  Future<void> clearOtherSessions() async {
    emit(state.copyWith(isClearingSessions: true));
    try {
      await _authRepository.clearOtherSessions();
    } finally {
      emit(state.copyWith(isClearingSessions: false));
    }
  }

  void _subscribeToSessions() {
    final currentSessionId = _authRepository.currentSessionId;
    _sessionsSubscription = _authRepository.watchActiveSessions().listen((sessions) {
      emit(
        state.copyWith(
          sessions: sessions
              .map(
                (session) => SecuritySession(
                  id: session.id,
                  device: session.device,
                  location: session.location,
                  lastActive: session.lastActive,
                  isActive: session.isActive,
                  isCurrent: currentSessionId == session.id,
                ),
              )
              .toList(),
        ),
      );
    });
  }

  @override
  Future<void> close() async {
    await _sessionsSubscription?.cancel();
    return super.close();
  }
}
