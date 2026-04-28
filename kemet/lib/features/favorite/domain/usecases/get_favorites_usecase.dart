import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/favorite/domain/repositories/favorites_repository.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

class GetFavoritesUsecase {
  final FavoritesRepository repository;

  GetFavoritesUsecase(this.repository);

  Future<Either<Failure, List<Landmark>>> call() async {
    return await repository.getFavorites();
  }
}