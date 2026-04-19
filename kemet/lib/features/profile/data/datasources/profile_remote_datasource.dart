import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kemet/core/errors/exceptions.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkcategory.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';
import 'package:kemet/features/favorite/domain/entities/favorite.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';
import 'package:kemet/features/reviews/data/models/review_model.dart';

import '../models/profile_model.dart';


// Interface

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
  Future<List<Landmark>> getRecentPlaces(String userId);
  Future<List<Review>> getMyReviews(String userId, {int? limit});
  Future<List<Favorite>> getFavoritePlaces(String userId);
  Future<void> logout();
}


// Implementation
 
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final http.Client client;

  static String get _apiKey {
    final key = dotenv.env['API_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError('API_KEY is not set');
    }
    return key;
  }
  static const String _xidBase =
      'https://api.opentripmap.com/0.1/en/places/xid';

  ProfileRemoteDataSourceImpl({
    required this.firestore,
    required this.client,
  });


  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();

      if (!doc.exists) throw ServerException();

      final data = doc.data()!;
      final canViewPrivateData = await _canViewPrivateData(userId);

      final recentTrips = (data['recentTrips'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList();

      final savedCount = canViewPrivateData
          ? _extractSavedCount(data)
          : 0;
      final reviewsCount = canViewPrivateData
          ? await _countUserReviews(userId)
          : 0;

      return ProfileModel.fromFirestore(
        id: userId,
        data: data,
        tripsCount: canViewPrivateData ? recentTrips.length : 0,
        savedCount: savedCount,
        reviewsCount: reviewsCount,
      );
    } catch (_) {
      throw ServerException();
    }
  }


  @override
  Future<List<Landmark>> getRecentPlaces(String userId) async {
    try {
      final canViewPrivateData = await _canViewPrivateData(userId);
      if (!canViewPrivateData) {
        return [];
      }

      // 1 xids
      final doc = await firestore.collection('users').doc(userId).get();
      final List<dynamic> allXids = doc.data()?['recentTrips'] ?? [];
 
      if (allXids.isEmpty) return [];
 
        final recentXids = allXids.reversed.toList();
 
      final futures = recentXids.map((xid) async {
        try {
          final response = await client.get(
            Uri.parse('$_xidBase/$xid?apikey=$_apiKey'),
          );
 
          if (response.statusCode != 200) return null;
 
          final json = jsonDecode(response.body) as Map<String, dynamic>;
 
          
          if (json['name'] == null || json['name'].toString().trim().isEmpty) {
            return null;
          }
 
          return _mapJsonToLandmark(json);
        } catch (_) {
          return null;
        }
      }).toList();
 
      final results = await Future.wait(futures);
 
      return results.whereType<Landmark>().toList();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<List<Review>> getMyReviews(String userId, {int? limit}) async {
    try {
      final canViewPrivateData = await _canViewPrivateData(userId);
      if (!canViewPrivateData) {
        return [];
      }

      final snapshot = await firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .get();

      final models = snapshot.docs.map((doc) {
        final data = doc.data();
        var model = ReviewModel.fromJson(data, doc.id);
        if (model.userId.isEmpty) {
          model = ReviewModel(
            id: model.id,
            userId: userId,
            username: model.username,
            userImage: model.userImage,
            landmarkId: model.landmarkId,
            landmarkName: model.landmarkName,
            comment: model.comment,
            rating: model.rating,
            createdAt: model.createdAt,
          );
        }
        return model;
      }).toList();

      models.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final limited = (limit != null && limit > 0)
          ? models.take(limit).toList()
          : models;

      return limited.map((model) => model.toEntity()).toList();
    } catch (_) {
      throw ServerException();
    }
  }


  @override
  Future<List<Favorite>> getFavoritePlaces(String userId) async {
    try {
      final canViewPrivateData = await _canViewPrivateData(userId);
      if (!canViewPrivateData) {
        return [];
      }

      final doc = await firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return [];
      }

      final data = doc.data() ?? <String, dynamic>{};
      final raw = data['favorites'] ?? data['favoritePlaces'] ?? const [];
      if (raw is! List) {
        return [];
      }

      return raw
          .map((item) {
            if (item is Map<String, dynamic>) {
              final id = (item['id'] ?? item['landmarkId'] ?? '').toString();
              if (id.isEmpty) return null;
              return Favorite(
                id: id,
                name: (item['name'] ?? item['landmarkName'] ?? 'Unknown')
                    .toString(),
                location: (item['location'] ?? item['city'] ?? '').toString(),
                icon: item['icon']?.toString(),
              );
            }
            if (item is String && item.isNotEmpty) {
              return Favorite(id: item, name: item, location: '', icon: null);
            }
            return null;
          })
          .whereType<Favorite>()
          .toList();
    } catch (_) {
      throw ServerException();
    }
  }


  @override
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> _canViewPrivateData(String profileUserId) async {
    final viewerId = FirebaseAuth.instance.currentUser?.uid;
    if (viewerId == profileUserId && viewerId != null) return true;

    final doc = await firestore.collection('users').doc(profileUserId).get();
    final data = doc.data();
    final isPrivate = data?['isPrivate'] == true;
    return !isPrivate;
  }

  int _extractSavedCount(Map<String, dynamic> data) {
    final savedCountRaw = data['savedCount'];
    if (savedCountRaw is num) {
      return savedCountRaw.toInt();
    }

    final favorites = data['favorites'] ?? data['favoritePlaces'];
    if (favorites is List) {
      return favorites.length;
    }

    return 0;
  }

  Future<int> _countUserReviews(String userId) async {
    final snapshot = await firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.length;
  }


  Landmark _mapJsonToLandmark(Map<String, dynamic> json) {
    return Landmark(
      id: json['xid'] ?? '',
      name: json['name'] ?? 'Unknown',
      description:
          json['wikipedia_extracts']?['text'] ?? 'No description available',
      city: json['address']?['state'] ??
          json['address']?['village'] ??
          json['address']?['locality'] ??
          'Unknown',
      category: _mapKinds(json['kinds']),
      photos: _extractPhotos(json),
      openingTime: '',
      closingTime: '',
      audioUrl: null,
    );
  }

  LandmarkCategory _mapKinds(String? kinds) {
    if (kinds == null) return LandmarkCategory(id: 'other', name: 'Other');
    final list = kinds.split(',');
    if (list.contains('egyptian_temples') || list.contains('temples')) {
      return LandmarkCategory(id: 'temple', name: 'Temple');
    }
    if (list.contains('historic')) {
      return LandmarkCategory(id: 'historic', name: 'Historic');
    }
    if (list.contains('museum')) {
      return LandmarkCategory(id: 'museum', name: 'Museum');
    }
    if (list.contains('natural')) {
      return LandmarkCategory(id: 'nature', name: 'Nature');
    }
    if (list.contains('islands')) {
      return LandmarkCategory(id: 'island', name: 'Island');
    }
    return LandmarkCategory(id: 'other', name: 'Other');
  }

  List<LandmarkPhoto> _extractPhotos(Map<String, dynamic> json) {
    if (json['preview'] != null) {
      return [LandmarkPhoto(url: json['preview']['source'])];
    }
    if (json['image'] != null) {
      return [LandmarkPhoto(url: json['image'])];
    }
    return [];
  }
}