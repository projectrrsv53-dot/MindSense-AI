// lib/screens/patient/doctor_connect_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';
import '../../router/app_router.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorConnectScreen extends ConsumerStatefulWidget {
  final bool? isUploadFlow; // CHANGE: Made nullable and added safe getter below

  const DoctorConnectScreen({
    super.key,
    this.isUploadFlow = false,
  });

  // Safe getter to prevent "type 'Null' is not a subtype of type 'bool'" errors
  // which can occur during hot reload if the instance is stale.
  bool get effectiveIsUploadFlow => isUploadFlow ?? false;

  @override
  ConsumerState<DoctorConnectScreen> createState() => _DoctorConnectScreenState();
}

class _DoctorConnectScreenState extends ConsumerState<DoctorConnectScreen> {
  List<String> _selectedDoctorIds = [];
  bool _isConnecting = false;
  bool _connected = false;
  
  int get remainingSlots => 5 - _myDoctors.length;
  String? get patientId => ref.read(authProvider).userId;
  
  bool _showAvailableDoctors = false;
  bool _showConfirmation = false;
  
  List<_DoctorOption> _myDoctors = [];
  List<_DoctorOption> _availableDoctors = [];

  @override
  void initState() {
    super.initState();
    _fetchMyDoctors();
    _fetchAvailableDoctors();
  }

