// lib/screens/doctor/patient_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../router/app_router.dart';
import '../../widgets/doctor/patient_list_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/patient_model.dart';
import '../../providers/doctor_provider.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  const PatientListScreen({super.key, this.initialFilter});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _filterRisk = 'All';

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      _filterRisk = widget.initialFilter!;
    }
  }

  final Map<String, String> _riskFilters = {
    'All': 'All Patients',
    'highRisk': 'High Risk Only',
    'MODERATE': 'Moderate',
    'LOW': 'Low Risk',
  };

  List<PatientModel> filterPatients(List<PatientModel> patients) {
    return patients.where((p) {
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final risk = p.riskLevel.trim().toUpperCase();
      final matchRisk = _filterRisk == "All" ||
          (_filterRisk == "highRisk" && (risk == "HIGH" || risk == "CRITICAL")) ||
          (_filterRisk == "MODERATE" && risk == "MODERATE") ||
          (_filterRisk == "LOW" && risk == "LOW");

      return matchSearch && matchRisk;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(doctorPatientsProvider);
    
    return Scaffold(
      backgroundColor: DoctorColors.background,
      appBar: AppBar(
        backgroundColor: DoctorColors.background,
        title: Text('Patients', style: AppTextStyles.headingMedium()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go(AppRoutes.doctorDashboard),
        ),
        actions: [
          patientsAsync.whenData((patients) {
            final count = filterPatients(patients).length;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: DoctorColors.primarySurface, borderRadius: BorderRadius.circular(10)),
                  child: Text('$count patients', style: AppTextStyles.labelSmall(color: DoctorColors.primary)),
                ),
              ),
            );
          }).maybeWhen(orElse: () => const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    filled: true,
                    fillColor: DoctorColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: DoctorColors.divider)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: DoctorColors.divider)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _riskFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final key = _riskFilters.keys.elementAt(i);
                      final label = _riskFilters[key]!;
                      final isSelected = _filterRisk == key;
                      final filterColor = key == 'highRisk' ? DoctorColors.highRisk : (key == 'All' ? DoctorColors.primary : AppColors.getRiskColor(key));

                      return GestureDetector(
                        onTap: () => setState(() => _filterRisk = isSelected ? 'All' : key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? filterColor : DoctorColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? filterColor : DoctorColors.divider),
                          ),
                          child: Text(
                            label,
                            style: AppTextStyles.labelSmall(color: isSelected ? AppColors.white : DoctorColors.textSecondary),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_filterRisk == 'highRisk')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('Showing HIGH and CRITICAL risk patients only', style: AppTextStyles.bodySmall(color: DoctorColors.highRisk).copyWith(fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: patientsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (patients) {
                final filtered = filterPatients(patients);
                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => PatientListCard(
                    patient: filtered[i],
                    onTap: () => context.push(AppRoutes.doctorPatientDetails.replaceFirst(':patientId', filtered[i].patientId)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('No patients found', style: AppTextStyles.headingSmall()),
          Text('Try a different search or clear filters.', style: AppTextStyles.bodySmall()),
          const SizedBox(height: 16),
          if (_filterRisk != 'All' || _searchQuery.isNotEmpty)
            TextButton(
              onPressed: () => setState(() { _filterRisk = 'All'; _searchCtrl.clear(); _searchQuery = ''; }),
              child: const Text('Clear All Filters'),
            ),
        ],
      ),
    );
  }
}
