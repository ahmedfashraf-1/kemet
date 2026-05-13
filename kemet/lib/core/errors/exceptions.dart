class ServerException implements Exception {}

class EmptyCacheException implements Exception {}

class OfflineException implements Exception {}


// Thrown when Paymob's API returns 401 / 403 (bad or expired API key)
class PaymobAuthException implements Exception {
  final String message;
  const PaymobAuthException([this.message = 'Paymob authentication failed']);
}

// Thrown when Paymob's API returns a 4xx / 5xx with an error body
class PaymobServerException implements Exception {
  final String message;
  final int? statusCode;
  const PaymobServerException({
    this.message = 'Paymob server error',
    this.statusCode,
  });
}

// Thrown when a request to Paymob exceeds the timeout duration
class PaymobTimeoutException implements Exception {
  const PaymobTimeoutException();
}

// Thrown when the Paymob response body cannot be parsed
class PaymobParseException implements Exception {
  final String message;
  const PaymobParseException([this.message = 'Failed to parse Paymob response']);
}
