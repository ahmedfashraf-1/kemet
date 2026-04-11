import 'package:kemet/features/landmarks/domain/entities/landmarkcategory.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';

class Landmark {
  final String id;
  final String name;
  final String description;
  final String city;
  final double? latitude;
  final double? longitude;
  final LandmarkCategory category;
  final List<LandmarkPhoto> photos;
  final String openingTime;
  final String closingTime;
  final String? audioUrl;

  Landmark({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    this.latitude,
    this.longitude,
    required this.category,
    required this.photos,
    required this.openingTime,
    required this.closingTime,
    this.audioUrl,
  });
}
