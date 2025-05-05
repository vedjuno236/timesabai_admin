import 'package:admin_timesabai/components/logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class ReportMonthRecord extends StatefulWidget {
  final String searchName;
  final String searchStatus;
  final DateTime? monthDate;

  const ReportMonthRecord(
      {super.key,
      required this.searchName,
      required this.searchStatus,
      required this.monthDate});

  @override
  State<ReportMonthRecord> createState() => _ReportEmployeeState();
}

class _ReportEmployeeState extends State<ReportMonthRecord> {
  final formattedDateTime = DateFormat.yMMMMEEEEd().format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      canChangeOrientation: false,
      build: (format) => generateDocument(format),
    );
  }

//   Future<Uint8List> generateDocument(PdfPageFormat format) async {
//     final doc = pw.Document(pageMode: PdfPageMode.outlines);

//     // Load custom font for the PDF
//     final font = pw.Font.ttf(await rootBundle.load('assets/fonts/BoonHome-400.ttf'));

//     final employeeSnapshot = await FirebaseFirestore.instance.collection('Employee').get();

//     List<Map<String, dynamic>> employeeData = [];

//     final selectedMonth = widget.monthDate!;
//     final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
//     final lastDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

//     for (var employeeDoc in employeeSnapshot.docs) {
//       final employeeDataMap = employeeDoc.data() as Map<String, dynamic>;
//       final employeeName = employeeDataMap['name'] ?? 'ບໍ່ມີຂໍ້ມູນ';

//       if (widget.searchName.isNotEmpty && employeeName != widget.searchName) {
//         continue;
//       }

//       final recordSnapshot = await employeeDoc.reference.collection('Record').get();
//       final leaveSnapshot = await employeeDoc.reference.collection('Leave').get();

//       final records = recordSnapshot.docs;
//       final leaves = leaveSnapshot.docs;

//       logger.d(leaves);

//       for (int i = 0; i < lastDayOfMonth.day; i++) {
//         final currentDate = firstDayOfMonth.add(Duration(days: i));

//         final matchingRecord = records
//             .cast<QueryDocumentSnapshot<Map<String, dynamic>>?>()
//             .firstWhere(
//           (doc) {
//             final data = doc!.data();
//             final timestamp = data['date'] as Timestamp?;
//             if (timestamp == null) return false;
//             final recordDate = timestamp.toDate();
//             return recordDate.year == currentDate.year &&
//                 recordDate.month == currentDate.month &&
//                 recordDate.day == currentDate.day;
//           },
//           orElse: () => null as QueryDocumentSnapshot<Map<String, dynamic>>?,
//         );

//         if (matchingRecord != null) {
//           final data = matchingRecord.data();
//           // Check and replace missing or empty data with '------'
//           final clockInAM = (data['clockInAM'] == null ||
//                   data['clockInAM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
//                   (data['clockInAM'] is String && data['clockInAM'].trim().isEmpty))
//               ? '------'
//               : data['clockInAM'];
//           final clockOutAM = (data['clockOutAM'] == null ||
//                   data['clockOutAM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
//                   (data['clockOutAM'] is String && data['clockOutAM'].trim().isEmpty))
//               ? '------'
//               : data['clockOutAM'];
//           final clockInPM = (data['clockInPM'] == null ||
//                   data['clockInPM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
//                   (data['clockInPM'] is String && data['clockInPM'].trim().isEmpty))
//               ? '------'
//               : data['clockInPM'];
//           final clockOutPM = (data['clockOutPM'] == null ||
//                   data['clockOutPM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
//                   (data['clockOutPM'] is String && data['clockOutPM'].trim().isEmpty))
//               ? '------'
//               : data['clockOutPM'];

//           // Debug print to inspect values
//           print('Record for $currentDate:');
//           print('  clockInAM: ${data['clockInAM']} -> $clockInAM');
//           print('  clockOutAM: ${data['clockOutAM']} -> $clockOutAM');
//           print('  clockInPM: ${data['clockInPM']} -> $clockInPM');
//           print('  clockOutPM: ${data['clockOutPM']} -> $clockOutPM');
//           print('  Original status: ${data['status']}');

