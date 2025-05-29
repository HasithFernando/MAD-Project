// widgets/reviews_section.dart
import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../widgets/star_rating.dart';
import '../widgets/review_card.dart';
import '../pages/add_review_page.dart';

class ReviewsSection extends StatefulWidget {
  final String sellerId;
  final String productId;
  final String productName;
  final String? productImage;
  final bool showAddReviewButton;

  const ReviewsSection({
    Key? key,
    required this.sellerId,
    required this.productId,
    required this.productName,
    this.productImage,
    this.showAddReviewButton = true,
  }) : super(key: key);

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final ReviewService _reviewService = ReviewService();
  bool _showAllReviews = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and add review button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reviews & Ratings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.showAddReviewButton)
                TextButton.icon(
                  onPressed: () => _navigateToAddReview(),
                  icon: const Icon(Icons.rate_review, size: 18),
                  label: const Text('Write Review'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
            ],
          ),
        ),

        // Rating Summary
        StreamBuilder<SellerRating?>(
          stream: _reviewService.getSellerRating(widget.sellerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final sellerRating = snapshot.data;
            if (sellerRating == null || sellerRating.totalReviews == 0) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No reviews yet. Be the first to review!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RatingSummary(
                averageRating: sellerRating.averageRating,
                totalReviews: sellerRating.totalReviews,
                ratingBreakdown: sellerRating.ratingBreakdown,
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Reviews List
        StreamBuilder<List<Review>>(
          stream: _reviewService.getProductReviews(widget.productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error loading reviews: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const SizedBox.shrink();
            }

            // Show limited reviews initially
            final displayReviews = _showAllReviews 
                ? reviews 
                : reviews.take(3).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reviews header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Customer Reviews (${reviews.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Reviews list
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayReviews.length,
                  itemBuilder: (context, index) {
                    return ReviewCard(review: displayReviews[index]);
                  },
                ),

                // Show more/less button
                if (reviews.length > 3)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showAllReviews = !_showAllReviews;
                        });
                      },
                      child: Text(
                        _showAllReviews 
                            ? 'Show Less Reviews' 
                            : 'Show All ${reviews.length} Reviews',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _navigateToAddReview() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddReviewPage(
          sellerId: widget.sellerId,
          productId: widget.productId,
          productName: widget.productName,
          productImage: widget.productImage ?? '',
        ),
      ),
    );

    // Refresh the reviews if a new review was added
    if (result == true) {
      setState(() {});
    }
  }
}

// Compact Reviews Widget for product listings
class CompactReviewsWidget extends StatelessWidget {
  final String sellerId;
  final String productId;
  final double starSize;

  const CompactReviewsWidget({
    Key? key,
    required this.sellerId,
    required this.productId,
    this.starSize = 14.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SellerRating?>(
      stream: ReviewService().getSellerRating(sellerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: starSize,
            width: starSize,
            child: const CircularProgressIndicator(
              strokeWidth: 1,
            ),
          );
        }

        final sellerRating = snapshot.data;
        if (sellerRating == null || sellerRating.totalReviews == 0) {
          return Row(
            children: [
              StarRating(
                rating: 0,
                size: starSize,
                inactiveColor: Colors.grey[300]!,
              ),
              const SizedBox(width: 4),
              Text(
                'No reviews',
                style: TextStyle(
                  fontSize: starSize - 2,
                  color: Colors.grey[500],
                ),
              ),
            ],
          );
        }

        return CompactRating(
          rating: sellerRating.averageRating,
          reviewCount: sellerRating.totalReviews,
          starSize: starSize,
        );
      },
    );
  }
}

// Quick Rating Display for simple use cases
class QuickRatingDisplay extends StatelessWidget {
  final String sellerId;
  final bool showReviewCount;
  final double starSize;

  const QuickRatingDisplay({
    Key? key,
    required this.sellerId,
    this.showReviewCount = true,
    this.starSize = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        ReviewService().getAverageRating(sellerId),
        ReviewService().getTotalReviewCount(sellerId),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final averageRating = snapshot.data![0] as double;
        final reviewCount = snapshot.data![1] as int;

        if (reviewCount == 0) {
          return Text(
            'No reviews',
            style: TextStyle(
              fontSize: starSize - 2,
              color: Colors.grey[500],
            ),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StarRating(
              rating: averageRating,
              size: starSize,
            ),
            if (showReviewCount) ...[
              const SizedBox(width: 4),
              Text(
                '(${reviewCount})',
                style: TextStyle(
                  fontSize: starSize - 2,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
