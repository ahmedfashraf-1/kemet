import 'dart:convert';

import 'package:flutter/services.dart';

class ArabicLocalDescriptionService {
  ArabicLocalDescriptionService._();

  static final ArabicLocalDescriptionService instance =
      ArabicLocalDescriptionService._();

  Map<String, String>? _cache;
  Future<void>? _loading;

  Future<String?> getDescriptionForXid(String xid) async {
    final trimmed = xid.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    await _ensureLoaded();
    final value = _cache?[trimmed];
    if (value == null) {
      return null;
    }

    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  Future<void> _ensureLoaded() {
    if (_cache != null) {
      return Future.value();
    }
    _loading ??= _loadFromAssets();
    return _loading!;
  }

  Future<void> _loadFromAssets() async {
    try {
      final raw = await rootBundle.loadString('assets/landmarks_full.json');
      final data = json.decode(raw);
      if (data is! List) {
        _cache = {};
        return;
      }

      final map = <String, String>{};
      for (final entry in data) {
        if (entry is! Map) {
          continue;
        }
        final xid = entry['xid']?.toString().trim();
        final description = entry['description_ar']?.toString().trim();
        if (xid == null || xid.isEmpty) {
          continue;
        }
        if (description == null || description.isEmpty) {
          continue;
        }
        map[xid] = description;
      }

      _cache = map;
    } catch (_) {
      _cache = {};
    }
  }
}
