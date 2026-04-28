import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<Landmark>>> getFavorites();

  Future<Either<Failure, Unit>> toggleFavorite(String id);

  bool isFavorite(String id);
}