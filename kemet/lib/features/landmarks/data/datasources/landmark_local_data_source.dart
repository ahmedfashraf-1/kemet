import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/exceptions.dart';
import 'package:kemet/features/landmarks/data/models/landmarks_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LandmarkLocalDataSource {
  Future<List<LandmarkModel>> getCachedLandmarks({String? languageCode});
  Future<Unit> cacheLandmarks(
    List<LandmarkModel> landmarkModels, {
    String? languageCode,
  });
  Future<LandmarkModel?> getCachedLandmarkById(
    String id, {
    String? languageCode,
  });
}

const cacheLandmarksKeyPrefix = "CACHED_LANDMARKS_KEY_";

class LandmarkLocalDataSourceImpl implements LandmarkLocalDataSource {
  final SharedPreferences sharedPreferences;
  LandmarkLocalDataSourceImpl({required this.sharedPreferences});

  String _cacheKey(String? languageCode) {
    final normalized = languageCode == 'ar' ? 'ar' : 'en';
    return '$cacheLandmarksKeyPrefix$normalized';
  }

  @override
  Future<Unit> cacheLandmarks(
    List<LandmarkModel> landmarkModels, {
    String? languageCode,
  }) async {
    final cached = await getCachedLandmarksSafe(languageCode: languageCode);

    final Map<String, LandmarkModel> map = {
      for (var item in cached) item.id: item,
      for (var item in landmarkModels) item.id: item,
    };

    final allLandmarks = map.values.toList();
    /*
    final List<LandmarkModel> allLandmarks = List.from(cached);

    for (var newLandmark in landmarkModels) {
      allLandmarks.add(newLandmark);
    }
    */
    List landmarkModelsToJson = allLandmarks
        .map<Map<String, dynamic>>((landmarkModel) => landmarkModel.toJson())
        .toList();
    sharedPreferences.setString(
      _cacheKey(languageCode),
      json.encode(landmarkModelsToJson),
    );
    return Future.value(unit);
  }

  @override
  Future<List<LandmarkModel>> getCachedLandmarks({String? languageCode}) {
    final jsonString = sharedPreferences.getString(_cacheKey(languageCode));
    if (jsonString != null) {
      List decodeJsonData = json.decode(jsonString);
      List<LandmarkModel> jsonToLandmarkModels = decodeJsonData
          .map<LandmarkModel>(
            (jsonLandmarkModel) => LandmarkModel.fromJson(jsonLandmarkModel),
          )
          .toList();
      return Future.value(jsonToLandmarkModels);
    } else {
      throw EmptyCacheException();
    }
  }

  @override
  Future<LandmarkModel?> getCachedLandmarkById(
    String id, {
    String? languageCode,
  }) async {
    final cached = await getCachedLandmarksSafe(languageCode: languageCode);
    try {
      return cached.firstWhere((landmark) => landmark.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<LandmarkModel>> getCachedLandmarksSafe({
    String? languageCode,
  }) async {
    try {
      return await getCachedLandmarks(languageCode: languageCode);
    } catch (_) {
      return [];
    }
  }
}
