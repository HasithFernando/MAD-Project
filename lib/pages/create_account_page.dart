import 'package:flutter/material.dart';
import 'package:thriftale/pages/complete_profile.dart';
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

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Name validation
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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
    // Additional password strength checks
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain both letters and numbers';
    }
    return null;
  }

  // Confirm password validation
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
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

  // Handle create account
  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      _showErrorDialog('Please agree to the Terms & Conditions');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.createUserWithEmailAndPassword(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.success) {
        // Navigate to complete profile
        NavigationUtils.frontNavigation(context, CompleteProfilePage());
      } else {
        _showErrorDialog(result.error ?? 'Account creation failed');
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
              child: SingleChildScrollView(
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
                                controller: _nameController,
                                textColor:
                                    const Color.fromARGB(255, 61, 61, 61),
                                hintColor:
                                    const Color.fromARGB(255, 53, 53, 53),
                                borderColor:
                                    const Color.fromARGB(255, 66, 66, 66),
                                borderRadius: 10.0,
                                validator: _validateName,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              CustomTextField(
                                labelText: 'Email',
                                hintText: 'example@example.com',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textColor:
                                    const Color.fromARGB(255, 61, 61, 61),
                                hintColor:
                                    const Color.fromARGB(255, 53, 53, 53),
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
                                height: 10,
                              ),
                              PasswordTextField(
                                labelText: 'Re-Enter Password',
                                hintText: 'Confirm your password',
                                controller: _confirmPasswordController,
                                validator: _validateConfirmPassword,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              //terms and condition row section - FIXED
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _agreeToTerms = value ?? false;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Wrap(
                                      children: [
                                        CustomText(
                                          text: 'Agree with ',
                                          color: AppColors.black,
                                          fontSize:
                                              ParagraphTexts.normalParagraph,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        ClickableText(
                                          text: 'Terms & Conditions',
                                          onTap: () {
                                            // Show terms and conditions
                                            _showTermsDialog();
                                          },
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              CustomButton(
                                  text: _isLoading
                                      ? 'Creating Account...'
                                      : 'Create Account',
                                  backgroundColor: AppColors.highlightbrown,
                                  textColor: AppColors.Inicator,
                                  textWeight: FontWeight.w600,
                                  textSize: BtnText.imageBtn,
                                  width: double.infinity,
                                  height: 52,
                                  borderRadius: 100,
                                  onPressed: _isLoading
                                      ? _doNothing
                                      : _handleCreateAccount),
                            ],
                          ),
                        ),
                      ),
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
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Show terms and conditions dialog
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'By using Thriftale, you agree to our terms and conditions. '
            'This includes our privacy policy and user guidelines. '
            'Please read our full terms and conditions on our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
