import '../../domain/entities/order.dart';

class OrderModel extends Order {
  OrderModel({
    required super.orderId,
    required super.userId,
    required super.items,
    required super.totalPrice,
    required super.orderStatus,
    required super.paymentStatus,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'],
      userId: json['user_id'],
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
      totalPrice: json['total_price'].toDouble(),
      orderStatus: json['order_status'],
      paymentStatus: json['payment_status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'user_id': userId,
      'items': items.map((e) => (e as OrderItemModel).toJson()).toList(),
      'total_price': totalPrice,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class OrderItemModel extends OrderItem {
  OrderItemModel({
    required super.productId,
    required super.quantity,
    required super.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}