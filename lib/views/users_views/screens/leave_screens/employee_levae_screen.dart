import 'package:admin_timesabai/views/users_views/screens/leave_screens/report__month_leave.dart';
import 'package:admin_timesabai/views/users_views/screens/leave_screens/report_day_leave.dart';
import 'package:admin_timesabai/views/widget/date_month_year/shared/month_picker.dart';
import 'package:admin_timesabai/views/widget/loading_platform/loading.dart';
import 'package:admin_timesabai/views/widget/text_input_design.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class EmployeeLevaeScreen extends StatefulWidget {
  const EmployeeLevaeScreen({Key? key}) : super(key: key);
  @override
  _EmployeeLevaeScreenState createState() => _EmployeeLevaeScreenState();
}

class _EmployeeLevaeScreenState extends State<EmployeeLevaeScreen> {
  @override
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  bool isSearchClicked = false;
  String _searchName = '';
  String _month = DateFormat('MMMM').format(DateTime.now());
  String _day = DateFormat('dd').format(DateTime.now());

  bool _isDateFilterActive = false;

  // Future<List<Map<String, dynamic>>> fetchEmployeesWithLeaves(
  //     DateTime fromDate, DateTime toDate) async {
  //   final employeeSnapshot =
  //       await FirebaseFirestore.instance.collection('Employee').get();

  //   List<Map<String, dynamic>> leaveCards = [];

  //   for (var doc in employeeSnapshot.docs) {
  //     final leaveSnapshot = await FirebaseFirestore.instance
  //         .collection('Employee')
  //         .doc(doc.id)
  //         .collection('Leave')
  //         .get();

  //     for (var leaveDoc in leaveSnapshot.docs) {
  //       final leaveData = leaveDoc.data();
  //       final from = (leaveData['date'] as Timestamp).toDate();
  //       final to = (leaveData['toDate'] as Timestamp).toDate();

  //       final fromOnly = DateTime(from.year, from.month, from.day);
  //       final toOnly = DateTime(to.year, to.month, to.day);

  //       final isInRange = (fromOnly.isAtSameMomentAs(fromDate) ||
  //                   fromOnly.isAfter(fromDate)) &&
  //               (toOnly.isAtSameMomentAs(toDate) || toOnly.isBefore(toDate)) ||
  //           (fromOnly.isBefore(fromDate) && toOnly.isAfter(toDate));

  //       if (isInRange) {
  //         leaveCards.add({
  //           'employeeId': doc.id, // Store employee ID
  //           'leaveId': leaveDoc.id, // Store leave document ID
  //           'name': doc['name'],
  //           'profileImage': doc['profileImage'],

  //           'leave': leaveData,
  //         });
  //       }
  //     }
  //   }

  //   // Sort by leave start date (descending)
  //   leaveCards.sort((a, b) {
  //     final aFrom = (a['leave']['date'] as Timestamp).toDate();
  //     final bFrom = (b['leave']['date'] as Timestamp).toDate();
  //     return bFrom.compareTo(aFrom);
  //   });

  //   return leaveCards;
  // }

  Future<List<Map<String, dynamic>>> fetchEmployeesWithLeaves(
      DateTime? fromDate, DateTime? toDate, bool isDateFilter) async {
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
        final from = (leaveData['fromDate'] as Timestamp).toDate();
        final to = (leaveData['toDate'] as Timestamp).toDate();

        final fromOnly = DateTime(from.year, from.month, from.day);
        final toOnly = DateTime(to.year, to.month, to.day);

        bool isInRange = false;

        if (isDateFilter) {
          final selectedDateOnly = DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day);
          isInRange = (fromOnly.isAtSameMomentAs(selectedDateOnly) ||
                  fromOnly.isBefore(selectedDateOnly)) &&
              (toOnly.isAtSameMomentAs(selectedDateOnly) ||
                  toOnly.isAfter(selectedDateOnly));
        } else {
          isInRange = (fromOnly.isAtSameMomentAs(fromDate!) ||
                      fromOnly.isAfter(fromDate)) &&
                  (toOnly.isAtSameMomentAs(toDate!) ||
                      toOnly.isBefore(toDate)) ||
              (fromOnly.isBefore(fromDate) && toOnly.isAfter(toDate!));
        }

