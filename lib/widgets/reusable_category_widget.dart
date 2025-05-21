import 'package:flutter/material.dart';

// Category item model to hold the data for each category
class CategoryItem {
  final String image;
  final String text;
  final Function() onTap;

  CategoryItem({
    required this.image,
    required this.text,
    required this.onTap,
  });
}

// Widget for displaying a single category with circle background and text below
class CategoryCircle extends StatelessWidget {
  final String image;
  final String text;
  final Function() onTap;

  const CategoryCircle({
    super.key,
    required this.image,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: const Color(0xFFF8F0E3), // AppColors.categoryColor
              ),
              child: Center(
                child: Image.asset(
                  image,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14, // ParagraphTexts.normalParagraph
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget to display a horizontal scrollable list of categories
class CategoryList extends StatelessWidget {
  final List<CategoryItem> categories;

  const CategoryList({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: categories
            .map((category) => CategoryCircle(
                  image: category.image,
                  text: category.text,
                  onTap: category.onTap,
                ))
            .toList(),
      ),
    );
  }
}
