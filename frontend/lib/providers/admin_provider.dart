// lib/providers/admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor_verification_request.dart';
import '../models/patient_model.dart';
import '../services/admin_service.dart';
import '../services/api_service.dart';

import '../models/recent_activity.dart';

// --- Verification Requests ---
final pendingDoctorsProvider = StateNotifierProvider<PendingDoctorsNotifier, AsyncValue<List<DoctorVerificationRequest>>>((ref) {
  return PendingDoctorsNotifier();
});

class PendingDoctorsNotifier extends StateNotifier<AsyncValue<List<DoctorVerificationRequest>>> {
  PendingDoctorsNotifier() : super(const AsyncValue.loading()) {
    loadPendingDoctors();
  }

  Future<void> loadPendingDoctors() async {
    state = const AsyncValue.loading();
    try {
      final doctors = await AdminService.getPendingDoctors();
      state = AsyncValue.data(doctors);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    final success = await AdminService.updateDoctorStatus(doctorId: id, status: status);
    if (success) {
      await loadPendingDoctors();
    }
    return success;
  }
}

// --- Patient Management ---
final adminPatientsProvider = FutureProvider<List<PatientModel>>((ref) async {
  return await AdminService.getPatients();
});

// --- Reports & Analytics ---
final adminReportsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    return await AdminService.getSystemReports();
  } catch (e) {
    return {};
  }
});

final reportsAnalyticsProvider = adminReportsProvider;


// --- Recent Activity ---
final recentActivityProvider = FutureProvider<List<RecentActivity>>((ref) async {
  try {
    final rawData = await ApiService().getRecentActivity();
    return rawData.map((e) => RecentActivity.fromJson(e as Map<String, dynamic>)).toList();
  } catch (e) {
    return [];
  }
});


final adminDashboardStatsProvider =
FutureProvider<Map<String, dynamic>>((ref) async {
  return await AdminService.getDashboardStats();
});
final verificationStatsProvider =
FutureProvider<Map<String, dynamic>>((ref) async {
  return await AdminService.getVerificationStats();
});