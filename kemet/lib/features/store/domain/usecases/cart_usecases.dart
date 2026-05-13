import 'package:kemet/features/store/domain/repositories/cart_repository.dart';

import '../entities/cart.dart';
import '../../data/repositories/cart_repository_impl.dart';

class GetCartUseCase {
  final CartRepository repository;
  const GetCartUseCase(this.repository);
  Future<Cart> call() => repository.getCart();
}

class UpdateQuantityUseCase {
  final CartRepository repository;
  const UpdateQuantityUseCase(this.repository);
  Future<Cart> call(String productId, int quantity) =>
      repository.updateQuantity(productId, quantity);
}

class RemoveFromCartUseCase {
  final CartRepository repository;
  const RemoveFromCartUseCase(this.repository);
  Future<Cart> call(String productId) => repository.removeFromCart(productId);
}

class ClearCartUseCase {
  final CartRepository repository;
  const ClearCartUseCase(this.repository);
  Future<void> call() => repository.clearCart();
}