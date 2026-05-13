import 'package:kemet/features/notifications/domain/repositories/notification_repository.dart';

class MarkOneAsReadUsecase {
  final NotificationRepository _repo;
  MarkOneAsReadUsecase(this._repo);

  Future<void> call(String docId) => _repo.markOneAsRead(docId);
}