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

    
    final results = await Future.wait([
      getProfile(userId),
      getRecentTrips(userId),
      getMyReviews(userId),
      getFavoritePlaces(userId),
    ]);

    final profileResult       = results[0];
    final recentPlacesResult  = results[1];
    final reviewsResult       = results[2];
    final favoritesResult     = results[3];

    
    profileResult.fold(
      (failure) => emit(ProfileError()),
      (profile) => emit(ProfileLoaded(
        profile: profile as ProfileEntity,
        recentTrips: (recentPlacesResult as dynamic)
            .getOrElse(() => <Landmark>[]) as List<Landmark>,
        reviews: (reviewsResult as dynamic)
            .getOrElse(() => <Review>[]) as List<Review>,
        favoritePlaces: (favoritesResult as dynamic)
            .getOrElse(() => <Favorite>[]) as List<Favorite>,
      )),
    );
  }

  Future<void> logout() async {
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(ProfileError()),
      (_)       => emit(ProfileLoggedOut()),
    );
  }
}