import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';
import 'package:kemet/features/reviews/domain/repositories/reviews_repository.dart';

class GetReviewsForLandmarkUseCase {
  final ReviewsRepository repository;

  GetReviewsForLandmarkUseCase(this.repository);

  Future<Either<Failure, List<Review>>> call(String? landmarkId) async {
    return repository.getReviewsForLandmark(landmarkId);
  }
}
