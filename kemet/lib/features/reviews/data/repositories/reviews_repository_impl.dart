import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/exceptions.dart';
import 'package:kemet/core/errors/failures.dart';
import 'package:kemet/core/network/network_info.dart';
import 'package:kemet/features/reviews/data/datasources/reviews_remote_datasource.dart';
import 'package:kemet/features/reviews/data/models/review_model.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';
import 'package:kemet/features/reviews/domain/repositories/reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  ReviewsRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  final ReviewsRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<Review>>> getReviewsForLandmark(
    String landmarkId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(OfflineFailure());
    }

    try {
      final models = await remoteDatasource.getReviewsForLandmark(landmarkId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Review>> addReview(Review review) async {
    try {
      final model = ReviewModel.fromEntity(review);
      final saved = await remoteDatasource.addReview(model);
      return Right(saved.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteReview(String reviewId) async {
    try {
      await remoteDatasource.deleteReview(reviewId);
      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
