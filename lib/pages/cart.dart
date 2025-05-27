import 'package:flutter/material.dart';
import 'package:thriftale/models/product_model.dart';
import 'package:thriftale/pages/checkout.dart';
import 'package:thriftale/services/cart_service.dart';
import 'package:thriftale/services/product_service.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/Search_Notification_Widget.dart';
import 'package:thriftale/widgets/custom_button.dart';
import 'package:thriftale/widgets/custom_product_tile.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/widgets/newBottomBar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Method to remove item from cart
  Future<void> _removeFromCart(String cartItemId, String productName) async {
    try {
      await _cartService.removeFromCart(userId, cartItemId);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$productName removed from cart'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to remove item from cart'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Show confirmation dialog before removing item
  void _showRemoveConfirmation(String cartItemId, String productName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Item'),
          content: Text(
              'Are you sure you want to remove "$productName" from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeFromCart(cartItemId, productName);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 245, 245),
      body: SafeArea(
        child: Column(
          children: [
            SearchNotificationWidget(
              placeholder: "Search for products",
              notificationCount: 3,
              onSearchTap: () => print('Search tapped'),
              onNotificationTap: () => print('Notification tapped'),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _cartService.getCartItems(userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final cartItems = snapshot.data!;
                  if (cartItems.isEmpty) {
                    return const Center(child: Text("Your cart is empty."));
                  }

                  // Load all products at once
                  return FutureBuilder<List<Product?>>(
                    future: Future.wait(cartItems.map((item) =>
                        _productService.getProductById(item['productId']))),
                    builder: (context, productSnapshot) {
                      if (!productSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final productList = productSnapshot.data!;
                      double totalAmount = 0;
                      double totalCO2 = 0;
                      int landfillItems = cartItems.length; // one per item

                      // Calculate totals
                      for (int i = 0; i < productList.length; i++) {
                        final product = productList[i];
                        if (product != null) {
                          totalAmount += product.price;
                          totalCO2 += product.co2Saved;
                        }
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: productList.length,
                              itemBuilder: (context, index) {
                                final product = productList[index];
                                final cartItem = cartItems[index];

                                if (product == null)
                                  return const SizedBox.shrink();

                                return Column(
                                  children: [
                                    Stack(
                                      children: [
                                        CustomProductTile(
                                          title: product.name,
                                          location: product.location,
                                          timeAgo: 'Just now',
                                          sustainabilityText:
                                              '🌱 Saves ${product.co2Saved.toStringAsFixed(1)}kg CO₂ & 1 landfill item',
                                          price:
                                              'Rs. ${product.price.toStringAsFixed(2)}',
                                          productImage: product.imageUrls.first,
                                          iconImage: 'assets/images/icon.png',
                                          onTap: () {},
                                        ),
                                        // Remove button positioned at top-right
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () =>
                                                _showRemoveConfirmation(
                                              cartItem['id'],
                                              product.name,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.red.withOpacity(0.9),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                        text: 'Total amount:',
                                        color: AppColors.black,
                                        fontSize:
                                            ParagraphTexts.normalParagraph,
                                        fontWeight: FontWeight.normal),
                                    CustomText(
                                        text:
                                            'Rs. ${totalAmount.toStringAsFixed(2)}',
                                        color: AppColors.black,
                                        fontSize:
                                            ParagraphTexts.normalParagraph,
                                        fontWeight: FontWeight.w600),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                        text: 'Carbon Saved:',
                                        color: AppColors.black,
                                        fontSize:
                                            ParagraphTexts.normalParagraph,
                                        fontWeight: FontWeight.normal),
                                    CustomText(
                                        text:
                                            '${totalCO2.toStringAsFixed(1)} kg',
                                        color: AppColors.black,
                                        fontSize:
                                            ParagraphTexts.normalParagraph,
                                        fontWeight: FontWeight.w600),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                        text: 'Items Rescued from Landfills:',
                                        color: AppColors.black,
                                        fontSize:
                                            ParagraphTexts.normalParagraph,
                                        fontWeight: FontWeight.normal),
                                    CustomText(
                                        text: '$landfillItems items',
                                        color: AppColors.black,
                                        fontSize:
                                            ParagraphTexts.normalParagraph,
                                        fontWeight: FontWeight.w600),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                CustomButton(
                                  text: 'Checkout',
                                  backgroundColor:
                                      const Color.fromARGB(255, 213, 167, 66),
                                  textColor: AppColors.white,
                                  textWeight: FontWeight.w600,
                                  textSize: ParagraphTexts.textFieldLable,
                                  width: double.infinity,
                                  height: 52,
                                  borderRadius: 50,
                                  onPressed: () {
                                    NavigationUtils.frontNavigation(
                                        context, const Checkout());
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        alignment: Alignment.center,
        child: NewBottomBar(
          c1: AppColors.lightGray,
          c2: AppColors.lightGray,
          c3: AppColors.black,
          c4: AppColors.lightGray,
        ),
      ),
    );
  }
}
