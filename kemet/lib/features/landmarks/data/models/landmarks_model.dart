import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:kemet/features/landmarks/domain/entities/landmarkcategory.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarkphotos.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

class LandmarkModel extends Landmark {
  LandmarkModel({
    required super.id,
    required super.name,
    required super.description,
    required super.city,
    super.latitude,
    super.longitude,
    required super.category,
    required super.photos,
    required super.openingTime,
    required super.closingTime,
    super.audioUrl,
  });

  factory LandmarkModel.fromJson(Map<String, dynamic> json) {
    final point = json['point'] as Map<String, dynamic>?;
    final filteredPhotos = <String>{
      ..._extractNormalizedPhotoUrls(json['photos']),
      ..._extractNormalizedPhotoUrls(json['imageUrl']),
      ..._extractNormalizedPhotoUrls(json['photoUrl']),
      ..._extractNormalizedPhotoUrls(json['coverImage']),
      ..._extractNormalizedPhotoUrls(json['image']),
      ..._extractNormalizedPhotoUrls(json['photo']),
      ..._extractNormalizedPhotoUrls(json['preview']),
      ..._extractNormalizedPhotoUrls(json['thumbnail']),
    }.toList(growable: false);

    return LandmarkModel(
      id: json['xid'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      latitude: toDouble(point?['lat']),
      longitude: toDouble(point?['lon']),
      category: LandmarkCategory(
        id: json['category_id'] ?? '',
        name: json['category_name'] ?? '',
      ),
      photos: filteredPhotos.map((url) => LandmarkPhoto(url: url)).toList(),
      openingTime: json['opening_time'] ?? '',
      closingTime: json['closing_time'] ?? '',
      audioUrl: json['audio_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'xid': id,
      'name': name,
      'description': description,
      'city': city,
      'point': {'lat': latitude, 'lon': longitude},
      'category_id': category.id,
      'category_name': category.name,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'audio_url': audioUrl,
      'photos': photos.map((e) => e.url).toList(),
    };
  }

  static double? toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  static String? normalizePhotoUrl(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return _normalizeNetworkUrl(trimmed);
  }

  static String? _normalizeNetworkUrl(String value) {
    final candidates = <String>{
      value,
      if (value.startsWith('//')) 'https:$value',
      if (!value.contains('://') && value.contains('.')) 'https://$value',
      if (value.startsWith('http://')) value.replaceFirst('http://', 'https://'),
      if (value.startsWith('/')) ..._relativeUrlCandidates(value),
    };

    for (final candidate in candidates) {
      final uri = Uri.tryParse(candidate);
      if (uri == null) {
        continue;
      }
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        continue;
      }
      if (uri.host.isEmpty) {
        continue;
      }

      if (_isWikimediaHost(uri.host)) {
        final normalizedUri = _normalizeToDirectImageUri(uri);
        if (normalizedUri != null && _looksLikeImageUrl(normalizedUri)) {
          return normalizedUri.toString();
        }
        continue;
      }

      if (_looksLikeImageUrl(uri)) {
        return uri.toString();
      }
    }

    return null;
  }

  static Uri? _normalizeToDirectImageUri(Uri uri) {
    final converted = _wikimediaPageToUploadUri(uri) ?? uri;
    if ((converted.scheme != 'http' && converted.scheme != 'https') ||
        converted.host.isEmpty) {
      return null;
    }
    if (!_looksLikeImageUrl(converted)) {
      return null;
    }
    return converted;
  }

  static Uri? _wikimediaPageToUploadUri(Uri uri) {
    if (!_isWikimediaHost(uri.host)) {
      return null;
    }

    final fileName = _extractWikimediaFileName(uri);
    if (fileName == null) {
      return null;
    }

    final normalizedFileName = fileName.replaceAll(' ', '_');
    final digest = crypto.md5.convert(utf8.encode(normalizedFileName)).toString();
    final encodedFileName = Uri.encodeComponent(normalizedFileName);

    return Uri.parse(
      'https://upload.wikimedia.org/wikipedia/commons/${digest[0]}/${digest.substring(0, 2)}/$encodedFileName',
    );
  }

  static String? _extractWikimediaFileName(Uri uri) {
    const filePrefix = '/wiki/File:';
    const specialPrefix = '/wiki/Special:FilePath/';
    const fileTitlePrefix = 'File:';
    const filePathPrefix = 'Special:FilePath/';

    final path = uri.path;
    if (path.startsWith(filePrefix)) {
      return Uri.decodeComponent(path.substring(filePrefix.length));
    }
    if (path.startsWith(specialPrefix)) {
      return Uri.decodeComponent(path.substring(specialPrefix.length));
    }

    final title = uri.queryParameters['title'];
    if (title != null && title.isNotEmpty) {
      if (title.startsWith(fileTitlePrefix)) {
        return Uri.decodeComponent(title.substring(fileTitlePrefix.length));
      }
      if (title.startsWith(filePathPrefix)) {
        return Uri.decodeComponent(title.substring(filePathPrefix.length));
      }
    }

    final lastSegment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    if (lastSegment.startsWith('File%3A')) {
      return Uri.decodeComponent(lastSegment.substring('File%3A'.length));
    }

    return null;
  }

  static bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return false;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }
    return uri.host.isNotEmpty;
  }

  static bool _isWikimediaHost(String host) {
    final lowered = host.toLowerCase();
    return lowered.contains('wikimedia.org') || lowered.contains('wikipedia.org');
  }

  static bool _looksLikeImageUrl(Uri uri) {
    final path = uri.path.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif') ||
        path.endsWith('.bmp') ||
        path.endsWith('.avif') ||
        path.endsWith('.heic') ||
        path.endsWith('.heif') ||
        path.endsWith('.tif') ||
        path.endsWith('.tiff');
  }

  static Iterable<String> _relativeUrlCandidates(String value) {
    if (value.contains('/wikipedia/commons/')) {
      return <String>['https://upload.wikimedia.org$value'];
    }

    if (value.contains('/wiki/') ||
        value.contains('Special:FilePath') ||
        value.contains('/w/index.php')) {
      return <String>['https://commons.wikimedia.org$value'];
    }

    return <String>['https://api.opentripmap.com$value'];
  }

  static Iterable<String> _extractNormalizedPhotoUrls(dynamic source) {
    final normalizedUrls = <String>{};

    void collect(dynamic value) {
      if (value == null) {
        return;
      }

      if (value is String) {
        final normalized = normalizePhotoUrl(value);
        if (normalized != null) {
          normalizedUrls.add(normalized);
        }
        return;
      }

      if (value is List) {
        for (final item in value) {
          collect(item);
        }
        return;
      }

      if (value is Map<String, dynamic>) {
        for (final key in const [
          'source',
          'url',
          'image',
          'photo',
          'preview',
          'thumbnail',
        ]) {
          collect(value[key]);
        }

        for (final nestedValue in value.values) {
          if (nestedValue is String ||
              nestedValue is Map<String, dynamic> ||
              nestedValue is List) {
            collect(nestedValue);
          }
        }
      }
    }

    collect(source);
    return normalizedUrls;
  }

  static bool hasValidImageUrl(Landmark landmark) {
    return firstValidPhotoUrl(landmark) != null;
  }

  static String? firstValidPhotoUrl(Landmark landmark) {
    for (final photo in landmark.photos) {
      final normalized = normalizePhotoUrl(photo.url);
      if (normalized != null) {
        return normalized;
      }
    }
    return null;
  }
}
