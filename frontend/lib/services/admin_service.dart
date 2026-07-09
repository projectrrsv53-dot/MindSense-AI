// services/admin_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/doctor_verification_request.dart';
import '../models/patient_model.dart';

class AdminService {
  static Future<List<DoctorVerificationRequest>> getPendingDoctors() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.adminPendingDoctors));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['pending_doctors'] as List)
            .map((e) => DoctorVerificationRequest.fromJson(e))
            .toList();
      }
      throw Exception('Failed to load pending doctors');
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> updateDoctorStatus({
    required String doctorId,
    required String status,
  }) async {
    try {
      final endpoint = status == 'approved'
          ? '${ApiConfig.adminVerifyDoctor}/$doctorId'
          : '${ApiConfig.adminRejectDoctor}/$doctorId';

      final response = await http.patch(Uri.parse(endpoint));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<PatientModel>> getPatients() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.adminPatients));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['patients'] as List)
            .map((e) => PatientModel.fromJson(e))
            .toList();
      }
      throw Exception('Failed to load patients');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getSystemReports() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.adminReports));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to load reports');
    } catch (e) {
      rethrow;
    }

  }
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.adminDashboardStats),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception('Failed to load dashboard stats');
    } catch (e) {
      rethrow;
    }
  }
  static Future<Map<String, dynamic>>
  getVerificationStats() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.adminVerificationStats),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception(
        'Failed to load verification stats',
      );
    } catch (e) {
      rethrow;
    }
  }
}