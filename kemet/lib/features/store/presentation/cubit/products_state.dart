import 'package:equatable/equatable.dart';
import 'package:kemet/features/store/domain/entities/product.dart';


abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsSuccess extends ProductsState {
  final List<Product> products;
  const ProductsSuccess(this.products);

   @override
  List<Object?> get props => [products];
}

class ProductsEmpty extends ProductsState {
  const ProductsEmpty();
}

class ProductsError extends ProductsState {
  final String message;
  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}
