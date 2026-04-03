import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  late final Map<String, String> _localizedValues;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localization = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localization != null, 'AppLocalizations is not available in context');
    return localization!;
  }

  static const supportedLocales = <Locale>[Locale('en'), Locale('ar')];

  Future<void> load() async {
    final String jsonString = await rootBundle.loadString(
      'assets/l10n/${locale.languageCode}.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    _localizedValues = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  String translate(String key, {Map<String, String>? args}) {
    var value = _localizedValues[key] ?? key;
    args?.forEach((placeholder, replacement) {
      value = value.replaceAll('{$placeholder}', replacement);
    });
    return value;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supportedLocale) => supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension LocalizationX on BuildContext {
  String tr(String key, {Map<String, String>? args}) =>
      AppLocalizations.of(this).translate(key, args: args);
}

String translate(BuildContext context, String key, {Map<String, String>? args}) {
  return context.tr(key, args: args);
}

