class Review {
  final String id;
  final String userId;
  final String landmarkId;
  final String comment;
  final double rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.landmarkId,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });
}