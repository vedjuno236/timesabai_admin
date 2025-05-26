// import 'package:admin_timesabai/views/users_views/screens/record_screens/report_day_record.dart';
// import 'package:admin_timesabai/views/users_views/screens/record_screens/report_month_record.dart';
// import 'package:admin_timesabai/views/users_views/screens/record_screens/report_name_records.dart';
// import 'package:admin_timesabai/views/widget/date_month_year/shared/month_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';

// class UsersOrdersScreen extends StatefulWidget {
//   @override
//   _UsersOrdersScreenState createState() => _UsersOrdersScreenState();
// }

// class _UsersOrdersScreenState extends State<UsersOrdersScreen> {
//   String _searchName = '';
//   String _searchQuery = '';
//   bool isSearchClicked = false;
//   DateTime _selectedMonth = DateTime.now(); // To track the selected date
//   String _month = DateFormat('MMMM').format(DateTime.now());
//   DateTime _selectedDate = DateTime.now(); // To track the selected date
//   String _day = DateFormat('dd').format(DateTime.now());
//   bool _isMonthSelected = false;

//   final List<Color> colors = [
//     Color(0xFF5AD1fA),
//     Color(0xFF836FF0),
//     Color(0XFF1AC286),
//     Color(0XFFF984BC)
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF577DF4),
//         title: isSearchClicked
//             ? Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: TextField(
//                   onChanged: (value) {
//                     setState(() {
//                       _searchName = value.toLowerCase();
//                     });
//                   },
//                   decoration: InputDecoration(
//                     contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
//                     hintStyle: GoogleFonts.notoSansLao(
//                       textStyle: const TextStyle(
//                         color: Colors.black, // You can set the color here
//                       ),
//                     ),
//                     border: InputBorder.none,
//                     hintText: 'ຄົ້ນຫາຊື່ພະນັກງານ...',
//                   ),
//                 ),
//               )
//             : Text(
//                 'ຂໍ້ມູນມາປະຈໍາການ',
//                 style: GoogleFonts.notoSansLao(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white),
//               ).animate().scaleXY(
//                 begin: 0,
//                 end: 1,
//                 delay: 500.ms,
//                 duration: 500.ms,
//                 curve: Curves.easeInOutCubic),
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () {
//               setState(() {
//                 isSearchClicked = !isSearchClicked;
//               });
//             },
//             icon: Icon(isSearchClicked ? Icons.close : Icons.search),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: GestureDetector(
//                     onTap: () async {
//                       showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           DateTime now = DateTime.now();
//                           DateTime maxDate =
//                               DateTime(now.year, now.month + 1, 0);
//                           DateTime? tempSelectedMonth = _selectedMonth;
//                           return AlertDialog(
//                             elevation: 2,
//                             shadowColor: Colors.blue,
//                             backgroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15.0),
//                             ),
//                             content: SizedBox(
//                               height: 300,
//                               width: 450,
//                               child: MonthPicker(
//                                 selectedCellDecoration: const BoxDecoration(
//                                   color: Colors.blue,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 selectedCellTextStyle: GoogleFonts.notoSansLao(
//                                   fontSize: 14,
//                                 ),
//                                 enabledCellsTextStyle: GoogleFonts.notoSansLao(
//                                   fontSize: 14,
//                                 ),
//                                 disabledCellsTextStyle: GoogleFonts.notoSansLao(
//                                     fontSize: 14, color: Colors.grey),
//                                 currentDateTextStyle: GoogleFonts.notoSansLao(
//                                   fontSize: 14,
//                                 ),
//                                 currentDateDecoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     width: 1,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 splashColor: Colors.blue,
//                                 slidersColor: Colors.black,
//                                 centerLeadingDate: true,
//                                 minDate: DateTime(2000),
//                                 currentDate: _selectedMonth ?? DateTime.now(),
//                                 selectedDate: _selectedMonth ?? DateTime.now(),
//                                 onDateSelected: (month) {
//                                   setState(() {
//                                     tempSelectedMonth = month;
//                                   });
//                                 },
//                                 maxDate: maxDate,
//                               ),
//                             ),
//                             actions: [
//                               ElevatedButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   style: ElevatedButton.styleFrom(
//                                     elevation: 0,
//                                     backgroundColor: Colors.grey,
//                                   ),
//                                   child: Text('ຍົກເລີກ',
//                                       style: GoogleFonts.notoSansLao(
//                                         textStyle: const TextStyle(
//                                           fontSize: 15,
//                                           color: Colors.black,
//                                         ),
//                                       ))),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   elevation: 0,
//                                   backgroundColor: Colors.blue,
//                                 ),
//                                 onPressed: () {
//                                   if (tempSelectedMonth != null &&
//                                       tempSelectedMonth != _selectedMonth) {
//                                     setState(() {
//                                       _selectedMonth = tempSelectedMonth!;
//                                       _month = DateFormat('MMMM')
//                                           .format(_selectedMonth!);
//                                       _isMonthSelected = true;
//                                     });
//                                   }
//                                   Navigator.pop(context);
//                                 },
//                                 child: Text(
//                                   'ຕົກລົງ',
//                                   style: GoogleFonts.notoSansLao(
//                                     textStyle: const TextStyle(
//                                       fontSize: 15,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             ],
//                           );
//                         },
//                       );
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: Color(0xFF577DF4),
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.calendar_month, color: Colors.white),
//                           Text(
//                             "ເລືອກເດືອນ: ${_month.isEmpty ? "ເລືອກເດືອນ" : _month}",
//                             style: GoogleFonts.notoSansLao(
//                               textStyle: const TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: GestureDetector(
//                     onTap: () {
//                       showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             DateTime now = DateTime.now();
//                             DateTime maxDate = DateTime(now.year, now.month + 1,
//                                 0); // Last day of next month
//                             DateTime? tempSelectedDate =
//                                 _selectedDate; // Change variable name to reflect day selection
//                             return AlertDialog(
//                               elevation: 2,
//                               shadowColor: Colors.blue,
//                               backgroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15.0),
//                               ),
//                               content: SizedBox(
//                                 height: 300,
//                                 width: 450,
//                                 child: CalendarDatePicker(
//                                   initialDate: _selectedDate ?? DateTime.now(),
//                                   firstDate: DateTime(2000),
//                                   lastDate: DateTime.now(),
//                                   onDateChanged: (date) {
//                                     setState(() {
//                                       tempSelectedDate = date;
//                                     });
//                                   },
//                                   selectableDayPredicate: (date) {
//                                     // Optional: Customize which days are selectable
//                                     return true;
//                                   },
//                                 ),
//                               ),
//                               actions: [
//                                 ElevatedButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   style: ElevatedButton.styleFrom(
//                                     elevation: 0,
//                                     backgroundColor: Colors.grey,
//                                   ),
//                                   child: Text(
//                                     'ຍົກເລີກ',
//                                     style: GoogleFonts.notoSansLao(
//                                       textStyle: const TextStyle(
//                                         fontSize: 15,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     elevation: 0,
//                                     backgroundColor: Colors.blue,
//                                   ),
//                                   onPressed: () {
//                                     if (tempSelectedDate != null &&
//                                         tempSelectedDate != _selectedDate) {
//                                       setState(() {
//                                         _selectedDate = tempSelectedDate!;
//                                         _day = DateFormat('dd')
//                                             .format(_selectedDate!);
//                                         _isMonthSelected = true;
//                                       });
//                                     }
//                                     Navigator.pop(context);
//                                   },
//                                   child: Text(
//                                     'ຕົກລົງ',
//                                     style: GoogleFonts.notoSansLao(
//                                       textStyle: const TextStyle(
//                                         fontSize: 15,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF577DF4),
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.calendar_month, color: Colors.white),
//                           Text(
//                             "ເລືອກວັນທີ: ${_day.isEmpty ? "ເລືອກວັນທີ" : _day}",
//                             style: GoogleFonts.notoSansLao(
//                               textStyle: const TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ).animate().scaleXY(
//                 begin: 0,
//                 end: 1,
//                 delay: 500.ms,
//                 duration: 500.ms,
//                 curve: Curves.easeInOutCubic),
//             // buildSearchField(),
//             SizedBox(height: 10),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('Employee')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text('No users found.'));
//                   }

