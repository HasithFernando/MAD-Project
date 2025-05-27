import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp if needed
import 'package:thriftale/models/product_model.dart'; // Import your Product model
import 'package:thriftale/pages/home.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:timeago/timeago.dart' as timeago; // For timeAgo calculation
import '../widgets/submit_review_form.dart';
import '../widgets/reviews_section.dart';
import '../widgets/average_rating_display.dart';

class ProductDetails extends StatefulWidget {
  final Product product; // This page now requires a Product object

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int selectedSizeIndex = 0;
  int selectedColorIndex = 0;
  int quantity = 1;
  bool isFavorite = false;

  final List<String> availableSizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    'Free Size'
  ];
  final List<Color> availableColors = [
    Colors.red,
    Colors.blue.shade800,
    Colors.green,
    Colors.black,
    Colors.white,
    Colors.brown.shade400,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.yellow,
    Colors.teal,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    selectedSizeIndex = availableSizes.indexOf(widget.product.size);
    if (selectedSizeIndex == -1) {
      selectedSizeIndex = 0;
    }

    selectedColorIndex = availableColors.indexWhere(
      (color) => color.value == widget.product.color.value,
    );
    if (selectedColorIndex == -1) {
      selectedColorIndex = 0;
    }
  }

  String _getTimeAgo(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return timeago.format(dateTime);
  }

  String _formatPrice(double price) {
    return 'Rs. ${price.toStringAsFixed(2)}';
  }

  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
        (route) => false,
      );
    }
  }

  void _onAddToCart() {
    print(
        'Add to Cart: ${widget.product.name}, Size: ${availableSizes[selectedSizeIndex]}, Color: ${availableColors[selectedColorIndex]}, Quantity: $quantity');
  }

  void _onBuyNow() {
    print(
        'Buy Now: ${widget.product.name}, Size: ${availableSizes[selectedSizeIndex]}, Color: ${availableColors[selectedColorIndex]}, Quantity: $quantity');
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;

    return WillPopScope(
      onWillPop: () async {
        _navigateBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _navigateBack,
          ),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: () {
                print('Share product');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 300,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(
                          product.imageUrls[0],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            double? progressValue;
                            if (loadingProgress.expectedTotalBytes != null) {
                              progressValue = loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: progressValue,
                                color: Colors.brown.shade400,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.image, size: 80, color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image, size: 80, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          product.sellerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Saves ${product.co2Saved.toStringAsFixed(2)}kg CO2',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.location} • ${_getTimeAgo(product.timestamp)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AverageRatingDisplay(productId: product.id),
                    const SizedBox(height: 16),
                    Text(
                      _formatPrice(product.price),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SubmitReviewForm(productId: product.id),
                    const SizedBox(height: 24),
                    const Text(
                      'User Reviews',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ReviewsSection(productId: product.id),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _onBuyNow,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.brown.shade400,
                    side: BorderSide(color: Colors.brown.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
