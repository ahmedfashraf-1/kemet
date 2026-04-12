import 'package:kemet/features/favorite/domain/repositories/favorites_repository.dart';

class IsFavoriteUsecase {
  final FavoritesRepository repository;

  IsFavoriteUsecase(this.repository);

  /// Synchronous — no Either needed here, no I/O involved.
  bool call(String id) => repository.isFavorite(id);
}