// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/patient/book_appointment_screen.dart';
import '../screens/patient/live_record_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/patient/patient_signup_screen.dart';
import '../screens/patient/patient_login_screen.dart';
import '../screens/patient/consent_screen.dart';
import '../screens/patient/onboarding_screen.dart';
import '../screens/patient/patient_dashboard_screen.dart';
import '../screens/patient/upload_screen.dart';
import '../screens/patient/ai_processing_screen.dart';
import '../screens/patient/results_screen.dart';
import '../screens/patient/doctor_connect_screen.dart';
import '../screens/doctor/doctor_signup_screen.dart';
import '../screens/doctor/verification_pending_screen.dart';
import '../screens/doctor/doctor_login_screen.dart';
import '../screens/doctor/doctor_dashboard_screen.dart';
import '../screens/doctor/patient_list_screen.dart';
import '../screens/doctor/patient_analytics_screen.dart';
import '../screens/doctor/doctor_patient_details_screen.dart';
import '../screens/doctor/doctor_session_details_screen.dart';
import 'package:mindful/screens/admin/admin_login_screen.dart';
import 'package:mindful/screens/admin/admin_dashboard_screen.dart';
import 'package:mindful/screens/admin/sub_screens/patients_screen.dart';
import 'package:mindful/screens/admin/sub_screens/reports_screen.dart';
import 'package:mindful/screens/admin/sub_screens/settings_screen.dart';
import 'package:mindful/screens/admin/sub_screens/verification_requests_screen.dart';
import '../screens/patient/patient_history_screen.dart';
import '../screens/patient/patient_profile_screen.dart';
import '../screens/patient/live_record_screen.dart';
import '../screens/patient/analysis_disclaimer_screen.dart';
import '../screens/patient/analysis_success_screen.dart';
import '../screens/patient/patient_session_details_screen.dart';
import '../screens/doctor/doctor_availability_screen.dart';
import '../screens/doctor/doctor_appointments_screen.dart';
import '../screens/patient/patient_appointments_screen.dart';

// ── Route name constants ─────────────────
class AppRoutes {
  static const splash = '/';
  static const roleSelection = '/role-selection';

