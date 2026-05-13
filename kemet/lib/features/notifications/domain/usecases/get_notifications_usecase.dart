import 'package:kemet/features/notifications/domain/entities/notification_entity.dart';
import 'package:kemet/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsUsecase {
  final NotificationRepository repository;

  GetNotificationsUsecase(this.repository);

  Stream<List<NotificationEntity>> call(String userId) {
    return repository.getNotifications(userId);
  }
}

