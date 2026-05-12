import 'package:equatable/equatable.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

abstract class MapState extends Equatable {
  const MapState(); 

  // Comparison
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<Landmark> landmarks;
  final double? userLat;
  final double? userLng;
  final Landmark? selectedLandmark;

  const MapLoaded({
    required this.landmarks,
    this.userLat,
    this.userLng,
    this.selectedLandmark,
  });

  MapLoaded copyWith({
    List<Landmark>? landmarks,
    double? userLat,
    double? userLng,
    Landmark? selectedLandmark,
    bool clearSelected = false,
  }) {
    return MapLoaded(
      landmarks: landmarks ?? this.landmarks,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      selectedLandmark: clearSelected
          ? null
          : selectedLandmark ?? this.selectedLandmark,
    );
  }

  @override
  List<Object?> get props => [landmarks, userLat, userLng, selectedLandmark];
}

class MapError extends MapState {
  final String message;
  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}
