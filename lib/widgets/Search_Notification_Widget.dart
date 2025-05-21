import 'package:flutter/material.dart';

class SearchNotificationWidget extends StatelessWidget {
  final String placeholder;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final TextEditingController? controller;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;

  const SearchNotificationWidget({
    Key? key,
    this.placeholder = "Search for products",
    this.onNotificationTap,
    this.notificationCount = 0,
    this.controller,
    this.onSearchChanged,
    this.onSearchSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Real search TextField
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: TextField(
                controller: controller,
                onChanged: onSearchChanged,
                onSubmitted: onSearchSubmitted != null
                    ? (_) => onSearchSubmitted!()
                    : null,
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16.0,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
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

class NotificationBellWidget extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const NotificationBellWidget({
    Key? key,
    this.count = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 24.0,
            ),
          ),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  count > 9 ? '9+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
