import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String itemId;
  final String userId;
  final int rating;
  final String comment;
  final Timestamp timestamp;

  Review({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      itemId: data['itemId'],
      userId: data['userId'],
      rating: data['rating'],
      comment: data['comment'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}
