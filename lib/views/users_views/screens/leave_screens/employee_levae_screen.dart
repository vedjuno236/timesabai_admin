import 'dart:async';

import 'package:admin_timesabai/components/logging.dart';
import 'package:admin_timesabai/views/users_views/screens/leave_screens/pdf_leave_view.dart';
import 'package:admin_timesabai/views/users_views/screens/leave_screens/report__month_leave.dart';
import 'package:admin_timesabai/views/users_views/screens/leave_screens/report_day_leave.dart';
import 'package:admin_timesabai/views/users_views/screens/leave_screens/show_images.dart';
import 'package:admin_timesabai/views/widget/date_month_year/shared/month_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';

import '../../../../service/notification/notification_admin.dart';

class EmployeeLeaveSerceen extends StatefulWidget {
  const EmployeeLeaveSerceen({super.key});

  @override
  State<EmployeeLeaveSerceen> createState() => _EmployeeLeaveSerceenState();
}

class _EmployeeLeaveSerceenState extends State<EmployeeLeaveSerceen> {
  String _searchName = '';
  String _searchQuery = '';
  bool isSearchClicked = false;
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now(); // To track the selected date
  String _day = DateFormat('dd').format(DateTime.now());
  String _month = DateFormat('MMMM').format(DateTime.now());
  bool _isMonthSelected = false;

