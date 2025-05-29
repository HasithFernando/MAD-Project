import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewsSection extends StatelessWidget {
  final String itemId;

  const ReviewsSection({super.key, required this.itemId});

  Stream<List<Review>> _getReviews() {
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('itemId', isEqualTo: itemId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  String _formatDate(dynamic timestamp) {
    DateTime dateTime;

    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return 'Unknown date';
    }

    return dateTime.toLocal().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Review>>(
      stream: _getReviews(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final reviews = snapshot.data!;
        if (reviews.isEmpty) return const Text('No reviews yet.');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ratings & Reviews',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...reviews.map((review) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('Rating: ${review.rating}/5'),
                    subtitle: Text(review.comment),
                    trailing: Text(
                      _formatDate(review.timestamp),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }
}
