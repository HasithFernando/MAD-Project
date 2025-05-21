import 'package:flutter/material.dart';
import 'package:thriftale/pages/home.dart';
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
  // For gender selection
  String? selectedGender;
  List<String> genderOptions = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: Column(
                        children: [
                          CustomText(
                              text: 'Complete Your Profile',
                              color: AppColors.black,
                              fontSize: LableTexts.headers,
                              fontWeight: FontWeight.w600),
                          CustomText(
                              text: 'Fill Your Information Below',
                              color: AppColors.black,
                              fontSize: ParagraphTexts.normalParagraph,
                              fontWeight: FontWeight.normal),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),

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
                            ),
                            child: Center(
                              child: Icon(
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
                              onTap: () {
                                // Implement image selection functionality
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),

                    // Name field
                    SizedBox(height: 8),
                    CustomTextField(
                      labelText: 'Name',
                      hintText: 'example@example.com',
                      textColor: const Color.fromARGB(255, 61, 61, 61),
                      hintColor: const Color.fromARGB(255, 53, 53, 53),
                      borderColor: const Color.fromARGB(255, 66, 66, 66),
                      borderRadius: 10.0,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Phone Number
                    CustomTextField(
                      labelText: 'Phone Number',
                      hintText: '+94 xx xx xxx',
                      textColor: const Color.fromARGB(255, 61, 61, 61),
                      hintColor: const Color.fromARGB(255, 53, 53, 53),
                      borderColor: const Color.fromARGB(255, 66, 66, 66),
                      borderRadius: 10.0,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Gender Dropdown
                    CustomText(
                        text: 'Gender',
                        color: AppColors.black,
                        fontSize: ParagraphTexts.normalParagraph,
                        fontWeight: FontWeight.normal),
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
                            hint: Text('Select'),
                            value: selectedGender,
                            items: genderOptions.map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
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
                        text: 'Complete Profile',
                        backgroundColor: AppColors.highlightbrown,
                        textColor: AppColors.Inicator,
                        textWeight: FontWeight.w600,
                        textSize: BtnText.imageBtn,
                        width: double.infinity,
                        height: 52,
                        borderRadius: 100,
                        onPressed: () {
                          // Navigate to the next screen or complete registration
                          NavigationUtils.frontNavigation(context, Home());
                        }),
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
