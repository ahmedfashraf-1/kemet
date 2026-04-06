import 'package:dartz/dartz.dart';
import 'package:dartz/dartz_unsafe.dart';
import 'package:kemet/core/errors/exceptions.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/core/network/network_info.dart';
import 'package:kemet/features/landmarks/data/datasources/landmark_local_data_source.dart';
import 'package:kemet/features/landmarks/data/datasources/landmark_remote_data_source.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/repositories/landmarks_repository.dart';

class LandmarksRepositoryImpl implements LandmarksRepository{
  final LandmarkRemoteDataSource remoteDataSource;
  final LandmarkLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  LandmarksRepositoryImpl({required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo});

  @override
  Future<Either<Failure, List<Landmark>>> getAllLandmarks({required int page, required int limit, String? city, String? kind, String? query}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteLandmarks = await remoteDataSource.getAllLandmarks(page:page, limit: limit, city: city, kind: kind, query: query);
          await  localDataSource.cacheLandmarks(remoteLandmarks);
          return Right(remoteLandmarks);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        List<Landmark> localLandmarks = await localDataSource.getCachedLandmarks();

        if(city != null && city.isNotEmpty) {
          localLandmarks = localLandmarks.where((landmark) {
            return landmark.city.toLowerCase() == city.toLowerCase();
          }).toList();
        }

        if(kind != null && kind.isNotEmpty) {
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
        return Left(EmptyCacheFailure());
      }
    }
  }

}