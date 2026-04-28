import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';

class GetLandmarkByIdUseCase {
  final LandmarksRepository repository;

  const GetLandmarkByIdUseCase(this.repository);

  Future<Either<Failure, Landmark>> call(String id, {String? languageCode}) {
    return repository.getLandmarkById(id, languageCode: languageCode);
  }
}
