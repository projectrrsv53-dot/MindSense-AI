// lib/screens/patient/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../models/onboarding_slide.dart';
import '../../router/app_router.dart';
import '../../core/config/api_config.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < onboardingSlides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.patientDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == onboardingSlides.length - 1;

    return Scaffold(
      backgroundColor: PatientColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.patientDashboard),
                child: Text('Skip', style: AppTextStyles.bodyMedium(color: PatientColors.textHint)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: onboardingSlides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _OnboardingPage(slide: onboardingSlides[i]),
              ),
            ),

            // Indicators + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageCtrl,
                    count: onboardingSlides.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                      activeDotColor: PatientColors.primary,
                      dotColor: PatientColors.primaryLight.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: isLast ? 'Get Started 🚀' : 'Next',
                    gradient: PatientColors.mainGradient,
                    onPressed: _next,
                    icon: isLast ? null : Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingSlide slide;

  const _OnboardingPage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon bubble
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: PatientColors.cardGradient,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: PatientColors.primary.withOpacity(0.15),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Text(slide.icon, style: const TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 40),

          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.displayMedium(),
          ),
          const SizedBox(height: 16),

          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge(),
          ),
        ],
      ),
    );
  }
}
