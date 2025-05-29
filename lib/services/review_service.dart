// services/review_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if user can review a product (must have purchased it)
  Future<bool> canUserReviewProduct(String sellerId, String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if user has purchased this product
      final orderQuery = await _firestore
          .collection('orders')
          .where('buyerId', isEqualTo: user.uid)
          .where('sellerId', isEqualTo: sellerId)
          .where('productId', isEqualTo: productId)
          .where('status', isEqualTo: 'completed') // Only completed orders
          .limit(1)
          .get();

      if (orderQuery.docs.isEmpty) return false;

      // Check if user already reviewed this product
      final reviewQuery = await _firestore
          .collection('reviews')
          .where('buyerId', isEqualTo: user.uid)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      return reviewQuery.docs.isEmpty;
    } catch (e) {
      print('Error checking review eligibility: $e');
      return false;
    }
  }

  /// Add a new review
  Future<bool> addReview({
    required String sellerId,
    required String productId,
    required String productName,
    required double rating,
    required String comment,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user can review this product
      final canReview = await canUserReviewProduct(sellerId, productId);
      if (!canReview) {
        throw Exception('You can only review products you have purchased');
      }

      // Create review document
      final reviewData = {
        'sellerId': sellerId,
        'buyerId': user.uid,
        'buyerName': user.displayName ?? 'Anonymous User',
        'productId': productId,
        'productName': productName,
        'rating': rating,
        'comment': comment.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'buyerProfileImage': user.photoURL,
        'isVerifiedPurchase': true,
      };

      // Use batch write for atomic operation
      final batch = _firestore.batch();
      
      // Add review
      final reviewRef = _firestore.collection('reviews').doc();
      batch.set(reviewRef, reviewData);

      // Update seller rating
      await _updateSellerRating(sellerId, rating, batch);
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error adding review: $e');
      return false;
    }
  }

  /// Update seller rating statistics
  Future<void> _updateSellerRating(String sellerId, double newRating, WriteBatch batch) async {
    final sellerRatingRef = _firestore.collection('seller_ratings').doc(sellerId);
    final sellerRatingDoc = await sellerRatingRef.get();

    if (sellerRatingDoc.exists) {
      // Update existing rating
      final data = sellerRatingDoc.data()!;
      final currentAverage = (data['averageRating'] ?? 0).toDouble();
      final currentTotal = data['totalReviews'] ?? 0;
      final ratingBreakdown = Map<String, dynamic>.from(data['ratingBreakdown'] ?? {});

      // Calculate new average
      final newTotal = currentTotal + 1;
      final newAverage = ((currentAverage * currentTotal) + newRating) / newTotal;

      // Update rating breakdown
      final ratingKey = newRating.round().toString();
      ratingBreakdown[ratingKey] = (ratingBreakdown[ratingKey] ?? 0) + 1;

      batch.update(sellerRatingRef, {
        'averageRating': newAverage,
        'totalReviews': newTotal,
        'ratingBreakdown': ratingBreakdown,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      // Create new seller rating
      final ratingBreakdown = {newRating.round().toString(): 1};
      batch.set(sellerRatingRef, {
        'averageRating': newRating,
        'totalReviews': 1,
        'ratingBreakdown': ratingBreakdown,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get reviews for a specific seller
  Stream<List<Review>> getSellerReviews(String sellerId) {
    return _firestore
        .collection('reviews')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList()
        );
  }

  /// Get reviews for a specific product
  Stream<List<Review>> getProductReviews(String productId) {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList()
        );
  }

  /// Get seller rating summary
  Future<SellerRating?> getSellerRating(String sellerId) async {
    try {
      final doc = await _firestore.collection('seller_ratings').doc(sellerId).get();
      if (doc.exists) {
        return SellerRating.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting seller rating: $e');
      return null;
    }
  }

  /// Get average rating for a product
  Future<double> getProductAverageRating(String productId) async {
    try {
      final reviews = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();

      if (reviews.docs.isEmpty) return 0.0;

      double totalRating = 0;
      for (final doc in reviews.docs) {
        totalRating += (doc.data()['rating'] ?? 0).toDouble();
      }

      return totalRating / reviews.docs.length;
    } catch (e) {
      print('Error getting product average rating: $e');
      return 0.0;
    }
  }

  /// Delete a review (only by the reviewer)
  Future<bool> deleteReview(String reviewId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) return false;

      final reviewData = reviewDoc.data()!;
      if (reviewData['buyerId'] != user.uid) return false;

      // Delete review and recalculate seller rating
      await _firestore.collection('reviews').doc(reviewId).delete();
      await _recalculateSellerRating(reviewData['sellerId']);
      
      return true;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  /// Recalculate seller rating after review deletion
  Future<void> _recalculateSellerRating(String sellerId) async {
    try {
      final reviews = await _firestore
          .collection('reviews')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      if (reviews.docs.isEmpty) {
        // Delete seller rating if no reviews
        await _firestore.collection('seller_ratings').doc(sellerId).delete();
        return;
      }

      double totalRating = 0;
      Map<int, int> ratingBreakdown = {};

      for (final doc in reviews.docs) {
        final rating = (doc.data()['rating'] ?? 0).toDouble();
        totalRating += rating;
        
        final ratingInt = rating.round();
        ratingBreakdown[ratingInt] = (ratingBreakdown[ratingInt] ?? 0) + 1;
      }

      final averageRating = totalRating / reviews.docs.length;
      
      await _firestore.collection('seller_ratings').doc(sellerId).set({
        'averageRating': averageRating,
        'totalReviews': reviews.docs.length,
        'ratingBreakdown': ratingBreakdown.map((k, v) => MapEntry(k.toString(), v)),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recalculating seller rating: $e');
    }
  }
}
