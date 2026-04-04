import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import '../entities/profile_entity.dart';


import 'package:kemet/features/reviews/domain/entities/review.dart';
import 'package:kemet/features/favorite/domain/entities/favorite.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';


abstract class ProfileRepository {

  Future<Either<Failure, ProfileEntity>> getProfile(String userId);

  
  Future<Either<Failure, List<Landmark>>> getRecentTrips(String userId);

  
  Future<Either<Failure, List<Review>>> getMyReviews(String userId);

  
  Future<Either<Failure, List<Favorite>>> getFavoritePlaces(String userId);

  
  Future<Either<Failure, void>> logout();
}