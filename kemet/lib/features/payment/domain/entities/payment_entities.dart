import 'package:equatable/equatable.dart';


class AuthTokenEntity extends Equatable {
  final String token;
  const AuthTokenEntity({required this.token});

  @override
  List<Object?> get props => [token];
}


class OrderEntity extends Equatable {
  final int orderId;
  final int amountCents;
  final String currency;
  final String merchantOrderId;

  const OrderEntity({
    required this.orderId,
    required this.amountCents,
    required this.currency,
    required this.merchantOrderId,
  });

  @override
  List<Object?> get props => [orderId, amountCents, currency, merchantOrderId];
}


class PaymentKeyEntity extends Equatable {
  final String paymentKey;
  const PaymentKeyEntity({required this.paymentKey});

  @override
  List<Object?> get props => [paymentKey];
}


class WalletPayEntity extends Equatable {
  final String redirectUrl;
  const WalletPayEntity({required this.redirectUrl});

  @override
  List<Object?> get props => [redirectUrl];
}


class TransactionEntity extends Equatable {
  final String transactionId;
  final bool success;
  final bool isPending;
  final int amountCents;
  final String currency;
  final String createdAt;
  final String? errorMessage;

  const TransactionEntity({
    required this.transactionId,
    required this.success,
    required this.isPending,
    required this.amountCents,
    required this.currency,
    required this.createdAt,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        transactionId, success, isPending,
        amountCents, currency, createdAt, errorMessage,
      ];
}


class BillingDataEntity extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String apartment;
  final String floor;
  final String street;
  final String building;
  final String shippingMethod;
  final String postalCode;
  final String city;
  final String country;
  final String state;

  const BillingDataEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.apartment     = 'NA',
    this.floor         = 'NA',
    this.street        = 'NA',
    this.building      = 'NA',
    this.shippingMethod = 'NA',
    this.postalCode    = 'NA',
    this.city          = 'Cairo',
    this.country       = 'EG',
    this.state         = 'Cairo',
  });

  @override
  List<Object?> get props => [firstName, lastName, email, phone];
}