  // Patient
  static const patientSignup = '/patient/signup';
  static const patientLogin = '/patient/login';
  static const patientConsent = '/patient/consent';
  static const patientOnboarding = '/patient/onboarding';
  static const patientDashboard = '/patient/dashboard';
  static const patientUpload = '/patient/upload';
  static const aiProcessing = '/patient/processing';
  static const results = '/patient/results';
  static const doctorConnect = '/patient/doctor-connect';
  static const analysisDisclaimer = '/patient/analysis-disclaimer';
  static const analysisSuccess = '/patient/analysis-success';
  static const patientHistory = "/patient/history";
  static const patientSessionDetails = '/patient/session/:sessionId';
  static const patientProfile = "/patient/profile";
  static const patientAppointments = "/patient-appointments";
  // Doctor
  static const doctorSignup = '/doctor/signup';
  static const verificationPending = '/doctor/verification-pending';
  static const doctorLogin = '/doctor/login';
  static const doctorDashboard = '/doctor/dashboard';
  static const doctorAvailability = '/doctor/availability';
  static const doctorAppointments = '/doctor/appointments';
  static const patientList = '/doctor/patients';
  static const patientAnalytics = '/doctor/patients/:patientId/analytics';
  static const doctorPatientDetails = '/doctor/patient/:patientId';
  static const doctorSessionDetails = '/doctor/session/:sessionId';
  // Admin
  static const adminLogin = '/admin/login';
  static const adminDashboard = '/admin/dashboard';
  static const adminPatients = '/admin/manage-patients';
  static const adminReports = '/admin/reports';
  static const adminSettings = '/admin/settings';
  static const adminVerifications = '/admin/verify-doctors';
  static const adminDoctorDetails = "/admin/doctor/:doctorId";
  static const adminPatientDetails = "/admin/patient/:patientId";
  static const appointment="/appointment";
  static const liveRecord = "/live-record";

}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // ── Common ────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        name: 'roleSelection',
        builder: (_, __) => const RoleSelectionScreen(),
      ),

      // ── Patient Flow ─────────────────────
      GoRoute(
        path: AppRoutes.patientSignup,
        name: 'patientSignup',
        builder: (_, __) => const PatientSignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientLogin,
        name: 'patientLogin',
        builder: (_, __) => const PatientLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientConsent,
        name: 'patientConsent',
        builder: (_, __) => const ConsentScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientOnboarding,
        name: 'patientOnboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientDashboard,
        name: 'patientDashboard',
        builder: (_, __) => const PatientDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientAppointments,
        builder: (context, state) =>
        const PatientAppointmentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientUpload,

        name: 'patientUpload',

        builder: (context, state) {

          final type =
          state.uri.queryParameters['type'];

          return UploadScreen(

            type:
            type == 'text'
                ? AnalysisType.text
                : AnalysisType.fusion,
          );
        },
      ),
      GoRoute(
  path: AppRoutes.aiProcessing,
  name: 'aiProcessing',
  builder: (context, state) {
    final mode = state.uri.queryParameters['mode'] ?? 'fusion';

    return AiProcessingScreen(
      mode: mode,
    );
  },
),
      GoRoute(
        path: AppRoutes.results,
        name: 'results',
        builder: (_, __) => const ResultsScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctorConnect,
        name: 'doctorConnect',
        builder: (context, state) {
          final isUpload = state.uri.queryParameters['isUpload'] == 'true';
          return DoctorConnectScreen(isUploadFlow: isUpload);
        },
      ),
      GoRoute(
        path: AppRoutes.analysisDisclaimer,
        name: 'analysisDisclaimer',
        builder: (_, __) =>
        const AnalysisDisclaimerScreen(),
      ),
      GoRoute(
        path: AppRoutes.analysisSuccess,
        builder: (context, state) =>
        const AnalysisSuccessScreen(),
      ),


      // ── Doctor Flow ───────────────────────
      GoRoute(
        path: AppRoutes.doctorSignup,
        name: 'doctorSignup',
        builder: (_, __) => const DoctorSignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.verificationPending,
        name: 'verificationPending',
        builder: (_, __) => const VerificationPendingScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctorLogin,
        name: 'doctorLogin',
        builder: (_, __) => const DoctorLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctorDashboard,
        name: 'doctorDashboard',
        builder: (_, __) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctorAvailability,
        name: 'doctorAvailability',
        builder: (_, __) =>
        const DoctorAvailabilityScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctorAppointments,
        builder: (_, __) =>
        const DoctorAppointmentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientList,
        name: 'patientList',
        // builder: (_, __) => const PatientListScreen(),
        builder: (context, state) {

          final extra = state.extra as Map<String, dynamic>?;

          return PatientListScreen(
            initialFilter: extra?["filter"],
          );
        },
      ),
      // GoRoute(
      //   path: AppRoutes.patientAnalytics,
      //   name: 'patientAnalytics',
      //   builder: (context, state) {
      //     final patientId = state.pathParameters['patientId'] ?? '';
      //     return PatientAnalyticsScreen(patientId: patientId);
      //   },
      // ),
      GoRoute(
        path: AppRoutes.doctorPatientDetails,
        name: 'doctorPatientDetails',
        builder: (context, state) {

          final patientId =
          state.pathParameters['patientId']!;

          return DoctorPatientDetailsScreen(
            patientId: patientId,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.doctorSessionDetails,
        name: 'doctorSessionDetails',
        builder: (context, state) {

          final sessionId =
          state.pathParameters['sessionId']!;

          return DoctorSessionDetailsScreen(
            sessionId: sessionId,
          );
        },
      ),


      // ── Admin Flow ────────────────────────
      GoRoute(
        path: AppRoutes.adminLogin,
        name: 'adminLogin',
        builder: (_, __) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'adminDashboard',
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPatients,
        name: 'adminPatients',
        builder: (_, __) => const AdminPatientsScreen(),
      ),

      GoRoute(
        path: AppRoutes.adminReports,
        name: 'adminReports',
        builder: (_, __) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSettings,
        name: 'adminSettings',
        builder: (_, __) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminVerifications,
        name: 'adminVerifications',
        builder: (_, __) => const VerificationRequestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientHistory,
        builder: (context, state) =>
        const PatientHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.patientSessionDetails,
        builder: (context, state) {

          final sessionId =
          state.pathParameters['sessionId']!;

          return PatientSessionDetailsScreen(
            sessionId: sessionId,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.patientProfile,
        builder: (context, state) =>
        const PatientProfileScreen(),
      ),
      GoRoute(

        path: AppRoutes.liveRecord,

        builder: (context, state) => const LiveRecordScreen(),

      ),
      GoRoute(
  path: AppRoutes.appointment,
  name: '/bookAppointment',
  builder: (context, state) =>
      const BookAppointmentScreen(),
),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
});