import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/core/strings/failures.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';
import 'package:kemet/features/profile/domain/usecases/profile_usecases.dart';

part 'user_reviews_state.dart';

class UserReviewsCubit extends Cubit<UserReviewsState> {
  UserReviewsCubit({required this.getMyReviewsUseCase})
      : super(const UserReviewsInitial());

  final GetMyReviewsUseCase getMyReviewsUseCase;

  Future<void> loadReviews(String userId) async {
    emit(const UserReviewsLoading());
    try {
      final result = await getMyReviewsUseCase(userId);
      result.fold(
        (failure) => emit(UserReviewsError(message: _mapFailureToMessage(failure))),
        (reviews) => emit(UserReviewsLoaded(reviews: reviews)),
      );
    } catch (_) {
      emit(const UserReviewsError(message: unknownFailureMessage));
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
}
