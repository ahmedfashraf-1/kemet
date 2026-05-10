import 'package:uuid/uuid.dart';
import '../../domain/entities/order.dart';
import 'order_remote_datasource.dart';

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  /// TODO: Inject HTTP client when backend endpoints are ready

  @override
  Future<Order> createOrder({
    required String userId,
    required List<OrderItem> items,
    required double totalPrice,
    required String billingDataJson,
  }) async {
    // TODO: Replace with actual HTTP POST /orders/create
    // For now: generate mock order
    await Future.delayed(const Duration(milliseconds: 500));

    return Order(
      orderId: const Uuid().v4(),
      userId: userId,
      items: items,
      totalPrice: totalPrice,
      orderStatus: 'PENDING',
      paymentStatus: 'PENDING',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Order> getOrderById(String orderId) async {
    // TODO: Replace with actual HTTP GET /orders/{orderId}
    await Future.delayed(const Duration(milliseconds: 300));

    return Order(
      orderId: orderId,
      userId: '',
      items: const [],
      totalPrice: 0,
      orderStatus: 'PENDING',
      paymentStatus: 'PENDING',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Order> updateOrderPaymentStatus({
    required String orderId,
    required String paymentStatus,
    required String transactionId,
  }) async {
    // TODO: Replace with actual HTTP PATCH /orders/{orderId}/payment-status
    await Future.delayed(const Duration(milliseconds: 300));

    return Order(
      orderId: orderId,
      userId: '',
      items: const [],
      totalPrice: 0,
      orderStatus: paymentStatus == 'PAID' ? 'CONFIRMED' : 'PENDING',
      paymentStatus: paymentStatus,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<Order>> getUserOrders(String userId) async {
    // TODO: Replace with actual HTTP GET /orders/user/{userId}
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }
}
