import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';
import 'package:location/location.dart';

// 1. Get landmarks that contains (lat,lon)

class GetMapLocationsUseCase {
  final LandmarksRepository repository;
  // di
  const GetMapLocationsUseCase(this.repository);
  // left ---> faild , right ---> sucess
  // call() ---> as function
  Future<Either<Failure, List<Landmark>>> call() async {
    final result = await repository.getAllLandmarks(
      page: 1,
      limit: 50,
    );

    // filter
    return result.map(
      
      (landmarks) => landmarks
          .where((l) => l.latitude != null && l.longitude != null)
          .where((l) => l.latitude != 0.0 && l.longitude != 0.0)
          .toList(),
    );
  }
}


// 2. Get User Location

class GetUserLocationUseCase {
  // _ ---> private 
  final Location _location = Location();
 
  Future<LocationData?> call() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) return null;
      }
      

      // return lat,lon
      return await _location.getLocation();
    } catch (_) {
      return null;
    }
  }
}