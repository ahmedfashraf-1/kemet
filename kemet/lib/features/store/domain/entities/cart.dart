import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Cart {
  final List<CartItem> items;

  const Cart({this.items = const []});

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  bool get hasFreeShipping => subtotal > 500;
  double get shippingFee => hasFreeShipping ? 0 : (items.isEmpty ? 0 : 50);
  double get tax => subtotal * 0.14;
  double get total => subtotal + shippingFee + tax;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}