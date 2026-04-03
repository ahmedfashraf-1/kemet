class Review {
  final String id;
  final String? userId;
  final String? landmarkId;
  final String? placeName;
  final String? date;
  final String? comment;
  final double? rating;
  final DateTime? createdAt;

  Review({
    required this.id,
    this.placeName,
    this.date,
    this.comment,
    this.landmarkId,
    this.rating,
    this.userId,
    this.createdAt
    
  });
}
