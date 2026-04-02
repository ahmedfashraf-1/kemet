import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.createdAt,
    required super.tripsCount,
    required super.savedCount,
    required super.reviewsCount,
    super.avatarUrl,
  });

  /// من Firebase document
  factory ProfileModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
    required int tripsCount,
    required int savedCount,
    required int reviewsCount,
  }) {
    return ProfileModel(
      id: id,
      fullName: data['fullName'] ?? 'Unknown',
      email: data['email'] ?? '',
      createdAt: data['createdAt'] ?? '',
      tripsCount: tripsCount,
      savedCount: savedCount,
      reviewsCount: reviewsCount,
      avatarUrl: data['avatarUrl'] ?? 'https://example.com/default-avatar.png',
    );
  }
}