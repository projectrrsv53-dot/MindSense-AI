import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorAppointmentsScreen
    extends ConsumerStatefulWidget {

  const DoctorAppointmentsScreen({
    super.key,
  });

  @override
  ConsumerState<DoctorAppointmentsScreen>
  createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState
    extends ConsumerState<
        DoctorAppointmentsScreen> {

  List<dynamic> appointments = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadAppointments();
  }

  Future<void>
  loadAppointments() async {

    try {

      final doctorId =
      ref.read(
        authProvider,
      ).userId!;

      final data =
      await ApiService()
          .getDoctorAppointments(
          doctorId);

      setState(() {

        appointments =
            data;

        loading =
        false;

      });

    } catch (e) {

      setState(() {
        loading = false;
      });

      if (mounted) {

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
          ),
        );

      }
    }
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
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.doctorDashboard);
            }
          },
        ),

        title: const Text(
          "Appointments",
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

          ? const Center(
        child: Text(
          "No appointments booked yet.",
        ),
      )

          : ListView.builder(

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
          appointments[
          index];

          return Card(

            margin:
            const EdgeInsets.only(
              bottom: 16,
            ),

            elevation: 4,

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
                  16),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  Row(
                    children: [

                      const Icon(
                        Icons.person,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Expanded(
                        child: Text(
                          appointment[
                          "patient_name"] ??
                              "Unknown Patient",

                          style:
                          const TextStyle(
                            fontSize:
                            18,

                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    children: [

                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Text(
                        appointment[
                        "date"],
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Row(
                    children: [

                      const Icon(
                        Icons.access_time,
                        size: 18,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Text(
                        appointment[
                        "time"],
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Row(
                    children: [

                      const Icon(
                        Icons.notes,
                        size: 18,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Expanded(
                        child: Text(
                          appointment[
                          "reason"] ??
                              "Consultation",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Container(

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      Colors.green
                          .shade100,

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: const Text(
                      "Confirmed",
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}