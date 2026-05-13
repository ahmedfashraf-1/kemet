import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart'; 
import '../../domain/entities/payment_entities.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; 

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

  //  map to the correct Failure

  Future<Either<Failure, T>> _run<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Right(result);
    }
    on PaymobAuthException catch (e) {
      return Left(PaymobAuthFailure(e.message));
    } on PaymobTimeoutException {
      return const Left(PaymobTimeoutFailure());
    } on PaymobServerException catch (e) {
      return Left(PaymobServerFailure(e.message));
    } on PaymobParseException catch (e) {
      return Left(PaymobParseFailure(e.message));
    }
    on OfflineException {
      return const Left(OfflineFailure());
    } on ServerException {
      return const Left(ServerFailure());
    }
    on FormatException catch (e) {
      return Left(PaymobParseFailure(e.message));
    }
    catch (e) {
      return const Left(ServerFailure());
    }
  }
}
