import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kemet/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id:        doc.id,
      userId:    data['userId']  as String? ?? '',
      title:     data['title']   as String? ?? '',
      body:      data['body']    as String? ?? '',
      isRead:    data['isRead']  as bool?   ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}