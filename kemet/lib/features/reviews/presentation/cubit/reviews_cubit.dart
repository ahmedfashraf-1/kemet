import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/core/strings/failures.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';
import 'package:kemet/features/reviews/domain/usecases/add_review.dart';
import 'package:kemet/features/reviews/domain/usecases/delete_review.dart';
import 'package:kemet/features/reviews/domain/usecases/get_reviews_for_landmark.dart';
import 'package:kemet/features/reviews/domain/usecases/watch_reviews_for_landmark.dart';

part 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  final GetReviewsForLandmarkUseCase getReviewsForLandmarkUseCase;
  final WatchReviewsForLandmarkUseCase watchReviewsForLandmarkUseCase;
  final AddReviewUseCase addReviewUseCase;
  final DeleteReviewUseCase deleteReviewUseCase;

  ReviewsCubit({
    required this.getReviewsForLandmarkUseCase,
    required this.watchReviewsForLandmarkUseCase,
    required this.addReviewUseCase,
    required this.deleteReviewUseCase,
  }) : super(ReviewsInitial());

  Stream<List<Review>> watchReviewsForLandmark(String landmarkId) {
    return watchReviewsForLandmarkUseCase(landmarkId);
  }

  Future<void> getReviewsForLandmark(
    String landmarkId, {
    bool showLoading = true,
  }) async {
    if (showLoading) {
      emit(ReviewsLoading());
    }
    try {
      final failureOrReviews = await getReviewsForLandmarkUseCase(landmarkId);
      failureOrReviews.fold(
        (failure) => emit(ReviewsError(message: _mapFailureToMessage(failure))),
        (reviews) => emit(ReviewsLoaded(reviews: reviews)),
      );
    } catch (_) {
      emit(ReviewsError(message: unknownFailureMessage));
    }
  }

  Future<void> addReview(Review review) async {
    final currentReviews = state is ReviewsLoaded
        ? (state as ReviewsLoaded).reviews
        : const <Review>[];
    try {
      final failureOrReview = await addReviewUseCase(review);
      failureOrReview.fold(
        (failure) => emit(ReviewsError(message: _mapFailureToMessage(failure))),
        (savedReview) => emit(
          ReviewsLoaded(
            reviews: _replaceUserReview(currentReviews, savedReview),
          ),
        ),
      );
    } catch (_) {
      emit(ReviewsError(message: unknownFailureMessage));
    }
  }

  Future<void> deleteReview({
    required String reviewId,
    required String landmarkId,
    required String userId,
  }) async {
    final currentReviews = state is ReviewsLoaded
        ? (state as ReviewsLoaded).reviews
        : const <Review>[];
    try {
      final failureOrDelete = await deleteReviewUseCase(
        reviewId: reviewId,
        userId: userId,
      );
      failureOrDelete.fold(
        (failure) => emit(ReviewsError(message: _mapFailureToMessage(failure))),
        (_) => emit(
          ReviewsLoaded(reviews: _removeReview(currentReviews, reviewId)),
        ),
      );
    } catch (_) {
      emit(ReviewsError(message: unknownFailureMessage));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure() => serverFailureMessage,
      OfflineFailure() => offlineFailureMessage,
      EmptyCacheFailure() => emptyCacheFailureMessage,
      _ => unknownFailureMessage,
    };
  }

  List<Review> _replaceUserReview(List<Review> reviews, Review saved) {
    final updated = reviews
        .where(
          (review) =>
              review.userId != saved.userId ||
              review.landmarkId != saved.landmarkId,
        )
        .toList();
    updated.add(saved);
    updated.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return updated;
  }

  List<Review> _removeReview(List<Review> reviews, String reviewId) {
    return reviews.where((review) => review.id != reviewId).toList();
  }
}
