import 'package:flutter/material.dart';

// Model class for grid items
class GridItemModel {
  final String title;
  final String location;
  final String timeAgo;
  final String price;
  final String carbonSave;
  final String imageUrl;
  final VoidCallback onTap;

  GridItemModel({
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.price,
    required this.carbonSave,
    required this.imageUrl,
    required this.onTap,
  });
}

// Custom Grid Widget
class CustomGridWidget extends StatelessWidget {
  final List<GridItemModel> items;
  final double spacing;
  final double itemHeight;

  const CustomGridWidget({
    Key? key,
    required this.items,
    this.spacing = 16.0,
    this.itemHeight = 320.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildRows(context),
    );
  }

  List<Widget> _buildRows(BuildContext context) {
    List<Widget> rows = [];

    for (int i = 0; i < items.length; i += 2) {
      List<Widget> rowChildren = [];

      // First item in the row
      rowChildren.add(
        Expanded(
          child: _buildGridItem(context, items[i]),
        ),
      );

      // Add spacing between items
      if (i + 1 < items.length) {
        rowChildren.add(SizedBox(width: spacing));

        // Second item in the row
        rowChildren.add(
          Expanded(
            child: _buildGridItem(context, items[i + 1]),
          ),
        );
      } else {
        // If odd number of items, add empty space for alignment
        rowChildren.add(SizedBox(width: spacing));
        rowChildren.add(const Expanded(child: SizedBox()));
      }

      rows.add(
        Row(
          children: rowChildren,
        ),
      );

      // Add vertical spacing between rows (except for the last row)
      if (i + 2 < items.length) {
        rows.add(SizedBox(height: spacing));
      }
    }

    return rows;
  }

  Widget _buildGridItem(BuildContext context, GridItemModel item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: itemHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Location and Time
            Row(
              children: [
                Text(
                  '${item.location} • ',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  item.timeAgo,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Price and Carbon Save
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.price,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 145, 8, 8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.carbonSave,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
