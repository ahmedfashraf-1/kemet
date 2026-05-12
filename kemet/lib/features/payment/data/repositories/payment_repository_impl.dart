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

  // Authenticate
  @override
  Future<Either<Failure, AuthTokenEntity>> authenticate() =>
      _run(() => remoteDataSource.authenticate());

  // Register Order
  @override
  Future<Either<Failure, OrderEntity>> registerOrder({
    required String authToken,
    required int amountCents,
    required String currency,
    required String merchantOrderId,
  }) => _run(
    () => remoteDataSource.registerOrder(
      authToken: authToken,
      amountCents: amountCents,
      currency: currency,
      merchantOrderId: merchantOrderId,
    ),
  );

  // Get Payment Key
  @override
  Future<Either<Failure, PaymentKeyEntity>> getPaymentKey({
    required String authToken,
    required int orderId,
    required int amountCents,
    required String currency,
    required int integrationId,
    required BillingDataEntity billingData,
  }) => _run(
    () => remoteDataSource.getPaymentKey(
      authToken: authToken,
      orderId: orderId,
      amountCents: amountCents,
      currency: currency,
      integrationId: integrationId,
      billingData: billingData,
    ),
  );

  //  Wallet Payment 
  @override
  Future<Either<Failure, WalletPayEntity>> payWithWallet({
    required String paymentKey,
    required String walletPhone,
  }) => _run(
    () => remoteDataSource.payWithWallet(
      paymentKey: paymentKey,
      walletPhone: walletPhone,
    ),
  );

  //  Verify Transaction 
  @override
  Future<Either<Failure, TransactionEntity>> verifyTransaction({
    required String transactionId,
  }) => _run(
    () => remoteDataSource.verifyTransaction(transactionId: transactionId),
  );

  //  Generic runner 
  //
  // Pattern:
  //   1. Run the datasource call directly
  //   2. Catch each exception type → map to the correct Failure
  //
  // We intentionally avoid a pre-flight connectivity check here because
  // InternetConnectionChecker can report false negatives on some devices,
  // which would incorrectly show the offline banner even when the backend
  // request would otherwise succeed

  Future<Either<Failure, T>> _run<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Right(result);
    }
    //  Map Paymob-specific exceptions → new Paymob failures
    on PaymobAuthException catch (e) {
      return Left(PaymobAuthFailure(e.message));
    } on PaymobTimeoutException {
      return const Left(PaymobTimeoutFailure());
    } on PaymobServerException catch (e) {
      return Left(PaymobServerFailure(e.message));
    } on PaymobParseException catch (e) {
      return Left(PaymobParseFailure(e.message));
    }
    //  Map your existing exceptions → your existing failures
    on OfflineException {
      return const Left(OfflineFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
    //  JSON parse errors from fromJson()
    on FormatException catch (e) {
      return Left(PaymobParseFailure(e.message));
    }
    //  Catch-all
    catch (e) {
      return const Left(ServerFailure());
    }
  }
}
