import '../../domain/entities/product.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_datasource.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreDataSource remoteDataSource;

  StoreRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Product>> getProducts() async {
    return await remoteDataSource.getProducts();
  }
}