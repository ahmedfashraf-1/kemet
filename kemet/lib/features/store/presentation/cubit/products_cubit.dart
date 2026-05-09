import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/features/store/presentation/cubit/products_state.dart';
import 'package:kemet/features/store/domain/usecases/get_products_usecase.dart';



class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUseCase getProductsUseCase;

  ProductsCubit(this.getProductsUseCase)
      : super(const ProductsLoading());

Future<void> getProducts() async {
    emit(const ProductsLoading());
    try {
      final products = await getProductsUseCase();
      print("Success: Fetched ${products.length} products"); 
      if (products.isEmpty) {
        emit(const ProductsEmpty());
      } else {
        emit(ProductsSuccess(products));
      }
    } catch (e) {
      print("Error fetching products: $e"); 
      emit(ProductsError(e.toString()));
    }
  }
}