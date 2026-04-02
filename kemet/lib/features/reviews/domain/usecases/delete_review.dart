import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/reviews/domain/repositories/reviews_repository.dart';

class DeleteReviewUseCase {
  final ReviewsRepository repository;

  DeleteReviewUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String reviewId) async {
    return repository.deleteReview(reviewId);
  }
}
