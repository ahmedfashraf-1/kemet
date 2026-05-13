import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/core/strings/failures.dart';
import 'package:kemet/features/favorite/domain/usecases/get_favorites_usecase.dart';
import 'package:kemet/features/favorite/domain/usecases/toggle_favorite_usecase.dart';
import 'package:kemet/features/favorite/presentation/cubit/favorites_state.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/notifications/data/datasources/Local_notification.dart';


class FavoritesCubit extends Cubit<FavoritesState> {
  final GetFavoritesUsecase _getFavorites;
  final ToggleFavoriteUsecase _toggleFavorite;

  FavoritesCubit({
    required GetFavoritesUsecase getFavorites,
    required ToggleFavoriteUsecase toggleFavorite,
  })  : _getFavorites = getFavorites,
        _toggleFavorite = toggleFavorite,
        super(const FavoritesInitial());

  Future<void> loadFavorites() async {
    emit(const FavoritesLoading());

    final result = await _getFavorites();

    result.fold(
      (failure) => emit(FavoritesError(_mapFailureToMessage(failure))),
      (favorites) => emit(FavoritesLoaded(
        favorites: favorites,
        favoriteIds: favorites.map((l) => l.id).toSet(),
      )),
    );
  }


  Future<void> toggle(String id) async {
    if (state is FavoritesLoaded) {
      final current = state as FavoritesLoaded;
      final updatedIds = current.favoriteIds.toSet();
      List<Landmark> updatedFavorites;

      if (updatedIds.contains(id)) {
        updatedIds.remove(id);
        updatedFavorites =
            current.favorites.where((l) => l.id != id).toList();
      } else {
        updatedIds.add(id);
        updatedFavorites = current.favorites;
      }

      emit(FavoritesLoaded(
        favorites: updatedFavorites,
        favoriteIds: updatedIds,
      ));
    }

    final toggleResult = await _toggleFavorite(id);

  toggleResult.fold(
  (failure) => loadFavorites(),
  (_) async {
    final result = await _getFavorites();
    result.fold(
      (failure) => emit(FavoritesError(_mapFailureToMessage(failure))),
      (favorites) async {
        emit(FavoritesLoaded(
          favorites: favorites,
          favoriteIds: favorites.map((l) => l.id).toSet(),
        ));

        final userId = FirebaseAuth.instance.currentUser?.uid;
        final isNowFav = favorites.any((l) => l.id == id);

        if (userId != null) {
          if (isNowFav) {
            await LocalNotificationService.instance
                .showFavoriteNotification(
              added: true,
              userId: userId,
            );
          } else {
            await LocalNotificationService.instance
                .showFavoriteNotification(
              added: false,
              userId: userId,
            );
          }
        }
      },
    );
  },
);
  }

  String _mapFailureToMessage(Failure failure) {
  if (failure is ServerFailure) return serverFailureMessage;
  if (failure is OfflineFailure) return offlineFailureMessage;
  if (failure is EmptyCacheFailure) return emptyCacheFailureMessage;
  return unknownFailureMessage;
}
}