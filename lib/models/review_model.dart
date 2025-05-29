// models/review_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String sellerId;
  final String buyerId;
  final String buyerName;
  final String productId;
  final String productName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? buyerProfileImage;
  final bool isVerifiedPurchase;

  Review({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.buyerName,
    required this.productId,
    required this.productName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.buyerProfileImage,
    this.isVerifiedPurchase = false,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      buyerId: data['buyerId'] ?? '',
      buyerName: data['buyerName'] ?? 'Anonymous',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      buyerProfileImage: data['buyerProfileImage'],
      isVerifiedPurchase: data['isVerifiedPurchase'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'productId': productId,
      'productName': productName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'buyerProfileImage': buyerProfileImage,
      'isVerifiedPurchase': isVerifiedPurchase,
    };
  }
}

// Seller Rating Summary Model
class SellerRating {
  final String sellerId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingBreakdown;
  final DateTime lastUpdated;

  SellerRating({
    required this.sellerId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
    required this.lastUpdated,
  });

  factory SellerRating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final breakdown = Map<String, dynamic>.from(data['ratingBreakdown'] ?? {});

    return SellerRating(
      sellerId: doc.id,
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      ratingBreakdown: breakdown.map((key, value) => MapEntry(int.parse(key), value as int)),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingBreakdown': ratingBreakdown.map((key, value) => MapEntry(key.toString(), value)),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
