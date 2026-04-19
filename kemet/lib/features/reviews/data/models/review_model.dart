import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  ReviewModel({
    required super.id,
    required super.userId,
    required super.username,
    super.userImage,
    required super.landmarkId,
    required super.landmarkName,
    required super.comment,
    required super.rating,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json, String id) {
    final rawCreatedAt = json['createdAt'];

    final comment = (json['text'] as String?) ??
        (json['comment'] as String?) ??
        '';

    final username = (json['username'] as String?)?.trim() ??
        (json['userName'] as String?)?.trim() ??
        (json['fullName'] as String?)?.trim() ??
        '';

    final userImage = (json['userImage'] as String?) ??
        (json['userPhotoUrl'] as String?) ??
        (json['photoURL'] as String?) ??
        (json['photoUrl'] as String?) ??
        (json['avatarUrl'] as String?);

    return ReviewModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      username: username,
      userImage: userImage,
      landmarkId: json['landmarkId'] as String? ?? '',
      landmarkName: (json['landmarkName'] as String?) ?? '',
      comment: comment,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: _parseCreatedAt(rawCreatedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'landmarkId': landmarkId,
      'landmarkName': landmarkName,
      'username': username,
      'userImage': userImage,
      'comment': comment,
      'text': comment,
      'rating': rating,
      // Keep Firestore field type consistent to avoid mixed-type query issues.
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Review toEntity() {
    return Review(
      id: id,
      userId: userId,
      username: username,
      userImage: userImage,
      landmarkId: landmarkId,
      landmarkName: landmarkName,
      comment: comment,
      rating: rating,
      createdAt: createdAt,
    );
  }

  factory ReviewModel.fromEntity(Review review) {
    return ReviewModel(
      id: review.id,
      userId: review.userId,
      username: review.username,
      userImage: review.userImage,
      landmarkId: review.landmarkId,
      landmarkName: review.landmarkName,
      comment: review.comment,
      rating: review.rating,
      createdAt: review.createdAt,
    );
  }

  static DateTime _parseCreatedAt(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }
}
