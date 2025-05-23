import 'package:flutter/material.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/custom_text.dart';

class CustomProductTile extends StatelessWidget {
  final String title;
  final String location;
  final String timeAgo;
  final String sustainabilityText;
  final String price;
  final String productImage;
  final String iconImage;
  final VoidCallback onTap;

  const CustomProductTile({
    Key? key,
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.sustainabilityText,
    required this.price,
    required this.productImage,
    required this.iconImage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: AppColors.white,
        width: double.infinity,
        child: Row(
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(productImage),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: title,
                            color: AppColors.black,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.w600,
                          ),
                          CustomText(
                            text: '$location • $timeAgo',
                            color: AppColors.black,
                            fontSize: ParagraphTexts.smallText,
                            fontWeight: FontWeight.normal,
                          ),
                        ],
                      ),
                      Image.asset(iconImage),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: sustainabilityText,
                            color: AppColors.black,
                            fontSize: ParagraphTexts.smallText,
                            fontWeight: FontWeight.normal,
                          ),
                          SizedBox(height: 10),
                          CustomText(
                            text: price,
                            color: AppColors.black,
                            fontSize: ParagraphTexts.normalParagraph,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
