import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/maps/domain/usecases/map_usecases.dart';
import 'package:kemet/features/maps/presentation/cubit/map_state.dart';


class MapCubit extends Cubit<MapState> {
  final GetMapLocationsUseCase getMapLocations;
  final GetUserLocationUseCase getUserLocation;

  MapCubit({
    required this.getMapLocations,
    required this.getUserLocation,
  }) : super(MapInitial());

  Future<void> loadMap() async {
    emit(MapLoading());

    final results = await Future.wait([
      getMapLocations(),
      getUserLocation(),
    ]);

    final landmarksResult = results[0] as dynamic;
    final locationData    = results[1] as dynamic;

    landmarksResult.fold(
      (failure) => emit(MapError(failure.message)),
      (landmarks) => emit(MapLoaded(
        landmarks: landmarks,
        userLat: locationData?.latitude,
        userLng: locationData?.longitude,
      )),
    );
  }

  void selectLandmark(Landmark landmark) {
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(selectedLandmark: landmark));
    }
  }

  void clearSelection() {
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(clearSelected: true));
    }
  }
}