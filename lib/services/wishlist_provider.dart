import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import 'package:flutter/foundation.dart';

class WishlistService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> toggleFavorite(Product product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final wishlistRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(product.id);

    final docSnapshot = await wishlistRef.get();

    if (docSnapshot.exists) {
      // Remove from wishlist
      await wishlistRef.delete();
    } else {
      // Add to wishlist
      await wishlistRef.set({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrls': product.imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        // Add more if needed
      });
    }
  }

  Future<bool> isFavorite(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId)
        .get();

    return doc.exists;
  }
}
