import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String fontFamily;
  final TextAlign textAlign;

  const CustomText({
    Key? key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily = 'Poppins',
    this.textAlign = TextAlign.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      softWrap: true,
      overflow: TextOverflow.visible,
      textAlign: textAlign,
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: color ?? Colors.black, // Default to black if no color provided
          fontSize: fontSize ?? 14.0, // Default to 14.0 if no fontSize provided
          fontWeight: fontWeight ??
              FontWeight.normal, // Default to normal if no fontWeight provided
        ),
      ),
    );
  }
}
