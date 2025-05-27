import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thriftale/models/product_model.dart';
import 'package:thriftale/services/product_service.dart';
import 'package:thriftale/widgets/my_product_tile.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/pages/home.dart';
import 'package:thriftale/pages/product_adding_form.dart';
import 'package:thriftale/pages/product_details.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:thriftale/pages/update_product_form.dart';

class MyProductsPage extends StatefulWidget {
  final String currentUserId;

  const MyProductsPage({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  final ProductService _productService = ProductService();

  // These helper methods are no longer directly used here as MyProductTile handles them,
  // but keeping them just in case you use them elsewhere or want to re-add.
  String _getTimeAgo(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return timeago.format(dateTime);
  }

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

  // Method to show delete confirmation dialog
  Future<void> _showDeleteConfirmationDialog(Product product) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text(
              'Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Dismiss dialog first

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deleting product...')),
                );

                try {
                  await _productService.deleteProduct(product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _navigateBack,
        ),
        title: const Text(
          'My Products',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            onPressed: () {
              // Navigate to ProductAddingForm
              NavigationUtils.frontNavigation(
                context,
                const ProductAddingForm(),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productService.getMyProducts(widget.currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // It's good practice to print the error in debug mode
            debugPrint('Error loading products: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      'Failed to load products: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {}); // Simple rebuild to try fetching again
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        color: Colors.grey, size: 70),
                    const SizedBox(height: 20),
                    const Text(
                      'You haven\'t listed any products yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap the "+" icon above to add your first item!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 16.0), // Adds space between items
            itemBuilder: (context, index) {
              final product = products[index];
              return MyProductTile(
                product: product, // Pass the entire product object to the tile
                onTap: () {
                  // Navigate to ProductDetails, passing the full product object
                  NavigationUtils.frontNavigation(
                      context, ProductDetails(product: product));
                },
                onEdit: () {
                  NavigationUtils.frontNavigation(
                    context,
                    UpdateProductForm(
                      product: product,
                      currentUserId: widget.currentUserId,
                    ),
                  );
                },
                onDelete: () {
                  _showDeleteConfirmationDialog(product);
                },
              );
            },
          );
        },
      ),
    );
  }
}
