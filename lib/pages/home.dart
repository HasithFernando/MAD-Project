import 'package:flutter/material.dart';
import 'package:thriftale/pages/categories_page.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/Search_Notification_Widget.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/widgets/grid_item_model.dart';
import 'package:thriftale/widgets/newBottomBar.dart';
import 'package:thriftale/widgets/product_card.dart';
import 'package:thriftale/widgets/reusable_category_widget.dart';
import 'package:thriftale/widgets/slider_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    // Create the slides list directly when it's used
    final List<SlideModel> slides = [
      SlideModel(
        text: 'EARN BADGES AND REWARDS FOR REDUCING WASTE!',
        buttonText: 'Get Now',
        backgroundColor: const Color(0xFFE8855B),
        onButtonTap: () => print('Button clicked for slide 1'),
      ),
      SlideModel(
        text: 'SHOP PLANET-FRIENDLY PRODUCTS TODAY!',
        buttonText: 'Get Now',
        backgroundColor: const Color(0xFF4285F4),
        onButtonTap: () => print('Button clicked for slide 2'),
      ),
      SlideModel(
        text: 'JOIN OUR ECO-FRIENDLY COMMUNITY!',
        buttonText: 'Learn More',
        backgroundColor: const Color(0xFF34A853),
        onButtonTap: () => print('Button clicked for slide 3'),
      ),
    ];

    final List<CategoryItem> categories = [
      CategoryItem(
        image: 'assets/images/shirt.png',
        text: 'Shirt',
        onTap: () {
          print('Shirt category tapped');
          // Add your navigation or other logic here
        },
      ),
      CategoryItem(
        image: 'assets/images/shirt.png',
        text: 'Pants',
        onTap: () {
          print('Pants category tapped');
        },
      ),
      CategoryItem(
        image: 'assets/images/shirt.png',
        text: 'Pants',
        onTap: () {
          print('Pants category tapped');
        },
      ),
      CategoryItem(
        image: 'assets/images/shirt.png',
        text: 'Pants',
        onTap: () {
          print('Pants category tapped');
        },
      ),
      CategoryItem(
        image: 'assets/images/shirt.png',
        text: 'Pants',
        onTap: () {
          print('Pants category tapped');
        },
      ),
      CategoryItem(
        image: 'assets/images/shirt.png',
        text: 'Pants',
        onTap: () {
          print('Pants category tapped');
        },
      ),
      CategoryItem(
        image: 'assets/images/shirt.png',
        text: 'Pants',
        onTap: () {
          print('Pants category tapped');
        },
      ),
      CategoryItem(
        image: 'assets/images/shirt.png',
        text: 'Pants',
        onTap: () {
          print('Pants category tapped');
        },
      ),
    ];

    List<GridItemModel> sampleItems = [
      GridItemModel(
        title: 'Latest Products',
        location: 'Colombo',
        timeAgo: '2 days ago',
        price: 'Rs. 1000.00',
        carbonSave: 'Saves 0.2kg CO2',
        imageUrl:
            'https://chriscross.in/cdn/shop/files/ChrisCrossNavyBlueCottonT-Shirt.jpg?v=1740994598',
        onTap: () {
          NavigationUtils.frontNavigation(context, CategoriesPage());
        },
      ),
      GridItemModel(
        title: 'Fresh Vegetables',
        location: 'Galle',
        timeAgo: '1 day ago',
        price: 'Rs. 750.00',
        carbonSave: 'Saves 0.3kg CO2',
        imageUrl:
            'https://chriscross.in/cdn/shop/files/ChrisCrossNavyBlueCottonT-Shirt.jpg?v=1740994598',
        onTap: () {
          print('Item 2 tapped');
        },
      ),
      GridItemModel(
        title: 'Organic Fruits',
        location: 'Kandy',
        timeAgo: '3 hours ago',
        price: 'Rs. 1500.00',
        carbonSave: 'Saves 0.5kg CO2',
        imageUrl:
            'https://chriscross.in/cdn/shop/files/ChrisCrossNavyBlueCottonT-Shirt.jpg?v=1740994598',
        onTap: () {
          print('Item 3 tapped');
        },
      ),
      GridItemModel(
        title: 'Organic Fruits',
        location: 'Kandy',
        timeAgo: '3 hours ago',
        price: 'Rs. 1500.00',
        carbonSave: 'Saves 0.5kg CO2',
        imageUrl:
            'https://chriscross.in/cdn/shop/files/ChrisCrossNavyBlueCottonT-Shirt.jpg?v=1740994598',
        onTap: () {
          print('Item 3 tapped');
        },
      ),
      GridItemModel(
        title: 'Organic Fruits',
        location: 'Kandy',
        timeAgo: '3 hours ago',
        price: 'Rs. 1500.00',
        carbonSave: 'Saves 0.5kg CO2',
        imageUrl:
            'https://chriscross.in/cdn/shop/files/ChrisCrossNavyBlueCottonT-Shirt.jpg?v=1740994598',
        onTap: () {
          print('Item 3 tapped');
        },
      ),
      GridItemModel(
        title: 'Organic Fruits',
        location: 'Kandy',
        timeAgo: '3 hours ago',
        price: 'Rs. 1500.00',
        carbonSave: 'Saves 0.5kg CO2',
        imageUrl:
            'https://chriscross.in/cdn/shop/files/ChrisCrossNavyBlueCottonT-Shirt.jpg?v=1740994598',
        onTap: () {
          print('Item 3 tapped');
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/images/Thriftale.png',
          height: 40, // Adjust height as needed
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and notification widget - keep this outside the scrollable area
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

            // Make the rest of the content scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Auto slider
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AutoSlider(
                        slides: slides,
                        autoSlideDuration: const Duration(seconds: 3),
                        height: 180,
                      ),
                    ),

                    // Categories section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomText(
                                  text: 'Category',
                                  color: AppColors.black,
                                  fontSize: LableTexts.subLable,
                                  fontWeight: FontWeight.w600),
                              CustomText(
                                  text: 'See more',
                                  color: const Color.fromARGB(255, 235, 78, 78),
                                  fontSize: ParagraphTexts.normalParagraph,
                                  fontWeight: FontWeight.w600),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Category list
                          CategoryList(categories: categories),

                          const SizedBox(height: 30),

                          // Latest products section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomText(
                                  text: 'Latest Products',
                                  color: AppColors.black,
                                  fontSize: LableTexts.subLable,
                                  fontWeight: FontWeight.w600),
                              GestureDetector(
                                onTap: () {
                                  print('See all products tapped');
                                  // Add navigation to all products page
                                },
                                child: CustomText(
                                    text: 'See all',
                                    color:
                                        const Color.fromARGB(255, 235, 78, 78),
                                    fontSize: ParagraphTexts.normalParagraph,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          CustomGridWidget(
                            items: sampleItems,
                            spacing: 16.0,
                            itemHeight: 320.0,
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
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
          c1: AppColors.black,
          c2: AppColors.lightGray,
          c3: AppColors.lightGray,
          c4: AppColors.lightGray,
        ),
      ),
    );
  }
}
