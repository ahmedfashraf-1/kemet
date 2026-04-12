import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState extends Equatable {
  final bool pushNotificationsEnabled;
  final bool emailUpdatesEnabled;
  final bool soundEnabled;
  final bool darkModeEnabled;
  final String localeCode;
  final bool locationAccessEnabled;
  final bool isRequestingLocation;
  final String? avatarLocalPath;
  final String? avatarRemoteUrl;
  final int avatarCacheBuster;

  const SettingsState({
    required this.pushNotificationsEnabled,
    required this.emailUpdatesEnabled,
    required this.soundEnabled,
    required this.darkModeEnabled,
    required this.localeCode,
    required this.locationAccessEnabled,
    this.isRequestingLocation = false,
    this.avatarLocalPath,
    this.avatarRemoteUrl,
    this.avatarCacheBuster = 0,
  });

  SettingsState copyWith({
    bool? pushNotificationsEnabled,
    bool? emailUpdatesEnabled,
    bool? soundEnabled,
    bool? darkModeEnabled,
    String? localeCode,
    bool? locationAccessEnabled,
    bool? isRequestingLocation,
    String? avatarLocalPath,
    String? avatarRemoteUrl,
    int? avatarCacheBuster,
    bool clearAvatarLocalPath = false,
    bool clearAvatarRemoteUrl = false,
  }) {
    return SettingsState(
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailUpdatesEnabled: emailUpdatesEnabled ?? this.emailUpdatesEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      localeCode: localeCode ?? this.localeCode,
      locationAccessEnabled:
          locationAccessEnabled ?? this.locationAccessEnabled,
      isRequestingLocation: isRequestingLocation ?? this.isRequestingLocation,
      avatarLocalPath: clearAvatarLocalPath
          ? null
          : (avatarLocalPath ?? this.avatarLocalPath),
      avatarRemoteUrl: clearAvatarRemoteUrl
          ? null
          : (avatarRemoteUrl ?? this.avatarRemoteUrl),
      avatarCacheBuster: avatarCacheBuster ?? this.avatarCacheBuster,
    );
  }

  @override
  List<Object?> get props => [
    pushNotificationsEnabled,
    emailUpdatesEnabled,
    soundEnabled,
    darkModeEnabled,
    localeCode,
    locationAccessEnabled,
    isRequestingLocation,
    avatarLocalPath,
    avatarRemoteUrl,
    avatarCacheBuster,
  ];
}

class SettingsCubit extends Cubit<SettingsState> {
  static const String _pushNotificationsKey = 'settings_push_notifications';
  static const String _emailUpdatesKey = 'settings_email_updates';
  static const String _soundKey = 'settings_sound';
  static const String _darkModeKey = 'settings_dark_mode';
  static const String _localeKey = 'settings_locale_code';
  static const String _locationAccessKey = 'settings_location_access';
  static const String _avatarLocalPathPrefix = 'settings_avatar_local_path_';
  static const String _avatarRemoteUrlPrefix = 'settings_avatar_remote_url_';
  static const String _avatarCacheBusterPrefix =
      'settings_avatar_cache_buster_';

  final SharedPreferences sharedPreferences;

  SettingsCubit({required this.sharedPreferences})
    : super(
        SettingsState(
          pushNotificationsEnabled:
              sharedPreferences.getBool(_pushNotificationsKey) ?? true,
          emailUpdatesEnabled:
              sharedPreferences.getBool(_emailUpdatesKey) ?? false,
          soundEnabled: sharedPreferences.getBool(_soundKey) ?? true,
          darkModeEnabled: sharedPreferences.getBool(_darkModeKey) ?? true,
          localeCode: _normalizeLocaleCode(
            sharedPreferences.getString(_localeKey),
          ),
          locationAccessEnabled:
              sharedPreferences.getBool(_locationAccessKey) ?? true,
          avatarLocalPath: sharedPreferences.getString(
            _avatarLocalPathKey(_activeUserKey),
          ),
          avatarRemoteUrl: sharedPreferences.getString(
            _avatarRemoteUrlKey(_activeUserKey),
          ),
          avatarCacheBuster:
              sharedPreferences.getInt(_avatarCacheBusterKey(_activeUserKey)) ??
              0,
        ),
      );

  static String get _activeUserKey =>
      FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  static String _avatarLocalPathKey(String userKey) =>
      '$_avatarLocalPathPrefix$userKey';

  static String _avatarRemoteUrlKey(String userKey) =>
      '$_avatarRemoteUrlPrefix$userKey';

