import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';
import 'package:kemet/features/reviews/domain/repositories/reviews_repository.dart';

class AddReviewUseCase {
  final ReviewsRepository repository;

  AddReviewUseCase(this.repository);

  Future<Either<Failure, Review>> call(Review review) async {
    return repository.addReview(review);
  }
}
