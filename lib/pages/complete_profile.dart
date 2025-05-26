import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thriftale/pages/home.dart';
import 'package:thriftale/services/auth_service.dart';
import 'package:thriftale/services/profile_service.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/btn_text.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/custom_button.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/widgets/custom_text_field.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  // For gender selection
  String? selectedGender;
  List<String> genderOptions = ['Male', 'Female', 'Other'];

  // For image handling
  File? _selectedImage;
  String? _profileImageUrl;

  // Loading states
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadExistingUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Load existing user data if available
  Future<void> _loadExistingUserData() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      try {
        final userData = await _profileService.getUserProfile(user.uid);
        if (userData != null && mounted) {
          setState(() {
            _nameController.text = userData['name'] ?? user.displayName ?? '';
            _phoneController.text = userData['phone'] ?? '';
            selectedGender = userData['gender'];
            _profileImageUrl = userData['profileImageUrl'];
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  // Validate name
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  // Validate phone number
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove all non-digit characters for validation
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 9) {
      return 'Please enter a valid phone number';
    }
    if (digitsOnly.length > 15) {
      return 'Phone number is too long';
    }
    return null;
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Handle image selection
  Future<void> _selectImage() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null || _profileImageUrl != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error showing image options: $e');
      _showErrorDialog('Failed to open image options');
    }
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _profileImageUrl =
              null; // Clear existing URL when new image is selected
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorDialog('Failed to select image. Please try again.');
    }
  }

  // Remove selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _profileImageUrl = null;
    });
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return _profileImageUrl;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final user = _authService.getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final imageUrl = await _profileService.uploadProfileImage(
        userId: user.uid,
        imageFile: _selectedImage!,
      );

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      _showErrorDialog('Failed to upload image: ${e.toString()}');
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  // Handle profile completion
  Future<void> _handleCompleteProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedGender == null) {
      _showErrorDialog('Please select your gender');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        _showErrorDialog('User not authenticated. Please sign in again.');
        return;
      }

      // Upload image if selected
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null) {
          // Image upload failed, but we can continue without it
          print('Image upload failed, continuing without image');
        }
      } else {
        imageUrl = _profileImageUrl; // Keep existing image URL
      }

      // Prepare profile data
      final profileData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'gender': selectedGender!,
        'profileImageUrl': imageUrl,
        'profileCompleted': true,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Update user profile in Firestore
      final result = await _profileService.updateUserProfile(
        userId: user.uid,
        profileData: profileData,
      );

      if (result.success) {
        // Update user display name in Firebase Auth if different
        if (user.displayName != _nameController.text.trim()) {
          await _authService.updateUserProfile(
            displayName: _nameController.text.trim(),
            photoURL: imageUrl,
          );
        }

        _showSuccessMessage('Profile completed successfully!');

        // Navigate to home page
        await Future.delayed(Duration(milliseconds: 1500));
        if (mounted) {
          NavigationUtils.frontNavigation(context, Home());
        }
      } else {
        _showErrorDialog(result.error ?? 'Failed to complete profile');
      }
    } catch (e) {
      print('Error completing profile: $e');
      _showErrorDialog('An unexpected error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Skip profile completion
  void _skipProfileCompletion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Profile Setup?'),
        content: const Text(
          'You can complete your profile later from the settings page. '
          'However, having a complete profile helps other users trust you more.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              NavigationUtils.frontNavigation(context, Home());
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  // Empty function for disabled state
  void _doNothing() {
    // Do nothing when loading
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),

                      // Header with skip button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 48), // Balance the skip button
                          Expanded(
                            child: Center(
                              child: Column(
                                children: [
                                  CustomText(
                                    text: 'Complete Your Profile',
                                    color: AppColors.black,
                                    fontSize: LableTexts.headers,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  CustomText(
                                    text: 'Fill Your Information Below',
                                    color: AppColors.black,
                                    fontSize: ParagraphTexts.normalParagraph,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading
                                ? _doNothing
                                : _skipProfileCompletion,
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Profile Picture Upload
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Color(0xFFF5F5F5),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: _selectedImage != null
                                    ? Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      )
                                    : _profileImageUrl != null
                                        ? Image.network(
                                            _profileImageUrl!,
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 120,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.grey,
                                              );
                                            },
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _isLoading ? _doNothing : _selectImage,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.highlightbrown,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: _isUploadingImage
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.camera_alt,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),

                      // Name field
                      CustomTextField(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        controller: _nameController,
                        textColor: const Color.fromARGB(255, 61, 61, 61),
                        hintColor: const Color.fromARGB(255, 53, 53, 53),
                        borderColor: const Color.fromARGB(255, 66, 66, 66),
                        borderRadius: 10.0,
                        validator: _validateName,
                      ),
                      SizedBox(height: 16),

                      // Phone Number
                      CustomTextField(
                        labelText: 'Phone Number',
                        hintText: '+94 xx xxx xxxx',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textColor: const Color.fromARGB(255, 61, 61, 61),
                        hintColor: const Color.fromARGB(255, 53, 53, 53),
                        borderColor: const Color.fromARGB(255, 66, 66, 66),
                        borderRadius: 10.0,
                        validator: _validatePhone,
                      ),
                      SizedBox(height: 16),

                      // Gender Dropdown
                      CustomText(
                        text: 'Gender',
                        color: AppColors.black,
                        fontSize: ParagraphTexts.normalParagraph,
                        fontWeight: FontWeight.normal,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 66, 66, 66),
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(
                                'Select Gender',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 53, 53, 53),
                                ),
                              ),
                              value: selectedGender,
                              items: genderOptions.map((String gender) {
                                return DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(
                                    gender,
                                    style: TextStyle(
                                      color:
                                          const Color.fromARGB(255, 61, 61, 61),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: _isLoading
                                  ? null
                                  : (String? newValue) {
                                      setState(() {
                                        selectedGender = newValue;
                                      });
                                    },
                              padding: EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),

                      // Complete Profile Button
                      CustomButton(
                        text: _isLoading
                            ? 'Completing Profile...'
                            : 'Complete Profile',
                        backgroundColor: AppColors.highlightbrown,
                        textColor: AppColors.Inicator,
                        textWeight: FontWeight.w600,
                        textSize: BtnText.imageBtn,
                        width: double.infinity,
                        height: 52,
                        borderRadius: 100,
                        onPressed:
                            _isLoading ? _doNothing : _handleCompleteProfile,
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Completing your profile...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
