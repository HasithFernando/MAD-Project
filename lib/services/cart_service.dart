import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final _db = FirebaseFirestore.instance;

  // Add item to user's cart
  Future<void> addToCart(String userId, String productId, int quantity) async {
    await _db.collection('users').doc(userId).collection('carts').add({
      'productId': productId,
      'quantity': quantity,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove item from cart
  Future<void> removeFromCart(String userId, String cartItemId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('carts')
        .doc(cartItemId)
        .delete();
  }

  // Get all cart items for a user
  Stream<List<Map<String, dynamic>>> getCartItems(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('carts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'productId': doc['productId'],
                  'quantity': doc['quantity'],
                })
            .toList());
  }

  // Clear all cart items
  Future<void> clearCart(String userId) async {
    final cartSnapshot =
        await _db.collection('users').doc(userId).collection('carts').get();

    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
