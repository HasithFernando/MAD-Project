import 'package:flutter/material.dart';

class TrimmedText extends StatelessWidget {
  final String text;
  final int maxChars;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  const TrimmedText({
    Key? key,
    required this.text,
    this.maxChars = 16,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
  }) : super(key: key);

  String get trimmedText {
    return text.length > maxChars ? '${text.substring(0, maxChars)}...' : text;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      trimmedText,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
