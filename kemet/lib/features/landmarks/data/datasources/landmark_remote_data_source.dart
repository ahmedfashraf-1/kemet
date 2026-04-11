import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kemet/core/errors/exceptions.dart';
import 'package:kemet/features/landmarks/data/models/landmarks_model.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkcategory.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';

abstract class LandmarkRemoteDataSource {
  Future<List<LandmarkModel>> getAllLandmarks({
    required int page,
    required int limit,
    String? city,
    String? kind,
  });
}

const BASE_URL = "https://api.opentripmap.com/0.1/en/places/bbox";
const String API_KEY =
    "5ae2e3f221c38a28845f05b686f69838eab47a77852ceed62a3dfec3";
const double lonMin = 24.7;
const double latMin = 22.0;
const double lonMax = 36.9;
const double latMax = 31.6;

class LandmarkRemoteDataSourceImpl implements LandmarkRemoteDataSource {
  final http.Client client;
  LandmarkRemoteDataSourceImpl({required this.client});

  @override
  Future<List<LandmarkModel>> getAllLandmarks({
    required int page,
    required int limit,
    String? city,
    String? kind,
  }) async {
    final int offset = (page - 1) * limit;
    final String kindsParam = kind ?? 'interesting_places';

    http.Response response;
    if (city != null && city.isNotEmpty) {
      final geoResponse = await client.get(
        Uri.parse(
          'https://api.opentripmap.com/0.1/en/places/geoname?name=$city&apikey=$API_KEY',
        ),
      );

      if (geoResponse.statusCode == 200) {
        final geoData = json.decode(geoResponse.body);
        if (geoData['status'] == 'OK') {
          final lat = geoData['lat'];
          final lon = geoData['lon'];

          final radiusUrl =
              "https://api.opentripmap.com/0.1/en/places/radius?radius=10000&lon=$lon&lat=$lat&kinds=$kindsParam&format=json&limit=$limit&offset=$offset&apikey=$API_KEY";
          response = await client.get(Uri.parse(radiusUrl));
        } else {
          throw ServerException();
        }
      } else {
        throw ServerException();
      }
    } else {
      final boxUrl =
          "https://api.opentripmap.com/0.1/en/places/bbox?lon_min=$lonMin&lat_min=$latMin&lon_max=$lonMax&lat_max=$latMax&kinds=$kindsParam&format=json&limit=$limit&offset=$offset&apikey=$API_KEY";
      response = await client.get(Uri.parse(boxUrl));
    }

    if (response.statusCode == 200) {
      final List decodedJson = json.decode(response.body) as List;

      final futures = decodedJson.map((item) async {
        final xid = item['xid'];
        if (xid == null || xid.toString().isEmpty) {
          return _mapListItemToModel(item);
        }

        try {
          final detailsResponse = await client.get(
            Uri.parse(
              'https://api.opentripmap.com/0.1/en/places/xid/$xid?apikey=$API_KEY',
            ),
          );

          if (detailsResponse.statusCode == 200) {
            final jsonDetails = json.decode(detailsResponse.body);
            return _mapJsonToModel(jsonDetails);
          }
        } catch (_) {
          // Fall back to the list item when details fail.
        }

        return _mapListItemToModel(item);
      }).toList();

      final results = await Future.wait(futures);
      return results;
    } else {
      throw ServerException();
    }
  }

  LandmarkModel _mapJsonToModel(Map<String, dynamic> json) {
    final point = json['point'] as Map<String, dynamic>?;
    return LandmarkModel(
      id: json['xid'] ?? json['id'] ?? '',

      name: json['name'] ?? 'Unknown',

      description:
          json['wikipedia_extracts']?['text'] ?? 'No description available',

      city:
          json['address']?['state'] ??
          json['address']?['village'] ??
          json['address']?['locality'] ??
          'Unknown',

      latitude: LandmarkModel.toDouble(point?['lat']),
      longitude: LandmarkModel.toDouble(point?['lon']),

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

  LandmarkModel _mapListItemToModel(Map<String, dynamic> json) {
    final point = json['point'] as Map<String, dynamic>?;
    return LandmarkModel(
      id: json['xid'] ?? json['id'] ?? '',
      name: (json['name'] == null || json['name'].toString().isEmpty)
          ? 'Unknown'
          : json['name'],
      description: 'No description available',
      city: 'Unknown',
      latitude: LandmarkModel.toDouble(point?['lat']),
      longitude: LandmarkModel.toDouble(point?['lon']),
      category: _mapKinds(json['kinds']),
      photos: const <LandmarkPhoto>[],
      openingTime: "",
      closingTime: "",
      audioUrl: null,
    );
  }

  List<LandmarkPhoto> _extractPhotos(Map<String, dynamic> json) {
    List<LandmarkPhoto> photos = [];

    if (json['preview'] != null) {
      photos.add(LandmarkPhoto(url: json['preview']['source']));
    } else if (json['image'] != null) {
      photos.add(LandmarkPhoto(url: json['image']));
    }

    return photos;
  }
}
