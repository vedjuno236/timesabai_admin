import 'package:admin_timesabai/views/users_views/screens/ethnicity_screens/ethnicity_screens.dart';
import 'package:admin_timesabai/views/users_views/screens/provinces_screens/provinces_screens.dart';
import 'package:admin_timesabai/views/users_views/screens/settings/settings_stystem.dart';
import 'package:admin_timesabai/views/users_views/screens/type_leave/type_leave.dart';
import 'package:admin_timesabai/views/users_views/screens/user_screens/user_screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:simple_month_year_picker/simple_month_year_picker.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../models/folder.dart';
import '../agencies_screens/agencies_screens.dart';
import '../branch_screens/branch_screens.dart';
import '../department_screens/department_screens.dart';
import '../districts_screens/districts_screens.dart';
import '../employee_screens/employee_screens.dart';
import '../leave_screens/employee_levae_screen.dart';
import '../position_screens/position_screens.dart';
import '../record_screens/employee_records_serceen.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  List<Folder> folders = [
    Folder(folderName: 'ຈັດການຂໍ້ມູນພະນັກງານ', storage: '0', colors: '#3a86ff'),
    Folder(folderName: 'ຈັດການຂໍ້ມູນພາກວິຊາ', storage: '0', colors: '#2ec4b6'),
    Folder(folderName: 'ຈັດການຂໍ້ມູນສາຂາ', storage: '0', colors: '#ffbe0b'),
    Folder(folderName: 'ຈັດການຂໍ້ມູນຕໍາແໜ່ງ', storage: '0', colors: '#25D162'),
    Folder(folderName: 'ຂໍ້ມູນລາພັກ', storage: '0', colors: '#fb5607'),
    Folder(folderName: 'ຂໍ້ມູນມາປະຈໍາການ', storage: '0', colors: '#577DF4'),
    Folder(folderName: 'ຈັດການຂໍ້ມູນພະແນກ', storage: '0', colors: '#FFBFA9'),
    Folder(folderName: 'ຈັດການຂໍ້ມູນຊົນເຜົ່າ', storage: '0', colors: '#424769'),
    Folder(folderName: 'ຈັດການຂໍ້ມູນແຂວງ', storage: '0', colors: '#F3CCFF'),
    Folder(folderName: 'ຈັດການຂໍ້ມູນເມືອງ', storage: '0', colors: '#8B5DFF'),
    Folder(
        folderName: 'ຈັດການຂໍ້ມູນປະເພດລາພັກ', storage: '0', colors: '#FFBFA9'),
    Folder(
        folderName: 'ຈັດການຂໍ້ມູນຜູ້ໃຊ້ລະບົບ', storage: '0', colors: '#3a86ff'),
  ];

  @override
  void initState() {
    super.initState();
    fetchEmployeeCount();
    fetchDepartmentCount();
    fetchBranchCount();
    fetchPositionCount();
    countTodayLeave();
    countTodayRecord();
    fetchAgenciesCount();
    fetchEthnicityCount();
    fetchProvincesCount();
    fetchDistrictsCount();
    countTodayRecordDay();
    countTodayLeaveDay();
    countMonthLeaves(_selectedMonth!);
    DateTime now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    countMonthRecords(_selectedMonth!);
  }

  Future<void> fetchEmployeeCount() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Employee').get();
      setState(() {
        int employeeCount = snapshot.size;
        String message = 'ທັງໝົດ:$employeeCount';
        folders[0].storage = message;
      });
    } catch (e) {
      print("Error fetching document count: $e");
    }
  }

  Future<void> fetchDepartmentCount() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Department').get();

      setState(() {
        int departmentCount = snapshot.size;
        String message = 'ທັງໝົດ:$departmentCount';
        folders[1].storage = message;
      });
    } catch (e) {
      print("Error fetching document count: $e");
    }
  }

  Future<void> fetchBranchCount() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Branch').get();

      setState(() {
        int branchCount = snapshot.size;
        String message = 'ທັງໝົດ:$branchCount';
        folders[2].storage = message;
      });
    } catch (e) {
      print("Error fetching document count: $e");
    }
  }

  Future<void> fetchPositionCount() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Position').get();

      setState(() {
        int positionCount = snapshot.size;
        String message = 'ທັງໝົດ:$positionCount';
        folders[3].storage = message;
      });
    } catch (e) {
      print("Error fetching document count: $e");
    }
  }

  int leaveMonthCount = 0;

  // void countMonthLeaves() async {
  //   try {
  //     DateTime now = DateTime.now();
  //     DateTime startOfMonth = DateTime(now.year, now.month, 1);
  //     DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  //     QuerySnapshot snapshot = await FirebaseFirestore.instance
  //         .collectionGroup('Leave')
  //         .where('date',
  //             isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
  //         .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
  //         .get();

  //     setState(() {
  //       leaveMonthCount = snapshot.size; // อัปเดตค่า recordCount
  //     });
  //   } catch (e) {
  //     print("Error fetching the monthly records count: $e");
  //   }
  // }
  void countMonthLeaves(DateTime selectedMonth) async {
    try {
      DateTime startOfMonth =
          DateTime(selectedMonth.year, selectedMonth.month, 1);
      DateTime endOfMonth =
          DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('Record')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      setState(() {
        leaveMonthCount = snapshot.size;
      });
    } catch (e) {
      print("Error fetching records count: $e");
    }
  }

  int leaveCount = 0;
  void countTodayLeaveDay() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfToday = DateTime(today.year, today.month, today.day);
      DateTime endOfToday =
          DateTime(today.year, today.month, today.day, 23, 59, 59);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('Leave')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfToday))
          .get();

      setState(() {
        leaveCount = snapshot.size;
      });
    } catch (e) {
      print("Error fetching the records count: $e");
    }
  }

  void countTodayLeave() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfToday = DateTime(today.year, today.month, today.day);
      DateTime endOfToday =
          DateTime(today.year, today.month, today.day, 23, 59, 59);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('Leave')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfToday))
          .get();

      setState(() {
        int leaveCount = snapshot.size;
        String message = 'ວັນນີ້:$leaveCount';
        folders[4].storage = message;
      });
    } catch (e) {
      print("Error fetching the records count: $e");
    }
  }

  // void countMonthRecords() async {
  //   try {
  //     DateTime now = DateTime.now();
  //     DateTime startOfMonth = DateTime(now.year, now.month, 1);
  //     DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  //     QuerySnapshot snapshot = await FirebaseFirestore.instance
  //         .collectionGroup('Record')
  //         .where('date',
  //             isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
  //         .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
  //         .get();

  //     setState(() {
  //       recordMonthCount = snapshot.size; // อัปเดตค่า recordCount
  //     });
  //   } catch (e) {
  //     print("Error fetching the monthly records count: $e");
  //   }
  // }

  int recordMonthCount = 0;
  void countMonthRecords(DateTime selectedMonth) async {
    try {
      DateTime startOfMonth =
          DateTime(selectedMonth.year, selectedMonth.month, 1);
      DateTime endOfMonth =
          DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('Record')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      setState(() {
        recordMonthCount =
            snapshot.size; // Update the count based on selected month
      });
    } catch (e) {
      print("Error fetching records count: $e");
    }
  }

  int recordCount = 0;
  void countTodayRecordDay() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfToday = DateTime(today.year, today.month, today.day);
      DateTime endOfToday =
          DateTime(today.year, today.month, today.day, 23, 59, 59);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('Record')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfToday))
          .get();

      setState(() {
        recordCount = snapshot.size; // อัปเดตค่า recordCount
      });
    } catch (e) {
      print("Error fetching the records count: $e");
    }
  }

  void countTodayRecord() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfToday = DateTime(today.year, today.month, today.day);
      DateTime endOfToday =
          DateTime(today.year, today.month, today.day, 23, 59, 59);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('Record')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfToday))
          .get();

      setState(() {
        int recordCount = snapshot.size;
        String message = 'ວັນນີ້:$recordCount';
        folders[5].storage = message;
      });
    } catch (e) {
      print("Error fetching the records count: $e");
    }
  }

  Future<void> fetchAgenciesCount() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Agencies').get();

      setState(() {
        int agenciesCount = snapshot.size;
        String messages = 'ທັງໝົດ:$agenciesCount';

        folders[6].storage = messages;
      });
    } catch (e) {
      print("Error fetching document count: $e");
    }
  }

  Future<void> fetchEthnicityCount() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Ethnicity').get();

      setState(() {
        int ethnicityCount = snapshot.size;
        String messages = 'ທັງໝົດ:$ethnicityCount';
        print("ທັງໝົດ:$messages");
        folders[7].storage = messages;
      });
    } catch (e) {
      print("Error fetching document count: $e");
    }
  }

  Future<void> fetchProvincesCount() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Provinces').get();

      setState(() {
        int provincesCount = snapshot.size;
        String messages = 'ທັງໝົດ:$provincesCount';
        print("ທັງໝົດ:$messages");
        folders[8].storage = messages;
      });
    } catch (e) {
      print("Error fetching document count: $e");
    }
  }

  Future<void> fetchDistrictsCount() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Districts').get();

      setState(() {
        int districtsCount = snapshot.size;
        String messages = 'ທັງໝົດ:$districtsCount';
        print("ທັງໝົດ:$messages");
        folders[9].storage = messages;
      });
    } catch (e) {
      print("Error fetching document count: $e");
    }
  }

  final List<ChartData> chartData = [
    ChartData('ມາວຽກ', 90, Colors.blueAccent),
    ChartData('ມາຊ້າ', 10, Colors.orange),
    ChartData('ຂາດວຽກ', 30, Colors.pink),
  ];
  final List<ChartDataPie> chartDataPie = [
    ChartDataPie('ມາວຽກ', 90, Colors.blueAccent),
    ChartDataPie('ມາຊ້າ', 10, Colors.orange),
    ChartDataPie('ຂາດວຽກ', 30, Colors.pink),
    ChartDataPie('ລາພັກ', 30, Colors.cyanAccent),
  ];
  DateTime _selectedMonth = DateTime.now();
  String _month = DateFormat('MMMM').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 10, right: 16, left: 16, bottom: 16),
                decoration: const BoxDecoration(
                    color: Color(0xFF577DF4),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15))),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: const CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              backgroundImage: AssetImage('assets/profile.jpg'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Hi ADMIN!",
                          style: GoogleFonts.notoSansLao(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        IconButton(
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const SettingsStystem()));
                          },
                          icon: const FaIcon(FontAwesomeIcons.sliders),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                "Document TimeSabai",
                                style: GoogleFonts.notoSansLao(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "The application is saved in the logbook of faculty of engineering",
                                style: GoogleFonts.notoSansLao(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Image.asset('assets/folder.png'),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              Stack(
                alignment: Alignment.center,
                children: [
                  // Circular Chart
                  Center(
                    child: SizedBox(
                      height: 280,
                      width: 280,
                      child: SfCircularChart(
                        margin: EdgeInsets.zero,
                        series: <CircularSeries>[
                          RadialBarSeries<ChartData, String>(
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.category,
                            yValueMapper: (ChartData data, _) => data.value,
                            pointColorMapper: (ChartData data, _) => data.color,
                            trackColor:
                                Colors.grey.shade200, // Background track
                            cornerStyle: CornerStyle.bothCurve,
                            gap: '10%',
                            innerRadius:
                                '50%', // Creates space for the profile image
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Profile Image
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/profile.jpg'), // Replace with your image
                  ),
                ],
              ),

              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: chartData.map((data) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: data.color, size: 14),
                          SizedBox(width: 6),
                          Text(
                            data.category,
                            style: GoogleFonts.notoSansLao(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Colors.grey.shade200,
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'ມາປະຈໍາການແລະການລາພັກ',
                      style: GoogleFonts.notoSansLao(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await SimpleMonthYearPicker
                              .showMonthYearPickerDialog(
                            context: context,
                            titleTextStyle: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1230AE),
                              ),
                            ),
                            monthTextStyle: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1230AE),
                              ),
                            ),
                            yearTextStyle: GoogleFonts.notoSansLao(
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1230AE),
                              ),
                            ),
                            disableFuture: true,
                          );

                          if (picked != null && picked != _selectedMonth) {
                            setState(() {
                              _selectedMonth = picked;
                            });
                            countMonthLeaves(picked);
                            countMonthRecords(
                                picked); // Fetch records count for the selected month
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFF577DF4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month,
                                  color: Colors.white),
                              Text(
                                " ${_month.isEmpty ? "ເລືອກເດືອນ" : _month}",
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // Text(
                    //   'ມາການເດືອນ ${_selectedMonth != null ? DateFormat('MMMM yyyy').format(_selectedMonth!) : "ເລືອກເດືອນ"}: $recordMonthCount/ຄົນ',
                    //   style: GoogleFonts.notoSansLao(
                    //     fontSize: 15,
                    //     color: Colors.blueAccent.shade400,
                    //   ),
                    // ),
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.notoSansLao(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        text:
                            'ມາການເດືອນ ${_selectedMonth != null ? DateFormat('MMMM yyyy').format(_selectedMonth!) : "ເລືອກເດືອນ"}',
                        children: [
                          TextSpan(
                              text: ' :$recordMonthCount/ຄົນ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: 20,
                                color: Colors.blueAccent.shade400,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.notoSansLao(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        text:
                            'ລາພັກເດືອນ ${_selectedMonth != null ? DateFormat('MMMM yyyy').format(_selectedMonth!) : "ເລືອກເດືອນ"}',
                        children: [
                          TextSpan(
                              text: ' :$leaveMonthCount/ຄົນ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: 20,
                                color: Colors.blueAccent.shade400,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Center(
                    child: SizedBox(
                      height: 250,
                      width: 250,
                      child: SfCircularChart(
                        series: <CircularSeries>[
                          PieSeries<ChartDataPie, String>(
                            dataSource: chartDataPie,
                            xValueMapper: (ChartDataPie data, _) =>
                                data.category,
                            yValueMapper: (ChartDataPie data, _) => data.value,
                            pointColorMapper: (ChartDataPie data, _) =>
                                data.color,
                            dataLabelMapper: (ChartDataPie data, _) =>
                                data.category, // แสดงแค่ชื่อ
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition
                                  .outside, // ให้อยู่นอกวงกลม
                              connectorLineSettings: ConnectorLineSettings(
                                width: 1.5,
                                type: ConnectorType.line,
                              ),
                              textStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            explode: true, // ทำให้บางชิ้นแยกออก
                            explodeIndex: 1, // ชิ้นที่ 3 จะแยกออก
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ມາການວັນນີ້: $recordCount',
                        style: GoogleFonts.notoSansLao(
                            fontSize: 15, color: Colors.blueAccent),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'ລາພັກວັນນີ້: $leaveCount',
                        style: GoogleFonts.notoSansLao(
                            fontSize: 15, color: Colors.redAccent),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'ມາວຽກຊ້າວັນນີ້: $leaveMonthCount',
                        style: GoogleFonts.notoSansLao(
                            fontSize: 15, color: Colors.orangeAccent.shade400),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'ຂາດວຽກວັນນີ້: $leaveMonthCount',
                        style: GoogleFonts.notoSansLao(
                            fontSize: 15, color: Colors.brown.shade400),
                      ),
                    ],
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'ຈັດການຂໍ້ມູນ',
                  style: GoogleFonts.notoSansLao(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                padding: const EdgeInsets.all(10),
                children: [
                  for (int i = 0; i < folders.length; i++)
                    InkWell(
                      onTap: () {
                        if (i == 0) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EmployeeScreens()));
                        } else if (i == 1) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DepartmentScreens()));
                        } else if (i == 2) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => BranchScreens()));
                        } else if (i == 3) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PositionScreens()));
                        } else if (i == 4) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EmployeeLeaveSerceen()));
                        } else if (i == 5) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => UsersOrdersScreen()));
                        } else if (i == 6) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AgenciesScreens()));
                        } else if (i == 7) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EthnicityScreens()));
                        } else if (i == 8) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProvinceScreens()));
                        } else if (i == 9) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DistrictsScreens()));
                        } else if (i == 10) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => TypeLeaveScreens()));
                        } else if (i == 11) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => UserScreens()));
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: HexColor('${folders[i].colors}')
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "ຈໍານວນ ${folders[i].storage}",
                                    style: GoogleFonts.notoSansLao(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  "${folders[i].folderName}",
                                  style: GoogleFonts.notoSansLao(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: HexColor('${folders[i].colors}'),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.folder,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String category;
  final double value;
  final Color color;
  ChartData(this.category, this.value, this.color);
}

class ChartDataPie {
  final String category;
  final double value;
  final Color color;

  ChartDataPie(this.category, this.value, this.color);

  // Calculate percentage based on total value
  double percentage(List<ChartDataPie> dataList) {
    double total = dataList.fold(0, (sum, item) => sum + item.value);
    return (value / total) * 100;
  }
}
