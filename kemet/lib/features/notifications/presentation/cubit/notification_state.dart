import 'package:kemet/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationState {}

class NotificationInitial   extends NotificationState {}
class NotificationLoading   extends NotificationState {}
class NotificationError     extends NotificationState {
  final String message;
  NotificationError(this.message);
}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  NotificationLoaded({required this.notifications, this.unreadCount = 0});
}