import 'package:flutter_bloc/flutter_bloc.dart';

// ── States ──────────────────────────────────────────────────────────────────

class ProductDetailState {
  final int selectedImageIndex;
  final int quantity;

  const ProductDetailState({
    this.selectedImageIndex = 0,
    this.quantity = 1,
  });

  ProductDetailState copyWith({int? selectedImageIndex, int? quantity}) {
    return ProductDetailState(
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
      quantity: quantity ?? this.quantity,
    );
  }
}

// ── Cubit ────────────────────────────────────────────────────────────────────

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit() : super(const ProductDetailState());

  void selectImage(int index) =>
      emit(state.copyWith(selectedImageIndex: index));

  void increment(int maxStock) {
    if (state.quantity < maxStock) {
      emit(state.copyWith(quantity: state.quantity + 1));
    }
  }

  void decrement() {
    if (state.quantity > 1) {
      emit(state.copyWith(quantity: state.quantity - 1));
    }
  }

  void reset() => emit(const ProductDetailState());
}