//           // Determine status based on clockInPM
//           String status = data['status'] ?? 'ບໍ່ມີຂໍ້ມູນ';
//           if (clockInPM == '------' &&
//               (clockOutAM != '------' || clockOutPM != '------')) {
//             status = 'ມາວຽກ1ຕອນ';
//           }
//           print('  Final status: $status');

//           // Filter by status if provided
//           if (widget.searchStatus.isNotEmpty && status != widget.searchStatus) {
//             continue;
//           }

//           employeeData.add({
//             'name': employeeName,
//             'date': DateFormat.MMMMEEEEd('lo').format(currentDate),
//             'clockInAM': clockInAM,
//             'clockOutAM': clockOutAM,
//             'clockInPM': clockInPM,
//             'clockOutPM': clockOutPM,
//             'status': status,
//           });
//         } else {
//           final isWeekend = currentDate.weekday == 6 || currentDate.weekday == 7;
//           employeeData.add({
//             'name': employeeName,
//             'date': DateFormat.MMMMEEEEd('lo').format(currentDate),
//             'clockInAM': '------',
//             'clockOutAM': '------',
//             'clockInPM': '------',
//             'clockOutPM': '------',
//             'status': isWeekend ? 'ວັນພັກ' : 'ຂາດວຽກ',
//           });
//         }
//       }
//     }