  Future<void> sendNotification() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Users').get();
    snapshot.docs.forEach((doc) async {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data.containsKey('FCM')) {
        NotificationService().pushNotification(
            title: "HI",
            body: 'ຂໍລາຍເຊັນເພື່ອເຊັນໃບລາພັກຂອງພະນັກງານ',
            token: data['FCM']);
      }
    });
  }

  final List<Color> colors = [
    Color(0xFF5AD1fA),
    Color(0xFF836FF0),
    Color(0XFF1AC286),
    Color(0XFFF984BC)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF577DF4),
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
              ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearchClicked = !isSearchClicked;
              });
            },
            icon: Icon(isSearchClicked ? Icons.close : Icons.search),
          ),
          IconButton(
            onPressed: () {
              sendNotification();
            },
            icon: Icon(Icons.send),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            selectDateWidget(context),
            // buildSearchField(),
            SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Employee')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index].data() as Map<String, dynamic>;
                      final userId = users[index].id;
                      if (!_searchName.isEmpty &&
                          !user['name']
                              .toString()
                              .toLowerCase()
                              .contains(_searchName.toLowerCase())) {
                        return SizedBox.shrink(); // Skip this user
                      }

                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: colors[index % colors.length],
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12))),
                              height: 72,
                              width: 15,
                            ),
                            Expanded(
                              child: ExpansionTile(
                                title: Text(
                                  user['name'],
                                  style: GoogleFonts.notoSansLao(
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Employee')
                                        .doc(userId)
                                        .collection('Leave')
                                        .snapshots(),
                                    builder: (context, orderSnapshot) {
                                      if (orderSnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      } else if (orderSnapshot.hasError) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                              child: Text(
                                                  'Error: ${orderSnapshot.error}')),
                                        );
                                      } else if (!orderSnapshot.hasData ||
                                          orderSnapshot.data!.docs.isEmpty) {
                                        return Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Center(
                                              child: Text(
                                                'ບໍ່ມີຂໍໍມູນ.',
                                                style: GoogleFonts.notoSansLao(
                                                  textStyle: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ));
                                      }

                                      final orders = orderSnapshot.data!.docs;
                                      final filteredOrders =
                                          orders.where((order) {
                                        final date =
                                            (order['date'] as Timestamp)
                                                .toDate();
                                        if (_isMonthSelected) {
                                          return date.month ==
                                                  _selectedMonth.month &&
                                              date.year == _selectedMonth.year;
                                        } else {
                                          return date.day ==
                                                  _selectedDate.day &&
                                              date.month ==
                                                  _selectedDate.month &&
                                              date.year == _selectedDate.year;
                                        }
                                      }).toList();
                                      final searchFilteredOrders =
                                          filteredOrders.where((order) {
                                        final status = order['status']
                                            .toString()
                                            .toLowerCase();
                                        return status.contains(_searchQuery);
                                      }).toList();

                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                searchFilteredOrders.length,
                                            itemBuilder: (context, orderIndex) {
                                              final record =
                                                  searchFilteredOrders[
                                                              orderIndex]
                                                          .data()
                                                      as Map<String, dynamic>;
                                              List<dynamic> imageUrls =
                                                  record['imageUrl'];

                                              // logger.d(record);

                                              return ExpansionTile(
                                                title: Text(
                                                  "ວັນທີ: ${DateFormat.yMMMMEEEEd().format((record['date'] as Timestamp).toDate())}",
                                                  style:
                                                      GoogleFonts.notoSansLao(
                                                    textStyle: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'ຈາກວັນທີ: ${DateFormat.yMMMMEEEEd().format((record['fromDate'] as Timestamp).toDate())}',
                                                          style: GoogleFonts
                                                              .notoSansLao(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Text(
                                                          'ວັນທີສີ້ນສຸດ: ${DateFormat.yMMMMEEEEd().format((record['toDate'] as Timestamp).toDate())}',
                                                          style: GoogleFonts
                                                              .notoSansLao(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        SizedBox(height: 5),
                                                        Text(
                                                          '${record['daySummary']}',
                                                          style: GoogleFonts
                                                              .notoSansLao(
                                                                  fontSize: 15),
                                                        ),
                                                        SizedBox(height: 5),
                                                        Text(
                                                          'ເຫດຜົນ: ${record['doc']}',
                                                          style: GoogleFonts
                                                              .notoSansLao(
                                                                  fontSize: 15),
                                                        ),
                                                        SizedBox(height: 5),
                                                        Text(
                                                          'ປະເພດລາພັກ: ${record['leaveType']}',
                                                          style: GoogleFonts
                                                              .notoSansLao(
                                                                  fontSize: 15),
                                                        ),
                                                        SizedBox(height: 5),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                _showEditStatusDialog(
                                                                    record[
                                                                        'status'],
                                                                    userId,
                                                                    searchFilteredOrders[
                                                                            orderIndex]
                                                                        .id);
                                                              },
                                                              style: TextButton
                                                                  .styleFrom(
                                                                backgroundColor:
                                                                    getStatusColor(
                                                                        record[
                                                                            'status']),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              child: Text(
                                                                'ສະຖານະ: ${record['status']}',
                                                                style: GoogleFonts
                                                                    .notoSansLao(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .white),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                PanaraConfirmDialog
                                                                    .showAnimatedGrow(
                                                                  context,
                                                                  color: Colors
                                                                      .blue,
                                                                  title:
                                                                      "!!!!...!!!!",
                                                                  message:
                                                                      "ທ່ານຕ້ອງການລົບແທ້ບໍ່.",
                                                                  confirmButtonText:
                                                                      "ຕົກລົງ",
                                                                  cancelButtonText:
                                                                      "ຍົກເລີກ",
                                                                  onTapCancel:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  onTapConfirm:
                                                                      () async {
                                                                    try {
                                                                      // Reference the specific document to delete within the 'Leave' collection
                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Employee')
                                                                          .doc(
                                                                              userId)
                                                                          .collection(
                                                                              'Leave')
                                                                          .doc(searchFilteredOrders[orderIndex]
                                                                              .id)
                                                                          .delete();

                                                                      Navigator.pop(
                                                                          context);
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                            content:
                                                                                Text('ການລາພັກຖືກລົບສຳເລັດ')),
                                                                      );
                                                                    } catch (e) {
                                                                      // Handle any errors during deletion
                                                                      Navigator.pop(
                                                                          context);
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                            content:
                                                                                Text('ມີບັນຫາໃນການລົບການລາພັກ: $e')),
                                                                      );
                                                                    }
                                                                  },
                                                                  panaraDialogType:
                                                                      PanaraDialogType
                                                                          .success,
                                                                );
                                                              },
                                                              style: TextButton
                                                                  .styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .redAccent),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    'ລົບການລາພັກ',
                                                                    style: GoogleFonts.notoSansLao(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  SizedBox(
                                                                      width: 5),
                                                                  FaIcon(FontAwesomeIcons
                                                                      .trashCan),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 5),
                                                        SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            children: imageUrls
                                                                .map<Widget>(
                                                                    (imageUrl) {
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          FullScreenImage(
                                                                              imageUrl: imageUrls),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              10.0),
                                                                  child: Image
                                                                      .network(
                                                                    imageUrl,
                                                                    width: 150,
                                                                    height: 150,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    loadingBuilder: (BuildContext
                                                                            context,
                                                                        Widget
                                                                            child,
                                                                        ImageChunkEvent?
                                                                            loadingProgress) {
                                                                      if (loadingProgress ==
                                                                          null) {
                                                                        return child;
                                                                      }
                                                                      return Center(
                                                                        child: LoadingAnimationWidget
                                                                            .inkDrop(
                                                                          size:
                                                                              50,
                                                                          color:
                                                                              Colors.orange,
                                                                        ),
                                                                      );
                                                                    },
                                                                    errorBuilder: (BuildContext
                                                                            context,
                                                                        Object
                                                                            exception,
                                                                        StackTrace?
                                                                            stackTrace) {
                                                                      return Text(
                                                                        'ບໍ່ມີຮູບພາບ',
                                                                        style: GoogleFonts
                                                                            .notoSansLao(
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10),
                                                        GestureDetector(
                                                          onTap: () {
                                                            final documentUrl =
                                                                record['documentUrl']
                                                                    as String;
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Pdfview(
                                                                  documentUrl:
                                                                      documentUrl,
                                                                  leaveid: orders[
                                                                          orderIndex]
                                                                      .id,
                                                                  users: userId,
                                                                ),
                                                              ),
                                                            );

                                                            print(
                                                                "ID${documentUrl}");
                                                            print(
                                                                "User${orders[orderIndex].id}");
                                                          },
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            color: Colors.grey,
                                                            // Example background for the tap area
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .picture_as_pdf,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                Text(
                                                                  'ເປີດ PDF ເພື່ອເບິ່ງເອກະສານຂໍລາພັກ',
                                                                  style: GoogleFonts.notoSansLao(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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

                logger.d(_selectedDate);
              },
              backgroundColor: Colors.orangeAccent),
        ],
      ),
    );
  }

  Row selectDateWidget(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  DateTime now = DateTime.now();
                  DateTime maxDate = DateTime(
                      now.year, now.month + 1, 0); // Last day of next month
                  DateTime? tempSelectedDate =
                      _selectedDate; // Change variable name to reflect day selection
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
                        lastDate: DateTime.now(),
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
                              _day = DateFormat('dd').format(_selectedDate!);
                              _isMonthSelected = true;
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xFF577DF4),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.white),
                  Text(
                    "ເລືອກວັນທີ: ${_day.isEmpty ? "ເລືອກວັນທີ" : _day}",
                    style: GoogleFonts.notoSansLao(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () async {
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
                        currentDate: _selectedMonth ?? DateTime.now(),
                        selectedDate: _selectedMonth ?? DateTime.now(),
                        onDateSelected: (month) {
                          setState(() {
                            tempSelectedMonth = month;
                          });
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
                              _month =
                                  DateFormat('MMMM').format(_selectedMonth!);
                              _isMonthSelected = true;
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xFF577DF4),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.white),
                  Text(
                    "ເລືອກເດືອນ: ${_month.isEmpty ? "ເລືອກເດືອນ" : _month}",
                    style: GoogleFonts.notoSansLao(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditStatusDialog(
      String currentStatus, String userId, String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedStatus =
            currentStatus; // Holds the status selected by the user

        return AlertDialog(
          title: Text(
            'ແກ້ໄຂສະຖານະ',
            style: GoogleFonts.notoSansLao(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                value: selectedStatus,
                onChanged: (newValue) {
                  setState(() {
                    selectedStatus = newValue!;
                  });

                  // Show a message (using Snackbar in this case)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'ເຈົ້າເລືອກ: $newValue',
                        style: GoogleFonts.notoSansLao(fontSize: 15),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                items: ['ອະນຸມັດແລ້ວ', 'ລໍຖ້າອະນຸມັດ', 'ປະຕິເສດ']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.notoSansLao(fontSize: 15),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              child:
                  Text('ຍົກເລີກ', style: GoogleFonts.notoSansLao(fontSize: 15)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  Text('ບັນທຶກ', style: GoogleFonts.notoSansLao(fontSize: 15)),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('Employee')
                    .doc(userId)
                    .collection('Leave')
                    .doc(messageId)
                    .update({'status': selectedStatus});

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildSearchField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase(); // Set the search name
          });
        },
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          hintStyle: TextStyle(color: Colors.black),
          border: InputBorder.none,
          labelText: 'ຄົ້ນຫາສະຖານະ...',
          labelStyle: GoogleFonts.notoSansLao(
            textStyle: const TextStyle(
              color: Colors.black, // You can set the color here
            ),
          ),
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'ອະນຸມັດແລ້ວ':
        return Colors.blue;
      case 'ປະຕິເສດ':
        return Colors.red;
      default:
        return Colors.orangeAccent;
    }
  }
}
