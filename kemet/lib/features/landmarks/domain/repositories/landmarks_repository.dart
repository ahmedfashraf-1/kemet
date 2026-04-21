import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

abstract class LandmarksRepository {
  Future<Either<Failure, List<Landmark>>> getAllLandmarks({
    required int page,
    required int limit,
    String? city,
    String? kind,
    String? languageCode,
  });
  Future<Either<Failure, Landmark>> getLandmarkById(
    String id, {
    String? languageCode,
  });
}
