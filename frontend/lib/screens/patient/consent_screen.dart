// lib/screens/patient/consent_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../router/app_router.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _accepted = false;

  final List<_ConsentPoint> _points = const [
    _ConsentPoint(
      icon: '🔒',
      title: 'End-to-End Encrypted',
      desc: 'All audio recordings and transcripts are encrypted before upload.',
    ),
    _ConsentPoint(
      icon: '🤖',
      title: 'AI Analysis Only',
      desc: 'Your data is used solely for emotional wellness analysis.',
    ),
    _ConsentPoint(
      icon: '👁️',
      title: 'You Control Access',
      desc: 'No doctor sees your data unless you explicitly grant permission.',
    ),
    _ConsentPoint(
      icon: '🗑️',
      title: 'Right to Delete',
      desc: 'You can delete your data at any time from account settings.',
    ),
    _ConsentPoint(
      icon: '📵',
      title: 'Never Sold',
      desc: 'Your personal data is never sold or shared with third parties.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatientColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildHeader(),
                    const SizedBox(height: 28),

                    Text(
                      'Before we begin',
                      style: AppTextStyles.labelSmall(color: PatientColors.primary),
                    ),
                    const SizedBox(height: 12),

                    ...List.generate(_points.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildConsentTile(_points[i]),
                      );
                    }),

                    const SizedBox(height: 20),
                    _buildAcceptCard(),
                  ],
                ),
              ),
            ),

            // ── Bottom actions ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'I Agree — Continue',
                    gradient: _accepted ? PatientColors.mainGradient : null,
                    solidColor: _accepted ? null : PatientColors.textHint,
                    onPressed: _accepted
                        ? () => context.go(AppRoutes.patientOnboarding)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.roleSelection),
                    child: Text(
                      'Decline and go back',
                      style: AppTextStyles.bodySmall(color: PatientColors.textHint),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: PatientColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🛡️', style: TextStyle(fontSize: 44)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Privacy\nComes First', style: AppTextStyles.headingLarge()),
                const SizedBox(height: 4),
                Text(
                  'Please review how we handle your data.',
                  style: AppTextStyles.bodySmall(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentTile(_ConsentPoint point) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PatientColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PatientColors.divider),
        boxShadow: [
          BoxShadow(
            color: PatientColors.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PatientColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(point.icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(point.title, style: AppTextStyles.headingSmall()),
                const SizedBox(height: 3),
                Text(point.desc, style: AppTextStyles.bodySmall()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptCard() {
    return GestureDetector(
      onTap: () => setState(() => _accepted = !_accepted),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _accepted ? PatientColors.accentSurface : PatientColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _accepted ? PatientColors.accent : PatientColors.divider,
            width: _accepted ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _accepted ? PatientColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _accepted ? PatientColors.accent : PatientColors.textHint,
                  width: 2,
                ),
              ),
              child: _accepted
                  ? const Icon(Icons.check_rounded, color: AppColors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'I understand and consent to secure AI analysis of my audio and text data for emotional wellness purposes.',
                style: AppTextStyles.bodySmall(
                  color: _accepted ? PatientColors.textPrimary : PatientColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentPoint {
  final String icon;
  final String title;
  final String desc;
  const _ConsentPoint({required this.icon, required this.title, required this.desc});
}
