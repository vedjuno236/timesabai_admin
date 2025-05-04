import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportMonthLeave extends StatefulWidget {
  final String searchQuery;
  final DateTime? Month;

  const ReportMonthLeave(
      {super.key, required this.searchQuery, required this.Month});

  @override
  State<ReportMonthLeave> createState() => _ReportEmployeeState();
}

class _ReportEmployeeState extends State<ReportMonthLeave> {
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
    final font1 =
        pw.Font.ttf(await rootBundle.load('assets/fonts/BoonHome-400.ttf'));

    // Fetch employees from Firestore
    final QuerySnapshot employeeSnapshot =
        await FirebaseFirestore.instance.collection('Employee').get();

    List<Map<String, dynamic>> employeeData = [];

    // Loop through each employee document
    for (var employeeDoc in employeeSnapshot.docs) {
      final employeeDataMap = employeeDoc.data() as Map<String, dynamic>;

      // Fetch employee name
      final employeeName = employeeDataMap['name'] ?? 'ບໍມີຂໍໍມູນ';

      // Fetch employee records from the 'Record' subcollection
      final recordSnapshot =
          await employeeDoc.reference.collection('Leave').get();

      // Loop through each record and filter based on search conditions
      for (var recordDoc in recordSnapshot.docs) {
        final recordData = recordDoc.data() as Map<String, dynamic>;

        final leaveType = recordData['leaveType'] ?? 'ບໍມີຂໍໍມູນ';
        final daySummary = recordData['daySummary'] ?? 'ບໍມີຂໍໍມູນ';
        final status = recordData['status'] ?? 'ບໍມີຂໍໍມູນ';
        final fromDate = recordData['fromDate'] ?? 'ບໍມີຂໍໍມູນ';
        final toDate = recordData['toDate'] ?? 'ບໍມີຂໍໍມູນ';
        final doc = recordData['doc'] ?? 'ບໍມີຂໍໍມູນ';
        final day = recordData['date'] ?? 'ບໍມີຂໍໍມູນ';

        bool matchesName = true;
        if (widget.searchQuery.isNotEmpty &&
            !employeeName
                .toLowerCase()
                .contains(widget.searchQuery.toLowerCase())) {
          matchesName = false;
        }

        if (matchesName) {
          Timestamp? date = recordData['date'];
          if (date != null) {
            DateTime recordDate = date.toDate();

            if (widget.Month != null) {
              if (recordDate.year != widget.Month!.year ||
                  recordDate.month != widget.Month!.month) {
                continue;
              }
            }
          }

          String fromDateString = fromDate != null
              ? DateFormat('EEEE d MMMM yyyy').format(fromDate.toDate())
              : 'ບໍມີຂໍໍມູນ';

          String toDateString = toDate != 'ບໍມີຂໍໍມູນ' && toDate is Timestamp
              ? DateFormat('EEEE d MMMM yyyy').format(toDate.toDate())
              : 'ບໍມີຂໍໍມູນ';
          String todayString = day != 'ບໍມີຂໍໍມູນ' && date is Timestamp
              ? DateFormat('EEEE d MMMM ').format(date.toDate())
              : 'ບໍມີຂໍໍມູນ';

          employeeData.add({
            'name': employeeName,
            'date': todayString,
            'leaveType': leaveType,
            'daySummary': daySummary,
            'status': status,
            'fromDate': fromDateString,
            'toDate': toDateString,
            'doc': doc
          });
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
                          'ລາຍງານການລາພັກປະເດືອນ:  ${widget.Month != null ? DateFormat('MMMM yyyy', 'lo').format(widget.Month!) : ''}', // Add appropriate value if needed
                          style: pw.TextStyle(
                            font: font1,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          'ລາຍງານສະຖານະ: ${widget.searchQuery}',
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
                      font: font1, // Use bold font for headers
                      fontSize: 10,
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
