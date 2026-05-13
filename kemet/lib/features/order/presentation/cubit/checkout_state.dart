import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

// Order created successfully, ready for payment
class OrderCreated extends CheckoutState {
  final Order order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

// Payment confirmed and order status updated
class PaymentConfirmed extends CheckoutState {
  final Order order;

  const PaymentConfirmed(this.order);

  @override
  List<Object?> get props => [order];
}

// Error occurred during checkout
class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}
