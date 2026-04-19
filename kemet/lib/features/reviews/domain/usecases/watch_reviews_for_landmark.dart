import 'package:kemet/features/reviews/domain/entities/review.dart';
import 'package:kemet/features/reviews/domain/repositories/reviews_repository.dart';

class WatchReviewsForLandmarkUseCase {
  WatchReviewsForLandmarkUseCase(this.repository);

  final ReviewsRepository repository;

  Stream<List<Review>> call(String landmarkId) {
    return repository.watchReviewsForLandmark(landmarkId);
  }
}

