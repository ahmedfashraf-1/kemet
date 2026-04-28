import 'package:kemet/core/errors/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FavoritesLocalDataSource {
  
  Set<String> getCachedFavoriteIds();

  Future<void> cacheFavoriteIds(Set<String> ids);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const _kFavoriteIds = 'CACHED_FAVORITE_IDS';

  late Set<String> _cachedIds;

  FavoritesLocalDataSourceImpl({required this.sharedPreferences}) {
    final stored = sharedPreferences.getStringList(_kFavoriteIds);
    _cachedIds = stored != null ? stored.toSet() : {};
  }

  @override
  Set<String> getCachedFavoriteIds() {
    if (_cachedIds.isEmpty &&
        (sharedPreferences.getStringList(_kFavoriteIds) ?? []).isEmpty) {
      throw EmptyCacheException();
    }
    return Set.unmodifiable(_cachedIds);
  }

  @override
  Future<void> cacheFavoriteIds(Set<String> ids) async {
    _cachedIds = ids.toSet();          // keep mirror in sync
    await sharedPreferences.setStringList(_kFavoriteIds, ids.toList());
  }
}