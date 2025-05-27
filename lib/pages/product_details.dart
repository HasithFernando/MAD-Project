import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thriftale/models/product_model.dart';
import 'package:thriftale/pages/home.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thriftale/services/cart_service.dart';

class ProductDetails extends StatefulWidget {
  final Product product;

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1;
  bool isFavorite = false;
  bool isAddingToCart = false; // Loading state for cart operations

  @override
  void initState() {
    super.initState();
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
        (route) => false,
      );
    }
  }

  // Method to add single item to cart when quantity is increased
  Future<void> _addSingleItemToCart() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to cart.')),
      );
      return;
    }

    setState(() {
      isAddingToCart = true;
    });

    try {
      await CartService().addToCart(
        user.uid,
        widget.product.id,
        1, // Add only 1 item at a time
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.product.name} added to cart!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error adding to cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add to cart.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isAddingToCart = false;
        });
      }
    }
  }

  // Method to handle quantity increase with auto cart addition
  void _increaseQuantity() async {
    setState(() {
      quantity++;
    });

    // Automatically add the item to cart when quantity is increased
    await _addSingleItemToCart();
  }

  // Method to handle quantity decrease
  void _decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
      // Note: You might want to implement logic to remove from cart here as well
      // This would require a method to remove a single item from cart
    }
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
                          product.imageUrls[0],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            double? progressValue;
                            if (loadingProgress.expectedTotalBytes != null) {
                              progressValue =
                                  loadingProgress.cumulativeBytesLoaded /
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
                          product.sellerName,
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

                    // Product title
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Location and time
                    Text(
                      '${product.location} • ${_getTimeAgo(product.timestamp)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Price
                    Text(
                      _formatPrice(product.price),
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
                        product.size,
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
                        color: product.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quantity selection with auto cart addition
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
                                onPressed:
                                    quantity > 1 ? _decreaseQuantity : null,
                                icon: const Icon(Icons.remove),
                                color:
                                    quantity > 1 ? Colors.black : Colors.grey,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      quantity.toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (isAddingToCart) ...[
                                      const SizedBox(width: 8),
                                      const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed:
                                    isAddingToCart ? null : _increaseQuantity,
                                icon: const Icon(Icons.add),
                                color:
                                    isAddingToCart ? Colors.grey : Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Info text about auto cart addition
                    Text(
                      'Items are automatically added to cart when you increase quantity',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
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
                      product.description,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please log in to add items to cart.')),
                      );
                      return;
                    }

                    try {
                      await CartService().addToCart(
                        user.uid,
                        product.id,
                        quantity,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart!')),
                      );
                    } catch (e) {
                      print('Error adding to cart: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to add to cart.')),
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
