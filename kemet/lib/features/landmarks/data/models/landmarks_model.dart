import 'package:kemet/features/landmarks/domain/entities/landmarkcategory.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

class LandmarkModel extends Landmark {
  LandmarkModel({
    required super.id,
    required super.name,
    required super.description,
    required super.city,
    required super.category,
    required super.photos,
    required super.openingTime,
    required super.closingTime,
    super.audioUrl,
  });

  factory LandmarkModel.fromJson(Map<String, dynamic> json, String docId) {
    return LandmarkModel(
      id: docId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      category: LandmarkCategory(
        id: json['category_id'] ?? '',
        name: json['category_name'] ?? '',
      ),
      photos: (json['photos'] as List<dynamic>? ?? [])
          .map((e) => LandmarkPhoto(url: e))
          .toList(),
      openingTime: json['opening_time'] ?? '',
      closingTime: json['closing_time'] ?? '',
      audioUrl: json['audio_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'city': city,
      'category_id': category.id,
      'category_name': category.name,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'audio_url': audioUrl,
      'photos': photos.map((e) => e.url).toList(),
    };
  }
}