//     // Create PDF
//     Uint8List logoData = (await rootBundle.load('assets/icons/images.png')).buffer.asUint8List();
//     doc.addPage(
//       pw.MultiPage(
//         pageFormat: format,
//         build: (context) => [
//           pw.Center(
//             child: pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//               crossAxisAlignment: pw.CrossAxisAlignment.center,
//               children: [
//                 pw.Container(
//                   height: 100,
//                   child: pw.Image(
//                     pw.MemoryImage(logoData),
//                     fit: pw.BoxFit.contain,
//                   ),
//                 ),
//                 pw.Text(
//                   '  ມະຫາວິທະຍາໄລສຸພານຸວົງ ',
//                   style: pw.TextStyle(
//                     font: font,
//                     fontSize: 25,
//                   ),
//                 ),
//                 pw.Text(
//                   ' ຄະນະວິສະວະກໍາສາດ',
//                   style: pw.TextStyle(
//                     font: font,
//                     fontSize: 25,
//                   ),
//                 ),
//                 pw.Text(
//                   ' ລາຍງານຂໍ້ມູນປະຈໍາການ',
//                   style: pw.TextStyle(
//                     font: font,
//                     fontSize: 20,
//                   ),
//                 ),
//                 pw.Container(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Text(
//                     ' ວັນທີລາຍງານ: $formattedDateTime',
//                     style: pw.TextStyle(
//                       font: font,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ),
//                 pw.Container(
//                   alignment: pw.Alignment.centerLeft,
//                   child: pw.Text(
//                     'ລາຍງານປະຈໍາເດືອນ: ${widget.monthDate != null ? DateFormat(' MMMM ', 'lo').format(widget.monthDate!) : ''}',
//                     style: pw.TextStyle(
//                       font: font,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ),
//                 pw.Container(
//                   alignment: pw.Alignment.centerLeft,
//                   child: pw.Text(
//                     'ລາຍງານມາປະຈໍາການ: ${widget.searchName.isEmpty ? 'ທັງໝົດ' : widget.searchName}',
//                     style: pw.TextStyle(
//                       font: font,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//                 pw.Container(
//                   alignment: pw.Alignment.centerLeft,
//                   child: pw.Text(
//                     'ລາຍງານສະຖານະ: ${widget.searchStatus.isEmpty ? 'ທັງໝົດ' : widget.searchStatus}',
//                     style: pw.TextStyle(
//                       font: font,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(height: 10),
//           pw.Table(
//             border: pw.TableBorder.all(),
//             columnWidths: {
//               0: pw.FlexColumnWidth(2), // Name
//               1: pw.FlexColumnWidth(2), // Date
//               2: pw.FlexColumnWidth(1), // ClockInAM
//               3: pw.FlexColumnWidth(1), // ClockOutAM
//               4: pw.FlexColumnWidth(1), // ClockInPM
//               5: pw.FlexColumnWidth(1), // ClockOutPM
//               6: pw.FlexColumnWidth(1),
//             },
//             children: [
//               // Header row
//               pw.TableRow(
//                 decoration: pw.BoxDecoration(color: PdfColors.grey300),
//                 children: [
//                   pw.Padding(
//                     padding: pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       'ຊື່ ແລະ ນາມສະກຸນ',
//                       style: pw.TextStyle(
//                         font: font,
//                         fontSize: 10,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                       textAlign: pw.TextAlign.center,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       'ວັນທີ',
//                       style: pw.TextStyle(
//                         font: font,
//                         fontSize: 10,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                       textAlign: pw.TextAlign.center,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       'ເຂົ້າວຽກເຊົ້າ',
//                       style: pw.TextStyle(font: font, fontSize: 10),
//                       textAlign: pw.TextAlign.center,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       'ອອກວຽກເຊົ້າ',
//                       style: pw.TextStyle(font: font, fontSize: 10),
//                       textAlign: pw.TextAlign.center,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       'ເຂົ້າວຽກແລງ',
//                       style: pw.TextStyle(font: font, fontSize: 10),
//                       textAlign: pw.TextAlign.center,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       'ອອກວຽກແລງ',
//                       style: pw.TextStyle(font: font, fontSize: 10),
//                       textAlign: pw.TextAlign.center,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       'ສະຖານະ',
//                       style: pw.TextStyle(
//                         font: font,
//                         fontSize: 10,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                       textAlign: pw.TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//               // Data rows
//               ...employeeData.map(
//                 (e) => pw.TableRow(
//                   children: [
//                     pw.Padding(
//                       padding: pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         e['name'],
//                         style: pw.TextStyle(font: font, fontSize: 10),
//                         textAlign: pw.TextAlign.left,
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         e['date'],
//                         style: pw.TextStyle(font: font, fontSize: 10),
//                         textAlign: pw.TextAlign.left,
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         e['clockInAM'],
//                         style: pw.TextStyle(font: font, fontSize: 10),
//                         textAlign: pw.TextAlign.left,
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         e['clockOutAM'],
//                         style: pw.TextStyle(font: font, fontSize: 10),
//                         textAlign: pw.TextAlign.left,
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         e['clockInPM'],
//                         style: pw.TextStyle(font: font, fontSize: 10),
//                         textAlign: pw.TextAlign.left,
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         e['clockOutPM'],
//                         style: pw.TextStyle(font: font, fontSize: 10),
//                         textAlign: pw.TextAlign.left,
//                       ),
//                     ),
//                     pw.Padding(
//                       padding: pw.EdgeInsets.all(8),
//                       child: pw.Text(
//                         e['status'],
//                         style: pw.TextStyle(
//                           font: font,
//                           fontSize: 10,
//                           color: e['status'] == 'ວັນພັກ'
//                               ? PdfColors.blue
//                               : e['status'] == 'ຂາດວຽກ'
//                                   ? PdfColors.red
//                                   : e['status'] == 'ມາວຽກຊ້າ'
//                                       ? PdfColors.pink
//                                       : e['status'] == 'ມາວຽກ1ຕອນ'
//                                           ? PdfColors.blueAccent
//                                           : PdfColors.black,
//                         ),
//                         textAlign: pw.TextAlign.left,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );

//     return doc.save();
//   }
// }

  /// ສົມບຸນ ແຈ່ຍິງໄມາສະແດງ ລາພັກ ຫນື່ງຕອນ

// Future<Uint8List> generateDocument(PdfPageFormat format) async {
//   final doc = pw.Document(pageMode: PdfPageMode.outlines);

//   // Load custom font for the PDF
//   final font = pw.Font.ttf(await rootBundle.load('assets/fonts/BoonHome-400.ttf'));

//   final employeeSnapshot = await FirebaseFirestore.instance.collection('Employee').get();

//   List<Map<String, dynamic>> employeeData = [];

//   final selectedMonth = widget.monthDate!;
//   final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
//   final lastDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

//   for (var employeeDoc in employeeSnapshot.docs) {
//     final employeeDataMap = employeeDoc.data() as Map<String, dynamic>;
//     final employeeName = employeeDataMap['name'] ?? 'ບໍ່ມີຂໍ້ມູນ';

//     if (widget.searchName.isNotEmpty && employeeName != widget.searchName) {
//       continue;
//     }

