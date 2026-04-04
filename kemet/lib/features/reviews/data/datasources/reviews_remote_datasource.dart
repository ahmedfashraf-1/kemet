import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kemet/core/errors/exceptions.dart';
import 'package:kemet/features/reviews/data/models/review_model.dart';

abstract class ReviewsRemoteDatasource {
  Future<List<ReviewModel>> getReviewsForLandmark(String landmarkId);
  Future<ReviewModel> addReview(ReviewModel review);
  Future<void> deleteReview(String reviewId);
}

class ReviewsRemoteDatasourceImpl implements ReviewsRemoteDatasource {
  ReviewsRemoteDatasourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<ReviewModel>> getReviewsForLandmark(String landmarkId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('landmarkId', isEqualTo: landmarkId)
          .get();

      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data(), doc.id))
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<ReviewModel> addReview(ReviewModel review) async {
    try {
      final String id = review.id.isEmpty
          ? _firestore.collection('reviews').doc().id
          : review.id;

      final ReviewModel model = review.id == id
          ? review
          : ReviewModel(
              id: id,
              userId: review.userId,
              username: review.username,
              landmarkId: review.landmarkId,
              comment: review.comment,
              rating: review.rating,
              createdAt: review.createdAt,
            );

      await _firestore.collection('reviews').doc(id).set(model.toJson());
      return model;
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
    } catch (_) {
      throw ServerException();
    }
  }
}
