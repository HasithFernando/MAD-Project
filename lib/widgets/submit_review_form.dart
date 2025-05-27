import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubmitReviewForm extends StatefulWidget {
  final String itemId;

  const SubmitReviewForm({super.key, required this.itemId});

  @override
  State<SubmitReviewForm> createState() => _SubmitReviewFormState();
}

class _SubmitReviewFormState extends State<SubmitReviewForm> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 5;
  String _comment = '';

  void _submitReview() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('reviews').add({
          'itemId': widget.itemId,
          'userId': user.uid,
          'rating': _rating,
          'comment': _comment,
          'timestamp': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted!')),
        );
        setState(() {
          _comment = '';
          _rating = 5;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: _rating,
            decoration: const InputDecoration(labelText: 'Rating'),
            items: List.generate(5, (index) => DropdownMenuItem(
              value: index + 1,
              child: Text('${index + 1} Star(s)'),
            )),
            onChanged: (value) => setState(() => _rating = value!),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Comment'),
            onChanged: (value) => _comment = value,
            validator: (value) => value == null || value.isEmpty ? 'Enter a comment' : null,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submitReview,
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }
}
