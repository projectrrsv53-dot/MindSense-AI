// lib/screens/admin/admin_login_screen.dart
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
class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
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
  //   await Future.delayed(const Duration(milliseconds: 800));
  //   if (mounted) {
  //     ref.read(authProvider.notifier).loginAsAdmin(email: _emailCtrl.text.trim());
  //     context.go(AppRoutes.adminDashboard);
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
            ApiConfig.login
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
          "admin",
        }),
      );

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200) {

        final admin =
        data["user"];

        ref.read(authProvider.notifier)
            .loginAsAdmin(

          email:
          admin["email"],
        );

        context.go(
          AppRoutes.adminDashboard,
        );

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content: Text(
              data["error"] ??
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
            "Error: $e",
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
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Dark gradient banner ──────────────────────────
              _buildBanner(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 36),

                      Text('Admin Login', style: AppTextStyles.displayMedium()),
                      const SizedBox(height: 6),
                      Text(
                        'Restricted access — authorised personnel only.',
                        style: AppTextStyles.bodyMedium(color: AdminColors.textSecondary),
                      ),
                      const SizedBox(height: 32),

                      CustomTextField(
                        label: 'Admin Email',
                        prefixIcon: Icons.admin_panel_settings_outlined,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        focusColor: AdminColors.primary,
                        validator: AppValidators.validateEmail,
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        label: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        controller: _passwordCtrl,
                        isPassword: true,
                        focusColor: AdminColors.primary,
                        validator: AppValidators.validatePassword,
                      ),
                      const SizedBox(height: 28),

                      PrimaryButton(
                        label: 'Login as Admin',
                        gradient: AdminColors.mainGradient,
                        isLoading: _isLoading,
                        icon: Icons.security_rounded,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: TextButton(
                          onPressed: () => context.go(AppRoutes.roleSelection),
                          child: Text(
                            '← Back to Role Selection',
                            style: AppTextStyles.bodySmall(color: AdminColors.textHint),
                          ),
                        ),
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

  Widget _buildBanner() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 36),
          decoration: const BoxDecoration(
            gradient: AdminColors.mainGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.white.withOpacity(0.25), width: 1.5),
                ),
                child: const Center(child: Text('🛡️', style: TextStyle(fontSize: 38))),
              ),
              const SizedBox(height: 16),
              Text(
                'MindSense Admin',
                style: AppTextStyles.headingLarge(color: AppColors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'System management & doctor verification portal',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(color: AppColors.white.withOpacity(0.7)),
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