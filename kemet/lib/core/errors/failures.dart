import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {const Failure();}

class OfflineFailure extends Failure {
  const OfflineFailure(); 
  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  const ServerFailure();
  @override
  List<Object?> get props => [];
}

class EmptyCacheFailure extends Failure {
  const EmptyCacheFailure();
  @override
  List<Object?> get props => [];
}

// Paymob API key is invalid or the auth token expired
class PaymobAuthFailure extends Failure {
  final String message;
  const PaymobAuthFailure([this.message = 'Authentication failed']);

  @override
  List<Object?> get props => [message];
}

// Paymob returned a non-success HTTP response
class PaymobServerFailure extends Failure {
  final String message;
  const PaymobServerFailure([this.message = 'Paymob server error']);

  @override
  List<Object?> get props => [message];
}

// Request to Paymob timed out.
class PaymobTimeoutFailure extends Failure {
  const PaymobTimeoutFailure();

  @override
  List<Object?> get props => [];
}

// Response body from Paymob could not be parsed
class PaymobParseFailure extends Failure {
  final String message;
  const PaymobParseFailure([this.message = 'Invalid response from Paymob']);

  @override
  List<Object?> get props => [message];
}

// User closed the WebView before completing payment
class PaymentCancelledFailure extends Failure {
  const PaymentCancelledFailure();

  @override
  List<Object?> get props => [];
}

// Transaction was declined by the bank or wallet
class PaymentDeclinedFailure extends Failure {
  final String message;
  const PaymentDeclinedFailure([this.message = 'Payment was declined']);

  @override
  List<Object?> get props => [message];
}

