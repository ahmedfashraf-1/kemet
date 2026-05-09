import 'package:kemet/features/store/domain/entities/cart_repository.dart';

import '../entities/cart.dart';
import '../entities/product.dart';
import '../repositories/cart_repository_impl.dart';

class AddToCartUseCase {
  final CartRepository repository;
  const AddToCartUseCase(this.repository);

  Future<Cart> call(Product product, int quantity) =>
      repository.addToCart(product, quantity);
}