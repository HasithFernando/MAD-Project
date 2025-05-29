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
