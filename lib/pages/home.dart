import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp
import 'package:thriftale/pages/categories_page.dart';
import 'package:thriftale/pages/product_details.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/Search_Notification_Widget.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/widgets/grid_item_model.dart';
import 'package:thriftale/widgets/newBottomBar.dart';
import 'package:thriftale/widgets/reusable_category_widget.dart';
import 'package:thriftale/widgets/slider_widget.dart';
import 'package:thriftale/services/product_service.dart'; // Import your ProductService
import 'package:thriftale/models/product_model.dart'; // Import your Product model
import 'package:timeago/timeago.dart' as timeago; // For timeAgo calculation

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ProductService _productService =
      ProductService(); // Initialize ProductService

  // Helper to format time ago from a Firestore Timestamp
  String _getTimeAgo(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return timeago.format(dateTime);
  }

  // Helper to format price
  String _formatPrice(double price) {
    return 'Rs. ${price.toStringAsFixed(2)}';
  }

  // Helper to convert Product model to GridItemModel
  GridItemModel _productToGridItemModel(Product product) {
    return GridItemModel(
      title: product.name,
      location: product.location,
      timeAgo: _getTimeAgo(product.timestamp),
      price: _formatPrice(product.price),
      carbonSave:
          'CO2 Saved: ${product.co2Saved.toStringAsFixed(2)}kg', // Use calculated CO2
      imageUrl: product.imageUrls.isNotEmpty
          ? product.imageUrls[0]
          : 'https://via.placeholder.com/150x150.png?text=No+Image', // Placeholder
      onTap: () {
        // Navigate to product detail page, passing the actual product object
        NavigationUtils.frontNavigation(
            context, ProductDetails(product: product)); // <--- UPDATED
        print('Tapped on product: ${product.name}');
        // You might pass the product.id or product object to the detail page
        print('Tapped on product: ${product.name}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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

    // Static categories list (you might want to make this dynamic too later)
    final List<CategoryItem> categories = [
      CategoryItem(
        image: 'assets/images/shirt.png', // Ensure asset exists
        text: 'Tops',
        onTap: () {
          print('Tops category tapped');
          // Navigate to a filtered product list for 'Tops'
        },
      ),
      CategoryItem(
        image: 'assets/images/pants.png', // Example, ensure asset exists
        text: 'Bottoms',
        onTap: () {
          print('Bottoms category tapped');
        },
      ),
      CategoryItem(
        image: 'assets/images/dress.png', // Example, ensure asset exists
        text: 'Dresses',
        onTap: () {
          print('Dresses category tapped');
        },
      ),
      CategoryItem(
        image: 'assets/images/jacket.png', // Example, ensure asset exists
        text: 'Outerwear',
        onTap: () {
          print('Outerwear category tapped');
        },
      ),
      CategoryItem(
        image: 'assets/images/shoes.png', // Example, ensure asset exists
        text: 'Footwear',
        onTap: () {
          print('Footwear category tapped');
        },
      ),
      CategoryItem(
        image: 'assets/images/hat.png', // Example, ensure asset exists
        text: 'Accessories',
        onTap: () {
          print('Accessories category tapped');
        },
      ),
      // Add more categories as needed, ensuring you have corresponding assets
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/images/Thriftale.png',
          height: 40,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SearchNotificationWidget(
              placeholder: "Search for products",
              notificationCount: 3,
              onSearchTap: () {
                print('Search tapped');
                // Implement search functionality here
              },
              onNotificationTap: () {
                print('Notification tapped');
                // Implement notification navigation here
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AutoSlider(
                        slides: slides,
                        autoSlideDuration: const Duration(seconds: 3),
                        height: 180,
                      ),
                    ),
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
                              GestureDetector(
                                onTap: () {
                                  print('See more categories tapped');
                                  // Navigate to a dedicated categories page if you have one
                                  NavigationUtils.frontNavigation(context,
                                      const CategoriesPage()); // Assuming CategoriesPage lists all categories
                                },
                                child: CustomText(
                                    text: 'See more',
                                    color:
                                        const Color.fromARGB(255, 235, 78, 78),
                                    fontSize: ParagraphTexts.normalParagraph,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CategoryList(categories: categories),
                          const SizedBox(height: 30),
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
                                  print('See all latest products tapped');
                                  // Navigate to a page displaying all latest products
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

                          // --- Dynamic Product List from Firestore ---
                          StreamBuilder<List<Product>>(
                            stream: _productService
                                .getAllProducts(), // Fetch all products
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text('No products available.'));
                              }

                              final products = snapshot.data!;
                              // Convert Product list to GridItemModel list
                              final List<GridItemModel> gridItems = products
                                  .map((product) =>
                                      _productToGridItemModel(product))
                                  .toList();

                              return CustomGridWidget(
                                items: gridItems,
                                spacing: 16.0,
                                itemHeight:
                                    320.0, // Ensure this height is suitable for your ProductCard
                              );
                            },
                          ),
                          // --- End Dynamic Product List ---

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
