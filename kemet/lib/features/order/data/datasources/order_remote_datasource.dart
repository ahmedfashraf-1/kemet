import '../../domain/entities/order.dart';

abstract class OrderRemoteDataSource {
  // POST /orders/create — Creates an order in backend
  Future<Order> createOrder({
    required String userId,
    required List<OrderItem> items,
    required double totalPrice,
    required String billingDataJson,
  });

  // GET /orders/{orderId} — Retrieve order details
  Future<Order> getOrderById(String orderId);

  // PATCH /orders/{orderId}/payment-status — Update payment status
  Future<Order> updateOrderPaymentStatus({
    required String orderId,
    required String paymentStatus,
    required String transactionId,
  });

  // GET /orders/user/{userId} — Get user's order history
  Future<List<Order>> getUserOrders(String userId);
}
