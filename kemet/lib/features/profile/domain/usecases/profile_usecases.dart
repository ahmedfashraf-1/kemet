import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/favorite/domain/entities/favorite.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';

import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';


// 1. Get Profile

class GetProfileUseCase {
  final ProfileRepository repository;
  const GetProfileUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(String userId) {
    return repository.getProfile(userId);
  }
}


// 2. Get Recent Places

class GetRecentPlacesUseCase {
  final ProfileRepository repository;
  const GetRecentPlacesUseCase(this.repository);

  Future<Either<Failure, List<Landmark>>> call(String userId) {
    return repository.getRecentTrips(userId);
  }
}


// 3. Get My Reviews

class GetMyReviewsUseCase {
  final ProfileRepository repository;
  const GetMyReviewsUseCase(this.repository);

  Future<Either<Failure, List<Review>>> call(String userId, {int? limit}) {
    return repository.getMyReviews(userId, limit: limit);
  }
}


// 4. Get Favorite Places

class GetFavoritePlacesUseCase {
  final ProfileRepository repository;
  const GetFavoritePlacesUseCase(this.repository);

  Future<Either<Failure, List<Favorite>>> call(String userId) {
    return repository.getFavoritePlaces(userId);
  }
}

// 5. Logout

class LogoutUseCase {
  final ProfileRepository repository;
  const LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}