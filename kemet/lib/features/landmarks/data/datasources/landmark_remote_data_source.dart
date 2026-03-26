import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kemet/core/errors/exceptions.dart';
import 'package:kemet/features/landmarks/data/models/landmarks_model.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkcategory.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';

abstract class LandmarkRemoteDataSource {
   Future<List<LandmarkModel>> getAllLandmarks({required int limit, required int offset});
}

const BASE_URL = "https://api.opentripmap.com/0.1/en/places/bbox";
const String API_KEY = "5ae2e3f221c38a28845f05b686f69838eab47a77852ceed62a3dfec3";
const double lonMin = 24.7;
const double latMin = 22.0;
const double lonMax = 36.9;
const double latMax = 31.6;

class LandmarkRemoteDataSourceImpl implements LandmarkRemoteDataSource {
  final http.Client client;
  LandmarkRemoteDataSourceImpl({required this.client});

  @override
  Future<List<LandmarkModel>> getAllLandmarks({required int limit, required int offset}) async {
    final response = await client.get(
      Uri.parse("$BASE_URL?lon_min=$lonMin&lat_min=$latMin&lon_max=$lonMax&lat_max=$latMax&kinds=interesting_places&format=json&limit=$limit&offset=$offset&apikey=$API_KEY"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List decodedJson = json.decode(response.body) as List;
      List<LandmarkModel> landmarkModels = [];

      for (var item in decodedJson) {
        final String xid = item['xid'];
        
        final detailsUrl = Uri.parse(
            'https://api.opentripmap.com/0.1/en/places/xid/$xid?apikey=$API_KEY');
            
        final detailsResponse = await client.get(detailsUrl);

        if (detailsResponse.statusCode == 200) {
          final Map<String, dynamic> jsonDetails =
              json.decode(detailsResponse.body);

          if (jsonDetails['name'] != null &&
              jsonDetails['name'].toString().isNotEmpty) {
            landmarkModels.add(_mapJsonToModel(jsonDetails));
          }
        }
        // final List decodedJson = json.decode(response.body) as List;
        // final List<LandmarkModel> landmarkModels = decodedJson
        //     .map<LandmarkModel>((jsonLandmarkModel) => LandmarkModel.fromJson(jsonLandmarkModel))
        //     .toList();
      }
      return landmarkModels;
    } else {
      throw ServerException();
    }
  }

  LandmarkModel _mapJsonToModel(Map<String, dynamic> json) {
    return LandmarkModel(
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

      openingTime: "",
      closingTime: "",

      audioUrl: null,
    );
  }

  LandmarkCategory _mapKinds(String? kinds) {
      if (kinds == null) {
      return LandmarkCategory(id: "other", name: "Other");
    }

    final kindsList = kinds.split(',');

    if (kindsList.contains('egyptian_temples') ||
        kindsList.contains('temples')) {
      return LandmarkCategory(id: "temple", name: "Temple");
    }

    if (kindsList.contains('historic')) {
      return LandmarkCategory(id: "historic", name: "Historic");
    }

    if (kindsList.contains('museum')) {
      return LandmarkCategory(id: "museum", name: "Museum");
    }

    if (kindsList.contains('natural')) {
      return LandmarkCategory(id: "nature", name: "Nature");
    }

    if (kindsList.contains('islands')) {
      return LandmarkCategory(id: "island", name: "Island");
    }

    return LandmarkCategory(id: "other", name: "Other");
  }

  List<LandmarkPhoto> _extractPhotos(Map<String, dynamic> json) {
    List<LandmarkPhoto> photos = [];

    if (json['preview'] != null) {
      photos.add(
        LandmarkPhoto(
          url: json['preview']['source'],
        ),
      );
    } else if (json['image'] != null) {
      photos.add(
        LandmarkPhoto(
          url: json['image'],
        ),
      );
    }

    return photos;
  }

  //TO DO:
  /*
  @override
  Future<List<LandmarkModel>> getAllLandmarks({
    required int limit,
    required int offset,
  }) async {
    final response = await client.get(
      Uri.parse(
        "$BASE_URL?lon_min=24.7&lat_min=22.0&lon_max=36.9&lat_max=31.6&kinds=interesting_places&format=json&limit=$limit&offset=$offset&apikey=$API_KEY",
      ),
    );

    if (response.statusCode != 200) {
      throw ServerException();
    }

    final List decodedJson = json.decode(response.body);

    final futures = decodedJson.map((item) async {
      final xid = item['xid'];

      final detailsResponse = await client.get(
        Uri.parse(
          'https://api.opentripmap.com/0.1/en/places/xid/$xid?apikey=$API_KEY',
        ),
      );

      if (detailsResponse.statusCode == 200) {
        final jsonDetails = json.decode(detailsResponse.body);

        if (jsonDetails['name'] != null &&
            jsonDetails['name'].toString().isNotEmpty) {
          return _mapJsonToModel(jsonDetails);
        }
      }

      return null;
    }).toList();

    final results = await Future.wait(futures);

    return results.whereType<LandmarkModel>().toList();
  }
  */
}
