import 'package:admin_timesabai/views/users_views/screens/record_screens/report_day_record.dart';
import 'package:admin_timesabai/views/users_views/screens/record_screens/report_month_record.dart';
import 'package:admin_timesabai/views/users_views/screens/record_screens/report_status_record.dart';
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

class EmployeeRecordsSerceen extends StatefulWidget {
  const EmployeeRecordsSerceen({Key? key}) : super(key: key);

  @override
  _EmployeeRecordsSerceenState createState() => _EmployeeRecordsSerceenState();
}

class _EmployeeRecordsSerceenState extends State<EmployeeRecordsSerceen> {
  @override
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  bool isSearchClicked = false;
  String _searchName = '';
  String _searchTypeClock = '';
  String _month = DateFormat('MMMM').format(DateTime.now());
  String _day = DateFormat('dd').format(DateTime.now());

  bool _isDateFilterActive = false;

  Future<List<Map<String, dynamic>>> fetchEmployeesWithLeaves(
      DateTime? fromDate, DateTime? toDate, bool isDateFilter) async {
    final employeeSnapshot =
        await FirebaseFirestore.instance.collection('Employee').get();

    List<Map<String, dynamic>> recordCards = [];

    for (var doc in employeeSnapshot.docs) {
      final leaveSnapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(doc.id)
          .collection('Record')
          .get();

      for (var recordDoc in leaveSnapshot.docs) {
        final recordData = recordDoc.data();
        final from = (recordData['date'] as Timestamp).toDate();
        final to = (recordData['date'] as Timestamp).toDate();

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
          recordCards.add({
            'employeeId': doc.id,
            'recordId': recordDoc.id,
            'name': doc['name'],
            'profileImage': doc['profileImage'],
            'record': recordData,
          });
        }
      }
    }

    recordCards.sort((a, b) {
      final aFrom = (a['record']['date'] as Timestamp).toDate();
      final bFrom = (b['record']['date'] as Timestamp).toDate();
      return bFrom.compareTo(aFrom);
    });

