// lib/screens/patient/appoinment_screen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../router/app_router.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';


class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({
    super.key,
  });

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends ConsumerState<BookAppointmentScreen>
{

  DateTime? selectedDate;


  String? selectedTime= null;

  int selectedDoctor = 0;
  bool loadingDoctors = true;
  bool loadingSlots = false;
  bool booking = false;
  Future<void> loadDoctors() async {
  //   final patientId =
  //   ref.read(
  //     authProvider,
  //   ).userId!;
  //
  //
  //   final response = await ApiService()
  //       .getAvailableDoctors(
  //     patientId,
  //   );
  //
  //   setState(() {
  //     doctors = response;
  //     loadingDoctors = false;
  //   });
  // }
    try {

      final patientId =
      ref.read(
        authProvider,
      ).userId!;

      final response =
      await ApiService()
      //     .getAvailableDoctors(
      //   patientId,
      // );
          .getMyDoctors(patientId);
      if (!mounted) return;

      setState(() {

        doctors = response;
        loadingDoctors = false;

      });
      if (response.isNotEmpty) {
        generateAvailableDates(
          List<String>.from(
            response[0]["working_days"] ?? [],
          ),
        );
      }

    } catch (e) {

      setState(() {
        loadingDoctors = false;
      });

      debugPrint(
        e.toString(),
      );
    }
  }


  // final List<Map<String, dynamic>> doctors = [
  //
  //   {
  //     "name": "Dr. Sarah Johnson",
  //     "specialization": "Psychiatrist",
  //     "experience": "12 Years",
  //     "rating": 4.9,
  //   },
  //
  //   {
  //     "name": "Dr. Michael Brown",
  //     "specialization": "Clinical Psychologist",
  //     "experience": "8 Years",
  //     "rating": 4.8,
  //   },
  //
  //   {
  //     "name": "Dr. Emily Davis",
  //     "specialization": "Mental Health Specialist",
  //     "experience": "10 Years",
  //     "rating": 4.7,
  //   },
  //
  // ];
  List<Map<String,dynamic>> doctors = [];

  // final List<String> timings = [
  //
  //   "09:00 AM",
  //   "10:00 AM",
  //   "11:00 AM",
  //   "12:00 PM",
  //   "02:00 PM",
  //   "03:00 PM",
  //   "04:00 PM",
  //   "05:00 PM",
  //
  // ];
  List<String> timings = [];
  List<DateTime> availableDates = [];
  @override
  void initState() {

    super.initState();

    loadDoctors();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () {
  context.go(AppRoutes.patientDashboard);
},
      ),
      title: const Text(
        "Book Appointment",
      ),
      centerTitle: true,
    ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Choose Doctor",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),
            if (
            !loadingDoctors &&
                doctors.isEmpty
            )
              const Center(
                child: Text(
                  "No doctors available",
                ),
              )
            else
            loadingDoctors
                ? const Center(
              child:
              CircularProgressIndicator(),
            )

            :ListView.builder(

              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              itemCount: doctors.length,

              itemBuilder: (context,index){

                final doctor=doctors[index];

                return Card(

                  elevation: 3,

                  child: RadioListTile(

                    value: index,

                    groupValue: selectedDoctor,

                    onChanged: (value){

                      setState(() {

                        selectedDoctor=value!;
                        selectedDate = null;

                        selectedTime = null;

                        timings.clear();



                      });
                      generateAvailableDates(
                        List<String>.from(
                          doctors[
                          selectedDoctor
                          ]["working_days"] ?? [],
                        ),
                      );
                      // loadSlots();

                    },

                    title: Text(
                      doctor["name"],
                    ),

                    subtitle: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Text(
                          doctor["specialization"]?? "Mental Health",
                        ),

                        Text(
                          // "Experience: ${doctor["experience"]}?? N/A",
                          "Experience: ${doctor["experience"] ?? "N/A"}",
                        ),

                        Text(
                          // "⭐ ${doctor["rating"]} ?? -" ,

                            "⭐ ${doctor["rating"] ?? "-"}",
                        ),

                      ],

                    ),

                  ),

                );

              },

            ),

            const SizedBox(height: 20),

            const Text(

              "Select Date",

              style: TextStyle(

                fontSize: 20,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 10),

            // ElevatedButton.icon(
            //
            //   icon: const Icon(Icons.calendar_today),
            //
            //   label: Text(
            //
            //     selectedDate==null
            //
            //         ? "Choose Date"
            //
            //         : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
            //
            //   ),
            //
            //   onPressed: () async {
            //
            //     DateTime? picked=
            //
            //     await showDatePicker(
            //
            //       context: context,
            //
            //       firstDate: DateTime.now(),
            //
            //       lastDate: DateTime(2030),
            //
            //       initialDate: DateTime.now(),
            //
            //     );
            //
            //     if(picked!=null){
            //
            //       setState(() {
            //
            //         selectedDate=picked;
            //
            //       });
            //       loadSlots();
            //
            //     }
            //
            //   },
            //
            // ),
            // DropdownButton<DateTime>(
            //
            //   value: selectedDate,
            //
            //   hint: const Text(
            //     "Select Date",
            //   ),
            //
            //   isExpanded: true,
            //
            //   items:
            //   availableDates.map(
            //         (date) {
            //
            //       return DropdownMenuItem(
            //
            //         value: date,
            //
            //         child: Text(
            //           "${date.day}/"
            //               "${date.month}/"
            //               "${date.year}",
            //         ),
            //       );
            //     },
            //   ).toList(),
            //
            //   onChanged: (
            //       value,
            //       ) {
            //
            //     setState(() {
            //
            //       selectedDate =
            //           value;
            //
            //       selectedTime =
            //       null;
            //
            //     });
            //
            //     loadSlots();
            //   },
            // ),
            if (availableDates.isEmpty)

              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                ),
                child: Text(
                  "No available dates for this doctor.",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              )

            else

              DropdownButton<DateTime>(

                value: selectedDate,

                hint: const Text(
                  "Select Date",
                ),

                isExpanded: true,

                items: availableDates.map(
                      (date) {

                    return DropdownMenuItem<DateTime>(

                      value: date,

                      child: Text(
                        "${date.day.toString().padLeft(2, '0')}/"
                            "${date.month.toString().padLeft(2, '0')}/"
                            "${date.year}",
                      ),
                    );
                  },
                ).toList(),

                onChanged: (date) async {

                  if (date == null) return;

                  setState(() {

                    selectedDate = date;

                    selectedTime = null;

                  });

                  await loadSlots();

                },

              ),

            const SizedBox(height: 25),

            const Text(

              "Available Time Slots",

              style: TextStyle(

                fontSize: 20,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 10),

            loadingSlots
                ? const Center(
              child:
              CircularProgressIndicator(),
            )
                :Wrap(

              spacing: 10,

              runSpacing: 10,

              children: timings.map((time){

                return ChoiceChip(

                  // label: Text(time),
                  label: Text(
                    formatTime12Hour(time),
                  ),

                  selected: selectedTime==time,

                  onSelected: (_){

                    setState(() {

                      selectedTime=time;

                    });

                  },

                );

              }).toList(),

            ),

            const SizedBox(height: 35),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton(

                onPressed: booking
                    ? null
                    : () async{

                  if(selectedDate==null ||

                      selectedTime==null){

                    ScaffoldMessenger.of(context)

                        .showSnackBar(

                      const SnackBar(

                        content: Text(

                          "Please select date and time",

                        ),

                      ),

                    );

                    return;

                  }

                  // showDialog(
                  //
                  //   context: context,
                  //
                  //   builder:(_){
                  //
                  //     return AlertDialog(
                  //
                  //       title: const Text(
                  //
                  //         "Appointment Booked",
                  //
                  //       ),
                  //
                  //       content: Text(
                  //
                  //         "Your appointment has been booked with\n\n${doctors[selectedDoctor]["name"]}\n\nDate: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}\nTime: $selectedTime",
                  //
                  //       ),
                  //
                  //       actions: [
                  //
                  //         TextButton(
                  //
                  //           onPressed: (){
                  //
                  //             Navigator.pop(context);
                  //
                  //           },
                  //
                  //           child: const Text(
                  //
                  //             "OK",
                  //
                  //           ),
                  //
                  //         )
                  //
                  //       ],
                  //
                  //     );

                  //   },
                  //
                  // );
                  try {

                    final patientId =
                    ref.read(
                      authProvider,
                    ).userId!;
                    if (!mounted) return;
                    setState(() {
                      booking = true;
                    });

                    await ApiService()
                        .bookAppointment(

                      patientId:
                      patientId,

                      doctorId:
                      // doctors[
                      // selectedDoctor
                      // ]["_id"],
                      doctors[selectedDoctor]["user_id"],

                      date:
                      "${selectedDate!.year}-"
                          "${selectedDate!.month.toString().padLeft(2,'0')}-"
                          "${selectedDate!.day.toString().padLeft(2,'0')}",

                      time:
                      selectedTime!,

                      reason:
                      "Mental Health Consultation",

                    );
                    final bookedTime = selectedTime!;
                    await loadSlots();
                    selectedTime = null;

                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text("Appointment Booked"),
                            content: Text(
                              "Appointment booked with ${doctors[selectedDoctor]["name"]}\n\n"
                                  "Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}\n"
                                  "Time: ${formatTime12Hour(bookedTime)}",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  );
                                  context.go(
                                    AppRoutes.patientDashboard,
                                  );
                                },
                                child:
                                const Text(
                                  "OK",
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    setState(() {
                      booking = false;
                    });

                  }
                  // catch (e) {
                  //
                  //   ScaffoldMessenger.of(
                  //     context,
                  //   ).showSnackBar(
                  //
                  //     SnackBar(
                  //       content: Text(
                  //         e.toString(),
                  //       ),
                  //     ),
                  //
                  //   );
                  // }
                   on DioException catch (e) {

                  if (e.response?.statusCode == 409) {

                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                  content: Text(
                  "This time slot has already been booked. Please choose another time.",
                  ),
                  ),
                  );

                  await loadSlots(); // Refresh slots after conflict

                  } else {

                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                  content: Text(
                  e.message ?? "Booking failed",
                  ),
                  ),
                  );

                  }

                  } catch (e) {

                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                  content: Text(e.toString()),
                  ),
                  );

                  }
                  setState(() {
                    booking = false;
                  });

                },

                child:
                booking
                    ? const CircularProgressIndicator()
                    : const Text(

                  "Book Appointment",

                  style: TextStyle(

                    fontSize: 18,

                  ),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }
  // void generateAvailableDates(
  //     List<String> workingDays,
  //     ) {
  //
  //   availableDates.clear();
  //
  //   final today =
  //   DateTime.now();
  //
  //   final endDate =
  //   today.add(
  //     const Duration(
  //       days: 21,
  //     ),
  //   );
  //
  //   DateTime current =
  //       today;
  //
  //   while (
  //   current.isBefore(
  //     endDate,
  //   )
  //   ) {
  //
  //     final weekday =
  //     [
  //       "",
  //       "Monday",
  //       "Tuesday",
  //       "Wednesday",
  //       "Thursday",
  //       "Friday",
  //       "Saturday",
  //       "Sunday",
  //     ][current.weekday];
  //
  //     if (
  //     workingDays.contains(
  //         weekday)
  //     ) {
  //       availableDates.add(
  //         current,
  //       );
  //     }
  //
  //     current =
  //         current.add(
  //           const Duration(
  //             days: 1,
  //           ),
  //         );
  //   }
  // }
  void generateAvailableDates(
      List<String> workingDays,
      ) {

    availableDates.clear();

    final today = DateTime.now();

    final endDate = today.add(
      const Duration(days: 21),
    );

    DateTime current = DateTime(
      today.year,
      today.month,
      today.day,
    );

    while (
    !current.isAfter(endDate)
    ) {

      final weekday = [
        "",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
      ][current.weekday];

      if (
      workingDays.contains(
          weekday)
      ) {

        availableDates.add(
          current,
        );

      }

      current = current.add(
        const Duration(
          days: 1,
        ),
      );
    }

    setState(() {});
  }
  Future<void> loadSlots() async {
    try {
      if (
      selectedDate == null ||
          doctors.isEmpty
      ) {
        return;
      }

      final formattedDate =
          "${selectedDate!.year}-"
          "${selectedDate!.month.toString().padLeft(2, '0')}-"
          "${selectedDate!.day.toString().padLeft(2, '0')}";

      setState(() {
        loadingSlots = true;
        selectedTime = null;
      });
      final slots =
      await ApiService()
          .getAvailableSlots(
        // doctors[
        // selectedDoctor
        // ]["_id"],
        doctors[selectedDoctor]["user_id"],
        formattedDate,
      );

      setState(() {
        timings = slots;
        loadingSlots = false;
      });
    }

    catch (e) {
      if (!mounted) return;

      setState(() {
        loadingSlots = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load slots",
          ),
        ),
      );
    }

  }
  String formatTime12Hour(String time) {

    final parts = time.split(":");

    int hour = int.parse(parts[0]);

    final minute = parts[1];

    final period = hour >= 12 ? "PM" : "AM";

    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return "$hour:$minute $period";
  }
}
