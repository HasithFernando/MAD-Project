import 'package:flutter/material.dart';
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
            child: ListView(
              children: [
                // Your home screen content here
                // For example: product listings, categories, etc.
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Welcome to Thriftale",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Add more widgets as needed for your home screen
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Include the SearchNotificationWidget class from your code
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
