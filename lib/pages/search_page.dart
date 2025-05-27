import 'package:flutter/material.dart';
import 'package:thriftale/models/product_model.dart';
import 'package:thriftale/pages/product_details.dart';
import 'package:thriftale/services/product_service.dart';
import 'package:thriftale/widgets/grid_item_model.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:thriftale/pages/home.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  List<Product> _searchResults = [];
  bool _isLoading = false;

  void _performSearch(String query) async {
    setState(() => _isLoading = true);

    final allProducts = await _productService.getAllProducts().first;

    final results = allProducts
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.location.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  GridItemModel _productToGridItemModel(Product product) {
    return GridItemModel(
      title: product.name,
      location: product.location,
      timeAgo: timeago.format(product.timestamp.toDate()),
      price: 'Rs. ${product.price.toStringAsFixed(2)}',
      carbonSave: 'CO2 Saved: ${product.co2Saved.toStringAsFixed(2)}kg',
      imageUrl: product.imageUrls.isNotEmpty
          ? product.imageUrls[0]
          : 'https://via.placeholder.com/150x150.png?text=No+Image',
      onTap: () {
        NavigationUtils.frontNavigation(
            context, ProductDetails(product: product));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            NavigationUtils.frontNavigation(context, const Home());
          },
        ),
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for products...',
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              _performSearch(_searchController.text);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? const Center(child: Text("No results found"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomGridWidget(
                    items: _searchResults
                        .map((product) => _productToGridItemModel(product))
                        .toList(),
                    spacing: 16,
                    itemHeight: 320,
                  ),
                ),
    );
  }
}
