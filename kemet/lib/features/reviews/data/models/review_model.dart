import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  ReviewModel({
    required super.id,
    required super.userId,
    required super.landmarkId,
    required super.comment,
    required super.rating,
    required super.createdAt,
  });

  /// 🔹 from JSON (Firebase)
  factory ReviewModel.fromJson(Map<String, dynamic> json, String id) {
    return ReviewModel(
      id: id,
      userId: json['userId'],
      landmarkId: json['landmarkId'],
      comment: json['comment'],
      rating: (json['rating'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// 🔹 to JSON (Firebase)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'landmarkId': landmarkId,
      'comment': comment,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 🔹 convert to Entity
  Review toEntity() {
    return Review(
      id: id,
      userId: userId,
      landmarkId: landmarkId,
      comment: comment,
      rating: rating,
      createdAt: createdAt,
    );
  }

  /// 🔹 convert from Entity
  factory ReviewModel.fromEntity(Review review) {
    return ReviewModel(
      id: review.id,
      userId: review.userId,
      landmarkId: review.landmarkId,
      comment: review.comment,
      rating: review.rating,
      createdAt: review.createdAt,
    );
  }
}