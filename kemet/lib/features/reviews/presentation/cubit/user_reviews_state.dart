part of 'user_reviews_cubit.dart';

abstract class UserReviewsState extends Equatable {
  const UserReviewsState();

  @override
  List<Object?> get props => [];
}

class UserReviewsInitial extends UserReviewsState {
  const UserReviewsInitial();
}

class UserReviewsLoading extends UserReviewsState {
  const UserReviewsLoading();
}

class UserReviewsLoaded extends UserReviewsState {
  const UserReviewsLoaded({required this.reviews});

  final List<Review> reviews;

  @override
  List<Object?> get props => [reviews];
}

class UserReviewsError extends UserReviewsState {
  const UserReviewsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

