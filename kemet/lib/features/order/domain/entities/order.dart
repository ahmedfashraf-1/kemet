class Order {
  final String orderId;
  final String userId;
  final List<OrderItem> items;
  final double totalPrice;
  final String orderStatus;   
  final String paymentStatus;
  final DateTime createdAt;  

  const Order({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.orderStatus,
    required this.paymentStatus,
    required this.createdAt,
  });
}

class OrderItem {
  final String productId;
  final int quantity;
  final double price;

  const OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });
}