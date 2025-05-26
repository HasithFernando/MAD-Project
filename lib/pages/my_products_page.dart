import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thriftale/models/product_model.dart';
import 'package:thriftale/services/product_service.dart';
import 'package:thriftale/widgets/custom_product_tile.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/pages/product_adding_form.dart';
import 'package:thriftale/pages/product_details.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyProductsPage extends StatefulWidget {
  final String currentUserId;

  const MyProductsPage({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  final ProductService _productService = ProductService();

  String _getTimeAgo(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return timeago.format(dateTime);
  }

  String _formatPrice(double price) {
    return 'Rs. ${price.toStringAsFixed(2)}';
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
          onPressed: () {
            Navigator.pop(context);
          },
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
              NavigationUtils.frontNavigation(
                  context, const ProductAddingForm());
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
            // A more user-friendly error message
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
                        // Optionally retry by rebuilding the stream or navigating back
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
            // Changed to ListView.separated for better spacing
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 16.0), // Adds space between items
            itemBuilder: (context, index) {
              final product = products[index];
              return CustomProductTile(
                title: product.name,
                location: product.location,
                timeAgo: _getTimeAgo(product.timestamp),
                sustainabilityText:
                    'CO2 Saved: ${product.co2Saved.toStringAsFixed(2)}kg', // Format CO2 saved
                price: _formatPrice(product.price),
                productImage: product.imageUrls.isNotEmpty
                    ? product.imageUrls[0]
                    : 'https://via.placeholder.com/108x108.png?text=No+Image', // More descriptive placeholder
                iconImage:
                    'assets/icons/dummy_product.png', // Ensure this asset exists or make it dynamic
                onTap: () {
                  NavigationUtils.frontNavigation(
                      context, ProductDetails(product: product));
                  // You might pass the product object or its ID to the detail page
                  print(
                      'Tapped on product: ${product.name}, ID: ${product.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