//                   final users = snapshot.data!.docs;

//                   return ListView.builder(
//                     itemCount: users.length,
//                     itemBuilder: (context, index) {
//                       final user = users[index].data() as Map<String, dynamic>;
//                       final userId = users[index].id;

//                       if (!_searchName.isEmpty &&
//                           !user['name']
//                               .toString()
//                               .toLowerCase()
//                               .contains(_searchName.toLowerCase())) {
//                         return SizedBox.shrink(); // Skip this user
//                       }

//                       return Card(
//                               elevation: 0,
//                               color: Colors.white,
//                               child: Row(children: [
//                                 Container(
//                                   decoration: BoxDecoration(
//                                       color: colors[index % colors.length],
//                                       borderRadius: const BorderRadius.only(
//                                           topLeft: Radius.circular(12),
//                                           bottomLeft: Radius.circular(12))),
//                                   height: 72,
//                                   width: 15,
//                                 ),
//                                 Expanded(
//                                   child: ExpansionTile(
//                                     title: Text(
//                                       user['name'],
//                                       style: GoogleFonts.notoSansLao(
//                                         textStyle: const TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                     ),
//                                     children: [
//                                       StreamBuilder<QuerySnapshot>(
//                                         stream: FirebaseFirestore.instance
//                                             .collection('Employee')
//                                             .doc(userId)
//                                             .collection('Record')
//                                             .snapshots(),
//                                         builder: (context, orderSnapshot) {
//                                           if (orderSnapshot.connectionState ==
//                                               ConnectionState.waiting) {
//                                             return const Padding(
//                                               padding: EdgeInsets.all(8.0),
//                                               child: Center(
//                                                   child:
//                                                       CircularProgressIndicator()),
//                                             );
//                                           } else if (orderSnapshot.hasError) {
//                                             return Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: Center(
//                                                   child: Text(
//                                                       'Error: ${orderSnapshot.error}')),
//                                             );
//                                           } else if (!orderSnapshot.hasData ||
//                                               orderSnapshot
//                                                   .data!.docs.isEmpty) {
//                                             return Padding(
//                                                 padding: EdgeInsets.all(8.0),
//                                                 child: Center(
//                                                   child: Text(
//                                                     'ບໍ່ມີຂໍໍມູນ.',
//                                                     style:
//                                                         GoogleFonts.notoSansLao(
//                                                       textStyle:
//                                                           const TextStyle(
//                                                         fontSize: 15,
//                                                         color: Colors.black,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ));
//                                           }

