import '../entities/cart.dart';
import '../entities/product.dart';

abstract class CartRepository {
  Future<Cart> getCart();
  Future<Cart> addToCart(Product product, int quantity);
  Future<Cart> updateQuantity(String productId, int quantity);
  Future<Cart> removeFromCart(String productId);
  Future<void> clearCart();
}