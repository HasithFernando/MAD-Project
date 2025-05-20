import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color? iconColor; // Optional: if you want to tint the PNG
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const CustomBackButton({
    super.key,
    required this.onTap,
    this.iconColor,
    this.iconSize = 32,
    this.padding = const EdgeInsets.only(left: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 0,
      child: Padding(
        padding: padding,
        child: GestureDetector(
          onTap: onTap,
          child: Image.asset(
            'assets/icons/back.png', 
            height: iconSize,
            color:
                iconColor,
          ),
        ),
      ),
    );
  }
}
