import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:kemet/core/errors/exceptions.dart';

// ── نستخدم الـ entities الموجودة في الـ features التانية مباشرة
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkcategory.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';
import 'package:kemet/features/favorite/domain/entities/favorite.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';

import '../models/profile_model.dart';

// ─────────────────────────────────────────
// Interface
// ─────────────────────────────────────────
abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
  Future<List<Landmark>> getRecentPlaces(String userId);
  Future<List<Review>> getMyReviews(String userId);
  Future<List<Favorite>> getFavoritePlaces(String userId);
  Future<void> logout();
}

// ─────────────────────────────────────────
// Implementation
// ─────────────────────────────────────────
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final http.Client client;

  static const String _apiKey =
      '5ae2e3f221c38a28845f05b686f69838eab47a77852ceed62a3dfec3';
  static const String _xidBase =
      'https://api.opentripmap.com/0.1/en/places/xid';

  ProfileRemoteDataSourceImpl({
    required this.firestore,
    required this.client,
  });

  // ══════════════════════════════════════════
  // 1. Profile
  // بيانات اليوزر من Firebase users collection
  // + بنحسب الـ counts من الـ collections التانية
  // ══════════════════════════════════════════
  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final results = await Future.wait([
        firestore.collection('users').doc(userId).get(),
        firestore.collection('reviews')
            .where('userId', isEqualTo: userId)
            .count()
            .get(),
        firestore
            .collection('favorites')
            .where('userId', isEqualTo: userId)
            .count()
            .get(),
      ]);

      final doc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      if (!doc.exists) throw ServerException();

      final data = doc.data()!;
      final List<dynamic> tripXids = data['recentTrips'] ?? [];
      final reviewsCount =
          (results[1] as AggregateQuerySnapshot).count ?? 0;
      final savedCount =
          (results[2] as AggregateQuerySnapshot).count ?? 0;

      return ProfileModel.fromFirestore(
        id: userId,
        data: data,
        tripsCount: tripXids.length,
        savedCount: savedCount,
        reviewsCount: reviewsCount,
      );
    } catch (_) {
      throw ServerException();
    }
  }

  // ══════════════════════════════════════════
  // 2. Recent Places
  // بنجيب الـ xids من users.recentTrips
  // بعدين API call لكل xid على OpenTripMap
  // ══════════════════════════════════════════
  @override
  Future<List<Landmark>> getRecentPlaces(String userId) async {
    try {
      final doc =
          await firestore.collection('users').doc(userId).get();
      final List<dynamic> xids = doc.data()?['recentTrips'] ?? [];

      if (xids.isEmpty) return [];

      // آخر 5 بس
      final recentXids = xids.take(5).toList();

      final futures = recentXids.map((xid) async {
        final response = await client.get(
          Uri.parse('$_xidBase/$xid?apikey=$_apiKey'),
        );
        if (response.statusCode == 200) {
          final json =
              jsonDecode(response.body) as Map<String, dynamic>;
          if (json['name'] == null ||
              json['name'].toString().isEmpty) return null;
          return _mapJsonToLandmark(json);
        }
        return null;
      }).toList();

      final results = await Future.wait(futures);
      return results.whereType<Landmark>().toList();
    } catch (_) {
      throw ServerException();
    }
  }

  // ══════════════════════════════════════════
  // 3. My Reviews — reviews collection
  // ══════════════════════════════════════════
  @override
  Future<List<Review>> getMyReviews(String userId) async {
    try {
      final snapshot = await firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Review(
          id: doc.id,
          placeName: data['placeName'] ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          date: data['date'] ?? '',
        );
      }).toList();
    } catch (_) {
      throw ServerException();
    }
  }

  // ══════════════════════════════════════════
  // 4. Favorite Places — favorites collection
  // ══════════════════════════════════════════
  @override
  Future<List<Favorite>> getFavoritePlaces(String userId) async {
    try {
      final snapshot = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Favorite(
          id: doc.id,
          name: data['name'] ?? '',
          location: data['location'] ?? '',
          icon: data['icon'] ?? '⭐',
        );
      }).toList();
    } catch (_) {
      throw ServerException();
    }
  }

  // ══════════════════════════════════════════
  // 5. Logout
  // ══════════════════════════════════════════
  @override
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // ─────────────────────────────────────────
  // Helpers — نفس طريقة LandmarkRemoteDataSource
  // ─────────────────────────────────────────
  Landmark _mapJsonToLandmark(Map<String, dynamic> json) {
    return Landmark(
      id: json['xid'] ?? '',
      name: json['name'] ?? 'Unknown',
      description: json['wikipedia_extracts']?['text'] ??
          'No description available',
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