//                                           final orders =
//                                               orderSnapshot.data!.docs;
//                                           final filteredOrders =
//                                               orders.where((order) {
//                                             final date =
//                                                 (order['date'] as Timestamp)
//                                                     .toDate();
//                                             if (_isMonthSelected) {
//                                               return date.month ==
//                                                       _selectedMonth.month &&
//                                                   date.year ==
//                                                       _selectedMonth.year;
//                                             } else {
//                                               return date.day ==
//                                                       _selectedDate.day &&
//                                                   date.month ==
//                                                       _selectedDate.month &&
//                                                   date.year ==
//                                                       _selectedDate.year;
//                                             }
//                                           }).toList();
//                                           final searchFilteredOrders =
//                                               filteredOrders.where((order) {
//                                             final status = order['status']
//                                                 .toString()
//                                                 .toLowerCase();
//                                             return status
//                                                 .contains(_searchQuery);
//                                           }).toList();
//                                           print(
//                                               "Filtered orders count: ${filteredOrders.length}");

//                                           return Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               ListView.builder(
//                                                 physics:
//                                                     const NeverScrollableScrollPhysics(),
//                                                 shrinkWrap: true,
//                                                 itemCount:
//                                                     searchFilteredOrders.length,
//                                                 itemBuilder: (context, index) {
//                                                   final record =
//                                                       searchFilteredOrders[
//                                                                   index]
//                                                               .data()
//                                                           as Map<String,
//                                                               dynamic>;

