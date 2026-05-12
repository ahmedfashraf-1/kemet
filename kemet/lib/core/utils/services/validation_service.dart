class ValidationService {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
  );

  static String _tr(
    String key, {
    Map<String, String>? args,
    String Function(String key, {Map<String, String>? args})? translate,
  }) {
    if (translate != null) {
      return translate(key, args: args);
    }
    return key;
  }

  static String? validateName(
    String? value, {
    String fieldName = 'Name',
    String Function(String key, {Map<String, String>? args})? translate,
  }) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return _tr(
        'validation_name_required',
        args: {'field': fieldName},
        translate: translate,
      );
    }
    if (name.length < 2) {
      return _tr(
        'validation_name_short',
        args: {'field': fieldName},
        translate: translate,
      );
    }
    return null;
  }

  static String? validateEmail(
    String? value, {
    String Function(String key, {Map<String, String>? args})? translate,
  }) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return _tr('validation_email_required', translate: translate);
    }

    if (!_emailRegex.hasMatch(email)) {
      return _tr('validation_email_invalid', translate: translate);
    }

    return null;
  }

  static String? validatePassword(
    String? value, {
    String Function(String key, {Map<String, String>? args})? translate,
  }) {
    final password = value ?? '';
    if (password.isEmpty) {
      return _tr('validation_password_required', translate: translate);
    }

    if (!_passwordRegex.hasMatch(password)) {
      return _tr('validation_password_rules', translate: translate);
    }

    return null;
  }

  static String? validateLoginPassword(
    String? value, {
    String Function(String key, {Map<String, String>? args})? translate,
  }) {
    final password = value ?? '';
    if (password.isEmpty) {
      return _tr('validation_password_required', translate: translate);
    }
    return null;
  }

  static String? validateConfirmPassword(
    String password,
    String? confirmPassword, {
    String Function(String key, {Map<String, String>? args})? translate,
  }) {
    final confirm = confirmPassword ?? '';
    if (confirm.isEmpty) {
      return _tr('validation_confirm_password_required', translate: translate);
    }

    if (confirm != password) {
      return _tr('validation_password_mismatch', translate: translate);
    }

    return null;
  }

  static String? validatePhone(
    String? value, {
    String Function(String key, {Map<String, String>? args})? translate,
  }) {
    final phone = value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    if (phone.isEmpty) {
      return _tr('validation_phone_required', translate: translate);
    }
    if (phone.length != 11) {
      return _tr('validation_phone_invalid', translate: translate);
    }
    return null;
  }

  static String? validateAddress(
    String? value, {
    String fieldName = 'Address',
    String Function(String key, {Map<String, String>? args})? translate,
  }) {
    final address = value?.trim() ?? '';
    if (address.isEmpty) {
      return _tr(
        'validation_address_required',
        args: {'field': fieldName},
        translate: translate,
      );
    }
    if (address.length < 5) {
      return _tr('validation_address_short', translate: translate);
    }
    return null;
  }

  static String? validateCity(
    String? value, {
    String Function(String key, {Map<String, String>? args})? translate,
  }) {
    final city = value?.trim() ?? '';
    if (city.isEmpty) {
      return _tr('validation_city_required', translate: translate);
    }
    if (city.length < 2) {
      return _tr('validation_city_short', translate: translate);
    }
    return null;
  }

  static String? validatePostalCode(
    String? value, {
    String Function(String key, {Map<String, String>? args})? translate,
  }) {
    final postalCode = value?.trim() ?? '';
    if (postalCode.isEmpty) {
      return _tr('validation_postal_code_required', translate: translate);
    }
    if (!RegExp(r'^[0-9]{5,6}$|^[a-zA-Z0-9]{5,6}$').hasMatch(postalCode)) {
      return _tr('validation_postal_code_invalid', translate: translate);
    }
    return null;
  }
}
