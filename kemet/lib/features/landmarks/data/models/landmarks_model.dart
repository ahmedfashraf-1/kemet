import 'package:kemet/features/landmarks/domain/entities/landmarkcategory.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

class LandmarkModel extends Landmark {
  LandmarkModel({
    required super.id,
    required super.name,
    required super.description,
    required super.city,
    super.latitude,
    super.longitude,
    required super.category,
    required super.photos,
    required super.openingTime,
    required super.closingTime,
    super.audioUrl,
  });

  factory LandmarkModel.fromJson(Map<String, dynamic> json) {
    final point = json['point'] as Map<String, dynamic>?;
    final rawPhotos = (json['photos'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final extraPhotoCandidates = <String?>[
      json['imageUrl'] as String?,
      json['photoUrl'] as String?,
      json['coverImage'] as String?,
      json['image'] as String?,
      json['photo'] as String?,
    ];
    final allCandidates = <String>[...rawPhotos, ...extraPhotoCandidates.whereType<String>()];
    final filteredPhotos = allCandidates
        .map(LandmarkModel.normalizePhotoUrl)
        .whereType<String>()
        .toList();

    return LandmarkModel(
      id: json['xid'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      latitude: toDouble(point?['lat']),
      longitude: toDouble(point?['lon']),
      category: LandmarkCategory(
        id: json['category_id'] ?? '',
        name: json['category_name'] ?? '',
      ),
      photos: filteredPhotos.map((url) => LandmarkPhoto(url: url)).toList(),
      openingTime: json['opening_time'] ?? '',
      closingTime: json['closing_time'] ?? '',
      audioUrl: json['audio_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'xid': id,
      'name': name,
      'description': description,
      'city': city,
      'point': {'lat': latitude, 'lon': longitude},
      'category_id': category.id,
      'category_name': category.name,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'audio_url': audioUrl,
      'photos': photos.map((e) => e.url).toList(),
    };
  }

  static double? toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  static String? normalizePhotoUrl(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (_isAssetPath(trimmed) || _isAppStorageUrl(trimmed)) {
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
