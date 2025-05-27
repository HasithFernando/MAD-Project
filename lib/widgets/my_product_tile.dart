// widgets/my_product_tile.dart
import 'package:flutter/material.dart';
import 'package:thriftale/models/product_model.dart'; // Import your Product model
import 'package:timeago/timeago.dart' as timeago; // For timeAgo formatting

class MyProductTile extends StatelessWidget {
  final Product product; // Now takes the full Product object
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const MyProductTile({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  String _getTimeAgo(DateTime dateTime) {
    return timeago.format(dateTime);
  }

  String _formatPrice(double price) {
    return 'Rs. ${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero, // Consider adding some margin here for spacing
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      product.name, // Access directly from product object
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Location and Time Ago
                    Text(
                      '${product.location} • ${_getTimeAgo(product.timestamp.toDate())}', // Use helper
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Sustainability Text (CO2 Saved)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🌱 Saves ${product.co2Saved.toStringAsFixed(2)}kg CO2', // Access directly from product
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Text(
                      _formatPrice(product.price), // Use helper
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Edit Button
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue.shade700),
                          tooltip: 'Edit Product',
                          onPressed: onEdit, // Use the callback
                        ),
                        // Delete Button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red.shade700),
                          tooltip: 'Delete Product',
                          onPressed: onDelete, // Use the callback
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
