import 'package:kemet/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<List<NotificationEntity>> getNotifications(String userId);
  Stream<int> getUnreadCount(String userId);
  Future<void> markAllAsRead(String userId);
  Future<void> markOneAsRead(String docId);
  Future<void> deleteNotification(String docId);
}