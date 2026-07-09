// lib/screens/patient/patient_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';

class PatientProfileScreen extends ConsumerWidget {

  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final auth = ref.watch(authProvider);

    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go(AppRoutes.patientDashboard),
        ),
        title: const Text("Profile"),
        centerTitle: true,
      ),

      body: ListView(

        padding: const EdgeInsets.all(20),

        children: [

          const CircleAvatar(
            radius: 50,
            child: Icon(
              Icons.person,
              size: 50,
            ),
          ),

          const SizedBox(height:20),

          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text("Name"),
            subtitle: Text(auth.userName ?? ""),
          ),

          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text("User ID"),
            subtitle: Text(auth.userId ?? ""),
          ),

          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Email"),
            subtitle: Text(auth.userEmail  ?? ""),
          ),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Role"),
            subtitle: Text(
              auth.role == UserRole.patient
                  ? "Patient"
                  : auth.role == UserRole.doctor
                  ? "Doctor"
                  : auth.role == UserRole.admin
                  ? "Admin"
                  : "Unknown",
            ),
          ),

          const SizedBox(height:20),

          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go(AppRoutes.roleSelection);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}