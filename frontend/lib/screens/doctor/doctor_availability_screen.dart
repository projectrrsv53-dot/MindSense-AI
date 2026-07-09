import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../router/app_router.dart';
import 'package:go_router/go_router.dart';


class DoctorAvailabilityScreen
    extends ConsumerStatefulWidget {

  const DoctorAvailabilityScreen({
    super.key,
  });

  @override
  ConsumerState<DoctorAvailabilityScreen>
  createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState
    extends ConsumerState<
        DoctorAvailabilityScreen> {
  List<String> selectedDays = [];

  String? startTime;
  String? endTime;
  String? breakStart;
  String? breakEnd;
  String? displayStartTime;
  String? displayEndTime;
  String? displayBreakStart;
  String? displayBreakEnd;

  int slotDuration = 30;
  bool isSaving = false;

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => loadAvailability());
  }

  String formatBackendTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length < 2) return time;
      final tod = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      return tod.format(context);
    } catch (e) {
      debugPrint("Error formatting time: $e");
      return time;
    }
  }

  @override
  Widget build(BuildContext context,) {
    return Scaffold(

      // appBar: AppBar(
      //   title: const Text(
      //     "Doctor Availability",
      //   ),
      // ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            // context.pop();
            context.go(
              AppRoutes.doctorDashboard,
            );
          },
        ),
        title: const Text(
          "Doctor Availability",
        ),
        centerTitle: true,
      ),

      // body: const Center(
      //   child: Text(
      //     "Configure availability here",
      //   ),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            const Text(
              "Working Days",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            ...days.map(
                  (day) =>
                  CheckboxListTile(
                    title: Text(day),

                    value:
                    selectedDays.contains(
                        day),

                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                        }
                      });
                    },
                  ),
            ),

            const SizedBox(height: 20),

            ListTile(
              // title: Text(
              //   startTime ??
              //       "Select Start Time",
              // ),
              title: Text(
                displayStartTime ??
                    "Select Start Time",
              ),
              trailing:
              const Icon(
                Icons.access_time,
              ),
              onTap: () async {
                final picked =
                await showTimePicker(
                  context: context,
                  initialTime:
                  TimeOfDay.now(),
                );

                if (
                picked != null
                ) {
                  setState(() {
                    // startTime =
                    //     picked.format(
                    //         context);
                    displayStartTime =
                        picked.format(context);
                    startTime =
                    "${picked.hour.toString().padLeft(2,'0')}:"
                        "${picked.minute.toString().padLeft(2,'0')}";
                  });
                }
              },
            ),

            ListTile(
              // title: Text(
              //   endTime ??
              //       "Select End Time",
              // ),
              title: Text(
                displayEndTime ??
                    "Select End Time",
              ),
              trailing:
              const Icon(
                Icons.access_time,
              ),
              onTap: () async {
                final picked =
                await showTimePicker(
                  context: context,
                  initialTime:
                  TimeOfDay.now(),
                );

                if (
                picked != null
                ) {
                  setState(() {
                    // endTime =
                    //     picked.format(
                    //         context);
                    displayEndTime =
                        picked.format(context);
                    endTime =
                    "${picked.hour.toString().padLeft(2,'0')}:"
                        "${picked.minute.toString().padLeft(2,'0')}";
                  });
                }
              },
            ),

            const SizedBox(height: 20),
            const SizedBox(height: 20),

            ListTile(
              title: Text(
                displayBreakStart ?? "Select Break Start (Optional)",
              ),
              trailing: const Icon(
                Icons.coffee,
              ),
              onTap: () async {

                final picked =
                await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (picked != null) {

                  setState(() {
                    displayBreakStart = picked.format(context);
                    breakStart =
                    "${picked.hour.toString().padLeft(2,'0')}:"
                        "${picked.minute.toString().padLeft(2,'0')}";

                  });

                }
              },
            ),
            ListTile(
              title: Text(
                displayBreakEnd ?? "Select Break End (Optional)",
              ),
              trailing: const Icon(
                Icons.coffee_outlined,
              ),
              onTap: () async {

                final picked =
                await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (picked != null) {

                  setState(() {
                    displayBreakEnd = picked.format(context);
                    breakEnd =
                    "${picked.hour.toString().padLeft(2,'0')}:"
                        "${picked.minute.toString().padLeft(2,'0')}";

                  });

                }
              },
            ),

            DropdownButton<int>(
              value: slotDuration,

              items: const [
                DropdownMenuItem(
                  value: 15,
                  child: Text(
                    "15 Minutes",
                  ),
                ),

                DropdownMenuItem(
                  value: 30,
                  child: Text(
                    "30 Minutes",
                  ),
                ),

                DropdownMenuItem(
                  value: 45,
                  child: Text(
                    "45 Minutes",
                  ),
                ),

                DropdownMenuItem(
                  value: 60,
                  child: Text(
                    "60 Minutes",
                  ),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  slotDuration =
                  value!;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                isSaving
                    ? null
                    : saveAvailability,

                child:
                isSaving
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "Save Availability",
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  Future<void> saveAvailability() async {
    // setState(() {
    //   isSaving = true;
    // });
    if (
    selectedDays.isEmpty ||
        startTime == null ||
        endTime == null
    ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please complete all required fields.",
          ),
        ),
      );

      return;
    }


    final startParts =
    startTime!.split(":");

    final endParts =
    endTime!.split(":");

    final startMinutes =
        int.parse(startParts[0]) * 60 +
            int.parse(startParts[1]);

    final endMinutes =
        int.parse(endParts[0]) * 60 +
            int.parse(endParts[1]);

    if (
    endMinutes -
        startMinutes <
        240
    ) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "Availability must be at least 4 hours.",
          ),
        ),
      );

      return;
    }
    if (
    endMinutes <=
        startMinutes
    ) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "End time must be after start time.",
          ),
        ),
      );

      return;
    }
    setState(() {
      isSaving = true;
    });
    try {
      final doctorId =
      ref
          .read(
        authProvider,
      )
          .userId!;

      await ApiService()
          .saveDoctorAvailability(

        doctorId:
        doctorId,

        workingDays:
        selectedDays,

        startTime:
        startTime!,

        endTime:
        endTime!,

        breakStart:
        breakStart,

        breakEnd:
        breakEnd,

        slotDuration:
        slotDuration,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Availability saved successfully.",
          ),
        ),
      );

      context.go(
        AppRoutes.doctorDashboard,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }
  Future<void>
  loadAvailability() async {

    final doctorId =
    ref.read(
      authProvider,
    ).userId!;

    final data =
    await ApiService()
        .getDoctorAvailability(
        doctorId);

    if (
    data[
    "availability_configured"
    ] ==
        false
    ) {
      return;
    }

    setState(() {

      selectedDays =
      List<String>.from(
        data[
        "working_days"],
      );

      startTime =
      data[
      "start_time"];

      endTime =
      data[
      "end_time"];

      slotDuration =
      data[
      "slot_duration"];

      breakStart =
      data[
      "break_start"];

      breakEnd =
      data[
      "break_end"];

      displayStartTime = startTime != null ? formatBackendTime(startTime!) : null;
      displayEndTime = endTime != null ? formatBackendTime(endTime!) : null;
      displayBreakStart = breakStart != null ? formatBackendTime(breakStart!) : null;
      displayBreakEnd = breakEnd != null ? formatBackendTime(breakEnd!) : null;
    });
  }

}
