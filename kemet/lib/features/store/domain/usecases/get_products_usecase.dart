import '../../domain/repositories/store_repository.dart';
import '../../domain/entities/product.dart';

class GetProductsUseCase {
  final StoreRepository repository;
  GetProductsUseCase(this.repository);

  Future<List<Product>> call() async {
    return await repository.getProducts();
  }
}