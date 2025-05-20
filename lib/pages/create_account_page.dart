import 'package:flutter/material.dart';
import 'package:thriftale/utils/appColors.dart';
import 'package:thriftale/utils/btn_text.dart';
import 'package:thriftale/utils/lable_texts.dart';
import 'package:thriftale/utils/paragraph_texts.dart';
import 'package:thriftale/widgets/clickable_text.dart';
import 'package:thriftale/widgets/custom_button.dart';
import 'package:thriftale/widgets/custom_text.dart';
import 'package:thriftale/widgets/custom_text_field.dart';
import 'package:thriftale/widgets/password_text_field.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Center(
                        child: Column(
                          children: [
                            CustomText(
                                text: 'Create Account',
                                color: AppColors.black,
                                fontSize: LableTexts.mainBanner,
                                fontWeight: FontWeight.w600),
                            CustomText(
                                text: 'Fill Your Information Below',
                                color: AppColors.black,
                                fontSize: ParagraphTexts.normalParagraph,
                                fontWeight: FontWeight.normal),
                            SizedBox(
                              height: 60,
                            ),
                            CustomTextField(
                              labelText: 'Name',
                              hintText: 'John Doe',
                              textColor: const Color.fromARGB(255, 61, 61, 61),
                              hintColor: const Color.fromARGB(255, 53, 53, 53),
                              borderColor:
                                  const Color.fromARGB(255, 66, 66, 66),
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
                            CustomTextField(
                              labelText: 'Email',
                              hintText: 'example@example.com',
                              textColor: const Color.fromARGB(255, 61, 61, 61),
                              hintColor: const Color.fromARGB(255, 53, 53, 53),
                              borderColor:
                                  const Color.fromARGB(255, 66, 66, 66),
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
                              height: 10,
                            ),
                            PasswordTextField(
                              labelText: 'Re-Enter Password',
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
                            //terms and condition row section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Checkbox(
                                        value: true,
                                        onChanged: (bool? value) {
                                          // Handle checkbox state change
                                        }),
                                    CustomText(
                                        text: 'Agree with',
                                        color: AppColors.black,
                                        fontSize:
                                            ParagraphTexts.normalParagraph,
                                        fontWeight: FontWeight.normal),
                                    ClickableText(
                                      text: 'Terms & Conditions',
                                      onTap: () {
                                        // Your onTap logic here
                                      },
                                      color: Colors.black,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }
}