//                                                   print(record);
//                                                   return ExpansionTile(
//                                                     title: Text(
//                                                       "ວັນທີ: ${DateFormat.yMMMMEEEEd().format((record['date'] as Timestamp).toDate())}",
//                                                       style: GoogleFonts
//                                                           .notoSansLao(
//                                                         textStyle:
//                                                             const TextStyle(
//                                                           fontSize: 15,
//                                                           color: Colors.black,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     children: [
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(20.0),
//                                                         child: Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment
//                                                                   .start,
//                                                           children: [
//                                                             Text(
//                                                               'ເວລາເຂົ້າຕອນເຊົ້າ: ${record['clockInAM']}',
//                                                               style: GoogleFonts
//                                                                   .notoSansLao(
//                                                                 fontSize: 15,
//                                                               ),
//                                                             ),
//                                                             const SizedBox(
//                                                                 height: 5),
//                                                             Text(
//                                                               'ເວລາອອກຕອນເຊົ້າ: ${record['clockOutAM']}',
//                                                               style: GoogleFonts
//                                                                   .notoSansLao(
//                                                                 fontSize: 15,
//                                                               ),
//                                                             ),
//                                                             const SizedBox(
//                                                                 height: 5),
//                                                             Text(
//                                                               'ເວລາເຂົ້າຕອນແລງ: ${record['clockInPM']}',
//                                                               style: GoogleFonts
//                                                                   .notoSansLao(
//                                                                 fontSize: 15,
//                                                               ),
//                                                             ),
//                                                             const SizedBox(
//                                                                 height: 5),
//                                                             Text(
//                                                               'ເວລາອອກຕອນແລງ: ${record['clockOutPM']}',
//                                                               style: GoogleFonts
//                                                                   .notoSansLao(
//                                                                 fontSize: 15,
//                                                               ),
//                                                             ),
//                                                             const SizedBox(
//                                                                 height: 5),
//                                                             Text(
//                                                               'ຕໍາແໜ່ງເຂົ້າ: ${record['checkOutLocation']}',
//                                                               style: GoogleFonts
//                                                                   .notoSansLao(
//                                                                 fontSize: 15,
//                                                               ),
//                                                             ),
//                                                             SizedBox(height: 5),
//                                                             Text(
//                                                               'ຕໍາແໜ່ງອອກ: ${record['checkInLocation']}',
//                                                               style: GoogleFonts
//                                                                   .notoSansLao(
//                                                                 fontSize: 15,
//                                                               ),
//                                                             ),
//                                                             SizedBox(height: 5),
//                                                             TextButton(
//                                                               onPressed: () {
//                                                                 print(
//                                                                     'Button pressed');
//                                                               },
//                                                               style: TextButton
//                                                                   .styleFrom(
//                                                                 backgroundColor:
//                                                                     getStatusColor(
//                                                                         record[
//                                                                             'status']),
//                                                                 foregroundColor:
//                                                                     Colors
//                                                                         .white,
//                                                               ),
//                                                               child: Text(
//                                                                 'ສະຖານະ: ${record['status']}',
//                                                                 style: GoogleFonts
//                                                                     .notoSansLao(
//                                                                         fontSize:
//                                                                             15,
//                                                                         color: Colors
//                                                                             .white),
//                                                               ),
//                                                             ),
//                                                             SizedBox(height: 5),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   );
//                                                 },
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ]))
//                           .animate()
//                           .scaleXY(
//                               begin: 0,
//                               end: 1,
//                               delay: 500.ms,
//                               duration: 500.ms,
//                               curve: Curves.easeInOutCubic);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: SpeedDial(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         animatedIconTheme: IconThemeData(size: 22.0),
//         curve: Curves.bounceIn,
//         overlayColor: Colors.white,
//         foregroundColor: Colors.white,
//         elevation: 15.0,
//         icon: Icons.menu,
//         activeIcon: Icons.close,
//         backgroundColor: const Color(0xFF577DF4),
//         children: [
//           SpeedDialChild(
//               child: Icon(Icons.timelapse_sharp, color: Colors.white),
//               label: 'ລາຍງານຂໍ້ມູນລາຍເດືອນ',
//               labelStyle: GoogleFonts.notoSansLao(),
//               elevation: 10,
//               onTap: () async {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ReportMonthRecord(
//                       searchName: _searchName,
//                       monthDate: _selectedMonth,
//                     ),
//                   ),
//                 );
//               },
//               backgroundColor: Colors.yellow),
//           SpeedDialChild(
//               child: Icon(Icons.calendar_month, color: Colors.white),
//               label: 'ລາຍງານຂໍ້ມູນລາຍວັນ',
//               labelStyle: GoogleFonts.notoSansLao(),
//               elevation: 10,
//               onTap: () async {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ReportDayRecord(
//                       searchName: _searchName,
//                       dayDate: _selectedDate,
//                     ),
//                   ),
//                 );
//               },
//               backgroundColor: Colors.orangeAccent),
//           // SpeedDialChild(
//           //     child: const Icon(Icons.perm_identity, color: Colors.white),
//           //     label: 'ລາຍງານຂໍ້ມູນຕາມຊື່',
//           //     labelStyle: GoogleFonts.notoSansLao(),
//           //     elevation: 10,
//           //     onTap: () async {
//           //       Navigator.push(
//           //         context,
//           //         MaterialPageRoute(
//           //           builder: (context) => ReportNameRecord(
//           //             searchName: _searchName,
//           //             monthDate: _selectedMonth,
//           //           ),
//           //         ),
//           //       );
//           //     },
//           //     backgroundColor: Colors.blue),
//         ],
//       ),
//     );
//   }

