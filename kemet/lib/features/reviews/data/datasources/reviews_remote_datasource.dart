import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kemet/core/errors/exceptions.dart';
import 'package:kemet/features/reviews/data/models/review_model.dart';

abstract class ReviewsRemoteDatasource {
  Future<List<ReviewModel>> getReviewsForLandmark(String landmarkId);
  Stream<List<ReviewModel>> watchReviewsForLandmark(String landmarkId);
  Future<ReviewModel> addReview(ReviewModel review);
  Future<void> deleteReview(String reviewId, String userId);
}

class ReviewsRemoteDatasourceImpl implements ReviewsRemoteDatasource {
  ReviewsRemoteDatasourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<ReviewModel>> getReviewsForLandmark(String landmarkId) async {
    try {
      print('Fetching reviews for landmarkId: $landmarkId');
      final snapshot = await _firestore
          .collection('reviews')
          .where('landmarkId', isEqualTo: landmarkId)
          .get();

      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data(), doc.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      print('Fetched ${reviews.length} reviews for landmarkId: $landmarkId');
      return reviews;
    } catch (e) {
      print('Failed to fetch reviews for landmarkId: $landmarkId -> $e');
      throw ServerException();
    }
  }

  @override
  Stream<List<ReviewModel>> watchReviewsForLandmark(String landmarkId) {
    return _firestore
        .collection('reviews')
        .where('landmarkId', isEqualTo: landmarkId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReviewModel.fromJson(doc.data(), doc.id))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  @override
  Future<ReviewModel> addReview(ReviewModel review) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null ||
          firebaseUser.isAnonymous ||
          firebaseUser.uid != review.userId) {
        throw ServerException();
      }
      print('Saving review for landmarkId: ${review.landmarkId} uid=${review.userId}');
      final profile = await _getUserProfile(review.userId);
      final payload = review.toJson();
      if ((payload['username'] as String?)?.trim().isEmpty ?? true) {
        payload['username'] = (profile?['fullName'] as String?)?.trim() ?? '';
      }
      final imageUrl = _extractImageUrl(profile);
      if (imageUrl != null) {
        // Keep a denormalized copy only for backward compatibility; UI reads users/{userId}.imageUrl.
        payload['userImage'] = imageUrl;
      }
      if ((payload['landmarkName'] as String?)?.trim().isEmpty ?? true) {
        payload['landmarkName'] = review.landmarkName;
      }
      payload['createdAt'] = FieldValue.serverTimestamp();
      final docRef = _reviewDocRef(review);
      await docRef.set(payload, SetOptions(merge: true));
      print('Review saved. id=${docRef.id} landmarkId=${review.landmarkId}');

      return ReviewModel(
        id: docRef.id,
        userId: review.userId,
        username: (payload['username'] as String?)?.trim() ?? review.username,
        userImage: review.userImage ?? payload['userImage'] as String?,
        landmarkId: review.landmarkId,
        landmarkName: (payload['landmarkName'] as String?) ??
            review.landmarkName,
        comment: review.comment,
        rating: review.rating,
        createdAt: review.createdAt,
      );
    } catch (e) {
      print('Failed to save review for landmarkId: ${review.landmarkId} -> $e');
      throw ServerException();
    }
  }

  @override
  Future<void> deleteReview(String reviewId, String userId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      print('Failed to delete review id=$reviewId userId=$userId -> $e');
      throw ServerException();
    }
  }

  DocumentReference<Map<String, dynamic>> _reviewDocRef(ReviewModel review) {
    final hasStableId = review.userId.isNotEmpty && review.landmarkId.isNotEmpty;
    if (!hasStableId) {
      return _firestore.collection('reviews').doc();
    }
    return _firestore
        .collection('reviews')
        .doc('${review.userId}_${review.landmarkId}');
  }

  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    if (userId.isEmpty) {
      return null;
    }
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        print('User profile not found for uid=$userId while creating review');
      }
      return doc.data();
    } catch (e) {
      print('Failed to fetch user profile for uid=$userId: $e');
      return null;
    }
  }

  String? _extractImageUrl(Map<String, dynamic>? profile) {
    if (profile == null) {
      return null;
    }
    final url = profile['photoUrl'] ??
        profile['imageUrl'] ??
        profile['userImage'] ??
        profile['avatarUrl'];
    if (url is! String) {
      return null;
    }
    final trimmed = url.trim();
    if (trimmed.isEmpty || trimmed.contains('googleusercontent.com')) {
      return null;
    }
    if (_isAssetPath(trimmed) || _isAppStorageUrl(trimmed) || trimmed.startsWith('http')) {
      return trimmed;
    }
    return null;
  }

  bool _isAssetPath(String value) {
    return value.startsWith('images/') || value.startsWith('assets/');
  }

  bool _isAppStorageUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return false;
    }
    if (uri.scheme == 'gs') {
      return true;
    }
    final host = uri.host.toLowerCase();
    return host.contains('firebasestorage.googleapis.com') ||
        host.contains('storage.googleapis.com');
  }
}
