import 'package:equatable/equatable.dart';
import '../../domain/entities/cart.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final Cart cart;

  const CartLoaded(this.cart);

  int get itemCount => cart.itemCount;
  double get total => cart.total;

  @override
  List<Object?> get props => [cart.items];
}

class CartError extends CartState {
  final String message;
  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}