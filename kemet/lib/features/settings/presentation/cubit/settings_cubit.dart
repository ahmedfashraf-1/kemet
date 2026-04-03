import 'package:equatable/equatable.dart';
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

  const SettingsState({
    required this.pushNotificationsEnabled,
    required this.emailUpdatesEnabled,
    required this.soundEnabled,
    required this.darkModeEnabled,
    required this.localeCode,
    required this.locationAccessEnabled,
    this.isRequestingLocation = false,
  });

  SettingsState copyWith({
    bool? pushNotificationsEnabled,
    bool? emailUpdatesEnabled,
    bool? soundEnabled,
    bool? darkModeEnabled,
    String? localeCode,
    bool? locationAccessEnabled,
    bool? isRequestingLocation,
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
    );
  }

  @override
  List<Object> get props => [
    pushNotificationsEnabled,
    emailUpdatesEnabled,
    soundEnabled,
    darkModeEnabled,
    localeCode,
    locationAccessEnabled,
    isRequestingLocation,
  ];
}

class SettingsCubit extends Cubit<SettingsState> {
  static const String _pushNotificationsKey = 'settings_push_notifications';
  static const String _emailUpdatesKey = 'settings_email_updates';
  static const String _soundKey = 'settings_sound';
  static const String _darkModeKey = 'settings_dark_mode';
  static const String _localeKey = 'settings_locale_code';
  static const String _locationAccessKey = 'settings_location_access';

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
        ),
      );

  static String _normalizeLocaleCode(String? localeCode) {
    return localeCode == 'ar' ? 'ar' : 'en';
  }

  Future<void> setPushNotifications(bool value) async {
    emit(state.copyWith(pushNotificationsEnabled: value));
    await sharedPreferences.setBool(_pushNotificationsKey, value);
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
}

