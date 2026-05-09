import '../entities/product.dart';

abstract class StoreRepository {
  Future<List<Product>> getProducts();
}