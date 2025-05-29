import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Custom Star Rating Input Widget
class StarRatingInput extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingUpdate;
  final int itemCount;
  final double itemSize;

  const StarRatingInput({
    Key? key,
    required this.initialRating,
    required this.onRatingUpdate,
    this.itemCount = 5,
    this.itemSize = 30.0,
  }) : super(key: key);

  @override
  State<StarRatingInput> createState() => _StarRatingInputState();
}

class _StarRatingInputState extends State<StarRatingInput> {
  late double currentRating;

  @override
  void initState() {
    super.initState();
    currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.itemCount, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              currentRating = (index + 1).toDouble();
            });
            widget.onRatingUpdate(currentRating);
          },
          child: Icon(
            index < currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: widget.itemSize,
          ),
        );
      }),
    );
  }
}

class SubmitReviewForm extends StatefulWidget {
  final String itemId;
  final VoidCallback? onReviewSubmitted; // Callback to refresh reviews

  const SubmitReviewForm({
    super.key,
    required this.itemId,
    this.onReviewSubmitted, // Add this parameter to the constructor
  });

  @override
  State<SubmitReviewForm> createState() => _SubmitReviewFormState();
}

class _SubmitReviewFormState extends State<SubmitReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a review')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get user's display name
      String userName =
          user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous';

      // Add review to the product's reviews subcollection
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.itemId)
          .collection('reviews')
          .add({
        'userId': user.uid,
        'userName': userName,
        'rating': _rating,
        'comment': _commentController.text.trim(),
        'timestamp': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        setState(() {
          _rating = 5.0;
          _commentController.clear();
        });

        // Notify parent to refresh reviews
        widget.onReviewSubmitted?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Rating input
              const Text('Rating:'),
              const SizedBox(height: 4),
              StarRatingInput(
                initialRating: _rating,
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
                itemCount: 5,
                itemSize: 30.0,
              ),
              const SizedBox(height: 12),

              // Comment input
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Your Review',
                  hintText: 'Share your thoughts about this product...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your review';
                  }
                  if (value.trim().length < 10) {
                    return 'Review must be at least 10 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Submitting...'),
                          ],
                        )
                      : const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
