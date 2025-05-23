import 'package:flutter/material.dart';
import 'package:thriftale/pages/home.dart';
import 'package:thriftale/utils/pageNavigations.dart';

class Success extends StatefulWidget {
  const Success({super.key});

  @override
  State<Success> createState() => _SuccessState();
}

class _SuccessState extends State<Success> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Eco bag illustration
              Container(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Shopping bag
                    Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3E8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF2D5A2D),
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Bag handles
                          Positioned(
                            top: -8,
                            left: 15,
                            child: Container(
                              width: 25,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF2D5A2D),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: 15,
                            child: Container(
                              width: 25,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF2D5A2D),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          // Leaf icon on bag
                          Positioned(
                            bottom: 30,
                            left: 0,
                            right: 0,
                            child: Icon(
                              Icons.eco,
                              color: const Color(0xFF4CAF50),
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Decorative elements
                    Positioned(
                      top: 20,
                      left: 40,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 30,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D5A2D),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      right: 20,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Leaf decorations
                    const Positioned(
                      top: 60,
                      left: 20,
                      child: Icon(
                        Icons.eco,
                        color: Color(0xFF4CAF50),
                        size: 16,
                      ),
                    ),
                    const Positioned(
                      top: 30,
                      right: 50,
                      child: Icon(
                        Icons.eco,
                        color: Color(0xFF4CAF50),
                        size: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Success title
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A2D),
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Great Choice! ',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.eco,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Environmental impact message
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'By thrifting these items,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'you\'ve saved 2kg of Carbon and',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'kept 3 items out of landfills!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Thank you message
              const Text(
                'Thank you for choosing our app!',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Continue Shopping button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Add navigation logic here
                    NavigationUtils.frontNavigation(context, Home());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8956B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