//   Widget buildSearchField() {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: TextField(
//         onChanged: (value) {
//           setState(() {
//             _searchQuery = value.toLowerCase();
//           });
//         },
//         decoration: InputDecoration(
//           suffixIcon: Icon(Icons.search),
//           contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
//           hintStyle: TextStyle(color: Colors.black),
//           border: InputBorder.none,
//           hintText: 'ຄົ້ນຫາສະຖານະການມາວຽກ...',
//           labelStyle: GoogleFonts.notoSansLao(
//             textStyle: const TextStyle(
//               color: Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Color getStatusColor(String status) {
//     switch (status) {
//       case 'ມາວຽກຊ້າ':
//         return Colors.orange;
//       case 'ຂາດວຽກ':
//         return Colors.red;
//       case 'ວັນພັກ':
//         return Colors.black12;
//       default:
//         return Colors.blue;
//     }
//   }
// }

import 'package:admin_timesabai/views/users_views/screens/record_screens/report_day_record.dart';
import 'package:admin_timesabai/views/users_views/screens/record_screens/report_month_record.dart';
import 'package:admin_timesabai/views/widget/date_month_year/shared/month_picker.dart';
import 'package:admin_timesabai/views/widget/loading_platform/loading.dart';
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

                      var dataStatus =
                          getStatusColor(record['status'].toString());
                      Duration calculateTotalHours(
                          Map<String, dynamic> record) {
                        // Function to parse time string to DateTime
                        DateTime? parseTime(dynamic time) {
                          // Check for null, empty, or invalid strings
                          if (time == null ||
                              time.toString().trim().isEmpty ||
                              time.toString() == '------') {
                            return null;
                          }
                          try {
                            final format = DateFormat('HH:mm');
                            return format.parse(time.toString());
                          } catch (e) {
                            print('Error parsing time: $time, error: $e');
                            return null;
                          }
                        }

                        // Initialize total duration
                        Duration totalDuration = Duration();

                        // Calculate morning duration (clockInAM to clockOutAM)
                        DateTime? inAM = parseTime(record['clockInAM']);
                        DateTime? outAM = parseTime(record['clockOutAM']);
                        if (inAM != null && outAM != null) {
                          try {
                            totalDuration += outAM.difference(inAM);
                          } catch (e) {
                            print('Error calculating AM duration: $e');
                          }
                        }

                        // Calculate afternoon duration (clockInPM to clockOutPM)
                        DateTime? inPM = parseTime(record['clockInPM']);
                        DateTime? outPM = parseTime(record['clockOutPM']);
                        if (inPM != null && outPM != null) {
                          try {
                            totalDuration += outPM.difference(inPM);
                          } catch (e) {
                            print('Error calculating PM duration: $e');
                          }
                        }

                        return totalDuration;
                      }

                      return Padding(
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
                                              backgroundColor: Colors.grey[200],
                                              child: ClipOval(
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      employee['profileImage']
                                                          .toString(),
                                                  width: 110,
                                                  height: 110,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
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
                                                  'ຈໍານວນຊົ່ວໂມງ',
                                                  style:
                                                      GoogleFonts.notoSansLao(
                                                          fontSize: 15),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '${(calculateTotalHours(record).inMinutes / 60.0).toStringAsFixed(1)}',
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  record['status'].toString(),
                                                  style:
                                                      GoogleFonts.notoSansLao(
                                                          fontSize: 15),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                      'ເຂົ້າ',
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                              fontSize: 15),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      record['clockInAM'],
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                              fontSize: 15),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      record['clockInPM'],
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                              fontSize: 15),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      'ອອກ',
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                              fontSize: 15),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      record['clockOutAM'],
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                              fontSize: 15),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      record['clockOutPM'],
                                                      style: GoogleFonts
                                                          .notoSansLao(
                                                              fontSize: 15),
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
