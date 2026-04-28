import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/favorite/domain/entities/favorite.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/profile_usecases.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase getProfile;
  final GetRecentPlacesUseCase getRecentTrips;
  final GetMyReviewsUseCase getMyReviews;
  final GetFavoritePlacesUseCase getFavoritePlaces;
  final LogoutUseCase logoutUseCase;

  ProfileCubit({
    required this.getProfile,
    required this.getRecentTrips,
    required this.getMyReviews,
    required this.getFavoritePlaces,
    required this.logoutUseCase,
  }) : super(ProfileInitial());

  Future<void> loadProfile(String userId) async {
    emit(ProfileLoading());

    try {
      final profileResult = await getProfile(userId);
      final recentPlacesResult = await getRecentTrips(userId);
      final reviewsResult = await getMyReviews(userId, limit: 3);
      final favoritesResult = await getFavoritePlaces(userId);

      profileResult.fold(
        (_) => emit(ProfileError('Could not load profile information')),
        (profile) {
          final recentTrips = recentPlacesResult.fold(
            (_) => <Landmark>[],
            (data) => data,
          );
          final reviews = reviewsResult.fold(
            (_) => <Review>[],
            (data) => data,
          );
          final favoritePlaces = favoritesResult.fold(
            (_) => <Favorite>[],
            (data) => data,
          );

          emit(
            ProfileLoaded(
              profile: profile,
              recentTrips: recentTrips,
              reviews: reviews,
              favoritePlaces: favoritePlaces,
            ),
          );
        },
      );
    } catch (_) {
      emit(ProfileError('Could not load profile information'));
    }
  }

  Future<void> logout() async {
    final result = await logoutUseCase();
    result.fold(
      (_) => emit(ProfileError('Logout failed')),
      (_)       => emit(ProfileLoggedOut()),
    );
  }
}
