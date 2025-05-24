import 'package:flutter/material.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/widgets/newBottomBar.dart';
import 'package:thriftale/pages/profile.dart';

class Achievements extends StatefulWidget {
  const Achievements({super.key});

  @override
  State<Achievements> createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF0E6D2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 20,
            ),
          ),
          onPressed: () {
            // Use NavigationUtils to go back to Profile page
            NavigationUtils.frontNavigation(context, Profile());
          },
        ),
        title: CustomText(
          text: 'My Achievements',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level Progress Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: Center(
                          child: CustomText(
                            text: '2',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Level 2',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          CustomText(
                            text: '5 kg of Carbon to next level',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Progress Bar
                  Container(
                    height: 40,
                    child: Stack(
                      children: [
                        // Background progress bar
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFEB3B), // Yellow
                                Color(0xFF8BC34A), // Light green
                                Color(0xFF4CAF50), // Green
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                        // Progress indicator (84% filled)
                        Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width *
                              0.84 *
                              0.7, // 84% of available width
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFEB3B), // Yellow
                                Color(0xFF8BC34A), // Light green
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                        // Level 2 circle (start)
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFF9800), // Orange
                            ),
                            child: Center(
                              child: CustomText(
                                text: '2',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Progress text
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: CustomText(
                              text: '4200/5000',
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Level 3 circle (end)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF4CAF50), // Green
                            ),
                            child: Center(
                              child: CustomText(
                                text: '3',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Carbon Savings Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.eco,
                          color: Color(0xFF9C27B0),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      CustomText(
                        text: 'Total Carbon Savings',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  CustomText(
                    text: '7.5 Kg',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Color(0xFF4CAF50),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      CustomText(
                        text: '10%',
                        color: Color(0xFF4CAF50),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(width: 4),
                      CustomText(
                        text: 'vs last month',
                        color: Colors.grey[600]!,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Achievements Section
            Row(
              children: [
                CustomText(
                  text: 'Achievements',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomText(
                    text: '3',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600]!,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Achievement Items
            _buildAchievementItem(
              icon: 'assets/images/green_shopper_badge.png',
              title: 'Green Shopper',
              subtitle: 'February 02, 2025 • Saving 1Kg Carbon',
              isEarned: true,
            ),

            SizedBox(height: 16),

            _buildAchievementItem(
              icon: 'assets/images/eco_warrior_badge.png',
              title: 'Eco-Warrior',
              subtitle: 'February 02, 2025 • Saving 50Kg Carbon',
              isEarned: true,
            ),

            SizedBox(height: 16),

            _buildAchievementItem(
              icon: 'assets/images/eco_explorer_badge.png',
              title: 'Eco Explorer',
              subtitle: 'February 02, 2025 • Saving 100Kg Carbon',
              isEarned: true,
            ),

            SizedBox(height: 100), // Extra space for bottom navigation
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        alignment: Alignment.center,
        child: NewBottomBar(
          c1: AppColors.lightGray,
          c2: AppColors.lightGray,
          c3: AppColors.lightGray,
          c4: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildAchievementItem({
    required String icon,
    required String title,
    required String subtitle,
    required bool isEarned,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEarned ? Color(0xFF4CAF50) : Colors.grey[300],
            ),
            child: Icon(
              Icons.eco,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Earned',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600]!,
                ),
                CustomText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                CustomText(
                  text: subtitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600]!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
