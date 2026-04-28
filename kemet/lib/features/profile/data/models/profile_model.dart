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
    super.imageUrl,
    super.photoUrl,
    super.imageId,
    super.imagePath,
    super.avatarUrl,
    super.isPrivate,
  });

  /// من Firebase document
  factory ProfileModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
    required int tripsCount,
    required int savedCount,
    required int reviewsCount,
  }) {
    final resolvedPhotoUrl = _sanitizeAvatarUrl(data['photoUrl'] as String?) ??
        _sanitizeAvatarUrl(data['imageUrl'] as String?) ??
        _sanitizeAvatarUrl(data['userImage'] as String?) ??
        _sanitizeAvatarUrl(data['avatarUrl'] as String?);

    return ProfileModel(
      id: id,
      fullName: data['fullName'] ?? 'Unknown',
      email: data['email'] ?? '',
      createdAt: data['createdAt'] ?? '',
      tripsCount: tripsCount,
      savedCount: savedCount,
      reviewsCount: reviewsCount,
      imageUrl: resolvedPhotoUrl,
      photoUrl: resolvedPhotoUrl,
      imageId: _sanitizeText(data['imageId']),
      imagePath: _sanitizeText(data['imagePath']),
      avatarUrl: resolvedPhotoUrl,
      isPrivate: data['isPrivate'] == true,
    );
  }

  static String? _sanitizeText(dynamic value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _sanitizeAvatarUrl(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (_isAssetPath(trimmed) || _isAppStorageUrl(trimmed) || trimmed.startsWith('http')) {
      return trimmed;
    }
    return null;
  }

  static bool _isAssetPath(String value) {
    return value.startsWith('images/') || value.startsWith('assets/');
  }

  static bool _isAppStorageUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return false;
    }
    if (uri.scheme == 'gs') {
      return true;
    }
    final host = uri.host.toLowerCase();
    return host.contains('firebasestorage.googleapis.com') ||
        host.contains('storage.googleapis.com');
  }
}