  static String _avatarCacheBusterKey(String userKey) =>
      '$_avatarCacheBusterPrefix$userKey';

  static String _normalizeLocaleCode(String? localeCode) {
    return localeCode == 'ar' ? 'ar' : 'en';
  }

  // Push Notifications

  Future<void> setPushNotifications(bool value) async {
    emit(state.copyWith(pushNotificationsEnabled: value));
    await sharedPreferences.setBool(_pushNotificationsKey, value);

    if (value) {
      await FirebaseMessaging.instance.subscribeToTopic('all');
      await _saveTokenToFirestore();
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('all');
      await _deleteTokenFromFirestore();
      await FirebaseMessaging.instance.deleteToken();
    }
  }

  Future<void> _saveTokenToFirestore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _deleteTokenFromFirestore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
    } catch (_) {}
  }

  Future<void> setEmailUpdates(bool value) async {
    emit(state.copyWith(emailUpdatesEnabled: value));
    await sharedPreferences.setBool(_emailUpdatesKey, value);
  }

  Future<void> setSoundEnabled(bool value) async {
    emit(state.copyWith(soundEnabled: value));
    await sharedPreferences.setBool(_soundKey, value);
  }

  Future<void> setDarkMode(bool value) async {
    emit(state.copyWith(darkModeEnabled: value));
    await sharedPreferences.setBool(_darkModeKey, value);
  }

  Future<void> setLocale(String localeCode) async {
    final normalized = _normalizeLocaleCode(localeCode);
    emit(state.copyWith(localeCode: normalized));
    await sharedPreferences.setString(_localeKey, normalized);
  }

  Future<bool> setLocationAccess(bool enabled) async {
    if (!enabled) {
      emit(state.copyWith(locationAccessEnabled: false));
      await sharedPreferences.setBool(_locationAccessKey, false);
      return true;
    }

    emit(state.copyWith(isRequestingLocation: true));

    final status = await Permission.locationWhenInUse.request();
    final granted = status.isGranted || status.isLimited;

    emit(
      state.copyWith(
        locationAccessEnabled: granted,
        isRequestingLocation: false,
      ),
    );
    await sharedPreferences.setBool(_locationAccessKey, granted);

    return granted;
  }

  Future<void> setProfileAvatar({String? localPath, String? remoteUrl}) async {
    final userKey = _activeUserKey;
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;

    emit(
      state.copyWith(
        avatarLocalPath: localPath,
        avatarRemoteUrl: remoteUrl,
        clearAvatarLocalPath: localPath == null,
        clearAvatarRemoteUrl: remoteUrl == null,
        avatarCacheBuster: cacheBuster,
      ),
    );

    if (localPath == null || localPath.isEmpty) {
      await sharedPreferences.remove(_avatarLocalPathKey(userKey));
    } else {
      await sharedPreferences.setString(
        _avatarLocalPathKey(userKey),
        localPath,
      );
    }

    if (remoteUrl == null || remoteUrl.isEmpty) {
      await sharedPreferences.remove(_avatarRemoteUrlKey(userKey));
    } else {
      await sharedPreferences.setString(
        _avatarRemoteUrlKey(userKey),
        remoteUrl,
      );
    }

    await sharedPreferences.setInt(_avatarCacheBusterKey(userKey), cacheBuster);
  }

  Future<void> loadProfileAvatarForCurrentUser() async {
    final userKey = _activeUserKey;
    final localPath = sharedPreferences.getString(_avatarLocalPathKey(userKey));
    final remoteUrl = sharedPreferences.getString(_avatarRemoteUrlKey(userKey));
    final cacheBuster =
        sharedPreferences.getInt(_avatarCacheBusterKey(userKey)) ?? 0;

    emit(
      state.copyWith(
        avatarLocalPath: localPath,
        avatarRemoteUrl: remoteUrl,
        clearAvatarLocalPath: localPath == null || localPath.isEmpty,
        clearAvatarRemoteUrl: remoteUrl == null || remoteUrl.isEmpty,
        avatarCacheBuster: cacheBuster,
      ),
    );
  }

  Future<void> clearProfileAvatar() async {
    final userKey = _activeUserKey;
    emit(
      state.copyWith(clearAvatarLocalPath: true, clearAvatarRemoteUrl: true),
    );
    await sharedPreferences.remove(_avatarLocalPathKey(userKey));
    await sharedPreferences.remove(_avatarRemoteUrlKey(userKey));
  }
}
