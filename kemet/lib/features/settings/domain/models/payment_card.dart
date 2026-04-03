class PaymentCard {
  final String id;
  final String brand;
  final String last4;
  final String holderName;
  final String expiry;
  final bool isDefault;

  const PaymentCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.holderName,
    required this.expiry,
    required this.isDefault,
  });

  PaymentCard copyWith({
    String? id,
    String? brand,
    String? last4,
    String? holderName,
    String? expiry,
    bool? isDefault,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      holderName: holderName ?? this.holderName,
      expiry: expiry ?? this.expiry,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory PaymentCard.fromMap(Map<String, dynamic> map) {
    return PaymentCard(
      id: map['id'] as String,
      brand: map['brand'] as String,
      last4: map['last4'] as String,
      holderName: map['holderName'] as String,
      expiry: map['expiry'] as String,
      isDefault: map['isDefault'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'last4': last4,
      'holderName': holderName,
      'expiry': expiry,
      'isDefault': isDefault,
    };
  }
}

