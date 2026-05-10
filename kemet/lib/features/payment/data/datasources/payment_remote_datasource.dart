// features/payment/data/datasources/payment_remote_datasource.dart
//
// Makes the 5 HTTP calls to Paymob.
// Throws YOUR existing exceptions — the repository maps them to Failures.

import '../../../../core/constants/paymob_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/paymob_dio_client.dart';
import '../../domain/entities/payment_entities.dart';
import '../models/payment_models.dart';
import 'dart:math';

abstract class PaymentRemoteDataSource {
  Future<AuthTokenModel> authenticate();

  Future<OrderModel> registerOrder({
    required String authToken,
    required int amountCents,
    required String currency,
    required String merchantOrderId,
  });

  Future<PaymentKeyModel> getPaymentKey({
    required String authToken,
    required int orderId,
    required int amountCents,
    required String currency,
    required int integrationId,
    required BillingDataEntity billingData,
  });

  Future<WalletPayModel> payWithWallet({
    required String paymentKey,
    required String walletPhone,
  });

  Future<TransactionModel> verifyTransaction({
    required String transactionId,
  });
}


class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final PaymobDioClient client;
  const PaymentRemoteDataSourceImpl({required this.client});

  // ── Step 1 — Authenticate ────────────────────────────────────────────────

  @override
  Future<AuthTokenModel> authenticate() async {
    final res = await client.post(
      PaymobConstants.authEndpoint,
      data: {'api_key': PaymobConstants.apiKey},
    );
    _assertOk(res.statusCode, res.data);
    return AuthTokenModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Step 2 — Register Order ──────────────────────────────────────────────

  @override
  Future<OrderModel> registerOrder({
    required String authToken,
    required int amountCents,
    required String currency,
    required String merchantOrderId,
  }) async {
    final res = await client.post(
      PaymobConstants.orderEndpoint,
      data: {
        'auth_token':        authToken,
        'delivery_needed':   false,
        'amount_cents':      amountCents,
        'currency':          currency,
        'merchant_order_id': merchantOrderId,
        'items':             [],
      },
    );
    _assertOk(res.statusCode, res.data);
    return OrderModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Step 3 — Get Payment Key ─────────────────────────────────────────────

  @override
  Future<PaymentKeyModel> getPaymentKey({
    required String authToken,
    required int orderId,
    required int amountCents,
    required String currency,
    required int integrationId,
    required BillingDataEntity billingData,
  }) async {
    final res = await client.post(
      PaymobConstants.paymentKeyEndpoint,
      data: {
        'auth_token':          authToken,
        'amount_cents':        amountCents,
        'expiration':          PaymobConstants.paymentKeyExpiration,
        'order_id':            orderId,
        'billing_data':        BillingDataModel.toJson(billingData),
        'currency':            currency,
        'integration_id':      integrationId,
        'lock_order_when_paid': false,
      },
    );
    _assertOk(res.statusCode, res.data);
    return PaymentKeyModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Step 4b — Wallet Payment ─────────────────────────────────────────────

  @override
  Future<WalletPayModel> payWithWallet({
    required String paymentKey,
    required String walletPhone,
  }) async {
    final res = await client.post(
      PaymobConstants.walletPayEndpoint,
      data: {
        'source': {
          'identifier': walletPhone,
          'subtype':    'WALLET',
        },
        'payment_token': paymentKey,
      },
    );
    _assertOk(res.statusCode, res.data);
    return WalletPayModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Step 5 — Verify Transaction ──────────────────────────────────────────

  @override
  Future<TransactionModel> verifyTransaction({
    required String transactionId,
  }) async {
    final res = await client.get(
      PaymobConstants.transactionEndpoint(transactionId),
    );
    _assertOk(res.statusCode, res.data);
    return TransactionModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ─── Guard ────────────────────────────────────────────────────────────────

  void _assertOk(int? statusCode, dynamic body) {
    if (statusCode == null) {
      throw const PaymobServerException(message: 'No response from Paymob');
    }
    if (statusCode == 401 || statusCode == 403) {
      final msg = _msg(body) ?? 'Authentication failed';
      throw PaymobAuthException(msg);
    }
    if (statusCode >= 400) {
      final msg = _msg(body) ?? 'Error $statusCode';
      throw PaymobServerException(message: msg, statusCode: statusCode);
    }
  }

  String? _msg(dynamic body) {
    if (body is Map) {
      return body['message']?.toString()
          ?? body['detail']?.toString()
          ?? body['error']?.toString();
    }
    return null;
  }
}

