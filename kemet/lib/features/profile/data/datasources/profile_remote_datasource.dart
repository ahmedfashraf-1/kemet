// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:kemet/core/errors/exceptions.dart';

// // ── نستخدم الـ entities الموجودة في الـ features التانية مباشرة
// import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
// import 'package:kemet/features/landmarks/domain/entities/landmarkcategory.dart';
// import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';
// import 'package:kemet/features/favorite/domain/entities/favorite.dart';
// import 'package:kemet/features/reviews/domain/entities/review.dart';

// import '../models/profile_model.dart';

// // ─────────────────────────────────────────
// // Interface
// // ─────────────────────────────────────────
// abstract class ProfileRemoteDataSource {
//   Future<ProfileModel> getProfile(String userId);
//   Future<List<Landmark>> getRecentPlaces(String userId);
//   Future<List<Review>> getMyReviews(String userId);
//   Future<List<Favorite>> getFavoritePlaces(String userId);
//   Future<void> logout();
// }

// // ─────────────────────────────────────────
// // Implementation
// // ─────────────────────────────────────────
// class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
//   final FirebaseFirestore firestore;
//   final http.Client client;

//   static const String _apiKey =
//       '5ae2e3f221c38a28845f05b686f69838eab47a77852ceed62a3dfec3';
//   static const String _xidBase =
//       'https://api.opentripmap.com/0.1/en/places/xid';

//   ProfileRemoteDataSourceImpl({
//     required this.firestore,
//     required this.client,
//   });

//   // ══════════════════════════════════════════
//   // 1. Profile
//   // بيانات اليوزر من Firebase users collection
//   // + بنحسب الـ counts من الـ collections التانية
//   // ══════════════════════════════════════════
//   @override
//   Future<ProfileModel> getProfile(String userId) async {
//     try {
//       final results = await Future.wait([
//         firestore.collection('users').doc(userId).get(),
//         firestore.collection('reviews')
//             .where('userId', isEqualTo: userId)
//             .count()
//             .get(),
//         firestore
//             .collection('favorites')
//             .where('userId', isEqualTo: userId)
//             .count()
//             .get(),
//       ]);

//       final doc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
//       if (!doc.exists) throw ServerException();

//       final data = doc.data()!;
//       final List<dynamic> tripXids = data['recentTrips'] ?? [];
//       final reviewsCount =
//           (results[1] as AggregateQuerySnapshot).count ?? 0;
//       final savedCount =
//           (results[2] as AggregateQuerySnapshot).count ?? 0;

//       return ProfileModel.fromFirestore(
//         id: userId,
//         data: data,
//         tripsCount: tripXids.length,
//         savedCount: savedCount,
//         reviewsCount: reviewsCount,
//       );
//     } catch (_) {
//       throw ServerException();
//     }
//   }

//   // ══════════════════════════════════════════
//   // 2. Recent Places
//   // بنجيب الـ xids من users.recentTrips
//   // بعدين API call لكل xid على OpenTripMap
//   // ══════════════════════════════════════════
//   @override
//   Future<List<Landmark>> getRecentPlaces(String userId) async {
//     try {
//       final doc =
//           await firestore.collection('users').doc(userId).get();
//       final List<dynamic> xids = doc.data()?['recentTrips'] ?? [];

//       if (xids.isEmpty) return [];

//       // آخر 5 بس
//       final recentXids = xids.take(5).toList();

//       final futures = recentXids.map((xid) async {
//         final response = await client.get(
//           Uri.parse('$_xidBase/$xid?apikey=$_apiKey'),
//         );
//         if (response.statusCode == 200) {
//           final json =
//               jsonDecode(response.body) as Map<String, dynamic>;
//           if (json['name'] == null ||
//               json['name'].toString().isEmpty) return null;
//           return _mapJsonToLandmark(json);
//         }
//         return null;
//       }).toList();

//       final results = await Future.wait(futures);
//       return results.whereType<Landmark>().toList();
//     } catch (_) {
//       throw ServerException();
//     }
//   }

