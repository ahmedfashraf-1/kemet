import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';

class GetAllLandmarksUsecase {
  final LandmarksRepository repository;

  GetAllLandmarksUsecase(this.repository);

  Future<Either<Failure, List<Landmark>>> call({
    required int page,
    required int limit,
    String? city,
    String? kind,
    String? query,
  }) async {
    return await repository.getAllLandmarks(
      page: page,
      limit: limit,
      city: city,
      kind: kind,
      query: query,
    );
  }
}
