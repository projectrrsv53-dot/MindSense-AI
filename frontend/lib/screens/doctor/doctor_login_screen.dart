// lib/screens/doctor/doctor_login_screen.dart
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

import 'dart:convert';

import 'package:http/http.dart'
as http;
class DoctorLoginScreen extends ConsumerStatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  ConsumerState<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends ConsumerState<DoctorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Future<void> _handleLogin() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   setState(() => _isLoading = true);
  //   // await Future.delayed(const Duration(seconds: 1));
  //   // if (mounted) {
  //   //   ref.read(authProvider.notifier).loginAsDoctor(
  //   //     name: 'Dr. Anjali Sharma',
  //   //     email: _emailCtrl.text.trim(),
  //   //     pendingVerification: false,
  //   //   );
  //   final response = await AuthService.doctorLogin(
  //     email: _emailCtrl.text.trim(),
  //     password: _passwordCtrl.text.trim(),
  //   );
  //
  //   if (response['success']) {
  //     final doctor = response['doctor'];
  //
  //     ref.read(authProvider.notifier).loginAsDoctor(
  //       name: doctor['name'],
  //       email: doctor['email'],
  //       pendingVerification: doctor['verificationStatus'] != 'approved',
  //     );
  //
  //     if (doctor['verificationStatus'] == 'approved') {
  //       context.go(AppRoutes.doctorDashboard);
  //     } else {
  //       context.go(AppRoutes.verificationPending);
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(response['message'])),
  //     );
  //   }
  //     context.go(AppRoutes.doctorDashboard);
  //   }
  // }
  Future<void> _handleLogin() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {

      final response = await http.post(

        Uri.parse(
          ApiConfig.login,
        ),

        headers: {
          "Content-Type":
          "application/json",
        },

        body: jsonEncode({

          "identifier":
          _emailCtrl.text.trim(),

          "password":
          _passwordCtrl.text.trim(),

          "role":
          "doctor",
        }),
      );

      final data =
      jsonDecode(response.body);

      // =====================================================
      // SUCCESS
      // =====================================================

      if (response.statusCode == 200) {

        final doctor =
        data["user"];

        final verificationStatus =

            doctor["verification_status"] ??
                "pending";

        ref.read(authProvider.notifier)
            .loginAsDoctor(

          name:
          doctor["name"],

          email:
          doctor["email"],

          userId:
          doctor["user_id"] ?? doctor["id"] ?? "",

          pendingVerification:
          verificationStatus != "approved",
        );

        // ---------------------------------------------------
        // APPROVED
        // ---------------------------------------------------

        if (verificationStatus == "approved") {

          context.go(
            AppRoutes.doctorDashboard,
          );

          return;
        }

        // ---------------------------------------------------
        // PENDING
        // ---------------------------------------------------

        if (verificationStatus == "pending") {

          ScaffoldMessenger.of(context)
              .showSnackBar(

            const SnackBar(
              content: Text(
                "Your account is awaiting admin approval",
              ),
            ),
          );

          context.go(
            AppRoutes.verificationPending,
          );

          return;
        }

        // ---------------------------------------------------
        // REJECTED
        // ---------------------------------------------------

        if (verificationStatus == "rejected") {

          ScaffoldMessenger.of(context)
              .showSnackBar(

            const SnackBar(
              content: Text(
                "Your verification request was rejected",
              ),
            ),
          );

          return;
        }

        // ---------------------------------------------------
        // SUSPENDED
        // ---------------------------------------------------

      //   if (verificationStatus == "suspended") {
      //
      //     ScaffoldMessenger.of(context)
      //         .showSnackBar(
      //
      //       const SnackBar(
      //         content: Text(
      //           "Your account has been suspended",
      //         ),
      //       ),
      //     );
      //
      //     return;
      //   }
      //
      }

      // =====================================================
      // FAILED LOGIN
      // =====================================================

      else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content: Text(

              data["error"] ??

                  data["message"] ??

                  "Login failed",
            ),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Server error: $e",
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() =>
        _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Top banner ─────────────────────────────────
              _buildTopBanner(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Text('Welcome Back, Doctor 👋', style: AppTextStyles.displayMedium()),
                      const SizedBox(height: 6),
                      Text('Sign in to your clinical dashboard', style: AppTextStyles.bodyMedium()),
                      const SizedBox(height: 32),

                      CustomTextField(
                        label: 'Email Address',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        focusColor: DoctorColors.primary,
                        validator: AppValidators.validateEmail,
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        label: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        controller: _passwordCtrl,
                        isPassword: true,
                        focusColor: DoctorColors.primary,
                        validator: AppValidators.validatePassword,
                      ),
                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.bodySmall(color: DoctorColors.primary)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      PrimaryButton(
                        label: 'Sign In',
                        gradient: DoctorColors.mainGradient,
                        isLoading: _isLoading,
                        icon: Icons.login_rounded,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("New doctor? ", style: AppTextStyles.bodySmall()),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.doctorSignup),
                            child: Text(
                              'Register Here',
                              style: AppTextStyles.bodySmall(color: DoctorColors.primary)
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
            gradient: DoctorColors.mainGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.white.withOpacity(0.3)),
                ),
                child: const Center(child: Text('🩺', style: TextStyle(fontSize: 36))),
              ),
              const SizedBox(height: 14),
              Text(
                'Clinical Dashboard\nSecure Login',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge(color: AppColors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white),
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }
}