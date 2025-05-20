import 'package:flutter/material.dart';

class ClickableText extends StatelessWidget {
  final String text;
  final Function() onTap;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const ClickableText({
    Key? key,
    required this.text,
    required this.onTap,
    this.color = Colors.black,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.normal,
    this.textAlign,
    this.overflow,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}
