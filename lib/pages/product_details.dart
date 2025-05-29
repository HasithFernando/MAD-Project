import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp if needed
import 'package:thriftale/models/product_model.dart'; // Import your Product model
import 'package:thriftale/pages/home.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:timeago/timeago.dart' as timeago; // For timeAgo calculation
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thriftale/services/cart_service.dart'; // Make sure this import exists

class ProductDetails extends StatefulWidget {
  final Product product; // This page now requires a Product object

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  // These are no longer needed as we are directly displaying product's size and color
  // int selectedSizeIndex = 0;
  // int selectedColorIndex = 0;
  int quantity = 1;
  bool isFavorite =
      false; // You'd typically manage favorites with a service/backend

  // Remove the full lists for selection
  // final List<String> availableSizes = [
  //   'XS',
  //   'S',
  //   'M',
  //   'L',
  //   'XL',
  //   'XXL',
  //   'Free Size'
  // ];
  // final List<Color> availableColors = [
  //   Colors.red,
  //   Colors.blue.shade800,
  //   Colors.green,
  //   Colors.black,
  //   Colors.white,
  //   Colors.brown.shade400,
  //   Colors.purple,
  //   Colors.orange,
  //   Colors.pink,
  //   Colors.yellow,
  //   Colors.teal,
  //   Colors.grey,
  // ];

  @override
  void initState() {
    super.initState();
    // No need to initialize selectedSizeIndex or selectedColorIndex from available lists
    // as we're directly using widget.product.size and widget.product.color.

    // You might also check if this product is already favorited by the current user
    // isFavorite = _checkIfFavorite(widget.product.id); // Requires auth & favorites logic
  }

  // Helper to format time ago from a Firestore Timestamp
  String _getTimeAgo(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return timeago.format(dateTime);
  }

  // Helper to format price
  String _formatPrice(double price) {
    return 'Rs. ${price.toStringAsFixed(2)}';
  }

  // Method to handle back navigation
  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // If there's no previous page in the stack, navigate to Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the product data using widget.product
    final Product product = widget.product;

    return WillPopScope(
      onWillPop: () async {
        _navigateBack();
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _navigateBack, // Use the custom navigation method
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
                  // TODO: Implement logic to save/remove from user favorites in Firestore
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.black),
              onPressed: () {
                // TODO: Implement sharing functionality (e.g., Share.share package)
                print('Share product');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
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
                          product.imageUrls[0], // Display the first image
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child; // Image is fully loaded, show the image
                            }
                            // Calculate progress value
                            double? progressValue;
                            if (loadingProgress.expectedTotalBytes != null) {
                              progressValue =
                                  loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!;
                            }

                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    progressValue, // Use the calculated progress value (can be null)
                                color: Colors.brown.shade400,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seller Name and CO2 savings
                    Row(
                      children: [
                        Text(
                          product.sellerName, // Dynamic Seller Name
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Saves ${product.co2Saved.toStringAsFixed(2)}kg CO2', // Dynamic CO2 Saved
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

                    // Product title
                    Text(
                      product.name, // Dynamic Product Name
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Location and time
                    Text(
                      '${product.location} • ${_getTimeAgo(product.timestamp)}', // Dynamic Location and Time
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Price
                    Text(
                      _formatPrice(product.price), // Dynamic Price
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Display Current Size
                    const Text(
                      'Size',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.size, // Display the product's actual size
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Display Current Color
                    const Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            product.color, // Display the product's actual color
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quantity selection (mostly useful if you have multiple of the exact same thrift item)
                    Row(
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: quantity > 1
                                    ? () {
                                        setState(() {
                                          quantity--;
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.remove),
                                color:
                                    quantity > 1 ? Colors.black : Colors.grey,
                              ),
                              Text(
                                quantity.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                                icon: const Icon(Icons.add),
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description, // Dynamic Description
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),

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
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) {
                      // Optionally redirect to login
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Please log in to add items to cart.')),
                      );
                      return;
                    }

                    try {
                      await CartService().addToCart(
                        user.uid,
                        product.id,
                        quantity, // from your quantity selector
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to cart!')),
                      );
                    } catch (e) {
                      print('Error adding to cart: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add to cart.')),
                      );
                    }
                  },
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
                  onPressed: () {
                    // TODO: Implement Buy Now logic (e.g., direct checkout)
                    print(
                        'Buy Now: ${product.name}, Size: ${product.size}, Color: ${product.color.value}, Quantity: $quantity');
                  },
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
