import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Product {
  final String id; // Document ID from Firestore
  final String name;
  final double price;
  final String description;
  final String category;
  final String size;
  final Color color;
  final List<String> imageUrls;
  final String sellerId;
  final String sellerName;
  final String location;
  final double co2Saved;
  final Timestamp timestamp; // Use Timestamp for server-side timestamp

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.size,
    required this.color,
    required this.imageUrls,
    required this.sellerId,
    required this.sellerName,
    required this.location,
    required this.co2Saved,
    required this.timestamp,
  });

  // Factory constructor to create a Product from a Firestore DocumentSnapshot
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id, // Get the document ID
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      size: data['size'] ?? '',
      color: Color(data['color'] ?? 0xFFFFFFFF), // Reconstruct Color from int
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      location: data['location'] ?? '',
      co2Saved: (data['co2Saved'] ?? 0.0).toDouble(),
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }

  // Method to convert a Product object to a map for Firestore (optional, but good practice)
  Map<String, dynamic> toFirestore() {
    return {
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
      'timestamp': timestamp,
    };
  }
}
