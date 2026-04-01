import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:kemet/core/errors/exceptions.dart';
import 'package:kemet/features/landmarks/data/models/landmarks_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LandmarkLocalDataSource {
  Future<List<LandmarkModel>> getCachedLandmarks();
  Future<Unit> cacheLandmarks(List<LandmarkModel> landmarkModels);
}

const cacheLandmarksKey= "CACHED_LANDMARKS_KEY";

class LandmarkLocalDataSourceImpl implements LandmarkLocalDataSource {
  final SharedPreferences sharedPreferences;
  LandmarkLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Unit> cacheLandmarks(List<LandmarkModel> landmarkModels) async {
    final cached = await getCachedLandmarksSafe();

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
    List landmarkModelsToJson = allLandmarks.map<Map<String, dynamic>>((landmarkModel) => landmarkModel.toJson()).toList();
    sharedPreferences.setString(cacheLandmarksKey, json.encode(landmarkModelsToJson));
    return Future.value(unit);
  }

  @override
  Future<List<LandmarkModel>> getCachedLandmarks() {
    final jsonString = sharedPreferences.getString(cacheLandmarksKey);
    if (jsonString != null) {
      List decodeJsonData = json.decode(jsonString);
      List<LandmarkModel> jsonToLandmarkModels = decodeJsonData
          .map<LandmarkModel>((jsonLandmarkModel) => LandmarkModel.fromJson(jsonLandmarkModel))
          .toList();
      return Future.value(jsonToLandmarkModels);
    } else {
      throw EmptyCacheException();
    }
  }

  Future<List<LandmarkModel>> getCachedLandmarksSafe() async {
  try {
    return await getCachedLandmarks();
  } catch (_)
  {
    return [];
  }
}
  
}