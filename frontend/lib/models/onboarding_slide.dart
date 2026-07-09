//    models/onboarding_slide.dart

class OnboardingSlide {
  final String icon;
  final String title;
  final String description;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
  });
}

final List<OnboardingSlide> onboardingSlides = [
  const OnboardingSlide(
    icon: '🎙️',
    title: 'Record Your Voice',
    description:
    'Simply record a short audio of yourself speaking naturally. Our AI analyses speech patterns for emotional indicators.',
  ),
  const OnboardingSlide(
    icon: '📝',
    title: 'Upload Your Transcript',
    description:
    'Optionally upload a text transcript. Combining text and audio gives you more accurate and holistic emotional insights.',
  ),
  const OnboardingSlide(
    icon: '🧠',
    title: 'AI-Powered Insights',
    description:
    'Our multimodal model analyses your audio and text to provide a clear emotional wellness report — private and secure.',
  ),
];