//   // ══════════════════════════════════════════
//   // 3. My Reviews — reviews collection
//   // ══════════════════════════════════════════
//   @override
//   Future<List<Review>> getMyReviews(String userId) async {
//     try {
//       final snapshot = await firestore
//           .collection('reviews')
//           .where('userId', isEqualTo: userId)
//           .orderBy('date', descending: true)
//           .get();

//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         return Review(
//           id: doc.id,
//           placeName: data['placeName'] ?? '',
//           rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
//           date: data['date'] ?? '',
//         );
//       }).toList();
//     } catch (_) {
//       throw ServerException();
//     }
//   }

//   // ══════════════════════════════════════════
//   // 4. Favorite Places — favorites collection
//   // ══════════════════════════════════════════
//   @override
//   Future<List<Favorite>> getFavoritePlaces(String userId) async {
//     try {
//       final snapshot = await firestore
//           .collection('favorites')
//           .where('userId', isEqualTo: userId)
//           .get();

//       return snapshot.docs.map((doc) {
//         final data = doc.data();
//         return Favorite(
//           id: doc.id,
//           name: data['name'] ?? '',
//           location: data['location'] ?? '',
//           icon: data['icon'] ?? '⭐',
//         );
//       }).toList();
//     } catch (_) {
//       throw ServerException();
//     }
//   }

//   // ══════════════════════════════════════════
//   // 5. Logout
//   // ══════════════════════════════════════════
//   @override
//   Future<void> logout() async {
//     await FirebaseAuth.instance.signOut();
//     await Future.delayed(const Duration(milliseconds: 100));
//   }

//   // ─────────────────────────────────────────
//   // Helpers — نفس طريقة LandmarkRemoteDataSource
//   // ─────────────────────────────────────────
//   Landmark _mapJsonToLandmark(Map<String, dynamic> json) {
//     return Landmark(
//       id: json['xid'] ?? '',
//       name: json['name'] ?? 'Unknown',
//       description: json['wikipedia_extracts']?['text'] ??
//           'No description available',
//       city: json['address']?['state'] ??
//           json['address']?['village'] ??
//           json['address']?['locality'] ??
//           'Unknown',
//       category: _mapKinds(json['kinds']),
//       photos: _extractPhotos(json),
//       openingTime: '',
//       closingTime: '',
//       audioUrl: null,
//     );
//   }

//   LandmarkCategory _mapKinds(String? kinds) {
//     if (kinds == null) return LandmarkCategory(id: 'other', name: 'Other');
//     final list = kinds.split(',');
//     if (list.contains('egyptian_temples') || list.contains('temples')) {
//       return LandmarkCategory(id: 'temple', name: 'Temple');
//     }
//     if (list.contains('historic')) {
//       return LandmarkCategory(id: 'historic', name: 'Historic');
//     }
//     if (list.contains('museum')) {
//       return LandmarkCategory(id: 'museum', name: 'Museum');
//     }
//     if (list.contains('natural')) {
//       return LandmarkCategory(id: 'nature', name: 'Nature');
//     }
//     if (list.contains('islands')) {
//       return LandmarkCategory(id: 'island', name: 'Island');
//     }
//     return LandmarkCategory(id: 'other', name: 'Other');
//   }

//   List<LandmarkPhoto> _extractPhotos(Map<String, dynamic> json) {
//     if (json['preview'] != null) {
//       return [LandmarkPhoto(url: json['preview']['source'])];
//     }
//     if (json['image'] != null) {
//       return [LandmarkPhoto(url: json['image'])];
//     }
//     return [];
//   }
// }



