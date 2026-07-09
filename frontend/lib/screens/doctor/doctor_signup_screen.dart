// lib/screens/doctor/doctor_signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:http/http.dart' as http;
class DoctorSignupScreen extends ConsumerStatefulWidget {
  const DoctorSignupScreen({super.key});

  @override
  ConsumerState<DoctorSignupScreen> createState() => _DoctorSignupScreenState();
}

class _DoctorSignupScreenState extends ConsumerState<DoctorSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _selectedSpecialization;
  int? _selectedExperience;
  bool _isLoading = false;

  final List<String> _specializations = [
    'Psychiatrist',
    'Clinical Psychologist',
    'Neurologist',
    'General Practitioner',
    'Therapist',
    'Counsellor',
  ];

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _licenseCtrl, _hospitalCtrl, _passwordCtrl, _confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSignup() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSpecialization == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select specialization",
          ),
        ),
      );

      return;
    }

    if (_selectedExperience == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select years of experience",
          ),
        ),
      );

      return;
    }

    setState(() => _isLoading = true);

    try {

      final body = {

        "role": "doctor",

        "name":
        _nameCtrl.text.trim(),

        "email":
        _emailCtrl.text.trim(),

        "phone":
        _phoneCtrl.text.trim(),

        "specialization":
        _selectedSpecialization,

        "license_id":
        _licenseCtrl.text.trim(),

        "hospital_name":
        _hospitalCtrl.text.trim(),

        "years_experience":
        _selectedExperience,

        "password":
        _passwordCtrl.text.trim(),
      };

      debugPrint("━━━━━━━━━━━━━━━━━━━━");
      debugPrint("SIGNUP REQUEST");
      debugPrint(body.toString());

      final response = await http.post(

        Uri.parse(
            ApiConfig.register
        ),

        headers: {
          "Content-Type":
          "application/json",
        },

        body: jsonEncode(body),
      );

      debugPrint("STATUS CODE:");
      debugPrint(response.statusCode.toString());

      debugPrint("RAW RESPONSE:");
      debugPrint(response.body);

      final data =
      jsonDecode(response.body);

      if (response.statusCode == 200) {
        ref.read(authProvider.notifier).loginAsDoctor(name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(), userId: (data["user_id"] ?? data["id"] ?? "").toString(), pendingVerification: true);

        if (mounted) {

          ScaffoldMessenger.of(context)
              .showSnackBar(

            SnackBar(
              content: Text(
                data["message"] ??
                    "Doctor registered successfully",
              ),
            ),
          );

          context.go(
            AppRoutes.verificationPending,
          );
        }

      } else {

        debugPrint("BACKEND ERROR:");
        debugPrint(data.toString());

        if (mounted) {

          ScaffoldMessenger.of(context)
              .showSnackBar(

            SnackBar(
              content: Text(

                data["detail"]?.toString() ??

                    data["error"]?.toString() ??

                    data["message"]?.toString() ??

                    "Signup failed",
              ),
            ),
          );
        }
      }

    } catch (e) {

      debugPrint("━━━━━━━━━━━━━━━━━━━━");
      debugPrint("SIGNUP ERROR:");
      debugPrint(e.toString());

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content: Text(
              "Server error: $e",
            ),
          ),
        );
      }

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
      appBar: AppBar(
        backgroundColor: DoctorColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 28),

                Text('Personal Details',
                    style: AppTextStyles.labelSmall(color: DoctorColors.primary)),
                const SizedBox(height: 12),

                CustomTextField(
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _nameCtrl,
                  focusColor: DoctorColors.primary,
                  validator: AppValidators.validateName,
                ),
                const SizedBox(height: 14),

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
                  label: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  focusColor: DoctorColors.primary,
                  validator: AppValidators.validatePhone,
                ),
                const SizedBox(height: 24),

                Text('Professional Details',
                    style: AppTextStyles.labelSmall(color: DoctorColors.primary)),
                const SizedBox(height: 12),

                _buildSpecializationDropdown(),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'Medical License ID',
                  prefixIcon: Icons.badge_outlined,
                  controller: _licenseCtrl,
                  focusColor: DoctorColors.primary,
                  validator: AppValidators.validateLicense,
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'Hospital / Clinic (optional)',
                  prefixIcon: Icons.local_hospital_outlined,
                  controller: _hospitalCtrl,
                  focusColor: DoctorColors.primary,
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<int>(

                  value: _selectedExperience,

                  decoration: InputDecoration(

                    labelText: "Years of Experience",

                    prefixIcon:
                    const Icon(Icons.work_outline),

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),

                  items: List.generate(

                    51,

                        (index) => DropdownMenuItem(

                      value: index,

                      child: Text("$index Years"),
                    ),
                  ),

                  onChanged: (value) {

                    setState(() {

                      _selectedExperience =
                          value;
                    });
                  },

                  validator: (value) {

                    if (value == null) {

                      return "Select experience";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),

                Text('Security',
                    style: AppTextStyles.labelSmall(color: DoctorColors.primary)),
                const SizedBox(height: 12),

                CustomTextField(
                  label: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  controller: _passwordCtrl,
                  isPassword: true,
                  focusColor: DoctorColors.primary,
                  validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  label: 'Confirm Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  controller: _confirmCtrl,
                  isPassword: true,
                  focusColor: DoctorColors.primary,
                  validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 16),

                // Verification note
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: DoctorColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DoctorColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: DoctorColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your license will be verified by our admin team within 24–48 hours. You\'ll get email confirmation once approved.',
                          style: AppTextStyles.bodySmall(color: DoctorColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  label: 'Submit for Verification',
                  gradient: DoctorColors.mainGradient,
                  isLoading: _isLoading,
                  icon: Icons.verified_user_rounded,
                  onPressed: _handleSignup,
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already verified? ', style: AppTextStyles.bodySmall()),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.doctorLogin),
                      child: Text(
                        'Sign In',
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [DoctorColors.gradientStart.withOpacity(0.08), DoctorColors.gradientEnd.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DoctorColors.divider),
      ),
      child: Row(
        children: [
          const Text('🩺', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Doctor Registration', style: AppTextStyles.headingLarge()),
                const SizedBox(height: 4),
                Text('Join our verified clinician network.', style: AppTextStyles.bodyMedium()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSpecialization,
      decoration: InputDecoration(
        labelText: 'Specialization',
        prefixIcon: const Icon(Icons.medical_services_outlined, size: 20),
        filled: true,
        fillColor: DoctorColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DoctorColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DoctorColors.divider),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: _specializations
          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: AppTextStyles.bodyMedium())))
          .toList(),
      onChanged: (v) => setState(() => _selectedSpecialization = v),
      validator: (v) => v == null ? 'Select a specialization' : null,
      hint: Text('Specialization', style: AppTextStyles.bodySmall()),
    );
  }
}