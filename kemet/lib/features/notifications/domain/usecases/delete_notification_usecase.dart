import 'package:kemet/features/notifications/domain/repositories/notification_repository.dart';

class DeleteNotificationUsecase {
  final NotificationRepository _repo;
  DeleteNotificationUsecase(this._repo);

  Future<void> call(String docId) => _repo.deleteNotification(docId);
}