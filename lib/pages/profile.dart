import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thriftale/pages/achievements.dart';
import 'package:thriftale/pages/checkout.dart';
import 'package:thriftale/services/profile_backend_service.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/Search_Notification_Widget.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/widgets/dashboard_tile.dart';
import 'package:thriftale/widgets/newBottomBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thriftale/pages/wishlist.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ProfileBackendService _profileService = ProfileBackendService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentUserId;
  bool _isLoading = true;
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        setState(() {
          _currentUserId = currentUser.uid;
        });
        await _loadUserProfile();
      } else {
        // Handle case where user is not logged in
        setState(() {
          _isLoading = false;
          _userName = 'Guest User';
          _userEmail = 'Not logged in';
        });
      }
    } catch (e) {
      print('Error initializing user: $e');
      setState(() {
        _isLoading = false;
        _userName = 'Error loading';
        _userEmail = 'Error loading';
      });
    }
  }

  Future<void> _loadUserProfile() async {
    if (_currentUserId == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final userData = await _profileService.getUserProfile(_currentUserId!);

      if (userData != null) {
        setState(() {
          _userName = userData['name'] ?? 'No name';
          _userEmail = userData['email'] ?? 'No email';
          _profileImageUrl = userData['profileImageUrl'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _userName = 'Profile not found';
          _userEmail = 'Profile not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _userName = 'Error loading';
        _userEmail = 'Error loading';
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileImage() {
    if (_isLoading) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 2, color: Colors.green),
          color: Colors.grey[200],
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(width: 2, color: Colors.green),
      ),
      child: ClipOval(
        child: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
            ? Image.network(
                _profileImageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: Colors.grey[400],
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            SearchNotificationWidget(
              placeholder: "Search for products",
              notificationCount: 3,
              onSearchTap: () {
                print('Search tapped');
              },
              onNotificationTap: () {
                print('Notification tapped');
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Section with Firebase Data
                      InkWell(
                        onTap: () {
                          // Navigate to edit profile page
                          // NavigationUtils.frontNavigation(context, EditProfile());
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _buildProfileImage(),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: _userName,
                                          color: AppColors.black,
                                          fontSize: LableTexts.subLable,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        CustomText(
                                          text: _userEmail,
                                          color: AppColors.black,
                                          fontSize:
                                              ParagraphTexts.normalParagraph,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 30),
                                          child: Container(
                                            width: 200,
                                            height: 22,
                                            margin: EdgeInsets.only(top: 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(11),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFFFEB3B), // Yellow
                                                  Color(
                                                      0xFF8BC34A), // Light green
                                                  Color(0xFF4CAF50), // Green
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 0,
                                                  top: 0,
                                                  child: Container(
                                                    width: 22,
                                                    height: 22,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFFFF9800),
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
                                                Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: Container(
                                                    width: 22,
                                                    height: 22,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF4CAF50),
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
                          ],
                        ),
                      ),

                      SizedBox(height: 28),

                      // Dashboard Tiles
                      DashboardTile(
                        title: 'Dashboard',
                        subtitle: 'Already have 12 orders',
                        onTap: () {
                          print('Dashboard tile tapped');
                        },
                      ),
                      SizedBox(height: 30),

                      DashboardTile(
                        title: 'My orders',
                        subtitle: 'Already have 12 orders',
                        onTap: () {
                          print('My orders tile tapped');
                        },
                      ),
                      SizedBox(height: 30),

                      DashboardTile(
                        title: 'My Achievements',
                        subtitle: 'Level 2',
                        onTap: () {
                          NavigationUtils.frontNavigation(
                              context, Achievements());
                        },
                      ),
                      SizedBox(height: 30),

                      DashboardTile(
                        title: 'Payment methods',
                        subtitle: 'Visa  **34',
                        onTap: () {
                          NavigationUtils.frontNavigation(context, Checkout());
                        },
                      ),
                      SizedBox(height: 30),

                      DashboardTile(
                        title: 'My reviews',
                        subtitle: 'Reviews for 4 items',
                        onTap: () {
                          print('My reviews tile tapped');
                        },
                      ),
                      SizedBox(height: 30),

                      DashboardTile(
                          title: 'Wishlist',
                          subtitle: 'Already have 12 orders',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const WishlistPage()),
                            );
                          }),
                      SizedBox(height: 30),

                      DashboardTile(
                        title: 'Settings',
                        subtitle: 'Notifications, password',
                        onTap: () {
                          print('Settings tile tapped');
                        },
                      ),
                      SizedBox(height: 30),

                      // Refresh Button
                      ElevatedButton.icon(
                        onPressed: _loadUserProfile,
                        icon: Icon(Icons.refresh),
                        label: Text('Refresh Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
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

// Optional: Real-time version using StreamBuilder
class ProfileWithRealTimeUpdates extends StatelessWidget {
  final ProfileBackendService _profileService = ProfileBackendService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfileWithRealTimeUpdates({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text('Please log in to view profile'),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _profileService.getProfileStream(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(
              child: Text('Profile not found'),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final userName = userData['name'] ?? 'No name';
        final userEmail = userData['email'] ?? 'No email';
        final profileImageUrl = userData['profileImageUrl'];

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Column(
              children: [
                SearchNotificationWidget(
                  placeholder: "Search for products",
                  notificationCount: 3,
                  onSearchTap: () => print('Search tapped'),
                  onNotificationTap: () => print('Notification tapped'),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Profile header with real-time data
                          Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(width: 2, color: Colors.green),
                                ),
                                child: ClipOval(
                                  child: profileImageUrl != null
                                      ? Image.network(
                                          profileImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(Icons.person, size: 32),
                                        )
                                      : Icon(Icons.person, size: 32),
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: userName,
                                    color: AppColors.black,
                                    fontSize: LableTexts.subLable,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  CustomText(
                                    text: userEmail,
                                    color: AppColors.black,
                                    fontSize: ParagraphTexts.normalParagraph,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Rest of your dashboard tiles...
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
