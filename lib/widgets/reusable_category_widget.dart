import 'package:flutter/material.dart';

/// Category item model to hold the data for each category
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

/// Widget for displaying a single category with a circular background and label
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
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF8F0E3), // Category background color
            ),
            child: Center(
              child: Image.asset(
                image,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80, // Keep the label centered and limited in width
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget to display a horizontal scrollable list of categories
class CategoryList extends StatelessWidget {
  final List<CategoryItem> categories;

  const CategoryList({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text("No categories available"));
    }

    return SizedBox(
      height: 120, // Ensures enough height for image + text
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: List.generate(categories.length, (index) {
            final category = categories[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CategoryCircle(
                image: category.image,
                text: category.text,
                onTap: category.onTap,
              ),
            );
          }),
        ),
      ),
    );
  }
}
