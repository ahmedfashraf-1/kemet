class ValidationService {
  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  static final RegExp _passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');

  static String? validateName(String? value, {String fieldName = 'Name'}) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return '$fieldName is required';
    }
    if (name.length < 2) {
      return '$fieldName is too short';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (!_passwordRegex.hasMatch(password)) {
      return 'Use 8+ chars with upper, lower, number and symbol';
    }

    return null;
  }

  static String? validateLoginPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String password,
    String? confirmPassword,
  ) {
    final confirm = confirmPassword ?? '';
    if (confirm.isEmpty) {
      return 'Confirm password is required';
    }

    if (confirm != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}