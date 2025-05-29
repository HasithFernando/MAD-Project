// widgets/star_rating.dart
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final Function(double)? onRatingChanged;
  final bool allowHalfRating;
  final bool isInteractive;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 24.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.onRatingChanged,
    this.allowHalfRating = true,
    this.isInteractive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: isInteractive && onRatingChanged != null
              ? () => onRatingChanged!(index + 1.0)
              : null,
          child: Icon(
            _getStarIcon(index),
            size: size,
            color: _getStarColor(index),
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(int index) {
    if (rating >= index + 1) {
      return Icons.star;
    } else if (allowHalfRating && rating >= index + 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  Color _getStarColor(int index) {
    if (rating >= index + 1) {
      return activeColor;
    } else if (allowHalfRating && rating >= index + 0.5) {
      return activeColor;
    } else {
      return inactiveColor;
    }
  }
}

// Interactive Star Rating for input
class InteractiveStarRating extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const InteractiveStarRating({
    Key? key,
    this.initialRating = 5.0,
    required this.onRatingChanged,
    this.size = 32.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1.0;
            });
            widget.onRatingChanged(_currentRating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              _currentRating > index ? Icons.star : Icons.star_border,
              size: widget.size,
              color: _currentRating > index ? widget.activeColor : widget.inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}

// Compact Rating Display Widget
class CompactRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;
  final TextStyle? textStyle;

  const CompactRating({
    Key? key,
    required this.rating,
    required this.reviewCount,
    this.starSize = 16.0,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarRating(
          rating: rating,
          size: starSize,
        ),
        const SizedBox(width: 4),
        Text(
          '${rating.toStringAsFixed(1)} ($reviewCount)',
          style: textStyle ?? TextStyle(
            fontSize: starSize - 2,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// Rating Summary Widget with breakdown
class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingBreakdown;

  const RatingSummary({
    Key? key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Left side - Average rating
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              StarRating(
                rating: averageRating,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                '$totalReviews reviews',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Right side - Rating breakdown
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final starCount = 5 - index;
                final count = ratingBreakdown[starCount] ?? 0;
                final percentage = totalReviews > 0 ? (count / totalReviews) : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$starCount',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
