import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp if needed
import 'package:thriftale/models/product_model.dart'; // Import your Product model
import 'package:thriftale/pages/home.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:timeago/timeago.dart' as timeago; // For timeAgo calculation

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

  @override
  Widget build(BuildContext context) {
    // Access the product data using widget.product
    final Product product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
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

                  // Size selection
                  const Text(
                    'Size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: availableSizes.asMap().entries.map((entry) {
                      int index = entry.key;
                      String size = entry.value;
                      bool isSelected = selectedSizeIndex == index;

                      return GestureDetector(
                        onTap: () {
                          // Only allow selection if the product's actual size matches this option,
                          // or if you want to allow users to select from available sizes.
                          // For a thrift shop, typically a product has one specific size.
                          // If you want to only highlight the product's actual size:
                          // if (size == product.size) { // Only highlight the actual size
                          //   setState(() { selectedSizeIndex = index; });
                          // }

                          // If you want to let the user "select" available sizes (even if the product has only one):
                          setState(() {
                            selectedSizeIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.brown.shade400
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.brown.shade400
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Color selection
                  const Text(
                    'Color',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: availableColors.asMap().entries.map((entry) {
                      int index = entry.key;
                      Color color = entry.value;
                      bool isSelected = selectedColorIndex == index;

                      return GestureDetector(
                        onTap: () {
                          // Similar to size, for a thrift shop, a product has one specific color.
                          // If you want to only highlight the product's actual color:
                          // if (color.value == product.color.value) { // Only highlight the actual color
                          //   setState(() { selectedColorIndex = index; });
                          // }

<<<<<<< Updated upstream
                          // If you want to let the user "select" available colors:
                          setState(() {
                            selectedColorIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.brown.shade400
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
                              color: quantity > 1 ? Colors.black : Colors.grey,
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
=======
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
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
                onPressed: () {
                  // TODO: Implement Add to Cart logic
                  print(
                      'Add to Cart: ${product.name}, Size: ${availableSizes[selectedSizeIndex]}, Color: ${availableColors[selectedColorIndex]}, Quantity: $quantity');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
=======
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
                  onPressed: () {
                    // TODO: Implement Add to Cart logic
                    print(
                        'Add to Cart: ${product.name}, Size: ${product.size}, Color: ${product.color.value}, Quantity: $quantity');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implement Buy Now logic (e.g., direct checkout)
                  print(
                      'Buy Now: ${product.name}, Size: ${availableSizes[selectedSizeIndex]}, Color: ${availableColors[selectedColorIndex]}, Quantity: $quantity');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.brown.shade400,
                  side: BorderSide(color: Colors.brown.shade400),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
=======
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
>>>>>>> Stashed changes
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
    );
  }
}
