import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  ReviewModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.landmarkId,
    required super.comment,
    required super.rating,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json, String id) {
    final rawCreatedAt = json['createdAt'];

    final Username = (json['username'] as String?)?.trim();

    return ReviewModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      username: Username ?? '',
      landmarkId: json['landmarkId'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: _parseCreatedAt(rawCreatedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'landmarkId': landmarkId,
      'comment': comment,
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
      landmarkId: landmarkId,
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
      landmarkId: review.landmarkId,
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