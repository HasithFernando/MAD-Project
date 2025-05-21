import 'dart:async';
import 'package:flutter/material.dart';

/// A slide model class to hold the data for each slide
class SlideModel {
  final String text;
  final String buttonText;
  final Color backgroundColor;
  final VoidCallback onButtonTap;

  SlideModel({
    required this.text,
    this.buttonText = 'Get Now',
    required this.backgroundColor,
    required this.onButtonTap,
  });
}

/// The AutoSlider widget that displays slides and auto-rotates them
class AutoSlider extends StatefulWidget {
  /// List of slides to display
  final List<SlideModel> slides;

  /// Duration between automatic transitions
  final Duration autoSlideDuration;

  /// Height of the slider
  final double height;

  /// Constructor for AutoSlider
  const AutoSlider({
    Key? key,
    required this.slides,
    this.autoSlideDuration = const Duration(seconds: 3),
    this.height = 200,
  }) : super(key: key);

  @override
  State<AutoSlider> createState() => _AutoSliderState();
}

class _AutoSliderState extends State<AutoSlider> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(widget.autoSlideDuration, (timer) {
      if (_currentPage < widget.slides.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Page View for slides
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.slides.length,
              itemBuilder: (context, index) {
                return SlideContent(
                  slideModel: widget.slides[index],
                );
              },
            ),

            // Dot indicators
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.slides.length,
                  (index) => _buildDotIndicator(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentPage == index
              ? Colors.white
              : Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

/// Individual slide content widget
class SlideContent extends StatelessWidget {
  final SlideModel slideModel;

  const SlideContent({
    Key? key,
    required this.slideModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: slideModel.backgroundColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            slideModel.text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: slideModel.onButtonTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(slideModel.buttonText),
          ),
        ],
      ),
    );
  }
}
