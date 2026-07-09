// lib/widgets/common/role_card.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class RoleCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final LinearGradient gradient;
  final Color borderColor;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.gradient,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji icon in gradient bubble
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(height: 16),

            Text(title, style: AppTextStyles.headingMedium()),
            const SizedBox(height: 6),
            Text(subtitle, style: AppTextStyles.bodyMedium()),
            const SizedBox(height: 20),

            // Continue button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(buttonLabel, style: AppTextStyles.labelMedium()),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: AppColors.white, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
