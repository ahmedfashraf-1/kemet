import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/features/notifications/domain/entities/notification_entity.dart';
import 'package:kemet/features/notifications/domain/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repo;

  StreamSubscription<List<NotificationEntity>>? _notifSub;
  StreamSubscription<int>?                      _unreadSub;

  List<NotificationEntity> _notifications = [];
  int _unreadCount   = 0;
  bool _bellCleared = false;

  NotificationCubit(this._repo) : super(NotificationInitial());

  void startListening() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    emit(NotificationLoading());

    _notifSub = _repo.getNotifications(userId).listen(
      (list) {
        _notifications = list;
        emit(NotificationLoaded(
          notifications: _notifications,
          unreadCount: _bellCleared ? 0 : _unreadCount,
        ));
      },
      onError: (e) => emit(NotificationError(e.toString())),
    );

    _unreadSub = _repo.getUnreadCount(userId).listen((count) {
      _unreadCount = count;
      if (state is NotificationLoaded) {
        emit(NotificationLoaded(
          notifications: _notifications,
          unreadCount: _unreadCount,
        ));
      }
    });
  }

  Future<void> markAllAsRead() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    await _repo.markAllAsRead(userId);
  }

  void clearBellCount() {
    _bellCleared = true;
    if (state is NotificationLoaded) {
      emit(NotificationLoaded(
        notifications: _notifications,
        unreadCount: 0,
      ));
    }
  }


  Future<void> markOneAsRead(String docId) async {
    _bellCleared = false; 
    await _repo.markOneAsRead(docId);
  }
  @override
  Future<void> close() {
    _notifSub?.cancel();
    _unreadSub?.cancel();
    return super.close();
  }

  Future<void> deleteNotification(String docId) => 
    _repo.deleteNotification(docId);
}