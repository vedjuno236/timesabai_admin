import 'package:admin_timesabai/views/users_views/screens/leave_screens/pdf_leave_view.dart';
import 'package:admin_timesabai/views/widget/date_month_year/shared/month_picker.dart';
import 'package:admin_timesabai/views/widget/loading_platform/loading.dart';
import 'package:admin_timesabai/views/widget/text_input_design.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class NotificationScreens extends StatefulWidget {
  const NotificationScreens({Key? key}) : super(key: key);

  @override
  _NotificationScreensState createState() => _NotificationScreensState();
}

class _NotificationScreensState extends State<NotificationScreens> {
  DateTime _selectedMonth = DateTime.now();

  Future<List<Map<String, dynamic>>> fetchEmployeesWithLeaves(
      DateTime fromDate, DateTime toDate) async {
    final employeeSnapshot =
        await FirebaseFirestore.instance.collection('Employee').get();

    List<Map<String, dynamic>> leaveCards = [];

    for (var doc in employeeSnapshot.docs) {
      final leaveSnapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(doc.id)
          .collection('Leave')
          .get();

      for (var leaveDoc in leaveSnapshot.docs) {
        final leaveData = leaveDoc.data();
        final from = (leaveData['date'] as Timestamp).toDate();
        final to = (leaveData['toDate'] as Timestamp).toDate();

        final fromOnly = DateTime(from.year, from.month, from.day);
        final toOnly = DateTime(to.year, to.month, to.day);

        // Check if leave falls within the selected date range
        final isInRange = (fromOnly.isAtSameMomentAs(fromDate) ||
                    fromOnly.isAfter(fromDate)) &&
                (toOnly.isAtSameMomentAs(toDate) || toOnly.isBefore(toDate)) ||
            (fromOnly.isBefore(fromDate) && toOnly.isAfter(toDate));

        if (isInRange) {
          leaveCards.add({
            'employeeId': doc.id, // Store employee ID
            'leaveId': leaveDoc.id, // Store leave document ID
            'name': doc['name'],
            'profileImage': doc['profileImage'],
            'leave': leaveData,
          });
        }
      }
    }

    // Sort by leave start date (descending)
    leaveCards.sort((a, b) {
      final aFrom = (a['leave']['date'] as Timestamp).toDate();
      final bFrom = (b['leave']['date'] as Timestamp).toDate();
      return bFrom.compareTo(aFrom);
    });

    return leaveCards;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate fromDate and toDate for the selected month
    DateTime fromDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    DateTime toDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1)
        .subtract(const Duration(days: 1));

