import 'package:kemet/features/notifications/domain/repositories/notification_repository.dart';

class GetUnreadCountUsecase {
  final NotificationRepository _repo;
  GetUnreadCountUsecase(this._repo);

  Stream<int> call(String userId) => _repo.getUnreadCount(userId);
}