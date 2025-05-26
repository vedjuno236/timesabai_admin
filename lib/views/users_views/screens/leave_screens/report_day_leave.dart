import 'package:admin_timesabai/components/logging.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class ReportDayLeave extends StatefulWidget {
  final String searchName;
  final DateTime? Day;

  const ReportDayLeave(
      {super.key, required this.searchName, required this.Day});

  @override
  State<ReportDayLeave> createState() => _ReportEmployeeState();
}

class _ReportEmployeeState extends State<ReportDayLeave> {
  final formattedDateTime = DateFormat.yMMMMEEEEd().format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      canChangeOrientation: false,
      build: (format) => generateDocument(format),
    );
  }

Future<Uint8List> generateDocument(PdfPageFormat format) async {
  final doc = pw.Document(pageMode: PdfPageMode.outlines);

  // Load custom font for the PDF
  final font1 = pw.Font.ttf(await rootBundle.load('assets/fonts/BoonHome-400.ttf'));

  // Fetch employees from Firestore
  final QuerySnapshot employeeSnapshot =
      await FirebaseFirestore.instance.collection('Employee').get();

  List<Map<String, dynamic>> employeeData = [];

  // Loop through each employee document
  for (var employeeDoc in employeeSnapshot.docs) {
    final employeeDataMap = employeeDoc.data() as Map<String, dynamic>;

    // Fetch employee name
    final employeeName = employeeDataMap['name'] ?? 'ບໍມີຂໍໍມູນ';

    final recordSnapshot =
        await employeeDoc.reference.collection('Leave').get();

    for (var recordDoc in recordSnapshot.docs) {
      final recordData = recordDoc.data() as Map<String, dynamic>;

      final leaveType = recordData['leaveType'] ?? 'ບໍມີຂໍໍມູນ';
      final daySummary = recordData['daySummary'] ?? 'ບໍມີຂໍໍມູນ';
      final status = recordData['status'] ?? 'ບໍມີຂໍໍມູນ';
      final fromDate = recordData['fromDate'];
      final toDate = recordData['toDate'];
      final doc = recordData['doc'] ?? 'ບໍມີຂໍໍມູນ';
      final date = recordData['date'];

      bool matchesName = true;
      if (widget.searchName.isNotEmpty &&
          !employeeName.toLowerCase().contains(widget.searchName.toLowerCase())) {
        matchesName = false;
      }

      if (matchesName && widget.Day != null) {
        if (fromDate is Timestamp && toDate is Timestamp) {
          DateTime fromDateTime = fromDate.toDate();
          DateTime toDateTime = toDate.toDate();
          DateTime selectedDay =
              DateTime(widget.Day!.year, widget.Day!.month, widget.Day!.day);

       
          bool isInRange = (selectedDay.isAtSameMomentAs(fromDateTime) ||
                  selectedDay.isAfter(fromDateTime)) &&
              (selectedDay.isAtSameMomentAs(toDateTime) ||
                  selectedDay.isBefore(toDateTime));

          if (isInRange) {
            String fromDateString = DateFormat('EEEE d MMMM yyyy', 'lo').format(fromDateTime);
            String toDateString = DateFormat('EEEE d MMMM yyyy', 'lo').format(toDateTime);
            String dateString = date is Timestamp
                ? DateFormat('EEEE d MMMM yyyy', 'lo').format(date.toDate())
                : 'ບໍມີຂໍໍມູນ';

            employeeData.add({
              'name': employeeName,
              'date': dateString,
              'leaveType': leaveType,
              'daySummary': daySummary,
              'status': status,
              'fromDate': fromDateString,
              'toDate': toDateString,
              'doc': doc,
            });
          }
        }
      }
    }
  }

    Uint8List logoData =
        (await rootBundle.load('assets/icons/images.png')).buffer.asUint8List();
    doc.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: format.copyWith(
            marginBottom: 0,
            marginLeft: 20,
            marginRight: 20,
            marginTop: 0,
          ),
          orientation: pw.PageOrientation.portrait,
          theme: pw.ThemeData.withFont(
            base: font1,
            bold: font1,
          ),
        ),
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 15),
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
                          font: font1,
                          fontSize: 25,
                        ),
                      ),
                      pw.Text(
                        'ຄະນະວິສະວະກໍາສາດ',
                        style: pw.TextStyle(
                          font: font1,
                          fontSize: 20,
                        ),
                      ),
                      pw.Text(
                        ' ລາຍງານຂໍ້ມູນການລາພັກ',
                        style: pw.TextStyle(
                          font: font1,
                          fontSize: 18,
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          ' ວັນທີລາຍງານ: $formattedDateTime',
                          style: pw.TextStyle(
                            font: font1,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      // Update the following fields accordingly
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          'ລາຍງານການລາພັກປະຈໍາວັນ:  ${widget.Day != null ? DateFormat('MMMM yyyy', 'lo').format(widget.Day!) : ''}', // Add appropriate value if needed
                          style: pw.TextStyle(
                            font: font1,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          'ລາຍງານສະຖານະ: ${widget.searchName}',
                          // Add appropriate value if needed
                          style: pw.TextStyle(
                            font: font1,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                // Table displaying employee data including checkIn and checkOut times
                pw.Center(
                  child: pw.Table.fromTextArray(
                    context: context,
                    cellAlignment: pw.Alignment.center,
                    headerStyle: pw.TextStyle(
                      font: font1,
                      fontSize: 9,
                    ),
                    cellStyle: pw.TextStyle(
                      font: font1,
                      fontSize: 6,
                    ),
                    oddCellStyle: pw.TextStyle(
                      font: font1,
                      fontSize: 6,
                    ),
                    headers: [
                      'ຊື່ ແລະ ນາມສະກຸນ',
                      'ວັນທີຂໍລາພັກ',
                      'ວັນທີລາພັກ',
                      'ວັນທີສີ້ນສູດ',
                      'ສະຫຼຸບວັນພັກ',
                      'ປະເພດລາພັກ',
                      'ເຫດຜົນ',
                      'ສະຖານະ'
                    ],
                    data: employeeData
                        .map((entry) => [
                              entry['name'].toString(),
                              entry['date'].toString(),
                              entry['fromDate'].toString(),
                              entry['toDate'].toString(),
                              entry['daySummary'].toString(),
                              entry['leaveType'].toString(),
                              entry['doc'].toString(),
                              entry['status'].toString(),
                            ])
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }
}
