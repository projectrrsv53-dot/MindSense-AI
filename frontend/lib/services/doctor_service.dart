// //  services/doctor_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/patient_model.dart';

class DoctorService {
  static Future<List<PatientModel>> getMyPatients(
      String doctorId) async {

    final response = await http.get(
      Uri.parse(
        ApiConfig.doctorPatients(doctorId),
      ),
    )
        .timeout(
      const Duration(
        seconds: 15,
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['patients'] as List)
          .map(
            (e) => PatientModel.fromJson(e),
      )
          .toList();
    }

    throw Exception(
      'Failed to load doctor patients',
    );
  }
  static Future<Map<String, dynamic>> getPatientDetails(
      String patientId) async {

    final response = await http.get(
      Uri.parse(
        ApiConfig.doctorPatientDetails(
          patientId,
        ),
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load patient details',
    );
  }
  static Future<Map<String, dynamic>> getSessionDetails(
      String sessionId) async {

    final response = await http.get(
      Uri.parse(
        ApiConfig.doctorSessionDetails(
          sessionId,
        ),
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load session details',
    );
  }
  static Future<List<dynamic>> getPatientMoods(
      String patientId,
      ) async {

    // final response = await http.get(
    //   Uri.parse(
    //     '${ApiConfig.baseUrl}/doctor/patient/$patientId/moods',
    //   ),
    // );
    final response = await http.get(
      Uri.parse(
        ApiConfig.doctorPatientMoods(
          patientId,
        ),
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['moods'];
    }

    throw Exception(
      'Failed to load patient moods',
    );
  }
  static Future<void> reviewSession(
      String sessionId,
      String doctorId,
      String doctorName,
      String feedback,
      bool requiresEmergencyContact,
      ) async {

    final response = await http.put(
      Uri.parse(
        ApiConfig.doctorReviewSession(
          sessionId,
        ),
      ),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "doctor_id": doctorId,
        "doctor_name": doctorName,
        "feedback": feedback,
        "requires_emergency_contact":
        requiresEmergencyContact,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);

      throw Exception(
        error["detail"] ??
        "Failed to review session",
      );
    }
  }
  static Future<void> confirmCritical(
      String sessionId,
      ) async {

    final response = await http.post(

      Uri.parse(
        ApiConfig.confirmCritical(
          sessionId,
        ),
      ),

    );

    // if (response.statusCode != 200) {
    //
    //   throw Exception(
    //     "Failed to notify emergency contacts",
    //   );


    // }
    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);

      throw Exception(
        error["detail"] ?? "Failed to notify emergency contacts",
      );
    }
  }

  static Future<void> resolveAlert(String alertId) async {
    final response = await http.put(
      Uri.parse(ApiConfig.resolveAlert(alertId)),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error["detail"] ?? "Failed to resolve alert");
    }
  }
}
