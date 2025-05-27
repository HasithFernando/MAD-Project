import 'package:flutter/material.dart';
import 'package:thriftale/pages/product_details.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/widgets/Search_Notification_Widget.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/widgets/grid_item_model.dart';
import 'package:thriftale/widgets/newBottomBar.dart';
import 'package:thriftale/widgets/reusable_category_widget.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
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

  late List<GridItemModel> sampleItems;

  @override
  void initState() {
    super.initState();
    // Initialize sampleItems here where context is available
    sampleItems = [
      GridItemModel(
        title: 'Latest Products',
        location: 'Colombo',
        timeAgo: '2 days ago',
        price: 'Rs. 1000.00',
        carbonSave: 'Saves 0.2kg CO2',
        imageUrl:
            'https://chriscross.in/cdn/shop/files/ChrisCrossNavyBlueCottonT-Shirt.jpg?v=1740994598',
        onTap: () {},
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                            text: 'Categories',
                            color: AppColors.black,
                            fontSize: LableTexts.subLable,
                            fontWeight: FontWeight.w600),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Category list
                    CategoryList(categories: categories),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                            text: 'Shirts',
                            color: AppColors.black,
                            fontSize: LableTexts.subLable,
                            fontWeight: FontWeight.w600),
                      ],
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    CustomGridWidget(
                      items: sampleItems,
                      spacing: 16.0,
                      itemHeight: 320.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        alignment: Alignment.center,
        child: NewBottomBar(
          c1: AppColors.lightGray,
          c2: AppColors.black,
          c3: AppColors.lightGray,
          c4: AppColors.lightGray,
        ),
      ),
    );
  }
}
