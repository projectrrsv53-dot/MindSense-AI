// lib/screens/doctor/doctor_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../theme/app_colors.dart';

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: DoctorColors.background,

      appBar: AppBar(
        title: const Text("Doctor Profile"),
        centerTitle: true,
        backgroundColor: DoctorColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(AppRoutes.doctorDashboard),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// Profile Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    const CircleAvatar(
                      radius: 55,
                      backgroundColor: DoctorColors.primary,
                      child: Icon(
                        Icons.medical_services,
                        color: Colors.white,
                        size: 55,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      auth.userName ?? "Dr. Sarah Johnson",
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Clinical Psychologist",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [

                        Icon(Icons.star,
                            color: Colors.amber, size: 20),

                        SizedBox(width: 5),

                        Text(
                          "4.9 Rating",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// Professional Details
            _sectionTitle("Professional Details"),

            _infoCard([
              _tile(Icons.badge, "Doctor ID", auth.userId ?? "DOC1024"),
              _tile(Icons.email, "Email",
                  auth.userEmail ?? "doctor@example.com"),
              _tile(Icons.medical_services,
                  "Specialization", "Clinical Psychologist"),
              _tile(Icons.school,
                  "Qualification", "MBBS, MD Psychiatry"),
              _tile(Icons.work,
                  "Experience", "12 Years"),
              _tile(Icons.local_hospital,
                  "Hospital", "MindCare Hospital"),
              _tile(Icons.verified,
                  "License No.", "MED-458923"),
            ]),

            const SizedBox(height: 20),

            /// Statistics

            _sectionTitle("Statistics"),

            Row(
              children: [

                Expanded(
                  child: _statCard(
                    "Patients",
                    "152",
                    Icons.people,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    "Reviews",
                    "487",
                    Icons.description,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: _statCard(
                    "Appointments",
                    "64",
                    Icons.calendar_month,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    "High Risk",
                    "18",
                    Icons.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// Availability

            _sectionTitle("Availability"),

            _infoCard([
              _tile(Icons.schedule,
                  "Working Hours", "Monday - Friday"),
              _tile(Icons.access_time,
                  "Timing", "9:00 AM - 5:00 PM"),
            ]),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: DoctorColors.primary,
              ),
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
              ),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go(AppRoutes.roleSelection);
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
            ),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget _infoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }

  static Widget _tile(
      IconData icon,
      String title,
      String value,
      ) {
    return ListTile(
      leading: Icon(icon, color: DoctorColors.primary),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  static Widget _statCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
        ),
        child: Column(
          children: [

            Icon(
              icon,
              size: 30,
              color: DoctorColors.primary,
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(title),
          ],
        ),
      ),
    );
  }
}