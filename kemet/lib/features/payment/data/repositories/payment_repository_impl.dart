// features/payment/data/repositories/payment_repository_impl.dart
//
// Bridges data ↔ domain.
// Catches exceptions thrown by the datasource and maps them to
// YOUR existing Failure subclasses (+ new Paymob-specific ones).
// Uses YOUR existing NetworkInfo interface (InternetConnectionChecker).

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart'; // YOUR existing NetworkInfo
import '../../domain/entities/payment_entities.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; // ← uses YOUR InternetConnectionChecker impl

  const PaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // ── 1. Authenticate ───────────────────────────────────────────────────────
  @override
  Future<Either<Failure, AuthTokenEntity>> authenticate() =>
      _run(() => remoteDataSource.authenticate());

  // ── 2. Register Order ─────────────────────────────────────────────────────
  @override
  Future<Either<Failure, OrderEntity>> registerOrder({
    required String authToken,
    required int amountCents,
    required String currency,
    required String merchantOrderId,
  }) =>
      _run(() => remoteDataSource.registerOrder(
            authToken: authToken,
            amountCents: amountCents,
            currency: currency,
            merchantOrderId: merchantOrderId,
          ));

  // ── 3. Get Payment Key ────────────────────────────────────────────────────
  @override
  Future<Either<Failure, PaymentKeyEntity>> getPaymentKey({
    required String authToken,
    required int orderId,
    required int amountCents,
    required String currency,
    required int integrationId,
    required BillingDataEntity billingData,
  }) =>
      _run(() => remoteDataSource.getPaymentKey(
            authToken: authToken,
            orderId: orderId,
            amountCents: amountCents,
            currency: currency,
            integrationId: integrationId,
            billingData: billingData,
          ));

  // ── 4. Wallet Payment ─────────────────────────────────────────────────────
  @override
  Future<Either<Failure, WalletPayEntity>> payWithWallet({
    required String paymentKey,
    required String walletPhone,
  }) =>
      _run(() => remoteDataSource.payWithWallet(
            paymentKey: paymentKey,
            walletPhone: walletPhone,
          ));

  // ── 5. Verify Transaction ─────────────────────────────────────────────────
  @override
  Future<Either<Failure, TransactionEntity>> verifyTransaction({
    required String transactionId,
  }) =>
      _run(() => remoteDataSource.verifyTransaction(
            transactionId: transactionId,
          ));

  // ─── Generic runner ───────────────────────────────────────────────────────
  //
  // Pattern:
  //   1. Check connectivity using YOUR NetworkInfo
  //   2. Run the datasource call
  //   3. Catch each exception type → map to the correct Failure

  Future<Either<Failure, T>> _run<T>(
    Future<T> Function() call,
  ) async {
    // ① Use YOUR existing NetworkInfo (InternetConnectionChecker)
    final connected = await networkInfo.isConnected;
    if (!connected) {
      return const Left(OfflineFailure()); // YOUR existing OfflineFailure
    }

    try {
      final result = await call();
      return Right(result);
    }

    // ② Map Paymob-specific exceptions → new Paymob failures
    on PaymobAuthException catch (e) {
      return Left(PaymobAuthFailure(e.message));
    }
    on PaymobTimeoutException {
      return const Left(PaymobTimeoutFailure());
    }
    on PaymobServerException catch (e) {
      return Left(PaymobServerFailure(e.message));
    }
    on PaymobParseException catch (e) {
      return Left(PaymobParseFailure(e.message));
    }

    // ③ Map your existing exceptions → your existing failures
    on OfflineException {
      return const Left(OfflineFailure());
    }
    on ServerException {
      return const Left(ServerFailure());
    }

    // ④ JSON parse errors from fromJson()
    on FormatException catch (e) {
      return Left(PaymobParseFailure(e.message));
    }

    // ⑤ Catch-all
    catch (e) {
      return const Left(ServerFailure());
    }
  }
}
