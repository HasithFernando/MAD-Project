import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String timeAgo;
  final String price;
  final String sustainabilityText;
  final VoidCallback onTap;
  final double borderRadius;
  final double? height; // Made optional
  final double width;

  const ProductCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.price,
    required this.sustainabilityText,
    required this.onTap,
    this.borderRadius = 16.0,
    this.height, // No default value so it can adapt to content
    this.width = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height:
            height, // Will be null if not specified, allowing content to determine height
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.blue,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min, // Important: Use minimum required space
          children: [
            // Image container with heart icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 160, // Reduced image height
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160, // Match reduced image height
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),

            // Title and content
            Padding(
              padding: const EdgeInsets.all(8.0), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Use minimum space
                children: [
                  // Title with icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18, // Reduced font size
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (title.toLowerCase().contains('shirt'))
                        const Icon(Icons.dry_cleaning,
                            size: 18), // Smaller icon
                    ],
                  ),

                  const SizedBox(height: 4), // Reduced spacing

                  // Location and time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "$location • $timeAgo",
                          style: const TextStyle(
                            fontSize: 14, // Reduced font size
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8), // Reduced spacing

                  // Price and sustainability
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 18, // Reduced font size
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          sustainabilityText,
                          style: const TextStyle(
                            fontSize: 14, // Reduced font size
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
