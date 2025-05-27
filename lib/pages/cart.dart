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
                                if (product == null)
                                  return const SizedBox.shrink();

                                return Column(
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
