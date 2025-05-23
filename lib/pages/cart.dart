import 'package:flutter/material.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/Search_Notification_Widget.dart';
import 'package:thriftale/widgets/custom_button.dart';
import 'package:thriftale/widgets/custom_product_tile.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/widgets/dashboard_tile.dart';
import 'package:thriftale/widgets/newBottomBar.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 245, 245),
      body: SafeArea(
        child: Column(
          children: [
            SearchNotificationWidget(
              placeholder: "Search for products",
              notificationCount: 3, // Set your notification count here
              onSearchTap: () {
                // Navigate to search screen or show search dialog
                print('Search tapped');
              },
              onNotificationTap: () {
                // Navigate to notifications screen
                print('Notification tapped');
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CustomProductTile(
                      title: 'Casual Shirt',
                      location: 'Colombo',
                      timeAgo: '2 days ago',
                      sustainabilityText: '🌱 Saves 3kg CO₂ & 1 landfill item',
                      price: 'RS. 510.00',
                      productImage: 'assets/images/tshirt.png',
                      iconImage: 'assets/images/icon.png',
                      onTap: () {
                        // Handle tap action
                        print('Product card tapped');
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CustomProductTile(
                      title: 'Casual Shirt',
                      location: 'Colombo',
                      timeAgo: '2 days ago',
                      sustainabilityText: '🌱 Saves 3kg CO₂ & 1 landfill item',
                      price: 'RS. 510.00',
                      productImage: 'assets/images/tshirt.png',
                      iconImage: 'assets/images/icon.png',
                      onTap: () {
                        // Handle tap action
                        print('Product card tapped');
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CustomProductTile(
                      title: 'Casual Shirt',
                      location: 'Colombo',
                      timeAgo: '2 days ago',
                      sustainabilityText: '🌱 Saves 3kg CO₂ & 1 landfill item',
                      price: 'RS. 510.00',
                      productImage: 'assets/images/tshirt.png',
                      iconImage: 'assets/images/icon.png',
                      onTap: () {
                        // Handle tap action
                        print('Product card tapped');
                      },
                    ),
                    SizedBox(
                      height: 80,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                            text: 'Total amount:',
                            color: AppColors.black,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.normal),
                        CustomText(
                            text: 'Rs. 1240.00',
                            color: AppColors.black,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.w600),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                            text: 'Carbon Saved:',
                            color: AppColors.black,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.normal),
                        CustomText(
                            text: ' 2 kg',
                            color: AppColors.black,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.w600),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                            text: 'Items Rescued from Landfills: ',
                            color: AppColors.black,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.normal),
                        CustomText(
                            text: ' 3 items',
                            color: AppColors.black,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.w600),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
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
                        onPressed: () {}),
                    // Add some bottom padding to account for the bottom navigation
                    SizedBox(height: 20),
                  ],
                ),
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
