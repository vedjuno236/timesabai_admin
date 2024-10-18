
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/folder.dart';
import '../branch_screens/branch_screens.dart';
import '../department_screens/department_screens.dart';
import '../employee_screens/employee_screens.dart';
import '../leave_screens/employee_leave_serceen.dart';
import '../leave_screens/leave_screens.dart';
import '../position_screens/position_screens.dart';
import '../record_screens/employee_records_serceen.dart';
import '../record_screens/record_screens.dart';


class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  String urlProfile = "https://gratisography.com/wp-content/uploads/2023/10/gratisography-cool-cat-800x525.jpg";

  List<Folder> folders = [
    Folder(folderName: 'ຈັດການຂໍ້ມູນອາຈານ', storage: '0', colors: '#3a86ff'), // Set initial storage to '0'
    Folder(folderName: 'ຈັດການຂໍ້ມູນພາກວິຊາ', storage: '0', colors: '#2ec4b6'),
    Folder(folderName: 'ຈັດການຂໍ້ມູນສາຂາ', storage: '0', colors: '#ffbe0b'),
    Folder(folderName: 'ຈັດການຂໍ້ມູນຕໍາແໜ່ງ', storage: '0', colors: '#25D162'),
    Folder(folderName: 'ຂໍ້ມູນລາພັກ', storage: '0', colors: '#fb5607'),
    Folder(folderName: 'ຂໍ້ມູນມາປະຈໍາການ', storage: '0', colors: '#193940'),
  ];

  int EmployeeCount = 0;
  int DepartmentCount = 0;
  int BranchCount =0;
  int PositionCount=0;
  int LeaveCount =0;
  int RecordCount =0;

  @override
  void initState() {
    super.initState();
    fetchEmployeeCount();
    fetchDepartmentCount();
    fetchBranchCount();
    fetchPositionCount();
    countTodayLeave();
    countTodayRecord();

  }

  void countTodayLeave() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfToday = DateTime(today.year, today.month, today.day);
      DateTime endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);


      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('Leave')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfToday))
          .get();

      setState(() {
        LeaveCount = snapshot.size;
        folders[4].storage = LeaveCount.toString();
      });
    } catch (e) {
      print("Error fetching the records count: $e");
    }
  }

  void countTodayRecord() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfToday = DateTime(today.year, today.month, today.day);
      DateTime endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('Record')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfToday))
          .get();

      setState(() {
        // RecordCount = snapshot.size;
        // folders[5].storage = RecordCount.toString();
        int RecordCount = snapshot.size;
        String message = 'ວັນນີ້/$RecordCount';
        folders[5].storage = message;
      });
    } catch (e) {
      print("Error fetching the records count: $e");
    }
  }




  Future<void> fetchEmployeeCount() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Employee').get();
      setState(() {
        int employeeCount = snapshot.size;
        String message = '$employeeCount';
        folders[0].storage = message;
      });
    } catch (e) {
      print("Error fetching document count: $e");
    }
  }


  Future<void> fetchDepartmentCount() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Department').get();
      setState(() {
        DepartmentCount = snapshot.size;
        folders[1].storage = DepartmentCount.toString(); // Update folder storage
      });
    } catch (e) {
      print("Error fetching document count: $e");
    }
  }


  Future<void> fetchBranchCount() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Branch').get();
      setState(() {
        BranchCount = snapshot.size;
        folders[2].storage = BranchCount.toString(); // Update folder storage
      });
    } catch (e) {
      print("Error fetching document count: $e");
    }
  }

  Future<void> fetchPositionCount() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Position').get();
      setState(() {
        PositionCount = snapshot.size;
        folders[3].storage = PositionCount.toString(); // Update folder storage
      });
    } catch (e) {
      print("Error fetching document count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, right: 16, left: 16, bottom: 16),
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(urlProfile),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Hi ADMIN!",
                        style: GoogleFonts.notoSansLao(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
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
                              "Document TimeSabi",
                              style: GoogleFonts.notoSansLao(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "The application is saved in the logbook of faculty of engineering",
                              style: GoogleFonts.notoSansLao(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
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
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the GridView
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: const EdgeInsets.all(20),
              children: [
                for (int i = 0; i < folders.length; i++)
                  InkWell(
                    onTap: () {
                      // Modify the navigation logic based on the folder tapped
                      if (i == 0) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => EmployeeScreens()));
                      } else if (i == 1) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DepartmentScreens()));
                      } else if (i == 2) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => BranchScreens()));
                      } else if (i == 3) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => PositionScreens()));
                      } else if (i == 4) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => EmployeeLeaveSerceen()));
                      } else if (i == 5) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => UsersOrdersScreen()));
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: HexColor('${folders[i].colors}').withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "ຈໍານວນ ${folders[i].storage}",
                                  style: GoogleFonts.notoSansLao(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                "${folders[i].folderName}",
                                style: GoogleFonts.notoSansLao(fontSize: 18, fontWeight: FontWeight.w600),
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
    );
  }
}
