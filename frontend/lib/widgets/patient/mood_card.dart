// lib/widgets/patient/mood_card.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class MoodCard extends StatelessWidget {
  final double score; // 0 to 100
  final String label;
  final DateTime timestamp;

  const MoodCard({
    super.key,
    required this.score,
    required this.label,
    required this.timestamp,
  });

  String get _moodEmoji {
    if (score >= 70) return '😊';
    if (score >= 45) return '😐';
    return '😔';
  }

  Color get _moodColor {
    if (score >= 70) return PatientColors.success;
    if (score >= 45) return PatientColors.warning;
    return PatientColors.error;
  }

  String get _moodLabel {
    if (score >= 70) return 'Good';
    if (score >= 45) return 'Moderate';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: PatientColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PatientColors.divider),
        boxShadow: [
          BoxShadow(
            color: PatientColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Current Mood',
                style: AppTextStyles.labelSmall(color: PatientColors.primary),
              ),
              const Spacer(),
              Text(
                _formatDate(timestamp),
                style: AppTextStyles.bodySmall(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(_moodEmoji, style: const TextStyle(fontSize: 44)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.headingSmall(color: PatientColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Wellness Score: ',
                          style: AppTextStyles.bodySmall(),
                        ),
                        Text(
                          '${score.toStringAsFixed(0)}%',
                          style: AppTextStyles.bodySmall(color: _moodColor)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _ScorePill(score: score, color: _moodColor, label: _moodLabel),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: PatientColors.divider,
              valueColor: AlwaysStoppedAnimation(_moodColor),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}

class _ScorePill extends StatelessWidget {
  final double score;
  final Color color;
  final String label;

  const _ScorePill({required this.score, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${score.toStringAsFixed(0)}',
            style: AppTextStyles.headingMedium(color: color),
          ),
          Text(label, style: AppTextStyles.bodySmall(color: color)),
        ],
      ),
    );
  }
}