import 'dart:convert';

import 'package:http/http.dart' as http;

class ArabicTranslationService {
  ArabicTranslationService._();

  static final ArabicTranslationService instance = ArabicTranslationService._();

  static final RegExp _arabicRegex = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]',
  );

  final Map<String, String> _translationCache = {};
  final Map<String, Future<String?>> _inFlightTranslations = {};

  bool isMostlyArabic(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    final arabicCount = _countMatches(trimmed, _arabicRegex);
    final latinCount = _countMatches(trimmed, RegExp(r'[A-Za-z]'));
    final total = arabicCount + latinCount;
    if (total == 0) {
      return false;
    }

    return arabicCount / total >= 0.4;
  }

  Future<String?> translateToArabic(String text, {String? cacheKey}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (isMostlyArabic(trimmed)) {
      return trimmed;
    }

    final key = cacheKey ?? trimmed;
    final cached = _translationCache[key];
    if (cached != null) {
      return cached;
    }

    final inFlight = _inFlightTranslations[key];
    if (inFlight != null) {
      return inFlight;
    }

    final future = _translateAndCache(trimmed, key);
    _inFlightTranslations[key] = future;
    try {
      return await future;
    } finally {
      _inFlightTranslations.remove(key);
    }
  }

  Future<String?> _translateAndCache(String text, String cacheKey) async {
    try {
      final chunks = _splitIntoChunks(text, maxLength: 450);
      final buffer = StringBuffer();

      for (final chunk in chunks) {
        final translatedChunk = await _translateChunkToArabic(chunk);
        if (translatedChunk == null || translatedChunk.trim().isEmpty) {
          return null;
        }

        if (buffer.isNotEmpty) {
          buffer.write(' ');
        }
        buffer.write(translatedChunk);
      }

      final translated = buffer.toString().trim();
      if (translated.isEmpty || !_containsArabic(translated)) {
        return null;
      }

      _translationCache[cacheKey] = translated;
      return translated;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _translateChunkToArabic(String chunk) async {
    final uri = Uri.https('api.mymemory.translated.net', '/get', {
      'q': chunk,
      'langpair': 'en|ar',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      return null;
    }

    final data = json.decode(response.body);
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final responseData = data['responseData'];
    if (responseData is! Map<String, dynamic>) {
      return null;
    }

    final translated =
        (responseData['translatedText'] as String?)?.trim() ?? '';
    return translated.isEmpty ? null : translated;
  }

  List<String> _splitIntoChunks(String text, {required int maxLength}) {
    if (text.length <= maxLength) {
      return [text];
    }

    final parts = <String>[];
    var remaining = text.trim();

    while (remaining.length > maxLength) {
      var splitIndex = remaining.lastIndexOf(RegExp(r'[.!?\n]'), maxLength);
      if (splitIndex <= 0) {
        splitIndex = remaining.lastIndexOf(' ', maxLength);
      }
      if (splitIndex <= 0) {
        splitIndex = maxLength;
      }

      parts.add(remaining.substring(0, splitIndex).trim());
      remaining = remaining.substring(splitIndex).trim();
    }

    if (remaining.isNotEmpty) {
      parts.add(remaining);
    }

    return parts;
  }

  int _countMatches(String text, RegExp pattern) {
    return pattern.allMatches(text).length;
  }

  bool _containsArabic(String text) {
    return _arabicRegex.hasMatch(text);
  }
}
