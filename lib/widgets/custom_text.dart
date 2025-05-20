import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final String fontFamily;
  final TextAlign textAlign; // New parameter for text alignment

  CustomText({
    required this.text,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
    this.fontFamily = 'Poppins',
    this.textAlign = TextAlign.left, // Default value for textAlign
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      softWrap: true,
      overflow: TextOverflow.visible,
      textAlign: textAlign, // Applying the textAlign parameter
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
