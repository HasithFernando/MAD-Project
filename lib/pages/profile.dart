import 'package:flutter/material.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/Search_Notification_Widget.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/widgets/dashboard_tile.dart';
import 'package:thriftale/widgets/newBottomBar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            SearchNotificationWidget(
              placeholder: "Search for products",
              notificationCount: 3, // Set your notification count here
              onSearchTap: () {
                // Navigate to search screen or show search dialog
                print('Search tapped');
              },
              onNotificationTap: () {
                // Navigate to notifications screen
                print('Notification tapped');
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.green,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/profile1.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: 'John Doe',
                                      color: AppColors.black,
                                      fontSize: LableTexts.subLable,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    CustomText(
                                      text: 'johndoe@email.com',
                                      color: AppColors.black,
                                      fontSize: ParagraphTexts.normalParagraph,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: 30), // Align with text content
                                      child: // Replace the problematic Padding widget with this:
                                          Container(
                                        width: 200, // Define explicit width
                                        height: 22,
                                        margin: EdgeInsets.only(
                                            top:
                                                8), // Add some top margin instead of left padding
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              11), // Pill shape
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
                                        child: Stack(
                                          children: [
                                            // Step 2 (Orange circle) - positioned at the start
                                            Positioned(
                                              left: 0,
                                              top: 0,
                                              child: Container(
                                                width: 22,
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(
                                                      0xFFFF9800), // Orange color
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '2',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Step 3 (Green circle) - positioned at the end
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container(
                                                width: 22,
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(
                                                      0xFF4CAF50), // Green color
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '3',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Image.asset(
                              'assets/images/Shape.png',
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        // Progress Bar Section - Circles inside the progress bar
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 28,
                  ),

                  //card
                  DashboardTile(
                    title: 'Dashboard',
                    subtitle: 'Already have 12 orders',
                    onTap: () {
                      // Your onTap logic here
                      print('Dashboard tile tapped');
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  DashboardTile(
                    title: 'My orders',
                    subtitle: 'Already have 12 orders',
                    onTap: () {
                      // Your onTap logic here
                      print('Dashboard tile tapped');
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  DashboardTile(
                    title: 'My Achievements',
                    subtitle: 'Level 2',
                    onTap: () {
                      // Your onTap logic here
                      print('Dashboard tile tapped');
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  DashboardTile(
                    title: 'Payment methods',
                    subtitle: 'Visa  **34',
                    onTap: () {
                      // Your onTap logic here
                      print('Dashboard tile tapped');
                    },
                  ),

                  SizedBox(
                    height: 30,
                  ),
                  DashboardTile(
                    title: 'My reviews',
                    subtitle: 'Reviews for 4 items',
                    onTap: () {
                      // Your onTap logic here
                      print('Dashboard tile tapped');
                    },
                  ),

                  SizedBox(
                    height: 30,
                  ),
                  DashboardTile(
                    title: 'Settings',
                    subtitle: 'Notifications, password',
                    onTap: () {
                      // Your onTap logic here
                      print('Dashboard tile tapped');
                    },
                  ),
                ],
              ),
            ),
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
}
