// features/payment/data/models/payment_models.dart
//
// Each model extends its domain entity and adds fromJson.
// Only the data layer touches these — domain uses the entity directly.

import '../../domain/entities/payment_entities.dart';

// ─── Auth ─────────────────────────────────────────────────────────────────────

class AuthTokenModel extends AuthTokenEntity {
  const AuthTokenModel({required super.token});

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    final token = json['token']?.toString();
    if (token == null || token.isEmpty) {
      throw const FormatException('Missing auth token in Paymob response');
    }
    return AuthTokenModel(token: token);
  }
}

// ─── Order ────────────────────────────────────────────────────────────────────

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.amountCents,
    required super.currency,
    required super.merchantOrderId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id == null) throw const FormatException('Missing order id');
    return OrderModel(
      orderId: _asInt(id),
      amountCents: _asInt(json['amount_cents']),
      currency: json['currency']?.toString() ?? 'EGP',
      merchantOrderId: json['merchant_order_id']?.toString() ?? '',
    );
  }
}

// ─── Payment Key ──────────────────────────────────────────────────────────────

class PaymentKeyModel extends PaymentKeyEntity {
  const PaymentKeyModel({required super.paymentKey});

  factory PaymentKeyModel.fromJson(Map<String, dynamic> json) {
    final token = json['token']?.toString();
    if (token == null || token.isEmpty) {
      throw const FormatException('Missing payment key in Paymob response');
    }
    return PaymentKeyModel(paymentKey: token);
  }
}

// ─── Wallet Pay ───────────────────────────────────────────────────────────────

class WalletPayModel extends WalletPayEntity {
  const WalletPayModel({required super.redirectUrl});

  factory WalletPayModel.fromJson(Map<String, dynamic> json) {
    final url = json['redirect_url']?.toString()
        ?? json['iframe_redirection_url']?.toString()
        ?? '';
    if (url.isEmpty) {
      throw const FormatException('Missing wallet redirect URL');
    }
    return WalletPayModel(redirectUrl: url);
  }
}

// ─── Transaction ──────────────────────────────────────────────────────────────

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.transactionId,
    required super.success,
    required super.isPending,
    required super.amountCents,
    required super.currency,
    required super.createdAt,
    super.errorMessage,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Error message is nested inside the "data" object
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return TransactionModel(
      transactionId: json['id']?.toString() ?? '',
      success: json['success'] as bool? ?? false,
      isPending: json['pending'] as bool? ?? false,
      amountCents: _asInt(json['amount_cents']),
      currency: json['currency']?.toString() ?? 'EGP',
      createdAt: json['created_at']?.toString() ?? '',
      errorMessage: data['message']?.toString(),
    );
  }
}

// ─── Billing Data serialiser ──────────────────────────────────────────────────

class BillingDataModel {
  /// Converts a [BillingDataEntity] into the JSON map Paymob expects.
  static Map<String, dynamic> toJson(BillingDataEntity e) => {
        'apartment':       e.apartment,
        'email':           e.email,
        'floor':           e.floor,
        'first_name':      e.firstName,
        'street':          e.street,
        'building':        e.building,
        'phone_number':    e.phone,
        'shipping_method': e.shippingMethod,
        'postal_code':     e.postalCode,
        'city':            e.city,
        'country':         e.country,
        'last_name':       e.lastName,
        'state':           e.state,
      };
}

// ─── Helper ───────────────────────────────────────────────────────────────────

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}
