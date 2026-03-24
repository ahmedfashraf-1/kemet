import 'package:kemet/features/cart/domain/entities/cart.dart';

class CartItemModel extends CartItem {
  CartItemModel({
    required super.cartItemId,
    required super.userId,
    required super.productId,
    required super.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: json['cart_item_id'],
      userId: json['user_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_item_id': cartItemId,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    };
  }
}