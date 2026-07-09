import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../services/api_service.dart';

class PatientAppointmentsScreen extends ConsumerStatefulWidget {
  const PatientAppointmentsScreen({
    super.key,
  });

  @override
  ConsumerState<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState
    extends ConsumerState<PatientAppointmentsScreen> {

  List<dynamic> appointments = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {

    try {

      final patientId =
      ref.read(authProvider).userId!;

      final data =
      await ApiService()
          .getPatientAppointments(
        patientId,
      );

      if (!mounted) return;

      setState(() {

        appointments = data;

        loading = false;

      });

    } catch (e) {

      if (!mounted) return;

      setState(() {

        loading = false;

      });

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(

            e.toString(),

          ),

        ),

      );

    }

  }

  String formatTime12Hour(
      String time,
      ) {

    final parts = time.split(":");

    int hour = int.parse(
      parts[0],
    );

    final minute =
    parts[1];

    final period =
    hour >= 12
        ? "PM"
        : "AM";

    hour =
        hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return "$hour:$minute $period";

  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      appBar: AppBar(

        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back_ios,
          ),

          onPressed: () {

            if (
            context.canPop()
            ) {

              context.pop();

            } else {

              context.go(
                AppRoutes.patientDashboard,
              );

            }

          },

        ),

        title: const Text(
          "My Appointments",
        ),

        centerTitle: true,

      ),

      body:

      loading

          ? const Center(

        child:
        CircularProgressIndicator(),

      )

          : appointments.isEmpty

          ? RefreshIndicator(

        onRefresh:
        loadAppointments,

        child: ListView(

          children: const [

            SizedBox(
              height: 200,
            ),

            Icon(
              Icons.calendar_today,
              size: 80,
              color: Colors.grey,
            ),

            SizedBox(
              height: 20,
            ),

            Center(

              child: Text(

                "No appointments booked yet.",

                style: TextStyle(

                  fontSize: 18,

                  fontWeight:
                  FontWeight.w500,

                ),

              ),

            ),

          ],

        ),

      )

          : RefreshIndicator(

        onRefresh:
        loadAppointments,

        child: ListView.builder(

          padding:
          const EdgeInsets.all(
            16,
          ),

          itemCount:
          appointments.length,

          itemBuilder:
              (
              context,
              index,
              ) {

            final appointment =
            appointments[index];

            return Card(

              elevation: 4,

              margin:
              const EdgeInsets.only(
                bottom: 16,
              ),

              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(
                  16,
                ),

              ),

              child: Padding(

                padding:
                const EdgeInsets.all(
                  16,
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    Row(

                      children: [

                        CircleAvatar(

                          radius: 24,

                          child: Text(

                            appointment["doctor_name"]
                                .toString()
                                .substring(
                              0,
                              1,
                            ),

                          ),

                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(

                          child: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(

                                appointment["doctor_name"],

                                style:
                                const TextStyle(

                                  fontSize:
                                  18,

                                  fontWeight:
                                  FontWeight.bold,

                                ),

                              ),

                              Text(

                                appointment["specialization"] ??
                                    "",

                                style:
                                TextStyle(

                                  color:
                                  Colors.grey.shade700,

                                ),

                              ),

                            ],

                          ),

                        ),

                      ],

                    ),

                    const Divider(
                      height: 30,
                    ),

                    Row(

                      children: [

                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Text(

                          appointment["date"],

                          style:
                          const TextStyle(

                            fontSize: 16,

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(

                      children: [

                        const Icon(
                          Icons.access_time,
                          size: 18,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Text(

                          formatTime12Hour(
                            appointment["time"],
                          ),

                          style:
                          const TextStyle(

                            fontSize: 16,

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        const Icon(
                          Icons.notes,
                          size: 18,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(

                          child: Text(

                            appointment["reason"] ??
                                "Consultation",

                            style:
                            const TextStyle(

                              fontSize: 16,

                            ),

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Align(

                      alignment:
                      Alignment.centerRight,

                      child: Container(

                        padding:
                        const EdgeInsets.symmetric(

                          horizontal: 14,

                          vertical: 8,

                        ),

                        decoration:
                        BoxDecoration(

                          color:
                          Colors.green.shade100,

                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),

                        ),

                        child: Text(

                          appointment["status"] ??
                              "Confirmed",

                          style:
                          const TextStyle(

                            fontWeight:
                            FontWeight.bold,

                            color:
                            Colors.green,

                          ),

                        ),

                      ),

                    ),

                  ],

                ),

              ),

            );

          },

        ),

      ),

    );

  }

}