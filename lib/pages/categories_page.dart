import 'package:flutter/material.dart';
import 'package:thriftale/models/product_model.dart';
import 'package:thriftale/pages/product_details.dart';
import 'package:thriftale/services/product_service.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/widgets/Search_Notification_Widget.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/widgets/grid_item_model.dart';
import 'package:thriftale/widgets/newBottomBar.dart';
import 'package:thriftale/widgets/reusable_category_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final ProductService _productService = ProductService();

  final List<Map<String, String>> staticCategories = [
    {'name': 'Tops', 'image': 'assets/images/shirt.png'},
    {'name': 'Bottoms', 'image': 'assets/images/pants.png'},
    {'name': 'Dresses', 'image': 'assets/images/dress.png'},
    {'name': 'Outerwear', 'image': 'assets/images/jacket.png'},
    {'name': 'Footwear', 'image': 'assets/images/shoes.png'},
    {'name': 'Accessories', 'image': 'assets/images/hat.png'},
  ];

  List<Product> selectedCategoryProducts = [];
  String selectedCategory = 'Tops';

  @override
  void initState() {
    super.initState();
    _loadCategoryProducts(selectedCategory);
  }

  Future<void> _loadCategoryProducts(String category) async {
    final products = await _productService.getProductsByCategory(category);
    setState(() {
      selectedCategory = category;
      selectedCategoryProducts = products;
    });
  }

  GridItemModel _productToGridItemModel(Product product) {
    return GridItemModel(
      title: product.name,
      location: product.location,
      timeAgo: _getTimeAgo(product.timestamp.toDate()),
      price: _formatPrice(product.price),
      carbonSave: 'CO2 Saved: ${product.co2Saved.toStringAsFixed(2)}kg',
      imageUrl: product.imageUrls.isNotEmpty
          ? product.imageUrls[0]
          : 'https://via.placeholder.com/150x150.png?text=No+Image',
      onTap: () {
        NavigationUtils.frontNavigation(
            context, ProductDetails(product: product));
        print('Tapped on product: ${product.name}');
      },
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final duration = DateTime.now().difference(timestamp);
    if (duration.inDays > 0) return '${duration.inDays} days ago';
    if (duration.inHours > 0) return '${duration.inHours} hours ago';
    return '${duration.inMinutes} minutes ago';
  }

  String _formatPrice(double price) => 'Rs. ${price.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    List<CategoryItem> categoryWidgets = staticCategories.map((cat) {
      return CategoryItem(
        image: cat['image']!,
        text: cat['name']!,
        onTap: () => _loadCategoryProducts(cat['name']!),
      );
    }).toList();

    List<GridItemModel> gridItems =
        selectedCategoryProducts.map(_productToGridItemModel).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchNotificationWidget(
                placeholder: "Search for products",
                notificationCount: 3,
                onSearchTap: () => print('Search tapped'),
                onNotificationTap: () => print('Notification tapped'),
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
                    CategoryList(categories: categoryWidgets),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                            text: selectedCategory,
                            color: AppColors.black,
                            fontSize: LableTexts.subLable,
                            fontWeight: FontWeight.w600),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomGridWidget(
                      items: gridItems,
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
