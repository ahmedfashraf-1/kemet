import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';

class GetAllLandmarksUsecase {
  final LandmarksRepository repository;

  GetAllLandmarksUsecase(this.repository);

  Future<Either<Failure, List<Landmark>>> call({required int limit, required int offset}) async {
    return await repository.getAllLandmarks(limit: limit, offset: offset);
  }
}