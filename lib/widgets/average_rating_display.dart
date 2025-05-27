import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AverageRatingDisplay extends StatelessWidget {
  final String itemId;

  const AverageRatingDisplay({super.key, required this.itemId});

  Future<double> _getAverageRating() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('itemId', isEqualTo: itemId)
        .get();

    if (snapshot.docs.isEmpty) return 0;

    final ratings = snapshot.docs
        .map((doc) => (doc.data()['rating'] as int))
        .toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    return avg;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _getAverageRating(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('Loading rating...');
        final avg = snapshot.data!;
        return Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 5),
            Text('(average)', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        );
      },
    );
  }
}
