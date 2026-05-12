import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kemet/features/store/domain/entities/cart.dart';
import 'package:kemet/features/payment/domain/entities/payment_entities.dart';
import '../../domain/usecases/order_usecases.dart';
import '../../../../core/utils/cart_to_order_converter.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CreateOrderUseCase createOrder;
  final GetOrderUseCase getOrder;
  final UpdateOrderPaymentStatusUseCase updatePaymentStatus;

  CheckoutCubit({
    required this.createOrder,
    required this.getOrder,
    required this.updatePaymentStatus,
  }) : super(const CheckoutInitial());

  // Create order from cart and proceed to payment
  Future<void> createOrderFromCart({
    required Cart cart,
    required BillingDataEntity billingData,
  }) async {
    emit(const CheckoutLoading());

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      emit(const CheckoutError('User not authenticated'));
      return;
    }

    try {
      // Convert cart items to order items
      final orderItems = CartToOrderConverter.convertItems(cart.items);
      final billingDataJson = CartToOrderConverter.billingDataToJson(
        billingData,
      );

      final result = await createOrder(
        userId: userId,
        items: orderItems,
        totalPrice: cart.total,
        billingDataJson: billingDataJson,
      );

      result.fold(
        (failure) => emit(CheckoutError(failure.toString())),
        (order) => emit(OrderCreated(order)),
      );
    } catch (e) {
      emit(CheckoutError('Failed to create order: $e'));
    }
  }

  // Update order status after successful payment
  Future<void> markPaymentSuccess({
    required String orderId,
    required String transactionId,
  }) async {
    emit(const CheckoutLoading());

    try {
      final result = await updatePaymentStatus(
        orderId: orderId,
        paymentStatus: 'PAID',
        transactionId: transactionId,
      );

      result.fold(
        (failure) => emit(CheckoutError(failure.toString())),
        (order) => emit(PaymentConfirmed(order)),
      );
    } catch (e) {
      emit(CheckoutError('Failed to confirm payment: $e'));
    }
  }

  // Reset checkout state
  void reset() => emit(const CheckoutInitial());

 
}
