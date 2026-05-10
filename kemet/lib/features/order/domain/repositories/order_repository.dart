import 'package:dartz/dartz.dart' as functional;
import '../../../../core/errors/failures.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  /// Create a new order from cart items
  Future<functional.Either<Failure, Order>> createOrder({
    required String userId,
    required List<OrderItem> items,
    required double totalPrice,
    required String billingDataJson,
  });

  /// Get order by ID
  Future<functional.Either<Failure, Order>> getOrderById(String orderId);

  /// Update order payment status after successful payment
  Future<functional.Either<Failure, Order>> updateOrderPaymentStatus({
    required String orderId,
    required String paymentStatus,
    required String transactionId,
  });

  /// Get order history for user
  Future<functional.Either<Failure, List<Order>>> getUserOrders(String userId);
}
