import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kemet/features/notifications/data/model/notification_model.dart';
import 'package:kemet/features/notifications/domain/entities/notification_entity.dart';
import 'package:kemet/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {

  final _db = FirebaseFirestore.instance;

  @override
  Stream<List<NotificationEntity>> getNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(NotificationModel.fromFirestore).toList());
  }

  @override
  Stream<int> getUnreadCount(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final unread = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    if (unread.docs.isEmpty) return;
    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> markOneAsRead(String docId) async {
    await _db.collection('notifications').doc(docId).update({'isRead': true});
  }

  @override
  Future<void> deleteNotification(String docId) async {
  await _db.collection('notifications').doc(docId).delete();
}

}