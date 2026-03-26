import 'package:dartz/dartz.dart';
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
  Future<Either<Failure, List<Landmark>>> getAllLandmarks({required int limit, required int offset}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteLandmarks = await remoteDataSource.getAllLandmarks(limit: limit, offset: offset);
        await  localDataSource.cacheLandmarks(remoteLandmarks);
        return Right(remoteLandmarks);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localLandmarks = await localDataSource.getCachedLandmarks();
        return Right(localLandmarks);
      } on EmptyCacheException {
        return Left(EmptyCacheFailure());
      }
    }
  }
  
}