import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/exceptions.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/core/network/network_info.dart';
import 'package:kemet/features/landmarks/data/datasources/landmark_local_data_source.dart';
import 'package:kemet/features/landmarks/data/datasources/landmark_remote_data_source.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';

class LandmarksRepositoryImpl implements LandmarksRepository {
  final LandmarkRemoteDataSource remoteDataSource;
  final LandmarkLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  LandmarksRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Landmark>>> getAllLandmarks({
    required int page,
    required int limit,
    String? city,
    String? kind,
    String? query,
  }) async {
    final hasQuery = query != null && query.trim().isNotEmpty;
    if (hasQuery) {
      final cachedResult = await _getFromCacheForSearch(city: city, kind: kind);
      if (cachedResult != null) {
        return Right(cachedResult);
      }
    }

    try {
      // 1) Always try remote first.
      final remoteLandmarks = await remoteDataSource.getAllLandmarks(
        page: page,
        limit: limit,
        city: city,
        kind: kind,
      );
      await localDataSource.cacheLandmarks(remoteLandmarks);
      return Right(remoteLandmarks);
    } on ServerException {
      // 2) If remote fails, fall back to cache.
      return _getFromCacheOrFail(
        page: page,
        limit: limit,
        city: city,
        kind: kind,
      );
    } catch (_) {
      return _getFromCacheOrFail(
        page: page,
        limit: limit,
        city: city,
        kind: kind,
      );
    }
  }

  Future<List<Landmark>?> _getFromCacheForSearch({
    String? city,
    String? kind,
  }) async {
    try {
      List<Landmark> localLandmarks = await localDataSource
          .getCachedLandmarks();

      if (city != null && city.isNotEmpty) {
        localLandmarks = localLandmarks.where((landmark) {
          return landmark.city.toLowerCase() == city.toLowerCase();
        }).toList();
      }

      if (kind != null && kind.isNotEmpty) {
        localLandmarks = localLandmarks.where((landmark) {
          return landmark.category.name.toLowerCase() == kind.toLowerCase();
        }).toList();
      }

      return localLandmarks;
    } on EmptyCacheException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Either<Failure, List<Landmark>>> _getFromCacheOrFail({
    required int page,
    required int limit,
    String? city,
    String? kind,
  }) async {
    try {
      List<Landmark> localLandmarks = await localDataSource
          .getCachedLandmarks();

      if (city != null && city.isNotEmpty) {
        localLandmarks = localLandmarks.where((landmark) {
          return landmark.city.toLowerCase() == city.toLowerCase();
        }).toList();
      }

      if (kind != null && kind.isNotEmpty) {
        localLandmarks = localLandmarks.where((landmark) {
          return landmark.category.name.toLowerCase() == kind.toLowerCase();
        }).toList();
      }

      final int startIndex = (page - 1) * limit;

      if (startIndex >= localLandmarks.length) {
        return const Right([]);
      }

      int endIndex = startIndex + limit;
      if (endIndex > localLandmarks.length) {
        endIndex = localLandmarks.length;
      }

      final paginatedLandmarks = localLandmarks.sublist(startIndex, endIndex);

      return Right(paginatedLandmarks);
    } on EmptyCacheException {
      // 3) Cache missing: choose failure based on connectivity.
      final bool isConnected = await networkInfo.isConnected;
      return Left(isConnected ? ServerFailure() : OfflineFailure());
    } catch (_) {
      final bool isConnected = await networkInfo.isConnected;
      return Left(isConnected ? ServerFailure() : OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Landmark>> getLandmarkById(String id) async {
    try {
      final cached = await localDataSource.getCachedLandmarkById(id);
      if (cached != null) {
        return Right(cached);
      }

      final bool isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Left(OfflineFailure());
      }

      final remoteLandmark = await remoteDataSource.getLandmarkById(id);
      await localDataSource.cacheLandmarks([remoteLandmark]);
      return Right(remoteLandmark);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
