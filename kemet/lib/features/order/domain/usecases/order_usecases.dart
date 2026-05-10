import 'package:dartz/dartz.dart' as functional;
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

/// Create an order from checkout
class CreateOrderUseCase {
  final OrderRepository repository;

  const CreateOrderUseCase(this.repository);

  Future<functional.Either<Failure, Order>> call({
    required String userId,
    required List<OrderItem> items,
    required double totalPrice,
    required String billingDataJson,
  }) => repository.createOrder(
    userId: userId,
    items: items,
    totalPrice: totalPrice,
    billingDataJson: billingDataJson,
  );
}

/// Retrieve order by ID
class GetOrderUseCase {
  final OrderRepository repository;

  const GetOrderUseCase(this.repository);

  Future<functional.Either<Failure, Order>> call(String orderId) =>
      repository.getOrderById(orderId);
}

/// Update order payment status after Paymob verification
class UpdateOrderPaymentStatusUseCase {
  final OrderRepository repository;

  const UpdateOrderPaymentStatusUseCase(this.repository);

  Future<functional.Either<Failure, Order>> call({
    required String orderId,
    required String paymentStatus,
    required String transactionId,
  }) => repository.updateOrderPaymentStatus(
    orderId: orderId,
    paymentStatus: paymentStatus,
    transactionId: transactionId,
  );
}

/// Get user's order history
class GetUserOrdersUseCase {
  final OrderRepository repository;

  const GetUserOrdersUseCase(this.repository);

  Future<functional.Either<Failure, List<Order>>> call(String userId) =>
      repository.getUserOrders(userId);
}
