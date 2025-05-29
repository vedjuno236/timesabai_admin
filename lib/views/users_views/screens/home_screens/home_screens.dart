import 'package:admin_timesabai/components/logging.dart';
import 'package:admin_timesabai/views/users_views/screens/ethnicity_screens/ethnicity_screens.dart';
import 'package:admin_timesabai/views/users_views/screens/notification/notification_screens.dart';
import 'package:admin_timesabai/views/users_views/screens/provinces_screens/provinces_screens.dart';
import 'package:admin_timesabai/views/users_views/screens/settings/settings_stystem.dart';
import 'package:admin_timesabai/views/users_views/screens/type_leave/type_leave.dart';
import 'package:admin_timesabai/views/users_views/screens/user_screens/user_screens.dart';
import 'package:admin_timesabai/views/widget/date_month_year/shared/month_picker.dart';
import 'package:admin_timesabai/views/widget/loading_platform/loading.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
  List<Folder> filteredFolders = [];
  String userRole = '';
  String leaveMessage = 'ກໍາລັງໂຫລດຂໍ້ມູນ...';
  String recordlateMessage = 'ກໍາລັງໂຫລດຂໍ້ມູນ...';
  @override
  void initState() {
    super.initState();
    fetchUserRole();
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
    countrecordMonthCountLate(_selectedMonth!);
    countMonthLeaves(_selectedMonth!);
    DateTime now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    countMonthRecords(_selectedMonth!);
    fetchLeaveNames();
    fetchRecordLateNames();
  }

  bool isLoading = true;
  void fetchUserRole() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        setState(() {
          isLoading = false;
          filteredFolders = folders;
        });
        return;
      }

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (documentSnapshot.exists) {
        if (documentSnapshot.data() != null &&
            (documentSnapshot.data() as Map<String, dynamic>)
                .containsKey('rool')) {
          setState(() {
            userRole = documentSnapshot.get('rool') ?? '';
            if (userRole == 'ຄະນະບໍດີ') {
              filteredFolders = folders.where((folder) {
                return folder.folderName == 'ຂໍ້ມູນລາພັກ' ||
                    folder.folderName == 'ຈັດການຂໍ້ມູນຜູ້ໃຊ້ລະບົບ' ||
                    folder.folderName == 'ຂໍ້ມູນມາປະຈໍາການ';
              }).toList();
            } else {
              filteredFolders = folders;
            }
            isLoading = false;
          });
        } else {
       
          setState(() {
            userRole = '';
            filteredFolders = folders;
            isLoading = false;
          });
          print('Field "role" does not exist in the document');
        }
      } else {
        setState(() {
          isLoading = false;
          filteredFolders = folders;
        });
        print('Document does not exist in the database');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        filteredFolders = folders;
      });
      print('Error fetching user role: $e');
    }
  }

  void fetchLeaveNames() async {
    String message = await getTodayLeaveNames();
    setState(() {
      leaveMessage = message;
    });
  }

  Future<String> fetchRecordLateNames() async {
    String message = await getLateUserNamesToday();
    setState(() {
      recordlateMessage = message;
    });
    return message;
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

      // เพิ่ม debug information
      print('Today: ${today}');
      print('Checking leave records...');

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collectionGroup('Leave').get();

      List<String> leaveNames = [];
      List<Map<String, dynamic>> leaveDetails =
          []; // เก็บรายละเอียดสำหรับ debug

      print('Total documents found: ${snapshot.docs.length}');

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Debug: แสดงข้อมูลแต่ละ document
        print('Document data: ${data}');

        if (data['fromDate'] != null &&
            data['toDate'] != null &&
            data['name'] != null) {
          Timestamp fromTimestamp = data['fromDate'] as Timestamp;
          Timestamp toTimestamp = data['toDate'] as Timestamp;

          DateTime fromDate = fromTimestamp.toDate();
          DateTime toDate = toTimestamp.toDate();

          // แปลงเป็นวันที่เฉพาะ (ไม่นับเวลา)
          DateTime fromDateOnly =
              DateTime(fromDate.year, fromDate.month, fromDate.day);
          DateTime toDateOnly = DateTime(toDate.year, toDate.month, toDate.day);
          DateTime todayOnly = DateTime(today.year, today.month, today.day);

          print(
              'Comparing: Today=$todayOnly, From=$fromDateOnly, To=$toDateOnly');

          // ตรวจสอบว่าวันนี้อยู่ในช่วงการลาหรือไม่
          // วันนี้ต้องอยู่ระหว่าง fromDate และ toDate (รวมทั้งสองวัน)
          bool isOnLeaveToday = (todayOnly.isAtSameMomentAs(fromDateOnly) ||
                  todayOnly.isAfter(fromDateOnly)) &&
              (todayOnly.isAtSameMomentAs(toDateOnly) ||
                  todayOnly.isBefore(toDateOnly));

          print('Is on leave today: $isOnLeaveToday');

          if (isOnLeaveToday) {
            String name = data['name'] as String;

            print('Found leave: $name from $fromDateOnly to $toDateOnly');

            if (!leaveNames.contains(name)) {
              leaveNames.add(name);
              leaveDetails.add({
                'name': name,
                'fromDate': fromDateOnly,
                'toDate': toDateOnly,
                'leaveType': data['leaveType'] ?? 'N/A',
                'status': data['status'] ?? 'N/A'
              });
            }
          }
        } else {
          print('Missing required fields in document: ${doc.id}');
        }
      }

      setState(() {
        leaveCount = leaveNames.length;
      });

      // แสดงผลลัพธ์สุดท้าย
      print('=== FINAL RESULT ===');
      print('Total people on leave today: ${leaveNames.length}');
      print('Names: ${leaveNames.join(", ")}');
      print('Details: $leaveDetails');
    } catch (e) {
      print("Error fetching leave names: $e");

      setState(() {
        leaveCount = 0;
      });
    }
  }

  void countTodayLeave() async {
    try {
      DateTime today = DateTime.now();

      // เพิ่ม debug information
      print('Today: ${today}');
      print('Checking leave records...');

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collectionGroup('Leave').get();

      List<String> leaveNames = [];
      List<Map<String, dynamic>> leaveDetails =
          []; // เก็บรายละเอียดสำหรับ debug

      print('Total documents found: ${snapshot.docs.length}');

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Debug: แสดงข้อมูลแต่ละ document
        print('Document data: ${data}');

        if (data['fromDate'] != null &&
            data['toDate'] != null &&
            data['name'] != null) {
          Timestamp fromTimestamp = data['fromDate'] as Timestamp;
          Timestamp toTimestamp = data['toDate'] as Timestamp;

          DateTime fromDate = fromTimestamp.toDate();
          DateTime toDate = toTimestamp.toDate();

          // แปลงเป็นวันที่เฉพาะ (ไม่นับเวลา)
          DateTime fromDateOnly =
              DateTime(fromDate.year, fromDate.month, fromDate.day);
          DateTime toDateOnly = DateTime(toDate.year, toDate.month, toDate.day);
          DateTime todayOnly = DateTime(today.year, today.month, today.day);

          print(
              'Comparing: Today=$todayOnly, From=$fromDateOnly, To=$toDateOnly');

          // ตรวจสอบว่าวันนี้อยู่ในช่วงการลาหรือไม่
          // วันนี้ต้องอยู่ระหว่าง fromDate และ toDate (รวมทั้งสองวัน)
          bool isOnLeaveToday = (todayOnly.isAtSameMomentAs(fromDateOnly) ||
                  todayOnly.isAfter(fromDateOnly)) &&
              (todayOnly.isAtSameMomentAs(toDateOnly) ||
                  todayOnly.isBefore(toDateOnly));

          print('Is on leave today: $isOnLeaveToday');

          if (isOnLeaveToday) {
            String name = data['name'] as String;

            print('Found leave: $name from $fromDateOnly to $toDateOnly');

            if (!leaveNames.contains(name)) {
              leaveNames.add(name);
              leaveDetails.add({
                'name': name,
                'fromDate': fromDateOnly,
                'toDate': toDateOnly,
                'leaveType': data['leaveType'] ?? 'N/A',
                'status': data['status'] ?? 'N/A'
              });
            }
          }
        } else {
          print('Missing required fields in document: ${doc.id}');
        }
      }

      setState(() {
        int leaveCount = leaveNames.length;
        String message = 'ວັນນີ້: $leaveCount ຄົນ';
        folders[4].storage = message;
      });

      // แสดงผลลัพธ์สุดท้าย
      print('=== FINAL RESULT ===');
      print('Total people on leave today: ${leaveNames.length}');
      print('Names: ${leaveNames.join(", ")}');
      print('Details: $leaveDetails');
    } catch (e) {
      print("Error fetching leave names: $e");

      setState(() {
        folders[4].storage = 'ເກີດຂໍ້ຜິດພາດ';
      });
    }
  }

  Future<String> getTodayLeaveNames() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfToday = DateTime(today.year, today.month, today.day);
      DateTime endOfToday =
          DateTime(today.year, today.month, today.day, 23, 59, 59);

      // เพิ่ม debug information
      print('Today: ${today}');
      print('Checking leave records...');

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collectionGroup('Leave').get();

      List<String> leaveNames = [];

      print('Total documents found: ${snapshot.docs.length}');
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['fromDate'] != null &&
            data['toDate'] != null &&
            data['name'] != null) {
          Timestamp fromTimestamp = data['fromDate'] as Timestamp;
          Timestamp toTimestamp = data['toDate'] as Timestamp;

          DateTime fromDate = fromTimestamp.toDate();
          DateTime toDate = toTimestamp.toDate();

          DateTime fromDateOnly =
              DateTime(fromDate.year, fromDate.month, fromDate.day);
          DateTime toDateOnly = DateTime(toDate.year, toDate.month, toDate.day);
          DateTime todayOnly = DateTime(today.year, today.month, today.day);

          if ((todayOnly.isAtSameMomentAs(fromDateOnly) ||
                  todayOnly.isAfter(fromDateOnly)) &&
              (todayOnly.isAtSameMomentAs(toDateOnly) ||
                  todayOnly.isBefore(toDateOnly))) {
            print(
                'Found leave: ${data['name']} from ${fromDateOnly} to ${toDateOnly}');

            String name = data['name'] as String;
            if (!leaveNames.contains(name)) {
              leaveNames.add(name);
            }
          }
        }
      }

      String message = leaveNames.isEmpty
          ? 'ວັນນີ້ບໍ່ມີພະນັກງານລາພັກ'
          : 'ພະນັກງານທີ່ພັກວັນນີ້: ${leaveNames.join(", ")}';

      print(message);
      return message;
    } catch (e) {
      print("Error fetching leave names: $e");
      return 'ເກີດຂໍ້ຜິດພາດໃນການດຶງຂໍ້ມູນ';
    }
  }

  Future<String> getLateUserNamesToday() async {
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

      List<String> lateUserNames = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status']?.toString().trim();

        if (status == 'ມາວຽກຊ້າ') {
          final parentId = doc.reference.parent.parent?.id;

          if (parentId != null) {
            final userDoc = await FirebaseFirestore.instance
                .collection('Employee')
                .doc(parentId)
                .get();

            final name = userDoc.data()?['name'] ?? 'ບໍ່ຮູ້ຊື່';
            lateUserNames.add(name);
          }
        }
      }

      String message = lateUserNames.isEmpty
          ? 'ວັນນີ້ບໍ່ມີພະນັກງານມາຊ້າ'
          : 'ພະນັກງານທີ່ມາຊ້າວັນນີ້: ${lateUserNames.join(", ")}';

      logger.d("ผู้ที่มาทำงานช้า: $lateUserNames");
      return message;
    } catch (e) {
      print("Error fetching late users: $e");
      return "Error fetching data";
    }
  }

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
        recordMonthCount = snapshot.size;
      });
    } catch (e) {
      print("Error fetching records count: $e");
    }
  }

  int recordMonthCountLate = 0;

  Future<void> countrecordMonthCountLate(DateTime selectedMonth) async {
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
          // .where('status', isEqualTo: 'ມາວຽກຊ້າ')
          .get();

      int lateCount = 0;

      for (var doc in snapshot.docs) {
        final status = doc['status']?.toString().trim();
        if (status == 'ມາວຽກຊ້າ') {
          lateCount++;
        } else {
          print("พบ status ที่ไม่ตรง: '$status'");
        }
      }
      setState(() {
        recordMonthCountLate = lateCount;

        logger.d(recordMonthCountLate);
      });
    } catch (e) {
      print("Error fetching late records count: $e");
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
        recordCount = snapshot.size;
      });
    } catch (e) {
      print("Error fetching the records count: $e");
    }
  }

  int lateCount = 0;
  void countTodayLateRecords() async {
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
          .where('status', isEqualTo: 'ມາວຽກຊ້າ')
          .get();

      setState(() {
        lateCount = snapshot.size;
      });

      print('Late records today: ${snapshot.size}');
    } catch (e) {
      print("Error fetching late records count: $e");
      setState(() {
        lateCount = 0;
      });
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

  List<ChartData> getChartData() {
    return [
      ChartData('ມາວຽກ', recordCount.toDouble(), Colors.blueAccent),
      ChartData('ມາຊ້າ', lateCount.toDouble(), Colors.orange),
      ChartData('ລາພັກ', leaveCount.toDouble(), Colors.cyan),
    ];
  }

  List<ChartDataPie> getchartDataPie() {
    return [
      ChartDataPie('ມາວຽກ', recordMonthCount.toDouble(), Colors.blueAccent),
      ChartDataPie('ມາຊ້າ', recordMonthCountLate.toDouble(), Colors.orange),
      ChartDataPie('ລາພັກ', leaveMonthCount.toDouble(), Colors.cyan),
    ];
  }

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
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Lottie.asset(
                              'assets/svg/profile.json',
                              width: 150,
                              height: 150,
                            ),
                            const CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.transparent,
                                backgroundImage:
                                    AssetImage('assets/profile.jpg'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 5),
                        FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: LoadingPlatformV2());
                            }

                            if (snapshot.hasError) {
                              return Center(child: Text('ເກີດຂໍ້ຜິດພາດ'));
                            }

                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return Center(child: Text('ບໍ່ມີຂໍ້ມູນ'));
                            }

                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi ${data['rool'] ?? ''}',
                                  style: GoogleFonts.notoSansLao(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            );
                          },
                        ),
                        const Spacer(),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationScreens()));
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: badges.Badge(
                                  position: badges.BadgePosition.topEnd(
                                      top: 0, end: 0),
                                  child: FaIcon(FontAwesomeIcons.bell)),
                            ),
                          ),
                        ),
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
                          child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsStystem()));
                              },
                              child: Image.asset('assets/folder.png')),
                        ),
                      ],
                    )
                  ],
                ),
              ).animate().scaleXY(
                  begin: 0,
                  end: 1,
                  delay: 300.ms,
                  duration: 300.ms,
                  curve: Curves.easeInOutCubic),

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
                            dataSource: getChartData(), // Use the method here
                            xValueMapper: (ChartData data, _) => data.category,
                            yValueMapper: (ChartData data, _) => data.value,
                            pointColorMapper: (ChartData data, _) => data.color,
                            trackColor: Colors.grey.shade200,
                            cornerStyle: CornerStyle.bothCurve,
                            gap: '10%',
                            innerRadius: '50%',
                          ),
                        ],
                      ),
                    ),
                  ).animate().scaleXY(
                      begin: 0,
                      end: 1,
                      delay: 300.ms,
                      duration: 300.ms,
                      curve: Curves.easeInOutCubic),
                  // Profile Image
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset(
                        'assets/svg/profile.json',
                        width: 140,
                        height: 140,
                      ),
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage('assets/profile.jpg'),
                      ).animate().scaleXY(
                          begin: 0,
                          end: 1,
                          delay: 300.ms,
                          duration: 300.ms,
                          curve: Curves.easeInOutCubic),
                    ],
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
                    children: getChartData().map((data) {
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
              ).animate().scaleXY(
                  begin: 0,
                  end: 1,
                  delay: 300.ms,
                  duration: 300.ms,
                  curve: Curves.easeInOutCubic),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Colors.grey.shade200,
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Column(
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
                      'ມາວຽກຊ້າວັນນີ້: $lateCount',
                      style: GoogleFonts.notoSansLao(
                          fontSize: 15, color: Colors.deepOrange),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'ລາພັກວັນນີ້: $leaveCount',
                      style: GoogleFonts.notoSansLao(
                          fontSize: 15, color: Colors.orange),
                    ),
                  ],
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
                                    selectedCellTextStyle:
                                        GoogleFonts.notoSansLao(
                                      fontSize: 14,
                                    ),
                                    enabledCellsTextStyle:
                                        GoogleFonts.notoSansLao(
                                      fontSize: 14,
                                    ),
                                    disabledCellsTextStyle:
                                        GoogleFonts.notoSansLao(
                                            fontSize: 14, color: Colors.grey),
                                    currentDateTextStyle:
                                        GoogleFonts.notoSansLao(
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
                                    currentDate:
                                        _selectedMonth ?? DateTime.now(),
                                    selectedDate:
                                        _selectedMonth ?? DateTime.now(),
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
                                        });
                                        countMonthLeaves(tempSelectedMonth!);
                                        countMonthRecords(tempSelectedMonth!);
                                        countrecordMonthCountLate(
                                            tempSelectedMonth!);
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
              ).animate().scaleXY(
                  begin: 0,
                  end: 1,
                  delay: 300.ms,
                  duration: 300.ms,
                  curve: Curves.easeInOutCubic),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                color: Colors.cyan,
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
                            'ມາວຽກຊ້າ ${_selectedMonth != null ? DateFormat('MMMM yyyy').format(_selectedMonth!) : "ເລືອກເດືອນ"}',
                        children: [
                          TextSpan(
                              text: ' :$recordMonthCountLate/ຄົນ',
                              style: GoogleFonts.notoSansLao(
                                fontSize: 20,
                                color: Colors.orange,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().scaleXY(
                  begin: 0,
                  end: 1,
                  delay: 300.ms,
                  duration: 300.ms,
                  curve: Curves.easeInOutCubic),
              Center(
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      PieSeries<ChartDataPie, String>(
                        dataSource: getchartDataPie(), // Call the method here
                        xValueMapper: (ChartDataPie data, _) => data.category,
                        yValueMapper: (ChartDataPie data, _) => data.value,
                        pointColorMapper: (ChartDataPie data, _) => data.color,
                        dataLabelMapper: (ChartDataPie data, _) =>
                            data.category,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                          connectorLineSettings: ConnectorLineSettings(
                            width: 1.5,
                            type: ConnectorType.line,
                          ),
                          textStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        explode: true,
                        explodeIndex: 1,
                      ),
                    ],
                  ),
                ),
              ).animate().scaleXY(
                  begin: 0,
                  end: 1,
                  delay: 300.ms,
                  duration: 300.ms,
                  curve: Curves.easeInOutCubic),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Colors.grey.shade200,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ລາຍຊື່ພະນັກງານທີລາພັກວັນນີ້',
                      style: GoogleFonts.notoSansLao(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      leaveMessage,
                      style: GoogleFonts.notoSansLao(fontSize: 15),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Colors.grey.shade200,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ລາຍຊື່ພະນັກງານທີມາການຊ້າ',
                      style: GoogleFonts.notoSansLao(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      recordlateMessage,
                      style: GoogleFonts.notoSansLao(fontSize: 15),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Colors.grey.shade200,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'ຈັດການຂໍ້ມູນ',
                  style: GoogleFonts.notoSansLao(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              isLoading
                  ? Center(
                      child: LoadingPlatformV2(),
                    )
                  : filteredFolders.isEmpty
                      ? Text('Nodata')
                      : GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.2,
                          padding: const EdgeInsets.all(10),
                          children: [
                            for (int i = 0; i < filteredFolders.length; i++)
                              InkWell(
                                onTap: () {
                                  // if (i == 0) {
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => EmployeeScreens()));
                                  // } else if (i == 1) {
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => DepartmentScreens()));
                                  // } else if (i == 2) {
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => BranchScreens()));
                                  // } else if (i == 3) {
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => const PositionScreens()));
                                  // } else if (i == 4) {
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => const EmployeeLevaeScreen()));
                                  // } else if (i == 5) {
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => EmployeeRecordsSerceen()));
                                  // } else if (i == 6) {
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => AgenciesScreens()));
                                  // } else if (i == 7) {
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => EthnicityScreens()));
                                  // } else if (i == 8) {
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => ProvinceScreens()));
                                  // } else if (i == 9) {
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => DistrictsScreens()));
                                  // } else if (i == 10) {
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => TypeLeaveScreens()));
                                  // } else if (i == 11) {
                                  //   Navigator.of(context).push(MaterialPageRoute(
                                  //       builder: (context) => UserScreens()));
                                  // }

                                  switch (filteredFolders[i].folderName) {
                                    case 'ຈັດການຂໍ້ມູນພະນັກງານ':
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EmployeeScreens()));
                                      break;
                                    case 'ຈັດການຂໍ້ມູນພາກວິຊາ':
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DepartmentScreens()));
                                      break;
                                    case 'ຈັດການຂໍ້ມູນສາຂາ':
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BranchScreens()));
                                      break;
                                    case 'ຈັດການຂໍ້ມູນຕໍາແໜ່ງ':
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const PositionScreens()));
                                      break;
                                    case 'ຂໍ້ມູນລາພັກ':
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const EmployeeLevaeScreen()));
                                      break;
                                    case 'ຂໍ້ມູນມາປະຈໍາການ':
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EmployeeRecordsSerceen()));
                                      break;
                                    case 'ຈັດການຂໍ້ມູນພະແນກ':
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AgenciesScreens()));
                                      break;
                                    case 'ຈັດການຂໍ້ມູນຊົນເຜົ່າ':
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EthnicityScreens()));
                                      break;
                                    case 'ຈັດການຂໍ້ມູນແຂວງ':
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProvinceScreens()));
                                      break;
                                    case 'ຈັດການຂໍ້ມູນເມືອງ':
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DistrictsScreens()));
                                      break;
                                    case 'ຈັດການຂໍ້ມູນປະເພດລາພັກ':
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TypeLeaveScreens()));
                                      break;
                                    case 'ຈັດການຂໍ້ມູນຜູ້ໃຊ້ລະບົບ':
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UserScreens()));
                                      break;
                                    default:
                                      print(
                                          'Unknown folder: ${filteredFolders[i].folderName}');
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "ຈໍານວນ ${filteredFolders[i].storage}",
                                              style: GoogleFonts.notoSansLao(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(height: 32),
                                          Text(
                                            "${filteredFolders[i].folderName}",
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
                                        color: HexColor(
                                            '${filteredFolders[i].colors}'),
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
                        )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 400.ms)
                          .move(
                            begin: const Offset(-16, 0),
                            curve: Curves.easeOutQuad,
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
