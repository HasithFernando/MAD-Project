class CartItem {
  final String id;
  final String productId;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'quantity': quantity,
      };

  factory CartItem.fromMap(String id, Map<String, dynamic> map) {
    return CartItem(
      id: id,
      productId: map['productId'],
      quantity: map['quantity'],
    );
  }
}
