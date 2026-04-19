import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/exceptions.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/favorite/domain/entities/favorite.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  const ProfileRepositoryImpl({required this.remoteDataSource});


  // 1 Get Profile

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(String userId) async {
    try {
      final model = await remoteDataSource.getProfile(userId);
      return Right(model);
    } on ServerException {
      return Left(ServerFailure());
    } on FirebaseException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }


  // 2 Get Recent Places

  @override
  Future<Either<Failure, List<Landmark>>> getRecentTrips(String userId) async {
    try {
      final data = await remoteDataSource.getRecentPlaces(userId);
      return Right(data);
    } on ServerException {
      return Left(ServerFailure());
    } on FirebaseException {
      return Left(ServerFailure());
    } catch (_) {

      return const Right([]);
    }
  }

  
  // 3 Get My Reviews
  @override
  Future<Either<Failure, List<Review>>> getMyReviews(
    String userId, {
    int? limit,
  }) async {
    try {
      final data = await remoteDataSource.getMyReviews(userId, limit: limit);
      return Right(data);
    } on ServerException {
      return Left(ServerFailure());
    } on FirebaseException {
      return Left(ServerFailure());
    } catch (_) {
      return const Right([]);
    }
  }


  // 4 Get Favorite Places

  @override
  Future<Either<Failure, List<Favorite>>> getFavoritePlaces(
      String userId) async {
    try {
      final data = await remoteDataSource.getFavoritePlaces(userId);
      return Right(data);
    } on ServerException {
      return Left(ServerFailure());
    } on FirebaseException {
      return Left(ServerFailure());
    } catch (_) {
      return const Right([]);
    }
  }


  // 5 Logout
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on FirebaseException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}