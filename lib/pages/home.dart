import 'package:flutter/material.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/Search_Notification_Widget.dart';
import 'package:thriftale/widgets/custom_text.dart';
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
    //

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          'assets/images/Thriftale.png',
          height: 40, // Adjust height as needed
        ),
      ),
      body: Column(
        children: [
          // Add the SearchNotificationWidget below the app bar
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

          // Add the AutoSlider widget here, after the search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AutoSlider(
              slides: slides,
              autoSlideDuration: const Duration(seconds: 3),
              height: 180,
            ),
          ),

          // Rest of your home screen content below
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                  SizedBox(
                    height: 20,
                  ),

                  //horizontal slider
                  CategoryList(categories: categories)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Include the SearchNotificationWidget class from your code
