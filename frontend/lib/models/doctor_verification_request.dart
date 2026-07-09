//         models/doctor_verification_request.dart

class DoctorVerificationRequest {
  final String id;
  final String name;
  final String email;
  final String specialization;
  final String licenseId;
  final String? hospitalName;
  final String status;
  final DateTime appliedDate;

  const DoctorVerificationRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.specialization,
    required this.licenseId,
    this.hospitalName,
    required this.status,
    required this.appliedDate,
  });

  factory DoctorVerificationRequest.fromJson(
      Map<String, dynamic> json,
      ) {
    DateTime parsedDate;

    try {
      parsedDate = DateTime.parse(
        json['created_at']?.toString() ??
            DateTime.now().toIso8601String(),
      );
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return DoctorVerificationRequest(
      // Try Mongo _id first, then user_id
      id: json['_id']?.toString() ??
          json['user_id']?.toString() ??
          json['id']?.toString() ??
          '',

      name: json['name']?.toString() ?? 'Unknown',

      email: json['email']?.toString() ?? '',

      specialization:
      json['specialization']?.toString() ?? 'N/A',

      licenseId:
      json['license_id']?.toString() ?? 'N/A',

      hospitalName:
      json['hospital_name']?.toString(),

      status:
      json['verification_status']?.toString() ??
          'pending',

      appliedDate: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'specialization': specialization,
      'license_id': licenseId,
      'hospital_name': hospitalName,
      'verification_status': status,
      'created_at': appliedDate.toIso8601String(),
    };
  }
}