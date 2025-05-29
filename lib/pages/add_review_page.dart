// pages/add_review_page.dart
import 'package:flutter/material.dart';
import '../services/review_service.dart';
import '../widgets/star_rating.dart';

class AddReviewPage extends StatefulWidget {
  final String sellerId;
  final String productId;
  final String productName;
  final String productImage;

  const AddReviewPage({
    Key? key,
    required this.sellerId,
    required this.productId,
    required this.productName,
    required this.productImage,
  }) : super(key: key);

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  double _rating = 5.0;
  bool _isSubmitting = false;
  bool _canReview = false;
  bool _isCheckingEligibility = true;

  @override
  void initState() {
    super.initState();
    _checkReviewEligibility();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkReviewEligibility() async {
    final canReview = await _reviewService.canUserReviewProduct(
      widget.sellerId,
      widget.productId,
    );
    
    setState(() {
      _canReview = canReview;
      _isCheckingEligibility = false;
    });
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _reviewService.addReview(
        sellerId: widget.sellerId,
        productId: widget.productId,
        productName: widget.productName,
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully! 🎉'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Failed to submit review');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String _getRatingText(double rating) {
    switch (rating.round()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Rate this item';
    }
  }
