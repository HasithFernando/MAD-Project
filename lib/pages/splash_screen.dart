import 'package:flutter/material.dart';
import 'package:thriftale/pages/dashboard.dart';
import 'package:thriftale/pages/signin_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Navigate to dashboard after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SigninPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              Image.asset(
                'assets/images/image.png',
                width: (MediaQuery.sizeOf(context).width) * 286 / 390,
                height: (MediaQuery.sizeOf(context).width) * 210 / 390,
              ),
              const Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.7,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _controller.value,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor),
                            minHeight: 5,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
