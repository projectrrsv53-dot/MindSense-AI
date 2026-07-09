import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/patient_model.dart';
import '../services/doctor_service.dart';
import '../services/api_service.dart';
import '../models/doctor_alert.dart';
import '../models/analysis_result.dart';
import 'auth_provider.dart';

final doctorPatientsProvider =
FutureProvider<List<PatientModel>>((ref) async {

  final auth = ref.watch(authProvider);

  final doctorId = auth.userId;

  if (doctorId == null) {
    return [];
  }

  return DoctorService.getMyPatients(
    doctorId,
  );
});

final patientDetailsProvider =
FutureProvider.family<Map<String, dynamic>, String>((ref, patientId) async {
  return DoctorService.getPatientDetails(patientId);
});

final sessionDetailsProvider =
FutureProvider.family<Map<String, dynamic>, String>((ref, sessionId) async {
  return DoctorService.getSessionDetails(sessionId);
});

final patientMoodProvider =
FutureProvider.family<List<dynamic>, String>((ref, patientId,) async {
  return DoctorService.getPatientMoods(patientId,);
});

// PERFORMANCE: Process patient sessions once and cache results
final processedPatientSessionsProvider = Provider.family<List<AnalysisResult>, String>((ref, patientId) {
  final details = ref.watch(patientDetailsProvider(patientId));
  return details.when(
    data: (data) {
      final List<dynamic> sessionsRaw = (data['sessions'] as List?) ?? [];
      return sessionsRaw.map((s) => AnalysisResult.fromBackend(s as Map<String, dynamic>)).toList();
    },
    loading: () => <AnalysisResult>[],
    error: (_, __) => <AnalysisResult>[],
  );
});

final doctorAlertsProvider = FutureProvider<List<DoctorAlert>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth.userId == null) return [];
  return ApiService().getDoctorAlerts(auth.userId!);
});

// PERFORMANCE: Pre-calculate risk distribution for dashboard (Patient-based)
final doctorRiskDistributionProvider = Provider<Map<String, int>>((ref) {
  final patientsAsync = ref.watch(doctorPatientsProvider);
  return patientsAsync.maybeWhen(
    data: (patients) {
      final highRisk = patients.where((p) {
        final risk = p.riskLevel.trim().toUpperCase();
        return risk == "HIGH" || risk == "CRITICAL";
      }).length;
      return {'high': highRisk, 'low': patients.length - highRisk};
    },
    orElse: () => {'high': 0, 'low': 0},
  );
});
