import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payment_entities.dart';

abstract class PaymentRepository {
  // Exchange API key for a short-lived auth token.
  Future<Either<Failure, AuthTokenEntity>> authenticate();

  // Register the order and get an order ID.
  Future<Either<Failure, OrderEntity>> registerOrder({
    required String authToken,
    required int amountCents,
    required String currency,
    required String merchantOrderId,
  });

  // Get a payment key (used for both card and wallet).
  Future<Either<Failure, PaymentKeyEntity>> getPaymentKey({
    required String authToken,
    required int orderId,
    required int amountCents,
    required String currency,
    required int integrationId,
    required BillingDataEntity billingData,
  });

  // Initiate a mobile wallet payment and get a redirect URL.
  Future<Either<Failure, WalletPayEntity>> payWithWallet({
    required String paymentKey,
    required String walletPhone,
  });

  // Verify the final transaction status.
  Future<Either<Failure, TransactionEntity>> verifyTransaction({
    required String transactionId,
  });
}
