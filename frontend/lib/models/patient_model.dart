//    models/patient_model.dart

import 'analysis_result.dart';

class PatientModel {
  final String id;
  final String patientId;
  final String name;
  final int age;
  final String gender;
  final String email;
  final DateTime joinedDate;
  final List<AnalysisResult> sessions;
  final bool hasGrantedAccess;
  final String prediction;
  final double confidence;
  final int sessionCount;
  final String _lastSessionDisplay;
  final String riskLevel;

  const PatientModel({
    required this.id,
    required this.patientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
    required this.joinedDate,
    required this.sessions,
    this.hasGrantedAccess = false,
    this.prediction = 'Unknown',
    this.confidence = 0.0,
    required this.riskLevel,
    required this.sessionCount,
    required String lastSessionDisplay,
  }) : _lastSessionDisplay = lastSessionDisplay;


  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final String idValue = (json['patient_id'] ?? json['id'] ?? json['user_id'] ?? '').toString();

    
    DateTime joined;
    try {
      joined = DateTime.parse(json['connected_at'] ?? json['created_at'] ?? DateTime.now().toIso8601String());
    } catch (_) {
      joined = DateTime.now();
    }

    return PatientModel(
      id: idValue,
      patientId: idValue,
      name: (json['name'] ?? 'Unknown').toString(),
      age: (json['age'] as num? ?? 0).toInt(),
      gender: (json['gender'] ?? 'Not specified').toString(),
      email: (json['email'] ?? '').toString(),
      joinedDate: joined,
      sessions: (json['sessions'] as List? ?? [])
          .map((s) => AnalysisResult.fromJson(s as Map<String, dynamic>))
          .toList(),
      hasGrantedAccess: json['has_granted_access'] ?? true,
      prediction: (json['prediction'] ?? 'Unknown').toString(),
      confidence: (json['confidence'] as num? ?? 0.0).toDouble(),
      sessionCount: (json["session_count"] as num? ?? 0).toInt(),
      lastSessionDisplay: (json['last_session_display'] ?? 'No sessions').toString(),
      riskLevel: (json['risk_level'] ?? 'LOW').toString(),
    );
  }

  String get lastSessionDisplay => _lastSessionDisplay;

  String get latestSentiment {
    return prediction;
  }

  String get formattedLastSession {
    return _lastSessionDisplay.isEmpty
        ? 'No sessions'
        : _lastSessionDisplay;
  }
  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}