  Future<void> _handleConnect() async {
    if (patientId == null) return;
    if (_selectedDoctorIds.isEmpty) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      for (final doctorId in _selectedDoctorIds) {
        await http.post(
          Uri.parse(ApiConfig.connectDoctor),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "patient_id": patientId!,
            "doctor_id": doctorId,
          }),
        );
      }

      if (mounted) {
        setState(() {
          _connected = true;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _fetchMyDoctors() async {
    if (patientId == null) return;
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.myDoctors(patientId!)),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _myDoctors = (data["doctors"] as List).map((e) {
            return _DoctorOption(
              id: e["user_id"].toString(),
              name: e["name"] ?? "",
              specialization: e["specialization"] ?? "",
              hospital: e["hospital_name"] ?? "",
              rating: (e["rating"] as num?)?.toDouble() ?? 5.0,
              emoji: "👨‍⚕️",
            );
          }).toList();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchAvailableDoctors() async {
    if (patientId == null) return;
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.availableDoctors(patientId!)),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _availableDoctors = (data["doctors"] as List).map((e) {
            return _DoctorOption(
              id: e["user_id"].toString(),
              name: e["name"] ?? "",
              specialization: e["specialization"] ?? "",
              hospital: e["hospital_name"] ?? "",
              rating: (e["rating"] as num?)?.toDouble() ?? 5.0,
              emoji: "👨‍⚕️",
            );
          }).toList();
        });
      }
    } catch (e) {
      print("Doctor fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatientColors.background,
      appBar: AppBar(
        backgroundColor: PatientColors.background,
        title: Text('Connect with Doctor', style: AppTextStyles.headingMedium()),
        leading: IconButton(
          icon: Icon(_showAvailableDoctors || _showConfirmation ? Icons.arrow_back_ios_rounded : Icons.close),
          onPressed: () {
            if (_showAvailableDoctors) {
              setState(() {
                _selectedDoctorIds.clear();
                _showAvailableDoctors = false;
              });
            } else if (_showConfirmation) {
              setState(() {
                _showConfirmation = false;
                _showAvailableDoctors = true;
              });
            } else {
              context.go(AppRoutes.patientDashboard);
            }
          },
        ),
      ),
      body: _connected
          ? _buildSuccessView()
          : _showConfirmation
              ? _buildConfirmationView()
              : _buildConnectView(),
    );
  }

  Widget _buildConnectView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info Banner ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9B59B6), Color(0xFF7C6FCD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Secure Data Sharing',
                          style: AppTextStyles.headingSmall(color: AppColors.white)),
                      const SizedBox(height: 4),
                      Text(
                        'Connected doctors will receive future analysis reports you submit.',
                        style: AppTextStyles.bodySmall(color: AppColors.white.withOpacity(0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Connected healthcare professionals',
            style: AppTextStyles.bodySmall(
              color: PatientColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // =======================
          // Connected Doctors
          // =======================
          if (_myDoctors.isNotEmpty) ...[
            Text(
              'Connected Doctors',
              style: AppTextStyles.bodySmall(
                color: PatientColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ..._myDoctors.map(
              (doc) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DoctorCard(
                  doctor: doc,
                  isSelected: false,
                  onTap: () {},
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // CHANGE: Logic for "Continue" button in Upload Flow
          if (widget.effectiveIsUploadFlow) ...[
            PrimaryButton(
              label: 'Continue',
              gradient: PatientColors.mainGradient,
              onPressed: () {
                context.go(AppRoutes.analysisDisclaimer);
              },
            ),
            const SizedBox(height: 12),
          ],

          // CHANGE: Logic for "Add More Doctors" button
          if (_myDoctors.length < 5)
            PrimaryButton(
              label: 'Add More Doctors',
              gradient: PatientColors.mainGradient,
              onPressed: () {
                setState(() {
                  _showAvailableDoctors = true;
                  _showConfirmation = false;
                });
              },
            ),

          // =======================
          // Available Doctors
          // =======================
          if (_showAvailableDoctors) ...[
            const SizedBox(height: 24),
            Text(
              'Available Doctors',
              style: AppTextStyles.bodySmall(
                color: PatientColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_myDoctors.length}/5 doctors connected • $remainingSlots slot(s) remaining',
              style: AppTextStyles.bodySmall(),
            ),
            const SizedBox(height: 12),
            ..._availableDoctors.map(
              (doc) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DoctorCard(
                  doctor: doc,
                  isSelected: _selectedDoctorIds.contains(doc.id),
                  onTap: () {
                    setState(() {
                      if (_selectedDoctorIds.contains(doc.id)) {
                        _selectedDoctorIds.remove(doc.id);
                      } else if (_selectedDoctorIds.length < remainingSlots) {
                        _selectedDoctorIds.add(doc.id);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("You can only add $remainingSlots more doctor(s)."),
                          ),
                        );
                      }
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedDoctorIds.clear();
                        _showAvailableDoctors = false;
                      });
                    },
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Continue',
                    gradient: _selectedDoctorIds.isNotEmpty ? PatientColors.mainGradient : null,
                    solidColor: _selectedDoctorIds.isEmpty ? PatientColors.textHint : null,
                    isLoading: _isConnecting,
                    onPressed: _selectedDoctorIds.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _showConfirmation = true;
                            });
                          },
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Center(
            child: Text(
              'You can revoke access at any time from Settings.',
              style: AppTextStyles.bodySmall(),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildConfirmationView() {
    final selectedDoctors = _availableDoctors.where((d) => _selectedDoctorIds.contains(d.id)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You are about to grant access to:",
            style: AppTextStyles.headingSmall(),
          ),
          const SizedBox(height: 20),
          if (_myDoctors.isNotEmpty) ...[
            Text(
              "Already connected:",
              style: AppTextStyles.bodyLarge(),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              _myDoctors.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "${index + 1}. ${_myDoctors[index].name}",
                  style: AppTextStyles.bodyMedium(),
                ),
              ),
            ),
          ],
          if (selectedDoctors.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              "New doctors being added:",
              style: AppTextStyles.bodyLarge(),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              selectedDoctors.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "${_myDoctors.length + index + 1}. ${selectedDoctors[index].name}",
                  style: AppTextStyles.bodyMedium(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showConfirmation = false;
                      _showAvailableDoctors = true;
                    });
                  },
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleConnect,
                  child: const Text("Confirm"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final selectedDoctors = _availableDoctors.where((d) => _selectedDoctorIds.contains(d.id)).toList();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text('Doctors Updated!', style: AppTextStyles.displayMedium()),
            const SizedBox(height: 12),
            Text(
              selectedDoctors.isEmpty
                  ? 'Your healthcare team currently includes:\n\n${_myDoctors.map((d) => d.name).join('\n')}'
                  : 'Your healthcare team now includes:\n\n${[
                      ..._myDoctors,
                      ...selectedDoctors,
                    ].map((d) => d.name).join('\n')}',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge(),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Done',
              gradient: PatientColors.mainGradient,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final _DoctorOption doctor;
  final bool isSelected;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.doctor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? PatientColors.primarySurface : PatientColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? PatientColors.primary : PatientColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: PatientColors.primary.withOpacity(0.1), blurRadius: 12)]
              : [],
        ),
        child: Row(
          children: [
            Text(doctor.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name,
                      style: AppTextStyles.headingSmall(color: PatientColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(
                    '${doctor.specialization} • ${doctor.hospital}',
                    style: AppTextStyles.bodySmall(),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFB347), size: 14),
                      const SizedBox(width: 3),
                      Text('${doctor.rating}', style: AppTextStyles.bodySmall()),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: PatientColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}

class _DoctorOption {
  final String id, name, specialization, hospital, emoji;
  final double rating;
  const _DoctorOption({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.rating,
    required this.emoji,
  });
}
