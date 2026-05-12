// features/payment/presentation/cubit/payment_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/payment_entities.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}


class PaymentInitial extends PaymentState {
  const PaymentInitial();
}


class PaymentAuthenticating extends PaymentState {
  const PaymentAuthenticating();
}

class PaymentRegisteringOrder extends PaymentState {
  const PaymentRegisteringOrder();
}

class PaymentGettingKey extends PaymentState {
  const PaymentGettingKey();
}

class PaymentWalletLoading extends PaymentState {
  const PaymentWalletLoading();
}

class PaymentVerifying extends PaymentState {
  const PaymentVerifying();
}


class PaymentCardReady extends PaymentState {
  final String iframeUrl;
  const PaymentCardReady({required this.iframeUrl});

  @override
  List<Object?> get props => [iframeUrl];
}

class PaymentWalletReady extends PaymentState {
  final String redirectUrl;
  const PaymentWalletReady({required this.redirectUrl});

  @override
  List<Object?> get props => [redirectUrl];
}


class PaymentSuccess extends PaymentState {
  final TransactionEntity transaction;
  const PaymentSuccess({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class PaymentFailed extends PaymentState {
  final String message;
  const PaymentFailed({required this.message});

  @override
  List<Object?> get props => [message];
}

class PaymentCancelled extends PaymentState {
  const PaymentCancelled();
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError({required this.message});

  @override
  List<Object?> get props => [message];
}
