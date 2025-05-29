import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:thriftale/models/product_model.dart';
import 'package:image_picker/image_picker.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Public getter to access the Firestore instance
  FirebaseFirestore get firestore => _firestore;

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

  // Function to delete an image from Firebase Storage
  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('Image deleted from storage: $imageUrl');
    } on FirebaseException catch (e) {
      print('Error deleting image from storage: ${e.message}');
      // It's okay if the image doesn't exist anymore, just log the error.
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
    String? productId, // Optional for new product, will be generated if null
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

  // NEW: Function to update an existing product
  Future<void> updateProduct(Product product, List<XFile> newImages) async {
    try {
      // 1. Upload new images if any
      List<String> uploadedNewImageUrls = [];
      for (XFile imageFile in newImages) {
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
        Reference storageRef =
            _storage.ref().child('product_images/${product.id}/$fileName');
        UploadTask uploadTask = storageRef.putFile(File(imageFile.path));
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        uploadedNewImageUrls.add(downloadUrl);
      }

      // 2. Combine existing image URLs with newly uploaded ones
      List<String> finalImageUrls =
          List.from(product.imageUrls) // Existing URLs from the product object
            ..addAll(uploadedNewImageUrls); // Add newly uploaded URLs

      // 3. Prepare data for Firestore update
      Map<String, dynamic> productData =
          product.toFirestore(); // Use your toFirestore method
      productData['imageUrls'] =
          finalImageUrls; // Override with the final combined list

      // 4. Update the document in Firestore
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(productData);
      print('Product ${product.id} updated successfully!');
    } catch (e) {
      print('Error updating product: $e');
      rethrow; // Re-throw the error so the UI can catch it
    }
  }

  // NEW: Function to delete a product and its associated images
  Future<void> deleteProduct(String productId) async {
    try {
      // First, get the product document to retrieve image URLs
      DocumentSnapshot productDoc =
          await _firestore.collection('products').doc(productId).get();

      if (productDoc.exists) {
        List<String> imageUrls =
            (productDoc.data() as Map<String, dynamic>)['imageUrls']
                    ?.cast<String>() ??
                [];

        // Delete each image from Firebase Storage
        for (String imageUrl in imageUrls) {
          await deleteImageFromStorage(imageUrl);
        }

        // Then, delete the product document from Firestore
        await _firestore.collection('products').doc(productId).delete();
        print('Product and its images deleted successfully: $productId');
      } else {
        print('Product with ID $productId not found.');
      }
    } on FirebaseException catch (e) {
      print('Error deleting product: ${e.message}');
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

  // Method to get ALL products (e.g., for the home page feed)
  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection('products')
        .orderBy('timestamp', descending: true) // Order by latest products
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<Product?> getProductById(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }

  Future<List<Product>> getProductsByCategory(String categoryName) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: categoryName)
          .get();

      return snapshot.docs
          .map((doc) =>
              Product.fromFirestore(doc)) // doc is already DocumentSnapshot
          .toList();
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }
}
