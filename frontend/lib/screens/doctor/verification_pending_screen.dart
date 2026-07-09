// lib/screens/doctor/verification_pending_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';

class VerificationPendingScreen extends ConsumerWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: DoctorColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Illustration ────────────────────────────────
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: DoctorColors.primarySurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: DoctorColors.primary.withOpacity(0.2), width: 2),
                ),
                child: const Center(
                  child: Text('⏳', style: TextStyle(fontSize: 54)),
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Verification Pending',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayMedium(),
              ),
              const SizedBox(height: 12),

              if (auth.userName != null)
                Text(
                  'Hi Dr. ${auth.userName}!',
                  style: AppTextStyles.headingSmall(color: DoctorColors.primary),
                ),
              const SizedBox(height: 12),

              Text(
                'Your registration has been submitted. Our admin team will verify your medical license and activate your account within 24–48 hours.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge(),
              ),

              const SizedBox(height: 32),

              // ── Status steps ─────────────────────────────────
              _buildStatusSteps(),

              const Spacer(flex: 2),

              // ── Email reminder card ───────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DoctorColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: DoctorColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Text('📧', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You will receive an email once your account is approved. Check your inbox and spam folder.',
                        style: AppTextStyles.bodySmall(color: DoctorColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Demo: simulate approval

              PrimaryButton(
                label: 'Go to Sign In',
                gradient: DoctorColors.mainGradient,
                icon: Icons.login_rounded,
                onPressed: () {

                  ref.read(authProvider.notifier)
                      .logout();

                  context.go(
                    AppRoutes.doctorLogin,
                  );
                },
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go(AppRoutes.roleSelection);
                },
                child: Text(
                  'Back to Role Selection',
                  style: AppTextStyles.bodySmall(color: DoctorColors.textHint),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSteps() {
    final steps = [
      ('✅', 'Registration Submitted', true),
      ('⏳', 'License Verification', false),
      ('🔓', 'Account Activated', false),
    ];

    return Column(
      children: steps.map((s) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Text(s.$1, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 14),
              Text(
                s.$2,
                style: AppTextStyles.bodyMedium(
                  color: s.$3 ? DoctorColors.textPrimary : DoctorColors.textHint,
                ),
              ),
              if (s.$3) ...[
                const Spacer(),
                const Icon(Icons.check_circle_rounded, color: DoctorColors.success, size: 18),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}