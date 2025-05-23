import 'package:flutter/material.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/custom_text.dart';

class DashboardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? iconPath;

  const DashboardTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconPath = 'assets/images/Shape.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: title,
                color: AppColors.black,
                fontSize: ParagraphTexts.textFieldLable,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(
                height: 4,
              ),
              CustomText(
                text: subtitle,
                color: AppColors.black,
                fontSize: ParagraphTexts.normalParagraph,
                fontWeight: FontWeight.normal,
              ),
            ],
          ),
          if (iconPath != null)
            Image.asset(
              iconPath!,
              fit: BoxFit.cover,
            ),
        ],
      ),
    );
  }
}