//     final recordSnapshot = await employeeDoc.reference.collection('Record').get();
//     final leaveSnapshot = await employeeDoc.reference.collection('Leave').get();

//     final records = recordSnapshot.docs;
//     final leaves = leaveSnapshot.docs;

//     logger.d('Leave data: $leaves');

//     for (int i = 0; i < lastDayOfMonth.day; i++) {
//       final currentDate = firstDayOfMonth.add(Duration(days: i));

//       bool isOnLeave = false;
//       for (var leaveDoc in leaves) {
//         final leaveData = leaveDoc.data() as Map<String, dynamic>;
//         final leaveStart = (leaveData['fromDate'] as Timestamp?)?.toDate();
//         final leaveEnd = (leaveData['toDate'] as Timestamp?)?.toDate();

//         if (leaveStart != null && leaveEnd != null) {
//           if (currentDate.isAfter(leaveStart.subtract(Duration(days: 1))) &&
//               currentDate.isBefore(leaveEnd.add(Duration(days: 1)))) {
//             isOnLeave = true;
//             break;
//           }
//         }
//       }

//       if (isOnLeave) {
//         // If the employee is on leave, add leave status
//         employeeData.add({
//           'name': employeeName,
//           'date': DateFormat.MMMMEEEEd('lo').format(currentDate),
//           'clockInAM': '------',
//           'clockOutAM': '------',
//           'clockInPM': '------',
//           'clockOutPM': '------',
//           'status': 'ລາພັກ',
//         });
//         continue; // Skip further processing for this date
//       }

//       final matchingRecord = records
//           .cast<QueryDocumentSnapshot<Map<String, dynamic>>?>()
//           .firstWhere(
//         (doc) {
//           final data = doc!.data();
//           final timestamp = data['date'] as Timestamp?;
//           if (timestamp == null) return false;
//           final recordDate = timestamp.toDate();
//           return recordDate.year == currentDate.year &&
//               recordDate.month == currentDate.month &&
//               recordDate.day == currentDate.day;
//         },
//         orElse: () => null as QueryDocumentSnapshot<Map<String, dynamic>>?,
//       );

//       if (matchingRecord != null) {
//         final data = matchingRecord.data();
//         // Check and replace missing or empty data with '------'
//         final clockInAM = (data['clockInAM'] == null ||
//                 data['clockInAM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
//                 (data['clockInAM'] is String && data['clockInAM'].trim().isEmpty))
//             ? '------'
//             : data['clockInAM'];
//         final clockOutAM = (data['clockOutAM'] == null ||
//                 data['clockOutAM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
//                 (data['clockOutAM'] is String && data['clockOutAM'].trim().isEmpty))
//             ? '------'
//             : data['clockOutAM'];
//         final clockInPM = (data['clockInPM'] == null ||
//                 data['clockInPM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
//                 (data['clockInPM'] is String && data['clockInPM'].trim().isEmpty))
//             ? '------'
//             : data['clockInPM'];
//         final clockOutPM = (data['clockOutPM'] == null ||
//                 data['clockOutPM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
//                 (data['clockOutPM'] is String && data['clockOutPM'].trim().isEmpty))
//             ? '------'
//             : data['clockOutPM'];

//         // Debug print to inspect values
//         print('Record for $currentDate:');
//         print('  clockInAM: ${data['clockInAM']} -> $clockInAM');
//         print('  clockOutAM: ${data['clockOutAM']} -> $clockOutAM');
//         print('  clockInPM: ${data['clockInPM']} -> $clockInPM');
//         print('  clockOutPM: ${data['clockOutPM']} -> $clockOutPM');
//         print('  Original status: ${data['status']}');

//         // Determine status based on clockInPM
//         String status = data['status'] ?? 'ບໍ່ມີຂໍ້ມູນ';
//         if (clockInPM == '------' &&
//             (clockOutAM != '------' || clockOutPM != '------')) {
//           status = 'ມາວຽກ1ຕອນ';
//         }
//         print('  Final status: $status');

//         // Filter by status if provided
//         if (widget.searchStatus.isNotEmpty && status != widget.searchStatus) {
//           continue;
//         }