        if (isInRange) {
          leaveCards.add({
            'employeeId': doc.id,
            'leaveId': leaveDoc.id,
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
    DateTime? fromDate;
    DateTime? toDate;
    bool isDateFilter = _isDateFilterActive;

    if (isDateFilter) {
      // Use selected date for filtering
      fromDate =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      toDate = fromDate;
    } else {
      // Use selected month for filtering
      fromDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      toDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1)
          .subtract(const Duration(days: 1));
    }

    return Scaffold(
      backgroundColor: const Color(0xffF0F2F6),
      appBar: AppBar(
        centerTitle: true,
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
        title: isSearchClicked
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchName = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    hintStyle: GoogleFonts.notoSansLao(
                      textStyle: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    border: InputBorder.none,
                    hintText: 'ຄົ້ນຫາພະນັກງານ...',
                  ),
                ),
              )
            : Text(
                'ຂໍ້ມູນລາພັກ',
                style: GoogleFonts.notoSansLao(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ).animate().scaleXY(
                begin: 0,
                end: 1,
                delay: 500.ms,
                duration: 500.ms,
                curve: Curves.easeInOutCubic),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearchClicked = !isSearchClicked;
              });
            },
            icon: Icon(isSearchClicked ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDateFilterActive = false;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          DateTime now = DateTime.now();
                          DateTime maxDate =
                              DateTime(now.year, now.month + 1, 0);
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
                                      _month = DateFormat('MMMM')
                                          .format(_selectedMonth!);
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
                    child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Image.asset('assets/images/calendar.png'),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                    "ເລືອກເດືອນ: ${_month.isEmpty ? "ເລືອກເດືອນ" : _month}",
                                    style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ))),
                              ],
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDateFilterActive = true;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          DateTime now = DateTime.now();
                          DateTime maxDate =
                              DateTime(now.year, now.month + 1, 0);
                          DateTime? tempSelectedDate = _selectedDate;
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
                              child: CalendarDatePicker(
                                initialDate: _selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2050),
                                onDateChanged: (date) {
                                  setState(() {
                                    tempSelectedDate = date;
                                  });
                                },
                                selectableDayPredicate: (date) {
                                  // Optional: Customize which days are selectable
                                  return true;
                                },
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.grey,
                                ),
                                child: Text(
                                  'ຍົກເລີກ',
                                  style: GoogleFonts.notoSansLao(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: () {
                                  if (tempSelectedDate != null &&
                                      tempSelectedDate != _selectedDate) {
                                    setState(() {
                                      _selectedDate = tempSelectedDate!;
                                      _day = DateFormat('dd')
                                          .format(_selectedDate!);
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
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.0),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Image.asset('assets/images/calendar.png'),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                    "ເລືອກວັນທີ: ${_day.isEmpty ? "ເລືອກວັນທີ" : _day}",
                                    style: GoogleFonts.notoSansLao(
                                        textStyle: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ))),
                              ],
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future:
                    fetchEmployeesWithLeaves(fromDate, toDate, isDateFilter),
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
                              width: 250,
                              height: 250,
                              child: Lottie.asset('assets/svg/data.json')),
                          Text(
                            'ບໍ່ມີຂໍ້ມູນການລາພັກ',
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

                      var dataStatus =
                          getCheckStatus(leave['status'].toString());
                      Color colorStatus = dataStatus['color'];
                      if (!_searchName.isEmpty &&
                          !employee['name']
                              .toString()
                              .toLowerCase()
                              .contains(_searchName.toLowerCase())) {
                        return SizedBox.shrink(); // Skip this user
                      }

                      return GestureDetector(
                        onTap: () {
                          bottoSheetApp(context, leave, employee);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                              child: Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white, width: 1.0),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor:
                                                Color(0xFF7A5AF8).withAlpha(40),
                                            child: Image.asset(
                                                'assets/images/ot.png'),
                                          ),
                                          const SizedBox(width: 20),
                                          Text(
                                              // data.typeName
                                              leave['leaveType'].toString(),
                                              style: GoogleFonts.notoSansLao(
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color(0xFFEDEFF7),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor:
                                                    Colors.grey[200],
                                                child: ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        employee['profileImage']
                                                            .toString(),
                                                    width: 110,
                                                    height: 110,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        const Center(
                                                            child:
                                                                LoadingPlatformV2()),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error,
                                                            size: 40,
                                                            color: Colors.red),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
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
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Divider(
                                            color: Colors.grey.withAlpha(60),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${DateFormat.d().format((leave['date'] as Timestamp).toDate())} - ${DateFormat.yMMMMd().format((leave['toDate'] as Timestamp).toDate())}',
                                                style: GoogleFonts.notoSansLao(
                                                    fontSize: 15),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${leave['daySummary'].toString()}',
                                                style: GoogleFonts.notoSansLao(
                                                    fontSize: 15),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        animatedIconTheme: IconThemeData(size: 22.0),
        curve: Curves.bounceIn,
        overlayColor: Colors.white,
        foregroundColor: Colors.white,
        elevation: 15.0,
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: const Color(0xFF577DF4),
        children: [
          SpeedDialChild(
              child: Icon(Icons.timelapse_sharp, color: Colors.white),
              label: 'ລາຍງານຂໍ້ມູນລາຍເດືອນ',
              labelStyle: GoogleFonts.notoSansLao(),
              elevation: 10,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportMonthLeave(
                      searchName: _searchName,
                      Month: _selectedMonth,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.yellow),
          SpeedDialChild(
              child: Icon(Icons.calendar_month, color: Colors.white),
              label: 'ລາຍງານຂໍ້ມູນລາຍວັນ',
              labelStyle: GoogleFonts.notoSansLao(),
              elevation: 10,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportDayLeave(
                      searchName: _searchName,
                      Day: _selectedDate,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.orangeAccent),
        ],
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
