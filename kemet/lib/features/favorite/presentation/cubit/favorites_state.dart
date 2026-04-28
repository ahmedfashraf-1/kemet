import 'package:equatable/equatable.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<Landmark> favorites;
  final Set<String> favoriteIds;

  const FavoritesLoaded({
    required this.favorites,
    required this.favoriteIds,
  });

  bool isFavorite(String id) => favoriteIds.contains(id);

  @override
  List<Object?> get props => [favorites, favoriteIds];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}