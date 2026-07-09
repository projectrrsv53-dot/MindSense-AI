
// lib/screens/patient/patient_login_screen.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/api_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../utils/validators.dart';
class PatientLoginScreen extends ConsumerStatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  ConsumerState<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends ConsumerState<PatientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  // Simulate "returning user" — toggle for demo
  bool _isReturningUser = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Future<void> _handleLogin() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   setState(() => _isLoading = true);
  //   await Future.delayed(const Duration(seconds: 1));
  //   if (mounted) {
  //     ref.read(authProvider.notifier).loginAsPatient(
  //       name: 'Rahul Sharma',
  //       email: _emailCtrl.text.trim(),
  //       isFirst: !_isReturningUser,
  //     );
  //     // First time → consent, returning → dashboard
  //     if (!_isReturningUser) {
  //       context.go(AppRoutes.patientConsent);
  //     } else {
  //       context.go(AppRoutes.patientDashboard);
  //     }
  //   }
  // }
  Future<void> _handleLogin() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {

      final response = await http.post(

        // Uri.parse("http://10.0.2.2:8000/login"),
        Uri.parse(ApiConfig.login),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "identifier": _emailCtrl.text.trim(),

          "password": _passwordCtrl.text.trim(),

          "role": "patient"

        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["message"] == "Login successful") {

        ref.read(authProvider.notifier).loginAsPatient(

          name: data["user"]["name"],

          email: data["user"]["email"],

          userId: data["user"]["user_id"],
          isFirst: false,
        );

        if (mounted) {

          context.go(AppRoutes.patientDashboard);
        }

      } else {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(
            content: Text(
                data["error"] ?? "Login failed"
            ),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text("Server error: $e"),
        ),
      );

    } finally {

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatientColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Top gradient banner ─────────────
              _buildTopBanner(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),

                      Text('Welcome Back 👋', style: AppTextStyles.displayMedium()),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to your account',
                        style: AppTextStyles.bodyMedium(),
                      ),
                      const SizedBox(height: 32),

                      CustomTextField(
                        label: 'Email or Phone',
                        prefixIcon: Icons.person_outline_rounded,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        focusColor: PatientColors.primary,
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        label: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        controller: _passwordCtrl,
                        isPassword: true,
                        focusColor: PatientColors.primary,
                        validator: AppValidators.validatePassword,
                      ),
                      const SizedBox(height: 10),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.bodySmall(color: PatientColors.primary)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Demo toggle: new / returning user
                      _buildDemoToggle(),
                      const SizedBox(height: 24),

                      PrimaryButton(
                        label: 'Sign In',
                        gradient: PatientColors.mainGradient,
                        isLoading: _isLoading,
                        icon: Icons.login_rounded,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 16),

                      // Biometric button
                      OutlineButton(
                        label: '🔐  Sign in with Biometrics',
                        borderColor: PatientColors.primary,
                        textColor: PatientColors.primary,
                        onPressed: () {},
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: AppTextStyles.bodySmall()),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.patientSignup),
                            child: Text(
                              'Sign Up',
                              style: AppTextStyles.bodySmall(color: PatientColors.primary)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          decoration: const BoxDecoration(
            gradient: PatientColors.cardGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              const Text('🌙', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(
                'Your safe space to\ncheck in with yourself',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge(color: PatientColors.textSecondary),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: PatientColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PatientColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: PatientColors.primary),
          const SizedBox(width: 8),
          Text('Demo: ', style: AppTextStyles.bodySmall(color: PatientColors.primary)),
          Text('Returning user?', style: AppTextStyles.bodySmall()),
          const Spacer(),
          Switch.adaptive(
            value: _isReturningUser,
            onChanged: (v) => setState(() => _isReturningUser = v),
            activeColor: PatientColors.primary,
          ),
        ],
      ),
    );
  }
}
