import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final FontWeight textWeight;
  final double textSize;
  final double width;
  final double height;
  final double borderRadius;
  final VoidCallback onPressed; // Added onPressed parameter

  CustomButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.textWeight,
    required this.textSize,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.onPressed, // Accepting the onPressed callback
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: MaterialButton(
        onPressed: onPressed, // Trigger the passed onPressed function
        child: Text(
          text,
          style: GoogleFonts.poppins(
            // Use Poppins font
            textStyle: TextStyle(
              color: textColor,
              fontWeight: textWeight,
              fontSize: textSize,
            ),
          ),
        ),
      ),
    );
  }
}
