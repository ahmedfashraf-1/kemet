import 'package:kemet/features/notifications/domain/repositories/notification_repository.dart';

class MarkAllAsReadUsecase {
  final NotificationRepository _repo;
  MarkAllAsReadUsecase(this._repo);

  Future<void> call(String userId) => _repo.markAllAsRead(userId);
}