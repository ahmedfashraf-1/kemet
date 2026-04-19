class Review {
  final String id;
  final String userId;
  final String username;
  final String? userImage;
  final String landmarkId;
  final String landmarkName;
  final String comment;
  final double rating;
  final DateTime createdAt;

  @Deprecated('Use userImage')
  String? get userPhotoUrl => userImage;

  Review({
    required this.id,
    required this.userId,
    required this.username,
    String? userImage,
    @Deprecated('Use userImage') String? userPhotoUrl,
    required this.landmarkId,
    this.landmarkName = '',
    required this.comment,
    required this.rating,
    required this.createdAt,
  }) : userImage = userImage ?? userPhotoUrl;
}
