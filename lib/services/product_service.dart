import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure this is imported
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:thriftale/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // NEW: Public getter to access the Firestore instance
  FirebaseFirestore get firestore => _firestore; // <--- Add this getter

  // Function to upload an image to Firebase Storage
  Future<String?> uploadProductImage(File imageFile, String productId) async {
    try {
      String fileName =
          'product_images/$productId/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Error uploading image: ${e.message}');
      return null;
    }
  }

  // Modified function to add a new product to Firestore
  Future<void> addProduct({
    required String name,
    required double price,
    required String description,
    required String category,
    required String size,
    required Color color,
    required List<String> imageUrls,
    required String sellerId,
    required String sellerName,
    required String location,
    required double co2Saved,
    String? productId,
  }) async {
    try {
      DocumentReference docRef = productId != null
          ? _firestore.collection('products').doc(productId)
          : _firestore.collection('products').doc();

      await docRef.set({
        'name': name,
        'price': price,
        'description': description,
        'category': category,
        'size': size,
        'color': color.value,
        'imageUrls': imageUrls,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'location': location,
        'co2Saved': co2Saved,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Product added successfully to Firestore with ID: ${docRef.id}');
    } on FirebaseException catch (e) {
      print('Error adding product to Firestore: ${e.message}');
      rethrow;
    }
  }

  Stream<List<Product>> getMyProducts(String userId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // NEW: Method to get ALL products (e.g., for the home page feed)
  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection('products')
        .orderBy('timestamp', descending: true) // Order by latest products
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }
}
