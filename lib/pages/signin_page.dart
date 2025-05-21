import 'package:flutter/material.dart';
import 'package:thriftale/pages/complete_profile.dart';
import 'package:thriftale/pages/create_account_page.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/btn_text.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/pageNavigations.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/clickable_text.dart';
import 'package:thriftale/widgets/custom_button.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/widgets/custom_text_field.dart';
import 'package:thriftale/widgets/password_text_field.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: Center(
                      child: Column(
                        children: [
                          CustomText(
                              text: 'Sign in',
                              color: AppColors.black,
                              fontSize: LableTexts.startLable,
                              fontWeight: FontWeight.w600),
                          CustomText(
                              text: 'Hi! Welcome Back, youve been missed',
                              color: AppColors.black,
                              fontSize: ParagraphTexts.normalParagraph,
                              fontWeight: FontWeight.normal),
                          SizedBox(
                            height: 60,
                          ),
                          CustomTextField(
                            labelText: 'Email',
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
                          SizedBox(
                            height: 10,
                          ),
                          PasswordTextField(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ClickableText(
                                text: 'Forgot Password?',
                                onTap: () {
                                  // Your onTap logic here
                                },
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          CustomButton(
                              text: 'Sign in',
                              backgroundColor: AppColors.highlightbrown,
                              textColor: AppColors.Inicator,
                              textWeight: FontWeight.w600,
                              textSize: BtnText.imageBtn,
                              width: double.infinity,
                              height: 52,
                              borderRadius: 100,
                              onPressed: () {}),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom centered "Continue Without Login" text
            Positioned(
              left: 0,
              right: 0,
              bottom: 30, // Adjust this value to control how far from bottom
              child: Center(
                child: ClickableText(
                  text: 'Havent account? Register now',
                  onTap: () {
                    // Your onTap logic here
                    NavigationUtils.frontNavigation(
                        context, CreateAccountPage());
                  },
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
