//  core/config/api_config.dart

class ApiConfig {
  // Use 10.0.2.2:8000 for local development on laptop
  //static const String baseUrl = 'http://10.0.2.2:8000';
  //static const String baseUrl = 'http://127.0.0.1:8000';
  //static const String baseUrl = 'http://192.168.31.160:8000'; //my phone
  static const String baseUrl = 'http://192.168.1.10:8000';

  // Auth Endpoints
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String doctors = '$baseUrl/doctors';

  // Admin Endpoints
  static const String adminPendingDoctors = '$baseUrl/admin/pending-doctors';
  static const String adminVerifyDoctor = '$baseUrl/admin/verify-doctor';
  static const String adminRejectDoctor = '$baseUrl/admin/reject-doctor';
  static const String adminPatients = '$baseUrl/admin/patients';
  static const String adminReports = '$baseUrl/admin/reports';
  static const String adminDashboardStats = '$baseUrl/admin/dashboard-stats';
  static const String adminVerificationStats =
      '$baseUrl/admin/verification-stats';
  static const String adminRecentActivity = '$baseUrl/admin/recent-activity';
  static String adminPatientDetails(String patientId) => '$baseUrl/admin/patient/$patientId';
  static String adminDoctorDetails(String doctorId) => '$baseUrl/admin/doctor/$doctorId';
  static String adminSearch(String query) => '$baseUrl/admin/search?query=$query';
  // Analysis Endpoints

  // Analysis Endpoints
  static const String predictAudio = '$baseUrl/predict-audio';

  //pat
  static const String connectDoctor = "$baseUrl/patient/connect-doctor";
  static String myDoctors(String patientId) => "$baseUrl/patient/my-doctors/$patientId";
  static String availableDoctors(String patientId) => "$baseUrl/patient/available-doctors/$patientId";

  // Doctor
  static String doctorPatients(String doctorId) => "$baseUrl/doctor/patients/$doctorId";
  static String doctorSessionDetails(String sessionId) => '$baseUrl/doctor/session/$sessionId';
  static String doctorPatientDetails(String patientId) => '$baseUrl/doctor/patient/$patientId';
  static String doctorPatientMoods(String patientId) => '$baseUrl/doctor/patient/$patientId/moods';
  static String doctorReviewSession(String sessionId,) => '$baseUrl/doctor/session/$sessionId/review';
  static const String saveAvailability = '$baseUrl/doctor/availability';
  static String getAvailability(String doctorId,) => '$baseUrl/doctor/availability/$doctorId';
  static String availableSlots(String doctorId, String date,) => '$baseUrl/doctor/available-slots/$doctorId?date=$date';
  static String doctorAvailability(String doctorId,) => '$baseUrl/doctor/availability/$doctorId';
  static String patientHistory(String patientId) => '$baseUrl/patient/history/$patientId';
  static String patientAppointments(String patientId,) => "$baseUrl/patient/appointments/$patientId";
  // Alerts
  static String doctorAlerts(String doctorId,) => '$baseUrl/doctor/alerts/$doctorId';
  static String resolveAlert(String alertId,) => '$baseUrl/doctor/alerts/$alertId/resolve';
  static const String emergencyContact =
      '$baseUrl/patient/emergency-contact';
  static String emergencyContacts(String patientId) =>
      '$baseUrl/patient/emergency-contacts/$patientId';
  // Emergency escalation
  static String confirmCritical(String sessionId,) => '$baseUrl/doctor/session/$sessionId/confirm-critical';

}
