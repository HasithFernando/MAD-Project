class PaymentMethod {
  final String id;
  final String type; // 'visa', 'mastercard', 'amex'
  final String cardNumber;
  final String cardHolderName;
  final int expiryMonth;
  final int expiryYear;
  final String cvv;
  final bool isDefault;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    this.isDefault = false,
    required this.createdAt,
  });

  // Get last four digits for display
  String get lastFourDigits => cardNumber.length >= 4
      ? cardNumber.substring(cardNumber.length - 4)
      : cardNumber;

  // Get masked card number
  String get maskedCardNumber =>
      cardNumber.length >= 4 ? '**** **** **** ${lastFourDigits}' : cardNumber;

  factory PaymentMethod.fromMap(Map<String, dynamic> map, String id) {
    return PaymentMethod(
      id: id,
      type: map['type'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      cardHolderName: map['cardHolderName'] ?? '',
      expiryMonth: map['expiryMonth'] ?? 1,
      expiryYear: map['expiryYear'] ?? 2024,
      cvv: map['cvv'] ?? '',
      isDefault: map['isDefault'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'isDefault': isDefault,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  PaymentMethod copyWith({
    String? id,
    String? type,
    String? cardNumber,
    String? cardHolderName,
    int? expiryMonth,
    int? expiryYear,
    String? cvv,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cvv: cvv ?? this.cvv,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
