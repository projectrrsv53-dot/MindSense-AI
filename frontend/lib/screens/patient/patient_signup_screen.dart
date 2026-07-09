// lib/screens/patient/patient_signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../utils/validators.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/core/config/api_config.dart';

class EmergencyContactData {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  String? relationship;

  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
  }
}

class PatientSignupScreen extends ConsumerStatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  ConsumerState<PatientSignupScreen> createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends ConsumerState<PatientSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final List<EmergencyContactData> _emergencyContacts = [EmergencyContactData()];
  final List<String> _selectedConcerns = [];

  List<dynamic> _doctors = [];
  String? _selectedDoctorId;
  String? _selectedGender;
  bool _consentGiven = false;
  bool _isLoading = false;

  final List<String> _allConcerns = [
    "Anxiety", "Depression", "Stress", "Burnout", "Loneliness",
    "Sleep Issues", "Mood Swings", "Relationship Problems",
    "Academic Pressure", "Work Pressure"
  ];

  final List<String> _genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];

  final List<String> _relationships = [
    'Parent', 'Mother', 'Father', 'Sister', 'Brother', 'Spouse',
    'Friend', 'Guardian', 'Relative', 'Colleague', 'Therapist', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    for (var contact in _emergencyContacts) {
      contact.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.doctors),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _doctors = data["doctors"] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Doctor fetch error: $e");
    }
  }

  void _addEmergencyContact() {
    if (_emergencyContacts.length < 5) {
      setState(() {
        _emergencyContacts.add(EmergencyContactData());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 emergency contacts allowed.')),
      );
    }
  }

  void _removeEmergencyContact(int index) {
    if (_emergencyContacts.length > 1) {
      setState(() {
        final contact = _emergencyContacts.removeAt(index);
        contact.dispose();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 1 emergency contact is required.')),
      );
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedConcerns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one concern.')),
      );
      return;
    }

    if (!_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give consent to proceed.')),
      );
      return;
    }

    // Check for duplicate phone numbers in emergency contacts
    final phones = _emergencyContacts.map((c) => c.phoneCtrl.text.trim()).toList();
    if (phones.toSet().length != phones.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duplicate phone numbers in emergency contacts.')),
      );
      return;
    }
    // Check for duplicate emails
    final emails = _emergencyContacts
        .map((c) => c.emailCtrl.text.trim())
        .toList();

    if (emails.toSet().length != emails.length) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Duplicate emails in emergency contacts.',
          ),
        ),
      );

      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> emergencyContactsJson = _emergencyContacts.map((c) => {
        "name": c.nameCtrl.text.trim(),
        "phone": c.phoneCtrl.text.trim(),
        "email": c.emailCtrl.text.trim(),
        "relationship": c.relationship,
      }).toList();

      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameCtrl.text.trim(),
          "email": _emailCtrl.text.trim(),
          "phone": _phoneCtrl.text.trim(),
          "age": int.tryParse(_ageCtrl.text.trim()) ?? 0,
          "gender": _selectedGender,
          "password": _passwordCtrl.text.trim(),
          "role": "patient",
          "emergency_contacts": emergencyContactsJson,
          "preferred_doctor_id": _selectedDoctorId,
          "primary_concerns": _selectedConcerns,
          "consent_given": _consentGiven
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        ref.read(authProvider.notifier).loginAsPatient(
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              userId: data["user_id"],
              isFirst: true,
            );
        if (mounted) {
          context.go(AppRoutes.patientConsent);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["error"] ?? "Signup failed")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: $e")),
        );
      }
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
      appBar: AppBar(
        backgroundColor: PatientColors.background,
        elevation: 0,
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
                const SizedBox(height: 32),

                // -- Personal Info --
                Text('Personal Info', style: AppTextStyles.labelSmall(color: PatientColors.primary)),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Full Name',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _nameCtrl,
                  focusColor: PatientColors.primary,
                  validator: AppValidators.validateName,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Email Address',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  focusColor: PatientColors.primary,
                  validator: AppValidators.validateEmail,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  focusColor: PatientColors.primary,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => (v == null || v.length < 10) ? 'Enter valid number' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Age',
                        prefixIcon: Icons.cake_outlined,
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        focusColor: PatientColors.primary,
                        validator: AppValidators.validateAge,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: _buildGenderDropdown()),
                  ],
                ),
                const SizedBox(height: 24),

                // -- Security --
                Text('Security', style: AppTextStyles.labelSmall(color: PatientColors.primary)),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  controller: _passwordCtrl,
                  isPassword: true,
                  focusColor: PatientColors.primary,
                  validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Confirm Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  controller: _confirmCtrl,
                  isPassword: true,
                  focusColor: PatientColors.primary,
                  validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 24),

                // -- Emergency Contacts --
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Emergency Contacts', style: AppTextStyles.labelSmall(color: PatientColors.primary)),
                    TextButton.icon(
                      onPressed: _addEmergencyContact,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text('Add', style: AppTextStyles.labelSmall(color: PatientColors.primary)),
                      style: TextButton.styleFrom(foregroundColor: PatientColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._buildEmergencyContactFields(),
                const SizedBox(height: 24),

                // -- Mental Health Info --
                Text('Primary Concerns (Select 1-3)', style: AppTextStyles.labelSmall(color: PatientColors.primary)),
                const SizedBox(height: 12),
                _buildConcernChips(),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedDoctorId,
                  decoration: _dropdownDecoration('Preferred Doctor (Optional)'),
                  items: _doctors.map((doctor) {
                    return DropdownMenuItem<String>(
                      value: doctor["user_id"].toString(),
                      child: Text("${doctor["name"]} (${doctor["user_id"]})", style: AppTextStyles.bodyMedium()),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedDoctorId = value),
                ),
                const SizedBox(height: 24),

                // -- Consent --
                _buildConsentCard(),
                const SizedBox(height: 28),

                PrimaryButton(
                  label: 'Create Account',
                  gradient: PatientColors.mainGradient,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSignup,
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: AppTextStyles.bodySmall()),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.patientLogin),
                      child: Text(
                        'Sign In',
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
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: PatientColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: PatientColors.primary.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: PatientColors.primary.withOpacity(0.2)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: PatientColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🌿', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Account', style: AppTextStyles.headingLarge()),
                const SizedBox(height: 4),
                Text('Your emotional wellbeing matters.', style: AppTextStyles.bodyMedium()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: _dropdownDecoration('Gender').copyWith(
        prefixIcon: const Icon(Icons.wc_outlined, size: 20),
      ),
      items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g, style: AppTextStyles.bodyMedium()))).toList(),
      onChanged: (v) => setState(() => _selectedGender = v),
      hint: Text('Gender', style: AppTextStyles.bodySmall()),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  List<Widget> _buildEmergencyContactFields() {
    return _emergencyContacts.asMap().entries.map((entry) {
      int idx = entry.key;
      EmergencyContactData contact = entry.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PatientColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PatientColors.primary.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Contact #${idx + 1}', style: AppTextStyles.labelSmall(color: PatientColors.primary.withOpacity(0.6))),
                if (_emergencyContacts.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: PatientColors.error, size: 20),
                    onPressed: () => _removeEmergencyContact(idx),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            CustomTextField(
              label: 'Name',
              prefixIcon: Icons.person_outline,
              controller: contact.nameCtrl,
              focusColor: PatientColors.primary,
              validator: AppValidators.validateName,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              controller: contact.phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              focusColor: PatientColors.primary,
              validator: AppValidators.validatePhone,
            ),
            const SizedBox(height: 12),

            CustomTextField(
              label: 'Email Address',
              prefixIcon: Icons.email_outlined,
              controller: contact.emailCtrl,
              keyboardType: TextInputType.emailAddress,
              focusColor: PatientColors.primary,
              validator: AppValidators.validateEmail,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: contact.relationship,
              decoration: _dropdownDecoration('Relationship').copyWith(
                prefixIcon: const Icon(Icons.people_outline, size: 20),
              ),
              items: _relationships.map((r) => DropdownMenuItem(value: r, child: Text(r, style: AppTextStyles.bodyMedium()))).toList(),
              onChanged: (v) => setState(() => contact.relationship = v),
              validator: (v) => v == null ? 'Select relationship' : null,
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildConcernChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 0,
      children: _allConcerns.map((concern) {
        final isSelected = _selectedConcerns.contains(concern);
        return FilterChip(
          label: Text(concern, style: AppTextStyles.bodySmall(
            color: isSelected ? Colors.white : PatientColors.textSecondary,
          )),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                if (_selectedConcerns.length < 3) {
                  _selectedConcerns.add(concern);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Maximum 3 concerns allowed.')),
                  );
                }
              } else {
                _selectedConcerns.remove(concern);
              }
            });
          },
          selectedColor: PatientColors.primary,
          checkmarkColor: Colors.white,
          backgroundColor: PatientColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? PatientColors.primary : PatientColors.primary.withOpacity(0.2),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConsentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PatientColors.accentSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PatientColors.accent.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _consentGiven,
            onChanged: (v) => setState(() => _consentGiven = v ?? false),
            activeColor: PatientColors.accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall(color: PatientColors.textSecondary),
                  children: [
                    const TextSpan(text: 'I consent to secure '),
                    TextSpan(
                      text: 'AI analysis of my audio and text data',
                      style: AppTextStyles.bodySmall(color: PatientColors.primary)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(
                      text: '. My data is encrypted and never shared without permission.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
