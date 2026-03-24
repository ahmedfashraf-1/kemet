import 'package:kemet/features/landmarks/domain/entities/landmarkcategory.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';

class Landmark {
  final String id;
  final String name;
  final String description;
  final String city;
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
    required this.category,
    required this.photos,
    required this.openingTime,
    required this.closingTime,
    this.audioUrl,
  });
}
