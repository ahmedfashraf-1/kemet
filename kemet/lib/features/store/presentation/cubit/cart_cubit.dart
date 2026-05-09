import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/cart_usecases.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final GetCartUseCase getCart;
  final AddToCartUseCase addToCart;
  final UpdateQuantityUseCase updateQuantity;
  final RemoveFromCartUseCase removeFromCart;
  final ClearCartUseCase clearCart;

  CartCubit({
    required this.getCart,
    required this.addToCart,
    required this.updateQuantity,
    required this.removeFromCart,
    required this.clearCart,
  }) : super(const CartInitial());

  Future<void> loadCart() async {
    emit(const CartLoading());
    try {
      final cart = await getCart();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> add(Product product, int quantity) async {
    try {
      final cart = await addToCart(product, quantity);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> update(String productId, int quantity) async {
    try {
      final cart = await updateQuantity(productId, quantity);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> remove(String productId) async {
    try {
      final cart = await removeFromCart(productId);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> clear() async {
    try {
      await clearCart();
      final cart = await getCart();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  /// كمية منتج معين في السلة الحالية
  int quantityOf(String productId) {
    if (state is CartLoaded) {
      final items = (state as CartLoaded).cart.items;
      final match = items.where((i) => i.product.productId == productId);
      return match.isEmpty ? 0 : match.first.quantity;
    }
    return 0;
  }
}