//         employeeData.add({
//           'name': employeeName,
//           'date': DateFormat.MMMMEEEEd('lo').format(currentDate),
//           'clockInAM': clockInAM,
//           'clockOutAM': clockOutAM,
//           'clockInPM': clockInPM,
//           'clockOutPM': clockOutPM,
//           'status': status,
//         });
//       } else {
//         final isWeekend = currentDate.weekday == 6 || currentDate.weekday == 7;
//         employeeData.add({
//           'name': employeeName,
//           'date': DateFormat.MMMMEEEEd('lo').format(currentDate),
//           'clockInAM': '------',
//           'clockOutAM': '------',
//           'clockInPM': '------',
//           'clockOutPM': '------',
//           'status': isWeekend ? 'ວັນພັກ' : 'ຂາດວຽກ',
//         });
//       }
//     }
//   }

//   // Create PDF
//   Uint8List logoData = (await rootBundle.load('assets/icons/images.png')).buffer.asUint8List();
//   doc.addPage(
//     pw.MultiPage(
//       pageFormat: format,
//       build: (context) => [
//         pw.Center(
//           child: pw.Column(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//             crossAxisAlignment: pw.CrossAxisAlignment.center,
//             children: [
//               pw.Container(
//                 height: 100,
//                 child: pw.Image(
//                   pw.MemoryImage(logoData),
//                   fit: pw.BoxFit.contain,
//                 ),
//               ),
//               pw.Text(
//                 '  ມະຫາວິທະຍາໄລສຸພານຸວົງ ',
//                 style: pw.TextStyle(
//                   font: font,
//                   fontSize: 25,
//                 ),
//               ),
//               pw.Text(
//                 ' ຄະນະວິສະວະກໍາສາດ',
//                 style: pw.TextStyle(
//                   font: font,
//                   fontSize: 25,
//                 ),
//               ),
//               pw.Text(
//                 ' ລາຍງານຂໍ້ມູນປະຈໍາການ',
//                 style: pw.TextStyle(
//                   font: font,
//                   fontSize: 20,
//                 ),
//               ),
//               pw.Container(
//                 alignment: pw.Alignment.centerRight,
//                 child: pw.Text(
//                   ' ວັນທີລາຍງານ: $formattedDateTime',
//                   style: pw.TextStyle(
//                     font: font,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//               pw.Container(
//                 alignment: pw.Alignment.centerLeft,
//                 child: pw.Text(
//                   'ລາຍງານປະຈໍາເດືອນ: ${widget.monthDate != null ? DateFormat(' MMMM ', 'lo').format(widget.monthDate!) : ''}',
//                   style: pw.TextStyle(
//                     font: font,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//               pw.Container(
//                 alignment: pw.Alignment.centerLeft,
//                 child: pw.Text(
//                   'ລາຍງານມາປະຈໍາການ: ${widget.searchName.isEmpty ? 'ທັງໝົດ' : widget.searchName}',
//                   style: pw.TextStyle(
//                     font: font,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//               pw.Container(
//                 alignment: pw.Alignment.centerLeft,
//                 child: pw.Text(
//                   'ລາຍງານສະຖານະ: ${widget.searchStatus.isEmpty ? 'ທັງໝົດ' : widget.searchStatus}',
//                   style: pw.TextStyle(
//                     font: font,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         pw.SizedBox(height: 10),
//         pw.Table(
//           border: pw.TableBorder.all(),
//           columnWidths: {
//             0: pw.FlexColumnWidth(2), // Name
//             1: pw.FlexColumnWidth(2), // Date
//             2: pw.FlexColumnWidth(1), // ClockInAM
//             3: pw.FlexColumnWidth(1), // ClockOutAM
//             4: pw.FlexColumnWidth(1), // ClockInPM
//             5: pw.FlexColumnWidth(1), // ClockOutPM
//             6: pw.FlexColumnWidth(1),
//           },
//           children: [
//             // Header row
//             pw.TableRow(
//               decoration: pw.BoxDecoration(color: PdfColors.grey300),
//               children: [
//                 pw.Padding(
//                   padding: pw.EdgeInsets.all(8),
//                   child: pw.Text(
//                     'ຊື່ ແລະ ນາມສະກຸນ',
//                     style: pw.TextStyle(
//                       font: font,
//                       fontSize: 10,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                     textAlign: pw.TextAlign.center,
//                   ),
//                 ),
//                 pw.Padding(
//                   padding: pw.EdgeInsets.all(8),
//                   child: pw.Text(
//                     'ວັນທີ',
//                     style: pw.TextStyle(
//                       font: font,
//                       fontSize: 10,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                     textAlign: pw.TextAlign.center,
//                   ),
//                 ),
//                 pw.Padding(
//                   padding: const pw.EdgeInsets.all(8),
//                   child: pw.Text(
//                     'ເຂົ້າວຽກເຊົ້າ',
//                     style: pw.TextStyle(font: font, fontSize: 10),
//                     textAlign: pw.TextAlign.center,
//                   ),
//                 ),
//                 pw.Padding(
//                   padding: const pw.EdgeInsets.all(8),
//                   child: pw.Text(
//                     'ອອກວຽກເຊົ້າ',
//                     style: pw.TextStyle(font: font, fontSize: 10),
//                     textAlign: pw.TextAlign.center,
//                   ),
//                 ),
//                 pw.Padding(
//                   padding: const pw.EdgeInsets.all(8),
//                   child: pw.Text(
//                     'ເຂົ້າວຽກແລງ',
//                     style: pw.TextStyle(font: font, fontSize: 10),
//                     textAlign: pw.TextAlign.center,
//                   ),
//                 ),
//                 pw.Padding(
//                   padding: const pw.EdgeInsets.all(8),
//                   child: pw.Text(
//                     'ອອກວຽກແລງ',
//                     style: pw.TextStyle(font: font, fontSize: 10),
//                     textAlign: pw.TextAlign.center,
//                   ),
//                 ),
//                 pw.Padding(
//                   padding: pw.EdgeInsets.all(8),
//                   child: pw.Text(
//                     'ສະຖານະ',
//                     style: pw.TextStyle(
//                       font: font,
//                       fontSize: 10,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                     textAlign: pw.TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//             // Data rows
//             ...employeeData.map(
//               (e) => pw.TableRow(
//                 children: [
//                   pw.Padding(
//                     padding: pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       e['name'],
//                       style: pw.TextStyle(font: font, fontSize: 10),
//                       textAlign: pw.TextAlign.left,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       e['date'],
//                       style: pw.TextStyle(font: font, fontSize: 10),
//                       textAlign: pw.TextAlign.left,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       e['clockInAM'],
//                       style: pw.TextStyle(font: font, fontSize: 10),
//                       textAlign: pw.TextAlign.left,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       e['clockOutAM'],
//                       style: pw.TextStyle(font: font, fontSize: 10),
//                       textAlign: pw.TextAlign.left,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       e['clockInPM'],
//                       style: pw.TextStyle(font: font, fontSize: 10),
//                       textAlign: pw.TextAlign.left,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       e['clockOutPM'],
//                       style: pw.TextStyle(font: font, fontSize: 10),
//                       textAlign: pw.TextAlign.left,
//                     ),
//                   ),
//                   pw.Padding(
//                     padding: pw.EdgeInsets.all(8),
//                     child: pw.Text(
//                       e['status'],
//                       style: pw.TextStyle(
//                         font: font,
//                         fontSize: 10,
//                         color: e['status'] == 'ວັນພັກ'
//                             ? PdfColors.blue
//                             : e['status'] == 'ຂາດວຽກ'
//                                 ? PdfColors.red
//                                 : e['status'] == 'ມາວຽກຊ້າ'
//                                     ? PdfColors.pink
//                                     : e['status'] == 'ມາວຽກ1ຕອນ'
//                                         ? PdfColors.blueAccent
//                                         : e['status'] == 'ລາພັກ'
//                                             ? PdfColors.green // Add color for leave status
//                                             : PdfColors.black,
//                       ),
//                       textAlign: pw.TextAlign.left,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ]),
//     );

