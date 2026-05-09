import 'package:kemet/features/store/domain/entities/cart_repository.dart';

import '../../domain/entities/cart.dart';
import '../../domain/entities/product.dart';
import 'cart_repository_impl.dart';

class CartRepositoryImpl implements CartRepository {
  final List<CartItem> _items = [];

  @override
  Future<Cart> getCart() async => Cart(items: List.unmodifiable(_items));

  @override
  Future<Cart> addToCart(Product product, int quantity) async {
    final index = _items.indexWhere((i) => i.product.productId == product.productId);
    if (index >= 0) {
      final newQty = (_items[index].quantity + quantity).clamp(1, product.stock);
      _items[index] = _items[index].copyWith(quantity: newQty);
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity.clamp(1, product.stock),
      ));
    }
    return Cart(items: List.unmodifiable(_items));
  }

  @override
  Future<Cart> updateQuantity(String productId, int quantity) async {
    final index = _items.indexWhere((i) => i.product.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
    }
    return Cart(items: List.unmodifiable(_items));
  }

  @override
  Future<Cart> removeFromCart(String productId) async {
    _items.removeWhere((i) => i.product.productId == productId);
    return Cart(items: List.unmodifiable(_items));
  }

  @override
  Future<void> clearCart() async => _items.clear();
}