import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/exceptions.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/favorite/data/datasources/favorites_local_data_source.dart';
import 'package:kemet/features/favorite/domain/repositories/favorites_repository.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  /// Needed only to resolve IDs → full Landmark entities.
  /// We call getAllLandmarks with a large limit so we get everything cached.
  final LandmarksRepository landmarksRepository;

  FavoritesRepositoryImpl({
    required this.localDataSource,
    required this.landmarksRepository,
  });

  // ── isFavorite ────────────────────────────────────────────────────────────
  // Synchronous. Reads the in-memory mirror inside the data source.
  @override
  bool isFavorite(String id) {
    try {
      return localDataSource.getCachedFavoriteIds().contains(id);
    } on EmptyCacheException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── toggleFavorite ────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, Unit>> toggleFavorite(String id) async {
    try {
      Set<String> ids;
      try {
        ids = localDataSource.getCachedFavoriteIds().toSet();
      } on EmptyCacheException {
        ids = {};
      }

      if (ids.contains(id)) {
        ids.remove(id);
      } else {
        ids.add(id);
      }

      await localDataSource.cacheFavoriteIds(ids);
      return const Right(unit);
    } catch (_) {
      return Left(EmptyCacheFailure());
    }
  }

  // ── getFavorites ──────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<Landmark>>> getFavorites() async {
    try {
      final Set<String> ids;
      try {
        ids = localDataSource.getCachedFavoriteIds();
      } on EmptyCacheException {
        return const Right([]);          // no favorites saved → empty list
      }

      if (ids.isEmpty) return const Right([]);

      // Fetch all landmarks from the existing LandmarksRepository
      // (which handles its own remote/cache/network logic).
      final result = await landmarksRepository.getAllLandmarks(
        page: 1,
        limit: 1000,   // large enough to cover the full catalog
      );

      return result.fold(
        Left.new,
        (allLandmarks) {
          final favorites =
              allLandmarks.where((l) => ids.contains(l.id)).toList();
          return Right(favorites);
        },
      );
    } catch (_) {
      return Left(EmptyCacheFailure());
    }
  }
}