//   return doc.save();
// }}

  Future<Uint8List> generateDocument(PdfPageFormat format) async {
    final doc = pw.Document(pageMode: PdfPageMode.outlines);

    // Load custom font for the PDF
    final font =
        pw.Font.ttf(await rootBundle.load('assets/fonts/BoonHome-400.ttf'));

    final employeeSnapshot =
        await FirebaseFirestore.instance.collection('Employee').get();

    List<Map<String, dynamic>> employeeData = [];

    final selectedMonth = widget.monthDate!;
    final firstDayOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    for (var employeeDoc in employeeSnapshot.docs) {
      final employeeDataMap = employeeDoc.data() as Map<String, dynamic>;
      final employeeName = employeeDataMap['name'] ?? 'ບໍ່ມີຂໍ້ມູນ';

      if (widget.searchName.isNotEmpty && employeeName != widget.searchName) {
        continue;
      }

      final recordSnapshot =
          await employeeDoc.reference.collection('Record').get();
      final leaveSnapshot =
          await employeeDoc.reference.collection('Leave').get();

      final records = recordSnapshot.docs;
      final leaves = leaveSnapshot.docs;

      logger.d('Leave data: $leaves');

      for (int i = 0; i < lastDayOfMonth.day; i++) {
        final currentDate = firstDayOfMonth.add(Duration(days: i));

        // Check if the current date is in the Leave collection
        bool isOnLeave = false;
        for (var leaveDoc in leaves) {
          final leaveData = leaveDoc.data() as Map<String, dynamic>;
          final leaveStart = (leaveData['fromDate'] as Timestamp?)?.toDate();
          final leaveEnd = (leaveData['toDate'] as Timestamp?)?.toDate();

          if (leaveStart != null && leaveEnd != null) {
            if (currentDate.isAfter(leaveStart.subtract(Duration(days: 1))) &&
                currentDate.isBefore(leaveEnd.add(Duration(days: 1)))) {
              isOnLeave = true;
              break;
            }
          }
        }

        final matchingRecord = records
            .cast<QueryDocumentSnapshot<Map<String, dynamic>>?>()
            .firstWhere(
          (doc) {
            final data = doc!.data();
            final timestamp = data['date'] as Timestamp?;
            if (timestamp == null) return false;
            final recordDate = timestamp.toDate();
            return recordDate.year == currentDate.year &&
                recordDate.month == currentDate.month &&
                recordDate.day == currentDate.day;
          },
          orElse: () => null as QueryDocumentSnapshot<Map<String, dynamic>>?,
        );

        if (matchingRecord != null) {
          final data = matchingRecord.data();
          // Check and replace missing or empty data with '------'
          final clockInAM = (data['clockInAM'] == null ||
                  data['clockInAM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
                  (data['clockInAM'] is String &&
                      data['clockInAM'].trim().isEmpty))
              ? '------'
              : data['clockInAM'];
          final clockOutAM = (data['clockOutAM'] == null ||
                  data['clockOutAM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
                  (data['clockOutAM'] is String &&
                      data['clockOutAM'].trim().isEmpty))
              ? '------'
              : data['clockOutAM'];
          final clockInPM = (data['clockInPM'] == null ||
                  data['clockInPM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
                  (data['clockInPM'] is String &&
                      data['clockInPM'].trim().isEmpty))
              ? '------'
              : data['clockInPM'];
          final clockOutPM = (data['clockOutPM'] == null ||
                  data['clockOutPM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
                  (data['clockOutPM'] is String &&
                      data['clockOutPM'].trim().isEmpty))
              ? '------'
              : data['clockOutPM'];

          String status = data['status'] ?? 'ບໍ່ມີຂໍ້ມູນ';
          if (isOnLeave) {
            // If on leave, determine status based on clock-in/out times
            if (clockInAM == '------' &&
                clockOutAM == '------' &&
                clockInPM == '------' &&
                clockOutPM == '------') {
              status = 'ລາພັກ'; // Full leave day (e.g., May 6)
            } else if ((clockInAM != '------' && clockOutAM != '------') ||
                (clockInPM != '------' && clockOutPM != '------')) {
              status =
                  'ລາພັກ 1 ຕອນ'; // Partial leave day (e.g., May 5 with AM times)
            }
          } else if (clockInPM == '------' &&
              (clockOutAM != '------' || clockOutPM != '------')) {
            status = 'ມາວຽກ1ຕອນ';
          }

          // Filter by status if provided
          if (widget.searchStatus.isNotEmpty && status != widget.searchStatus) {
            continue;
          }

          employeeData.add({
            'name': employeeName,
            'date': DateFormat.MMMMEEEEd('lo').format(currentDate),
            'clockInAM': clockInAM,
            'clockOutAM': clockOutAM,
            'clockInPM': clockInPM,
            'clockOutPM': clockOutPM,
            'status': status,
          });
        } else {
          final isWeekend =
              currentDate.weekday == 6 || currentDate.weekday == 7;
          String status = isWeekend ? 'ວັນພັກ' : 'ຂາດວຽກ';
          if (isOnLeave) {
            status =
                'ລາພັກ'; // Full leave day when no record exists (e.g., May 6)
          }

          // Filter by status if provided
          if (widget.searchStatus.isNotEmpty && status != widget.searchStatus) {
            continue;
          }

          employeeData.add({
            'name': employeeName,
            'date': DateFormat.MMMMEEEEd('lo').format(currentDate),
            'clockInAM': '------',
            'clockOutAM': '------',
            'clockInPM': '------',
            'clockOutPM': '------',
            'status': status,
          });
        }
      }
    }

    // Create PDF
    Uint8List logoData =
        (await rootBundle.load('assets/icons/images.png')).buffer.asUint8List();
    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (context) => [
          pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  height: 100,
                  child: pw.Image(
                    pw.MemoryImage(logoData),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.Text(
                  '  ມະຫາວິທະຍາໄລສຸພານຸວົງ ',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 25,
                  ),
                ),
                pw.Text(
                  ' ຄະນະວິສະວະກໍາສາດ',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 25,
                  ),
                ),
                pw.Text(
                  ' ລາຍງານຂໍ້ມູນປະຈໍາການ',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 20,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    ' ວັນທີລາຍງານ: $formattedDateTime',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 15,
                    ),
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'ລາຍງານປະຈໍາເດືອນ: ${widget.monthDate != null ? DateFormat(' MMMM ', 'lo').format(widget.monthDate!) : ''}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 15,
                    ),
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'ລາຍງານມາປະຈໍາການ: ${widget.searchName.isEmpty ? 'ທັງໝົດ' : widget.searchName}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                    ),
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'ລາຍງານສະຖານະ: ${widget.searchStatus.isEmpty ? 'ທັງໝົດ' : widget.searchStatus}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(2), // Name
              1: pw.FlexColumnWidth(2), // Date
              2: pw.FlexColumnWidth(1), // ClockInAM
              3: pw.FlexColumnWidth(1), // ClockOutAM
              4: pw.FlexColumnWidth(1), // ClockInPM
              5: pw.FlexColumnWidth(1), // ClockOutPM
              6: pw.FlexColumnWidth(1),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'ຊື່ ແລະ ນາມສະກຸນ',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'ວັນທີ',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'ເຂົ້າວຽກເຊົ້າ',
                      style: pw.TextStyle(font: font, fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'ອອກວຽກເຊົ້າ',
                      style: pw.TextStyle(font: font, fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'ເຂົ້າວຽກແລງ',
                      style: pw.TextStyle(font: font, fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'ອອກວຽກແລງ',
                      style: pw.TextStyle(font: font, fontSize: 10),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'ສະຖານະ',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),
              // Data rows
              ...employeeData.map(
                (e) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        e['name'],
                        style: pw.TextStyle(font: font, fontSize: 10),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        e['date'],
                        style: pw.TextStyle(font: font, fontSize: 10),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        e['clockInAM'],
                        style: pw.TextStyle(font: font, fontSize: 10),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        e['clockOutAM'],
                        style: pw.TextStyle(font: font, fontSize: 10),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        e['clockInPM'],
                        style: pw.TextStyle(font: font, fontSize: 10),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        e['clockOutPM'],
                        style: pw.TextStyle(font: font, fontSize: 10),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        e['status'],
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: e['status'] == 'ວັນພັກ'
                              ? PdfColors.blue
                              : e['status'] == 'ຂາດວຽກ'
                                  ? PdfColors.red
                                  : e['status'] == 'ມາວຽກຊ້າ'
                                      ? PdfColors.pink
                                      : e['status'] == 'ມາວຽກ1ຕອນ'
                                          ? PdfColors.blueAccent
                                          : e['status'] == 'ລາພັກ'
                                              ? PdfColors.green
                                              : e['status'] == 'ລາພັກ 1 ຕອນ'
                                                  ? PdfColors.greenAccent
                                                  : PdfColors.black,
                        ),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }
}
