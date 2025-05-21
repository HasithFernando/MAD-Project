import 'package:flutter/material.dart';
import 'package:thriftale/widgets/notification_bell_widget.dart';

class SearchNotificationWidget extends StatelessWidget {
  final String placeholder;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const SearchNotificationWidget({
    Key? key,
    this.placeholder = "Search for products",
    this.onSearchTap,
    this.onNotificationTap,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade600),
                    const SizedBox(width: 8.0),
                    Text(
                      placeholder,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16.0),

          // Notification bell
          NotificationBellWidget(
            count: notificationCount,
            onTap: onNotificationTap,
          ),
        ],
      ),
    );
  }
}
