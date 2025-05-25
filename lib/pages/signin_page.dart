import 'package:flutter/material.dart';
import 'package:thriftale/pages/complete_profile.dart';
import 'package:thriftale/pages/create_account_page.dart';
import 'package:thriftale/services/auth_service.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
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
      ),
    );
  }

  // Handle sign in
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.success) {
        // Navigate to complete profile or dashboard
        // You can check if profile is completed in Firestore
        NavigationUtils.frontNavigation(context, CompleteProfilePage());
      } else {
        _showErrorDialog(result.error ?? 'Sign in failed');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handle forgot password
  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your email address first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.resetPassword(
        email: _emailController.text.trim(),
      );

      if (result.success) {
        _showSuccessMessage('Password reset email sent!');
      } else {
        _showErrorDialog(result.error ?? 'Failed to send reset email');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textColor: const Color.fromARGB(255, 61, 61, 61),
                              hintColor: const Color.fromARGB(255, 53, 53, 53),
                              borderColor:
                                  const Color.fromARGB(255, 66, 66, 66),
                              borderRadius: 10.0,
                              validator: _validateEmail,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            PasswordTextField(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              controller: _passwordController,
                              validator: _validatePassword,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ClickableText(
                                  text: 'Forgot Password?',
                                  onTap: _isLoading
                                      ? _doNothing
                                      : _handleForgotPassword,
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
                              text: _isLoading ? 'Signing in...' : 'Sign in',
                              backgroundColor: AppColors.highlightbrown,
                              textColor: AppColors.Inicator,
                              textWeight: FontWeight.w600,
                              textSize: BtnText.imageBtn,
                              width: double.infinity,
                              height: 52,
                              borderRadius: 100,
                              onPressed:
                                  _isLoading ? _doNothing : _handleSignIn,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                  onTap: _isLoading
                      ? _doNothing
                      : () {
                          NavigationUtils.frontNavigation(
                              context, CreateAccountPage());
                        },
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
