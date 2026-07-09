// lib/screens/doctor/patient_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../router/app_router.dart';
import '../../widgets/doctor/analytics_detail.dart';
import '../../providers/doctor_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../models/analysis_result.dart';

class PatientAnalyticsScreen extends ConsumerWidget {
  final String patientId;

  const PatientAnalyticsScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientDetailsProvider(patientId));

    return Scaffold(
      backgroundColor: DoctorColors.background,
      appBar: AppBar(
        backgroundColor: DoctorColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: DoctorColors.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.doctorDashboard),
        ),
        title: Text('Patient Analytics', style: AppTextStyles.headingMedium()),
        centerTitle: true,
      ),
      body: patientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: DoctorColors.error),
              const SizedBox(height: 16),
              Text('Error loading analytics', style: AppTextStyles.headingSmall()),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Retry',
                width: 120,
                onPressed: () => ref.refresh(patientDetailsProvider(patientId)),
              ),
            ],
          ),
        ),
        data: (data) {
          final patient = data["patient"] ?? {};
          final rawSessions = data["sessions"] as List? ?? [];
          final List<AnalysisResult> sessions = rawSessions
              .map((s) => AnalysisResult.fromBackend(s as Map<String, dynamic>))
              .toList();

          if (patient.isEmpty) {
            return const Center(child: Text('Patient data not available'));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PatientInfoCard(patient: patient),
                      const SizedBox(height: 32),
                      
                      Text('Session Analytics', style: AppTextStyles.headingSmall()),
                      const SizedBox(height: 16),
                      AnalyticsDetail(sessions: sessions),
                      const SizedBox(height: 32),

                      Text('Session Notes', style: AppTextStyles.headingSmall()),
                      const SizedBox(height: 16),
                      
                      if (sessions.isEmpty)
                        _buildEmptyNotes()
                      else
                        ...sessions.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _SessionDoctorNoteCard(
                              session: entry.value,
                              sessionIndex: entry.key,
                            ),
                          );
                        }),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyNotes() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DoctorColors.divider),
      ),
      child: Center(
        child: Text('No session notes available', style: AppTextStyles.bodySmall()),
      ),
    );
  }
}

class _PatientInfoCard extends StatelessWidget {
  final Map<String, dynamic> patient;
  const _PatientInfoCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DoctorColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patient Information', style: AppTextStyles.headingSmall(color: DoctorColors.primary)),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.person_outline, label: 'Name', value: patient["name"] ?? "Unknown"),
          const SizedBox(height: 10),
          _InfoRow(icon: Icons.email_outlined, label: 'Email', value: patient["email"] ?? "N/A"),
          const SizedBox(height: 10),
          _InfoRow(icon: Icons.wc_outlined, label: 'Gender', value: patient["gender"] ?? "N/A"),
          const SizedBox(height: 10),
          _InfoRow(icon: Icons.cake_outlined, label: 'Age', value: '${patient["age"] ?? "N/A"} years'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: DoctorColors.textHint),
        const SizedBox(width: 12),
        Text('$label: ', style: AppTextStyles.bodySmall(color: DoctorColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium(color: DoctorColors.textPrimary).copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SessionDoctorNoteCard extends StatefulWidget {
  final dynamic session;
  final int sessionIndex;

  const _SessionDoctorNoteCard({required this.session, required this.sessionIndex});

  @override
  State<_SessionDoctorNoteCard> createState() => _SessionDoctorNoteCardState();
}

class _SessionDoctorNoteCardState extends State<_SessionDoctorNoteCard> {
  late TextEditingController _noteController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: _generateDummyNote());
  }

  String _generateDummyNote() {
    return "Patient demonstrates moderate emotional fluctuation patterns. Continue mindfulness activities and regular monitoring.";
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DoctorColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DoctorColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: DoctorColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "SESSION ${widget.sessionIndex + 1}",
                  style: AppTextStyles.bodySmall(color: DoctorColors.primary).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "17 Jul 2025",
                style: AppTextStyles.bodySmall(color: DoctorColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: DoctorColors.primary, size: 20),
              const SizedBox(width: 8),
              Text("Doctor Notes", style: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: () => setState(() => _isEditing = !_isEditing),
                icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded, color: DoctorColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DoctorColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: DoctorColors.divider),
            ),
            child: _isEditing
                ? TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: const InputDecoration(border: InputBorder.none, hintText: "Write clinical notes..."),
                    style: AppTextStyles.bodyMedium(),
                  )
                : Text(_noteController.text, style: AppTextStyles.bodyMedium()),
          ),
        ],
      ),
    );
  }
}
