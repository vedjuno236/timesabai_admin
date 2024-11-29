import 'package:admin_timesabai/views/users_views/screens/ethnicity_screens/ethnicity_screens.dart';
import 'package:admin_timesabai/views/users_views/screens/provinces_screens/provinces_screens.dart';
import 'package:admin_timesabai/views/users_views/screens/settings/settings_stystem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
  String urlProfile =
      "https://img.freepik.com/premium-photo/cartoon-avatar-auditor-perfect-your-profile-picture-messaging-apps-fun_1283595-16543.jpg?w=1380";

  List<Folder> folders = [
    Folder(folderName: 'ຈັດການຂໍ້ມຸນອາຈານ', storage: '0', colors: '#3a86ff'),
    Folder(folderName: 'ຈັດການຂໍ້ມຸນພາກວິຊາ', storage: '0', colors: '#2ec4b6'),
    Folder(folderName: 'ຈັດການຂໍ້ມຸນສາຂາ', storage: '0', colors: '#ffbe0b'),
    Folder(folderName: 'ຈັດການຂໍ້ມຸນຕໍາແໜ່ງ', storage: '0', colors: '#25D162'),
    Folder(folderName: 'ຂໍ້ມຸນລາພັກ', storage: '0', colors: '#fb5607'),
    Folder(folderName: 'ຂໍ້ມຸນມາປະຈໍາການ', storage: '0', colors: '#577DF4'),
    Folder(folderName: 'ຈັດການຂໍ້ມຸນພະແນກ', storage: '0', colors: '#FFBFA9'),
    Folder(folderName: 'ຈັດການຂໍ້ມຸນຊົນເຜົ່າ', storage: '0', colors: '#424769'),
    Folder(folderName: 'ຈັດການຂໍ້ມຸນແຂວງ', storage: '0', colors: '#F3CCFF'),
    Folder(folderName: 'ຈັດການຂໍ້ມຸນເມືອງ', storage: '0', colors: '#8B5DFF'),
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
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(urlProfile),
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
                        Spacer(),
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
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                padding: const EdgeInsets.all(8),
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
                                      fontSize: 18,
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
                              size: 30,
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
