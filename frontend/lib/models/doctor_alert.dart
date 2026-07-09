// class DoctorAlert {
//   final String patientId;
//   final String sessionId;
//   final String riskLevel;
//   final String message;
//   final bool isResolved;
//   final DateTime createdAt;
//
//   DoctorAlert({
//     required this.patientId,
//     required this.sessionId,
//     required this.riskLevel,
//     required this.message,
//     required this.isResolved,
//     required this.createdAt,
//   });
//
//   factory DoctorAlert.fromJson(
//       Map<String, dynamic> json,
//       ) {
//     return DoctorAlert(
//       patientId: json["patient_id"],
//       sessionId: json["session_id"],
//       riskLevel: json["risk_level"],
//       message: json["message"],
//       isResolved: json["is_resolved"],
//       createdAt: DateTime.parse(
//         json["created_at"],
//       ),
//     );
//   }
// }
class DoctorAlert {

  final String id;

  final String patientId;

  final String patientName;

  final String sessionId;

  final String analysisType;

  final String riskLevel;

  final String message;

  final bool doctorReviewed;

  final bool isResolved;

  final DateTime createdAt;

  DoctorAlert({

    required this.id,

    required this.patientId,

    required this.patientName,

    required this.sessionId,

    required this.analysisType,

    required this.riskLevel,

    required this.message,

    required this.doctorReviewed,

    required this.isResolved,

    required this.createdAt,

  });

  factory DoctorAlert.fromJson(
      Map<String, dynamic> json,
      ) {

    return DoctorAlert(

      id:
      json["id"] ?? "",

      patientId:
      json["patient_id"] ?? "",

      patientName:
      json["patient_name"] ??
          "Unknown Patient",

      sessionId:
      json["session_id"] ?? "",

      analysisType:
      json["analysis_type"] ?? "",

      riskLevel:
      json["risk_level"] ?? "",

      message:
      json["message"] ?? "",

      doctorReviewed:
      json["doctor_reviewed"] ?? false,

      isResolved:
      json["is_resolved"] ?? false,

      createdAt:
      DateTime.parse(
        json["created_at"],
      ),
    );
  }
}