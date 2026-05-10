import 'package:dartz/dartz.dart' as functional;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<functional.Either<Failure, Order>> createOrder({
    required String userId,
    required List<OrderItem> items,
    required double totalPrice,
    required String billingDataJson,
  }) async {
    final connected = await networkInfo.isConnected;
    if (!connected) {
      return const functional.Left(OfflineFailure());
    }

    try {
      final order = await remoteDataSource.createOrder(
        userId: userId,
        items: items,
        totalPrice: totalPrice,
        billingDataJson: billingDataJson,
      );
      return functional.Right(order);
    } on ServerException {
      return const functional.Left(ServerFailure());
    } catch (_) {
      return const functional.Left(ServerFailure());
    }
  }

  @override
  Future<functional.Either<Failure, Order>> getOrderById(String orderId) async {
    final connected = await networkInfo.isConnected;
    if (!connected) {
      return const functional.Left(OfflineFailure());
    }

    try {
      final order = await remoteDataSource.getOrderById(orderId);
      return functional.Right(order);
    } on ServerException {
      return const functional.Left(ServerFailure());
    } catch (_) {
      return const functional.Left(ServerFailure());
    }
  }

  @override
  Future<functional.Either<Failure, Order>> updateOrderPaymentStatus({
    required String orderId,
    required String paymentStatus,
    required String transactionId,
  }) async {
    final connected = await networkInfo.isConnected;
    if (!connected) {
      return const functional.Left(OfflineFailure());
    }

    try {
      final order = await remoteDataSource.updateOrderPaymentStatus(
        orderId: orderId,
        paymentStatus: paymentStatus,
        transactionId: transactionId,
      );
      return functional.Right(order);
    } on ServerException {
      return const functional.Left(ServerFailure());
    } catch (_) {
      return const functional.Left(ServerFailure());
    }
  }

  @override
  Future<functional.Either<Failure, List<Order>>> getUserOrders(
    String userId,
  ) async {
    final connected = await networkInfo.isConnected;
    if (!connected) {
      return const functional.Left(OfflineFailure());
    }

    try {
      final orders = await remoteDataSource.getUserOrders(userId);
      return functional.Right(orders);
    } on ServerException {
      return const functional.Left(ServerFailure());
    } catch (_) {
      return const functional.Left(ServerFailure());
    }
  }
}
