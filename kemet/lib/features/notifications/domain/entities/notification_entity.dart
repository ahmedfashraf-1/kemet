class NotificationEntity {
  final String id;
  final String userId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });
}