    return Scaffold(
      backgroundColor: const Color(0xffF0F2F6),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'ການແຈ້ງເຕື່ອນ',
          style: GoogleFonts.notoSansLao(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                Colors.blue.shade100,
                Colors.blue.shade300,
                Colors.blue.shade500
              ])),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  DateTime now = DateTime.now();
                  DateTime maxDate = DateTime(now.year, now.month + 1, 0);
                  DateTime? tempSelectedMonth = _selectedMonth;

                  return AlertDialog(
                    elevation: 2,
                    shadowColor: Colors.blue,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    content: SizedBox(
                      height: 300,
                      width: 450,
                      child: MonthPicker(
                        selectedCellDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        selectedCellTextStyle: GoogleFonts.notoSansLao(
                          fontSize: 14,
                        ),
                        enabledCellsTextStyle: GoogleFonts.notoSansLao(
                          fontSize: 14,
                        ),
                        disabledCellsTextStyle: GoogleFonts.notoSansLao(
                            fontSize: 14, color: Colors.grey),
                        currentDateTextStyle: GoogleFonts.notoSansLao(
                          fontSize: 14,
                        ),
                        currentDateDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1,
                            color: Colors.black,
                          ),
                        ),
                        splashColor: Colors.blue,
                        slidersColor: Colors.black,
                        centerLeadingDate: true,
                        minDate: DateTime(2000),
                        currentDate: _selectedMonth,
                        selectedDate: _selectedMonth,
                        onDateSelected: (month) {
                          tempSelectedMonth = month;
                        },
                        maxDate: maxDate,
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.grey,
                          ),
                          child: Text('ຍົກເລີກ',
                              style: GoogleFonts.notoSansLao(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ))),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          if (tempSelectedMonth != null &&
                              tempSelectedMonth != _selectedMonth) {
                            setState(() {
                              _selectedMonth = tempSelectedMonth!;
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: Text(
                          'ຕົກລົງ',
                          style: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IonIcons.ellipsis_vertical,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchEmployeesWithLeaves(fromDate, toDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: LoadingPlatformV2(
              size: 60,
              color: Colors.blue,
            ));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 200,
                      height: 200,
                      child: Lottie.asset('assets/svg/data.json')),
                  Text(
                    'ບໍ່ມີຂໍ້ມູນການລາໃນເດືອນນີ້',
                    style: GoogleFonts.notoSansLao(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final employee = data[index];
              final leave = employee['leave'];

              var dataStatus = getCheckStatus(leave['status'].toString());
              Color colorStatus = dataStatus['color'];

              return GestureDetector(
                onTap: () {
                  final documentUrl = leave['documentUrl'] as String;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Pdfview(
                          documentUrl: documentUrl,
                          leaveid: employee['leaveId'],
                          users: employee['employeeId']),
                    ),
                  );

                  print('👯${employee['leaveId']}');
                  print('🐶${employee['employeeId']}');
                },
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[200],
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        employee['profileImage'].toString(),
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                        child: LoadingPlatformV2()),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error,
                                            size: 40, color: Colors.red),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      employee['name'] ?? '',
                                      style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'on ${DateFormat.d().format((leave['date'] as Timestamp).toDate())} - ${DateFormat.yMMMMd().format((leave['toDate'] as Timestamp).toDate())}',
                                      style:
                                          GoogleFonts.notoSansLao(fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () async {
                            if (leave['status'] == 'ລໍຖ້າອະນຸມັດ') {
                              bottoSheetForme(context, leave, employee);
                            } else {
                              bottoSheetApp(context, leave, employee);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorStatus),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            backgroundColor: colorStatus,
                            padding: const EdgeInsets.all(8.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Bootstrap.check_circle_fill,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                leave['status'],
                                style: GoogleFonts.notoSansLao(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().scaleXY(
                      begin: 0,
                      end: 1,
                      delay: 400.ms,
                      duration: 400.ms,
                      curve: Curves.easeInOutCubic,
                    ),
              );
            },
          );
        },
      ),
    );
  }

  Future<dynamic> bottoSheetApp(
      BuildContext context, dynamic leaveData, dynamic employee) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.8,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Align(
                            alignment: Alignment.topRight,
                            child: Icon(Icons.close))),
                    Align(
                      alignment: Alignment.center,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: employee['profileImage'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: LoadingPlatformV2(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        employee['name'],
                        style: GoogleFonts.notoSansLao(fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () async {},
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: leaveData['status'] == 'ອະນຸມັດແລ້ວ'
                                    ? Colors.blue
                                    : Colors.orangeAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            backgroundColor:
                                leaveData['status'] == 'ອະນຸມັດແລ້ວ'
                                    ? Colors.blue
                                    : Colors.orangeAccent),
                        child: Text(
                          leaveData['status'] == 'ອະນຸມັດແລ້ວ'
                              ? 'ອະນຸມັດແລ້ວ'
                              : 'ຖືກປະຕິເສດ',
                          style: GoogleFonts.notoSansLao(
                              fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        style:
                            Theme.of(context).textTheme.titleSmall!.copyWith(),
                        text: 'ປະເພດລາພັກ: ',
                        children: [
                          TextSpan(
                            text: leaveData['leaveType'] ?? 'N/A',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: const Color(0xFF99A1BE)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ໄລຍະເວລາລາ:',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    CustomTextFieldDesign(
                      hintText:
                          'on ${DateFormat.d().format((leaveData['date'] as Timestamp).toDate())} - ${DateFormat.yMMMMd().format((leaveData['toDate'] as Timestamp).toDate())}',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ເຫດຜົນການລາ:',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    CustomTextFieldDesign(
                      maxLines: 4,
                      hintText: leaveData['doc'] ?? 'ບໍ່ມີເຫດຜົນ',
                    ),
                    const SizedBox(height: 10),
                    if (leaveData['imageUrl'] != null &&
                        leaveData['imageUrl'] is List &&
                        (leaveData['imageUrl'] as List).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ຮູບພາບແນບ:',
                            style: GoogleFonts.notoSansLao(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: leaveData['imageUrl'][0],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: LoadingPlatformV2(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<dynamic> bottoSheetForme(
      BuildContext context, dynamic leaveData, dynamic employee) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.8,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Align(
                            alignment: Alignment.topRight,
                            child: Icon(Icons.close))),
                    Align(
                      alignment: Alignment.center,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: employee['profileImage'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: LoadingPlatformV2(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        employee['name'],
                        style: GoogleFonts.notoSansLao(fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () async {
                              await _updateLeaveStatus(employee['employeeId'],
                                  employee['leaveId'], 'ອະນຸມັດແລ້ວ');
                            },
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                backgroundColor: Colors.blue),
                            child: Text(
                              'ອະນຸມັດ',
                              style: GoogleFonts.notoSansLao(
                                  fontSize: 15, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () async {
                              await _updateLeaveStatus(employee['employeeId'],
                                  employee['leaveId'], 'ປະຕິເສດ');
                            },
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.orangeAccent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                backgroundColor: Colors.orangeAccent),
                            child: Text(
                              'ປະຕິເສດ',
                              style: GoogleFonts.notoSansLao(
                                  fontSize: 15, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        style:
                            Theme.of(context).textTheme.titleSmall!.copyWith(),
                        text: 'ປະເພດລາພັກ: ',
                        children: [
                          TextSpan(
                            text: leaveData['leaveType'] ?? 'N/A',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: const Color(0xFF99A1BE)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ໄລຍະເວລາລາ:',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    CustomTextFieldDesign(
                      hintText:
                          'on ${DateFormat.d().format((leaveData['date'] as Timestamp).toDate())} - ${DateFormat.yMMMMd().format((leaveData['toDate'] as Timestamp).toDate())}',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ເຫດຜົນການລາ:',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    CustomTextFieldDesign(
                      maxLines: 4,
                      hintText: leaveData['doc'] ?? 'ບໍ່ມີເຫດຜົນ',
                    ),
                    const SizedBox(height: 10),
                    if (leaveData['imageUrl'] != null &&
                        leaveData['imageUrl'] is List &&
                        (leaveData['imageUrl'] as List).isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ຮູບພາບແນບ:',
                            style: GoogleFonts.notoSansLao(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: leaveData['imageUrl'][0],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: LoadingPlatformV2(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> _updateLeaveStatus(
      String employeeId, String leaveId, String newStatus) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseFirestore.instance
          .collection('Employee')
          .doc(employeeId)
          .collection('Leave')
          .doc(leaveId)
          .update({'status': newStatus});

      Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context).pop(); // Close bottom sheet

      Fluttertoast.showToast(
        msg: newStatus == 'ອະນຸມັດແລ້ວ'
            ? 'ອະນຸມັດການລາແລ້ວ'
            : 'ປະຕິເສດການລາແລ້ວ',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      setState(() {});
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ມີຂໍ້ຜິດພາດ: $e',
            style: GoogleFonts.notoSansLao(),
          ),
        ),
      );
    }
  }

  Map<String, dynamic> getCheckStatus(String title) {
    switch (title) {
      case "ອະນຸມັດແລ້ວ":
        return {
          'color': const Color(0xFF23A26D),
        };
      case "ປະຕິເສດ":
        return {
          'color': const Color(0xFFF28C84),
        };
      case "ລໍຖ້າອະນຸມັດ":
        return {
          'color': const Color(0xFFFFCE08),
        };
      default:
        return {
          'color': Colors.blueAccent,
        };
    }
  }
}
