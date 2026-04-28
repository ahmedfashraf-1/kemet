import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/favorite/domain/repositories/favorites_repository.dart';

class ToggleFavoriteUsecase {
  final FavoritesRepository repository;

  ToggleFavoriteUsecase(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.toggleFavorite(id);
  }
}