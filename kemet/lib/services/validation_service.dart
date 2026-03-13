class ValidationService {
  static final RegExp _emailRegex =
  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|net|org)$');

  static final RegExp _passwordRegex =
  RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');

  static String? validateEmail(String value) {
    final email = value.trim();

    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegex.hasMatch(email)) {
      return 'Invalid email';
    }

    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (!_passwordRegex.hasMatch(password)) {
      return 'Invalid password';
    }

    return null;
  }

  static String? validateConfirmPassword(
      String password,
      String confirmPassword,
      ) {
    if (confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }

    if (confirmPassword != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}