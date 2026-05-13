import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymobConstants {
  PaymobConstants._();

  // Loaded from .env via flutter_dotenv — never hardcoded.

  // Credentials (from .env)
  static String get apiKey => (dotenv.env['PAYMOB_API_KEY'] ?? '').trim();

  static int get cardIntegrationId =>
      int.tryParse((dotenv.env['PAYMOB_CARD_INTEGRATION_ID'] ?? '').trim()) ??
      0;

  static int get walletIntegrationId =>
      int.tryParse((dotenv.env['PAYMOB_WALLET_INTEGRATION_ID'] ?? '').trim()) ??
      0;

  static String get iframeId => (dotenv.env['PAYMOB_IFRAME_ID'] ?? '').trim();

  static String get hmacSecret =>
      (dotenv.env['PAYMOB_HMAC_SECRET'] ?? '').trim();

  // Config
  static String get currency =>
      (dotenv.env['PAYMENT_CURRENCY'] ?? 'EGP').trim();

  static int get paymentKeyExpiration =>
      int.tryParse((dotenv.env['PAYMENT_KEY_EXPIRATION'] ?? '').trim()) ?? 3600;

  //  Base URL
  static const String baseUrl = 'https://accept.paymob.com/api';

  // Endpoints
  static const String authEndpoint = '/auth/tokens';
  static const String orderEndpoint = '/ecommerce/orders';
  static const String paymentKeyEndpoint = '/acceptance/payment_keys';
  static const String walletPayEndpoint = '/acceptance/payments/pay';

  static String transactionEndpoint(String id) =>
      '/acceptance/transactions/$id';

  /// The full iFrame URL for card payment — inject the payment_token here.
  static String iframeUrl(String paymentToken) =>
      '$baseUrl/acceptance/iframes/$iframeId?payment_token=$paymentToken';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