import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:kemet/core/errors/exceptions.dart';
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
  // 1. Profile ← Firebase users collection (حقيقي)
  // بيانات اليوزر: fullName, email, createdAt, id
  // الـ counts: dummy مؤقتاً لحد ما الـ features تتكمل
  // ══════════════════════════════════════════
  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final doc =
          await firestore.collection('users').doc(userId).get();

      if (!doc.exists) throw ServerException();

      final data = doc.data()!;

      return ProfileModel.fromFirestore(
        id: userId,
        data: data,
        // TODO: استبدل بـ count() queries لما الـ collections تتضاف
        tripsCount: 0,
        savedCount: 0,
        reviewsCount: 0,
      );
    } catch (_) {
      throw ServerException();
    }
  }

  // ══════════════════════════════════════════
  // 2. Recent Places ← Dummy مؤقتاً
  // TODO: لما تتضاف recentTrips في Firebase
  // استبدل بـ:
  //   final doc = await firestore.collection('users').doc(userId).get();
  //   final List xids = doc.data()?['recentTrips'] ?? [];
  //   ثم API call لكل xid على OpenTripMap
  // ══════════════════════════════════════════
  @override
  Future<List<Landmark>> getRecentPlaces(String userId) async {
    try {
      // 1. جيب الـ xids من Firebase
      final doc = await firestore.collection('users').doc(userId).get();
      final List<dynamic> allXids = doc.data()?['recentTrips'] ?? [];
 
      if (allXids.isEmpty) return [];
 
      // ✅ آخر 5 بس — reversed عشان أحدثهم يجوا الأول
      final recentXids = allXids.reversed.take(5).toList();
 
      // 2. API call لكل xid بالتوازي
      final futures = recentXids.map((xid) async {
        try {
          final response = await client.get(
            Uri.parse('$_xidBase/$xid?apikey=$_apiKey'),
          );
 
          if (response.statusCode != 200) return null;
 
          final json = jsonDecode(response.body) as Map<String, dynamic>;
 
          // بنشيل اي landmark مالهاش اسم
          if (json['name'] == null || json['name'].toString().trim().isEmpty) {
            return null;
          }
 
          return _mapJsonToLandmark(json);
        } catch (_) {
          return null;
        }
      }).toList();
 
      final results = await Future.wait(futures);
 
      // 3. بنشيل الـ nulls ونرجع الـ list
      return results.whereType<Landmark>().toList();
    } catch (_) {
      throw ServerException();
    }
  }

  // ══════════════════════════════════════════
  // 3. My Reviews ← Dummy مؤقتاً
  // TODO: لما الـ reviews feature تتكمل استبدل بـ:
  //   firestore.collection('reviews')
  //     .where('userId', isEqualTo: userId)
  //     .orderBy('date', descending: true)
  //     .get()
  // ══════════════════════════════════════════
  @override
  Future<List<Review>> getMyReviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Review(
        id: 'r1',
        placeName: 'Karnak Temple',
        rating: 5.0,
        date: 'Mar 2025',
      ),
      Review(
        id: 'r2',
        placeName: 'Pyramids of Giza',
        rating: 4.0,
        date: 'Jan 2025',
      ),
    ];
  }

  // ══════════════════════════════════════════
  // 4. Favorite Places ← Dummy مؤقتاً
  // TODO: لما الـ favorites feature تتكمل استبدل بـ:
  //   firestore.collection('favorites')
  //     .where('userId', isEqualTo: userId)
  //     .get()
  // ══════════════════════════════════════════
  @override
  Future<List<Favorite>> getFavoritePlaces(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Favorite(
        id: 'f1',
        name: 'Ibn Tulun Mosque',
        location: 'Cairo',
        icon: '🕌',
      ),
      Favorite(
        id: 'f2',
        name: 'Ras Mohammed',
        location: 'Sinai',
        icon: '🌊',
      ),
      Favorite(
        id: 'f3',
        name: 'Egyptian Museum',
        location: 'Cairo',
        icon: '🏺',
      ),
    ];
  }

  // ══════════════════════════════════════════
  // 5. Logout ← Firebase Auth (حقيقي)
  // ══════════════════════════════════════════
  @override
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // ─────────────────────────────────────────
  // Helper — OpenTripMap JSON → Landmark
  // بيتستخدم لما نربط الـ recentTrips الحقيقية
  // ─────────────────────────────────────────
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