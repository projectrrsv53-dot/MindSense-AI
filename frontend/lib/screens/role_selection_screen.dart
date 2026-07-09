// lib/screens/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/role_card.dart';
import '../providers/auth_provider.dart';
import '../router/app_router.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: PatientColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // ── Header ────────────────────────────
              _buildHeader(),
              const SizedBox(height: 40),

              // ── Patient Card ──────────────────────
              RoleCard(
                emoji: '👤',
                title: 'I am a Patient',
                subtitle: 'Track your emotional wellbeing using AI-powered analysis',
                buttonLabel: 'Continue as Patient',
                gradient: PatientColors.mainGradient,
                borderColor: PatientColors.primary,
                onTap: () {
                  ref.read(authProvider.notifier).selectRole(UserRole.patient);
                  context.push(AppRoutes.patientLogin);
                },
              ),
              const SizedBox(height: 20),

              // ── Doctor Card ───────────────────────
              RoleCard(
                emoji: '🩺',
                title: 'I am a Doctor',
                subtitle: 'Monitor patient emotional analytics and clinical insights',
                buttonLabel: 'Continue as Doctor',
                gradient: DoctorColors.mainGradient,
                borderColor: DoctorColors.primary,
                onTap: () {
                  ref.read(authProvider.notifier).selectRole(UserRole.doctor);
                  context.push(AppRoutes.doctorLogin);
                },
              ),
              const SizedBox(height: 20),

              // ── Admin Card ────────────────────────
              RoleCard(
                emoji: '🔐',
                title: 'I am an Admin',
                subtitle: 'Manage system users, reports, and global configurations',
                buttonLabel: 'Continue as Admin',
                gradient: AdminColors.mainGradient,
                borderColor: AdminColors.primary,
                onTap: () {
                  ref.read(authProvider.notifier).selectRole(UserRole.admin);
                  context.push(AppRoutes.adminLogin);
                },
              ),
              const SizedBox(height: 32),

              // ── Secondary Action ───────────────────
              Center(
                child: Text(
                  'MindSense AI v1.0.0',
                  style: AppTextStyles.bodySmall(color: PatientColors.textHint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mini logo row
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: PatientColors.mainGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('🧠', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 10),
            Text('MindSense AI',
                style: AppTextStyles.headingSmall(color: PatientColors.primary)),
          ],
        ),
        const SizedBox(height: 28),
        Text('Continue As', style: AppTextStyles.displayLarge()),
        const SizedBox(height: 8),
        Text(
          'Select your role to get started',
          style: AppTextStyles.bodyMedium(),
        ),
      ],
    );
  }
}
