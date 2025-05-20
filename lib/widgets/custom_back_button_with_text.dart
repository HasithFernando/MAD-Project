import 'package:flutter/material.dart';

class CustomBackButtonWithText extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final Color? iconColor;
  final double iconSize;
  final TextStyle? titleStyle;

  const CustomBackButtonWithText({
    super.key,
    required this.onTap,
    required this.title,
    this.iconColor,
    this.iconSize = 32,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      child: Stack(
        children: [
          // Back Button on the left
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: onTap,
              child: Image.asset(
                'assets/icons/back.png',
                height: iconSize,
                color: iconColor,
              ),
            ),
          ),

          // Centered Title
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                title,
                style: titleStyle ??
                    const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
