import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';

abstract class ReviewsRepository {
  Future<Either<Failure, List<Review>>> getReviewsForLandmark(
    String landmarkId,
  );

  Stream<List<Review>> watchReviewsForLandmark(String landmarkId);

  Future<Either<Failure, Review>> addReview(Review review);

  Future<Either<Failure, Unit>> deleteReview({
    required String reviewId,
    required String userId,
  });
}
