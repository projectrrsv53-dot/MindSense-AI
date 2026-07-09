//  services/api_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/analysis_result.dart';
import '../models/analysis_history_model.dart';
import '../models/doctor_alert.dart';

class FusionPrediction {
  final bool isDepressed;
  final double confidence;
  final double probDepressed;
  final double probNonDepressed;

  FusionPrediction({
    required this.isDepressed,
    required this.confidence,
    required this.probDepressed,
    required this.probNonDepressed,
  });

  factory FusionPrediction.fromJson(Map<String, dynamic> json) {
    final probs = json['probabilities'] as Map<String, dynamic>?;
    final String prediction = (json['prediction'] ?? '').toString().trim().toLowerCase();

    return FusionPrediction(
      isDepressed: prediction == 'depressed',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      probDepressed: (probs?['depressed'] as num?)?.toDouble() ?? 0.0,
      probNonDepressed: (probs?['non_depressed'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FusionApiResponse {
  final String transcript;
  final String cleanedText;
  final FusionPrediction fusionPrediction;
  final String sentimentLabel;
  final double sentimentConfidence;
  final String recommendation;

  FusionApiResponse({
    required this.transcript,
    required this.cleanedText,
    required this.fusionPrediction,
    required this.sentimentLabel,
    required this.sentimentConfidence,
    required this.recommendation,
  });

  factory FusionApiResponse.fromJson(Map<String, dynamic> json) {
    if (json['error'] != null) {
      throw Exception(json['error'].toString());
    }

    if (json['fusion_prediction'] == null) {
      throw Exception('fusion_prediction missing from API response');
    }

    if (json['sentiment'] == null) {
      throw Exception('sentiment missing from API response');
    }

    final sentiment = json['sentiment'] as Map<String, dynamic>;

    return FusionApiResponse(
      transcript: json['transcript']?.toString() ?? '',
      cleanedText: json['cleaned_text']?.toString() ?? '',
      fusionPrediction: FusionPrediction.fromJson(json['fusion_prediction'] as Map<String, dynamic>),
      sentimentLabel: sentiment['label']?.toString() ?? '',
      sentimentConfidence: (sentiment['confidence'] as num?)?.toDouble() ?? 0.0,
      recommendation:
      json["recommendation"] ?? "",
    );
  }
}

class ApiService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://192.168.1.10:8000';//phone
  ApiService() {

    _dio.options = BaseOptions(

      connectTimeout: const Duration(
        seconds: 15,
      ),

      receiveTimeout: const Duration(
        seconds: 30,
      ),

      sendTimeout: const Duration(
        seconds: 30,
      ),

    );

  }

  Future<FusionApiResponse> predictFusionFile(String patientId,String filePath,) async {
    try {

      final formData = FormData.fromMap({
        'patient_id': patientId,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        '$_baseUrl/predict-fusion',
        data: formData,
      );

      // print('API RESPONSE:');
      // print(response.data);

      return FusionApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<FusionApiResponse> predictFusionBytes(Uint8List bytes, String patientId,String filename,) async {
    try {
      final formData = FormData.fromMap({
        'patient_id': patientId,
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _dio.post(
        '$_baseUrl/predict-fusion',
        data: formData,
      );

      // print('API RESPONSE:');
      // print(response.data);

      return FusionApiResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchTrendData() async {
    try {
      final response = await _dio.get('$_baseUrl/sessions/trend');
      // print('TREND RESPONSE:');
      // print(response.data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> predictText(String patientId,String text) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/predict-text',
        data: {"patient_id": patientId,"text": text},
      );
      // print('\nTEXT API RESPONSE:');
      // print(response.data);
      return (response.data as Map<String, dynamic>?) ?? {};
    } catch (e) {
      rethrow;
    }
  }

Future<Map<String, dynamic>> predictDirectText(String patientId,
  String text,
) async {
  try {
    final response = await _dio.post(
      '$_baseUrl/predict-text-direct',
      data: {
        "patient_id": patientId,
        "text": text,
      },
    );

    // print("DIRECT TEXT RESPONSE:");
    // print(response.data);

    return (response.data as Map<String, dynamic>?) ?? {};
  } catch (e) {
    rethrow;
  }
}




  Future<List<AnalysisHistoryModel>> fetchPatientHistory(String patientId) async {
    try {
      // print("Calling API:");
      // print('$_baseUrl/patient/history/$patientId');
      final response = await _dio.get(
        '$_baseUrl/patient/history/$patientId',
      );

      // print(response.data);
      return (response.data["sessions"] as List)
          .map(
            (e) => AnalysisHistoryModel.fromJson(e),
      )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  
  Future<List<AnalysisResult>> getPatientSessions(
      String patientId,
      ) async {

    final response = await http.get(
      Uri.parse(
        ApiConfig.patientHistory(patientId),
      ),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return (data["sessions"] as List)

          .map(
            (e) =>
            AnalysisResult.fromBackend(e),
      )

          .toList();
    }

    throw Exception(
        "Unable to fetch sessions");
  }
  Future<List<DoctorAlert>> getDoctorAlerts(
      String doctorId,
      ) async {

    try {

      final response = await _dio.get(
        ApiConfig.doctorAlerts(
          doctorId,
        ),
      );

      return (response.data["alerts"] as List)

          .map(
            (e) => DoctorAlert.fromJson(e),
      )

          .toList();

    } catch (e) {
      rethrow;
    }
  }
  Future<void> resolveAlert(
      String alertId,
      ) async {

    try {

      await _dio.put(
        ApiConfig.resolveAlert(
          alertId,
        ),
      );

    } catch (e) {
      rethrow;
    }
  }
  Future<void> confirmCritical(
      String sessionId,
      ) async {

    try {

      await _dio.post(
        ApiConfig.confirmCritical(
          sessionId,
        ),
      );

    } catch (e) {
      rethrow;
    }
  }
  Future<void> saveDoctorAvailability({

    required String doctorId,

    required List<String> workingDays,

    required String startTime,

    required String endTime,

    required int slotDuration,

    String? breakStart,

    String? breakEnd,

  }) async {

    await _dio.post(

      ApiConfig.saveAvailability,

      data: {

        "doctor_id": doctorId,

        "working_days": workingDays,

        "start_time": startTime,

        "end_time": endTime,

        "slot_duration": slotDuration,

        "break_start": breakStart,

        "break_end": breakEnd,

      },

    );

  }
  Future<Map<String,dynamic>>
  getDoctorAvailability(
      String doctorId,
      ) async {

    final response = await _dio.get(

      ApiConfig.doctorAvailability(
        doctorId,
      ),

    );

    return response.data;

  }
  Future<List<Map<String, dynamic>>>
  getMyDoctors(
      String patientId,
      ) async {

    final response = await _dio.get(

      ApiConfig.myDoctors(
        patientId,
      ),

    );

    return List<Map<String, dynamic>>.from(

      response.data["doctors"],

    );
  }
  Future<List<String>>
  getAvailableSlots(

      String doctorId,

      String date,

      ) async {

    final response = await _dio.get(

      ApiConfig.availableSlots(
        doctorId,
        date,
      ),

    );

    return List<String>.from(
      response.data["slots"],
    );

  }
  Future<List<dynamic>>
  getDoctorAppointments(
      String doctorId,
      ) async {

    final response = await _dio.get(

      "${ApiConfig.baseUrl}/doctor/appointments/$doctorId",

    );

    return response.data[
    "appointments"
    ];

  }
  // Future<List<dynamic>>
  // getPatientAppointments(
  //     String patientId,
  //     ) async {
  //
  //   final response = await _dio.get(
  //
  //     "${ApiConfig.baseUrl}/patient/appointments/$patientId",
  //
  //   );
  //
  //   return response.data[
  //   "appointments"
  //   ];
  //
  // }
  Future<List<Map<String, dynamic>>>
  getAvailableDoctors(
      String patientId,
      ) async {

    final response = await _dio.get(
      ApiConfig.availableDoctors(
        patientId,
      ),
    );

    return List<Map<String, dynamic>>.from(
      response.data["doctors"],
    );
  }
  Future<Map<String, dynamic>> getAdminReports() async {

    final response = await _dio.get(
      ApiConfig.adminReports,
    );

    return Map<String, dynamic>.from(response.data);
  }
  Future<List<dynamic>> getRecentActivity() async {

    final response = await _dio.get(
      ApiConfig.adminRecentActivity,
    );

    return List<dynamic>.from(
      response.data["activity"],
    );
  }
  Future<Map<String, dynamic>> searchAdmin(
      String query,
      ) async {

    final response = await _dio.get(
      ApiConfig.adminSearch(query),
    );

    return Map<String, dynamic>.from(response.data);
  }
  Future<Map<String, dynamic>> getAdminPatientDetails(
      String patientId,
      ) async {

    final response = await _dio.get(
      ApiConfig.adminPatientDetails(patientId),
    );

    return Map<String, dynamic>.from(response.data);
  }
  Future<Map<String, dynamic>> getAdminDoctorDetails(
      String doctorId,
      ) async {

    final response = await _dio.get(
      ApiConfig.adminDoctorDetails(doctorId),
    );

    return Map<String, dynamic>.from(response.data);
  }
  
  Future<List<Map<String, dynamic>>> getPatientAppointments(
      String patientId,
      ) async {

    final response = await _dio.get(
      ApiConfig.patientAppointments(
        patientId,
      ),
    );

    return List<Map<String, dynamic>>.from(
      response.data["appointments"],
    );
  }

  Future<void> bookAppointment({

    required String patientId,

    required String doctorId,

    required String date,

    required String time,

    required String reason,

  }) async {

    await _dio.post(

      "$_baseUrl/appointment/book",

      data:{

        "patient_id":patientId,

        "doctor_id":doctorId,

        "date":date,

        "time":time,

        "reason":reason,

      },

    );

  }
}



final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Keeping top-level functions for backward compatibility if needed, 
// but redirecting them to the class instance
final _api = ApiService();
Future<FusionApiResponse> predictFusionFile(String patientId,String filePath,) => _api.predictFusionFile(patientId,filePath);
Future<FusionApiResponse> predictFusionBytes(Uint8List bytes, String patientId,String filename) => _api.predictFusionBytes(bytes,patientId, filename);
Future<List<dynamic>> fetchTrendData() => _api.fetchTrendData();
Future<Map<String, dynamic>> predictText(String patientId,String text) => _api.predictText(patientId,text);
Future<List<AnalysisHistoryModel>> fetchPatientHistory(String patientId) => _api.fetchPatientHistory(patientId);
Future<Map<String, dynamic>> predictDirectText(String patientId,String text) =>
    _api.predictDirectText(patientId,text);
Future<List<DoctorAlert>> getDoctorAlerts(String doctorId,) => _api.getDoctorAlerts(doctorId,);
Future<void> resolveAlert(String alertId,) => _api.resolveAlert(alertId,);
Future<void> confirmCritical(String sessionId,) => _api.confirmCritical(sessionId,);
Future<void> saveDoctorAvailability({

  required String doctorId,

  required List<String> workingDays,

  required String startTime,

  required String endTime,

  required int slotDuration,

  String? breakStart,

  String? breakEnd,

}) => _api.saveDoctorAvailability(

  doctorId: doctorId,

  workingDays: workingDays,

  startTime: startTime,

  endTime: endTime,

  slotDuration: slotDuration,

  breakStart: breakStart,

  breakEnd: breakEnd,

);

Future<Map<String,dynamic>>
getDoctorAvailability(
    String doctorId,
    ) =>
    _api.getDoctorAvailability(
      doctorId,
    );

Future<List<String>>
getAvailableSlots(
    String doctorId,
    String date,
    ) =>
    _api.getAvailableSlots(
      doctorId,
      date,
    );

Future<List<dynamic>>
getDoctorAppointments(
    String doctorId,
    ) =>
    _api.getDoctorAppointments(
      doctorId,
    );

Future<List<Map<String,dynamic>>>
getPatientAppointments(
    String patientId,
    ) =>
    _api.getPatientAppointments(
      patientId,
    );
Future<List<Map<String,dynamic>>>
getAvailableDoctors(
    String patientId,
    ) =>
    _api.getAvailableDoctors(
      patientId,
    );
Future<List<Map<String,dynamic>>>
getMyDoctors(
    String patientId,
    ) =>
    _api.getMyDoctors(
      patientId,
    );
Future<Map<String, dynamic>>
getAdminReports() =>
    _api.getAdminReports();

Future<List<dynamic>>
getRecentActivity() =>
    _api.getRecentActivity();

Future<Map<String, dynamic>>
searchAdmin(
    String query,
    ) =>
    _api.searchAdmin(query);

Future<Map<String, dynamic>>
getAdminPatientDetails(
    String patientId,
    ) =>
    _api.getAdminPatientDetails(
      patientId,
    );

Future<Map<String, dynamic>>
getAdminDoctorDetails(
    String doctorId,
    ) =>
    _api.getAdminDoctorDetails(
      doctorId,
    );
final adminReportsProvider =
FutureProvider((ref) async {
  return ApiService().getAdminReports();
});

final recentActivityProvider =
FutureProvider((ref) async {
  return ApiService().getRecentActivity();
});
