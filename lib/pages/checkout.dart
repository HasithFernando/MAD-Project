import 'package:flutter/material.dart';
import 'package:thriftale/pages/success.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/custom_button.dart';
import 'package:thriftale/widgets/custom_text.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 246, 246),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1000),
                        color: AppColors.CardBg,
                      ),
                      child: Image.asset('assets/images/backBtn.png'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CustomText(
                    text: 'Checkout',
                    color: AppColors.black,
                    fontSize: LableTexts.subLable,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Shipping Address Section
                      CustomText(
                        text: 'Shipping address',
                        color: AppColors.black,
                        fontSize: ParagraphTexts.textFieldLable,
                        fontWeight: FontWeight.w600,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only(top: 12.0),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  text: 'Jane Doe',
                                  color: AppColors.black,
                                  fontSize: ParagraphTexts.textFieldLable,
                                  fontWeight: FontWeight.w600,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Handle change address action
                                  },
                                  child: CustomText(
                                    text: 'Change',
                                    color: Colors.red,
                                    fontSize: ParagraphTexts.textFieldLable,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            CustomText(
                              text: '3 Newbridge Court',
                              color: AppColors.black.withOpacity(0.7),
                              fontSize: ParagraphTexts.textFieldLable * 0.9,
                              fontWeight: FontWeight.w400,
                            ),
                            const SizedBox(height: 4.0),
                            CustomText(
                              text: 'Chino Hills, CA 91709, United States',
                              color: AppColors.black.withOpacity(0.7),
                              fontSize: ParagraphTexts.textFieldLable * 0.9,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Payment Section
                      CustomText(
                        text: 'Payment',
                        color: AppColors.black,
                        fontSize: ParagraphTexts.textFieldLable,
                        fontWeight: FontWeight.w600,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only(top: 12.0),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  text: 'Payment Method',
                                  color: AppColors.black,
                                  fontSize: ParagraphTexts.textFieldLable,
                                  fontWeight: FontWeight.w600,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Handle change payment method action
                                  },
                                  child: CustomText(
                                    text: 'Change',
                                    color: Colors.red,
                                    fontSize: ParagraphTexts.textFieldLable,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              children: [
                                // Mastercard logo container
                                Container(
                                  width: 40,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Red circle
                                      Positioned(
                                        left: 0,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEB001B),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      // Orange circle overlapping
                                      Positioned(
                                        left: 12,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF79E1B),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                CustomText(
                                  text: '**** **** **** 3947',
                                  color: AppColors.black,
                                  fontSize: ParagraphTexts.textFieldLable,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Order Summary Section
                      _buildSummaryRow('Order:', 'Rs. 1240.00'),
                      const SizedBox(height: 10),
                      _buildSummaryRow('Delivery:', '2 kg'),
                      const SizedBox(height: 10),
                      _buildSummaryRow('Summary:', '2 kg'),
                      const SizedBox(height: 10),
                      _buildSummaryRow('Carbon Saved:', '2 kg'),
                      const SizedBox(height: 10),
                      _buildSummaryRow(
                          'Items Rescued from Landfills:', '3 items'),

                      const SizedBox(height: 80),

                      // Submit Button
                      CustomButton(
                        text: 'Submit Order',
                        backgroundColor:
                            const Color.fromARGB(255, 213, 167, 66),
                        textColor: AppColors.white,
                        textWeight: FontWeight.w600,
                        textSize: ParagraphTexts.textFieldLable,
                        width: double.infinity,
                        height: 52,
                        borderRadius: 50,
                        onPressed: () {
                          NavigationUtils.frontNavigation(context, Success());
                        },
                      ),

                      // Bottom padding for safe scrolling
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: CustomText(
            text: label,
            color: AppColors.black,
            fontSize: ParagraphTexts.normalParagraph,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 1,
          child: CustomText(
            text: value,
            color: AppColors.black,
            fontSize: ParagraphTexts.normalParagraph,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