    return recordCards;
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
                'ຂໍ້ມູນການມາປະຈໍາການຂອງພະນັກງານ',
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
            // CustomTextFieldDesign(
            //   onChanged: (value) {
            //     setState(() {
            //       _searchTypeClock = value.toLowerCase();
            //     });
            //   },
            //   hintText: 'ຄົ້ນຫາການອອກວຽກນອກ...',
            // ),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchTypeClock = value.toLowerCase();
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
                  hintText: 'ຄົ້ນຫາການອອກວຽກນອກ...',
                ),
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
                      final record = employee['record'];

                      if (!_searchName.isEmpty &&
                          !employee['name']
                              .toString()
                              .toLowerCase()
                              .contains(_searchName.toLowerCase())) {
                        return SizedBox.shrink(); // Skip this user
                      }
                      if (_searchTypeClock.isNotEmpty &&
                          !((record['type_clock_out']
                                      ?.toString()
                                      .toLowerCase()
                                      ?.contains(
                                          _searchTypeClock.toLowerCase()) ??
                                  false) ||
                              (record['type_clock_in']
                                      ?.toString()
                                      .toLowerCase()
                                      ?.contains(
                                          _searchTypeClock.toLowerCase()) ??
                                  false))) {
                        return SizedBox.shrink(); // Skip this user
                      }

                      var dataStatus =
                          getStatusColor(record['status'].toString());

                      return GestureDetector(
                        onTap: () {
                          bottoSheetApp(context, record, employee);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                              child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: dataStatus, width: 01),
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
                                              '${DateFormat.yMMMMd().format((record['date'] as Timestamp).toDate())}',
                                              style: GoogleFonts.notoSansLao(
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              )),
                                        ],
                                      ),
                                      Text(
                                          '${DateFormat.EEEE().format((record['date'] as Timestamp).toDate())}',
                                          style: GoogleFonts.notoSansLao(
                                            textStyle: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          )),
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
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'ສະຖານະ',
                                                    style:
                                                        GoogleFonts.notoSansLao(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    record['status'] != null &&
                                                            record['status'] !=
                                                                '------'
                                                        ? record['status']
                                                            .toString()
                                                        : '',
                                                    style:
                                                        GoogleFonts.notoSansLao(
                                                      fontSize: 15,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    record['status_out_door'] !=
                                                            null
                                                        ? record[
                                                                'status_out_door']
                                                            .toString()
                                                        : '',
                                                    style:
                                                        GoogleFonts.notoSansLao(
                                                      fontSize: 15,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'ປະເພດ',
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        record['type_clock_in']
                                                                ?.toString() ??
                                                            '----',
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                                fontSize: 15),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        record['type_clock_out']
                                                                ?.toString() ??
                                                            '----',
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                                fontSize: 15),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'ເຂົ້າ',
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        record['clockInAM'],
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                                fontSize: 15),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        record['clockInPM'],
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                                fontSize: 15),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  // / ${record['type_clock_out'].toString() ?? ''} ${record['type_clock_in'].toString() ?? ''}
                                                  Column(
                                                    children: [
                                                      Text(
                                                        'ອອກ',
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Text(
                                                        record['clockOutAM'],
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                                fontSize: 15),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        record['clockOutPM'],
                                                        style: GoogleFonts
                                                            .notoSansLao(
                                                                fontSize: 15),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ],
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
              label: 'ລາຍງານພະນັກງານອອກວຽກນອກ',
              labelStyle: GoogleFonts.notoSansLao(),
              elevation: 10,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportMonthStatus(
                      searchstatus: _searchTypeClock,
                      Month: _selectedMonth,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.yellow),
          SpeedDialChild(
              child: Icon(Icons.timelapse_sharp, color: Colors.white),
              label: 'ລາຍງານຂໍ້ມູນລາຍເດືອນ',
              labelStyle: GoogleFonts.notoSansLao(),
              elevation: 10,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportMonthRecord(
                      searchName: _searchName,
                      monthDate: _selectedMonth,
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
                    builder: (context) => ReportDayRecord(
                      searchName: _searchName,
                      dayDate: _selectedDate,
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
      BuildContext context, dynamic recordData, dynamic employee) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.8,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                          imageUrl: employee['profileImage']?.toString() ?? '',
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
                        employee['name']?.toString() ?? '',
                        style: GoogleFonts.notoSansLao(fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ຕໍາແໜ່ງເຂົ້າ',
                      style: GoogleFonts.notoSansLao(fontSize: 15),
                    ),
                    const SizedBox(height: 5),
                    CustomTextFieldDesign(
                      hintText: recordData['checkInLocation']?.toString() ?? '',
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ຕໍາແໜ່ງອອກ',
                      style: GoogleFonts.notoSansLao(fontSize: 15),
                    ),
                    const SizedBox(height: 5),
                    CustomTextFieldDesign(
                      hintText:
                          recordData['checkOutLocation']?.toString() ?? '',
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ເວລາເຂົ້າ',
                                style: GoogleFonts.notoSansLao(fontSize: 15),
                              ),
                              const SizedBox(height: 5),
                              CustomTextFieldDesign(
                                hintText:
                                    recordData['clockInAM']?.toString() ?? '',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ເວລາອອກ',
                                style: GoogleFonts.notoSansLao(fontSize: 15),
                              ),
                              const SizedBox(height: 5),
                              CustomTextFieldDesign(
                                hintText:
                                    recordData['clockOutAM']?.toString() ?? '',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ເວລາເຂົ້າ',
                                style: GoogleFonts.notoSansLao(fontSize: 15),
                              ),
                              const SizedBox(height: 5),
                              CustomTextFieldDesign(
                                hintText: recordData['clockInPM'],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ເວລາອອກ',
                                style: GoogleFonts.notoSansLao(fontSize: 15),
                              ),
                              const SizedBox(height: 5),
                              CustomTextFieldDesign(
                                hintText: recordData['clockOutPM'],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ສະຖານະ',
                      style: GoogleFonts.notoSansLao(fontSize: 15),
                    ),
                    const SizedBox(height: 5),
                    CustomTextFieldDesign(
                      hintText: recordData['status'],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ປະເພດການບັນທືກຕອນເຊົ້າ',
                                style: GoogleFonts.notoSansLao(fontSize: 15),
                              ),
                              const SizedBox(height: 5),
                              CustomTextFieldDesign(
                                hintText:
                                    recordData['type_clock_in']?.toString() ??
                                        '-----',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ປະເພດການບັນທືກຕອນແລງ',
                                style: GoogleFonts.notoSansLao(fontSize: 15),
                              ),
                              const SizedBox(height: 5),
                              CustomTextFieldDesign(
                                hintText:
                                    recordData['type_clock_out']?.toString() ??
                                        '-----',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ຄໍາອະທຶບາຍ',
                      style: GoogleFonts.notoSansLao(fontSize: 15),
                    ),
                    const SizedBox(height: 5),
                    CustomTextFieldDesign(
                      hintText: recordData['title']?.toString() ?? '-----',
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ຮູບພາບ',
                      style: GoogleFonts.notoSansLao(fontSize: 15),
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
                            imageUrl: recordData['image']?.toString() ?? '',
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
              ),
            ),
          );
        });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'ມາວຽກຊ້າ':
        return Colors.orange;

      case 'ຂາດວຽກ':
        return Colors.red;
      case 'ວັນພັກ':
        return Colors.black12;
      default:
        return Colors.blue;
    }
  }
}
