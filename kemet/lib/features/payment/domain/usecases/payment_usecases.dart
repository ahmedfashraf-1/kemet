import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payment_entities.dart';
import '../repositories/payment_repository.dart';

// Authenticate 

class AuthenticateUseCase {
  final PaymentRepository repository;
  const AuthenticateUseCase(this.repository);

  Future<Either<Failure, AuthTokenEntity>> call() =>
      repository.authenticate();
}

// Register Order

class RegisterOrderParams {
  final String authToken;
  final int amountCents;
  final String currency;
  final String merchantOrderId;

  const RegisterOrderParams({
    required this.authToken,
    required this.amountCents,
    required this.currency,
    required this.merchantOrderId,
  });
}

class RegisterOrderUseCase {
  final PaymentRepository repository;
  const RegisterOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(RegisterOrderParams p) =>
      repository.registerOrder(
        authToken: p.authToken,
        amountCents: p.amountCents,
        currency: p.currency,
        merchantOrderId: p.merchantOrderId,
      );
}

// Get Payment Key

class GetPaymentKeyParams {
  final String authToken;
  final int orderId;
  final int amountCents;
  final String currency;
  final int integrationId;
  final BillingDataEntity billingData;

  const GetPaymentKeyParams({
    required this.authToken,
    required this.orderId,
    required this.amountCents,
    required this.currency,
    required this.integrationId,
    required this.billingData,
  });
}

class GetPaymentKeyUseCase {
  final PaymentRepository repository;
  const GetPaymentKeyUseCase(this.repository);

  Future<Either<Failure, PaymentKeyEntity>> call(GetPaymentKeyParams p) =>
      repository.getPaymentKey(
        authToken: p.authToken,
        orderId: p.orderId,
        amountCents: p.amountCents,
        currency: p.currency,
        integrationId: p.integrationId,
        billingData: p.billingData,
      );
}

// Pay with Wallet

class WalletPayParams {
  final String paymentKey;
  final String walletPhone;
  const WalletPayParams({required this.paymentKey, required this.walletPhone});
}

class PayWithWalletUseCase {
  final PaymentRepository repository;
  const PayWithWalletUseCase(this.repository);

  Future<Either<Failure, WalletPayEntity>> call(WalletPayParams p) =>
      repository.payWithWallet(
        paymentKey: p.paymentKey,
        walletPhone: p.walletPhone,
      );
}

// Verify Transaction

class VerifyTransactionUseCase {
  final PaymentRepository repository;
  const VerifyTransactionUseCase(this.repository);

  Future<Either<Failure, TransactionEntity>> call(String transactionId) =>
      repository.verifyTransaction(transactionId: transactionId);
}
