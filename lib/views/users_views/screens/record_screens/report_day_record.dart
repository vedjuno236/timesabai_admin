import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class ReportDayRecord extends StatefulWidget {
  final String searchName;
  final String searchStatus;
  final DateTime? dayDate;

  const ReportDayRecord({super.key, required this.searchName, required this.searchStatus,required this.dayDate});

  @override
  State<ReportDayRecord> createState() => _ReportEmployeeState();
}

class _ReportEmployeeState extends State<ReportDayRecord> {
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
    final QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
        .collection('Employee').get();

    List<Map<String, dynamic>> employeeData = [];

    // Loop through each employee document
    for (var employeeDoc in employeeSnapshot.docs) {
      final employeeDataMap = employeeDoc.data() as Map<String, dynamic>;

      // Fetch employee name
      final employeeName = employeeDataMap['name'] ?? 'ບໍມີຂໍໍມູນ';

      // Fetch employee records from the 'Record' subcollection
      final recordSnapshot = await employeeDoc.reference
          .collection('Record')
          .get();

      // Loop through each record and filter based on search conditions
      for (var recordDoc in recordSnapshot.docs) {
        final recordData = recordDoc.data() as Map<String, dynamic>;

        final checkInTime = recordData['checkIn'] ?? 'ບໍມີຂໍໍມູນ';
        final checkOutTime = recordData['checkOut'] ?? 'ບໍມີຂໍໍມູນ';
        final status = recordData['status'] ?? 'ບໍມີຂໍໍມູນ';

        bool matchesName = true; // Flag for matching name
        bool matchesStatus = true; // Flag for matching status

        // Check if we're searching by name
        if (widget.searchName.isNotEmpty && employeeName != widget.searchName) {
          matchesName = false; // Exclude this record if the name doesn't match
        }

        // Check if we're searching by status
        if (widget.searchStatus.isNotEmpty && status != widget.searchStatus) {
          matchesStatus = false; // Exclude this record if the status doesn't match
        }

        // Include the record if it matches either the name or the status
        if (matchesName || matchesStatus) {
          Timestamp? date = recordData['date'];
          if (date != null) {
            DateTime recordDate = date.toDate();

            // If searching by monthDate, exclude records not in that month
            if (widget.dayDate != null) {
              if (recordDate.year != widget.dayDate!.year || recordDate.month != widget.dayDate!.month  || recordDate.day!= widget.dayDate!.day) {
                continue; // Skip this record if it's not in the selected month
              }
            }
          }

          // Convert Firestore timestamp to string
          String formattedDate = date != null
              ? DateFormat.MMMMEEEEd().format(date.toDate())
              : 'ບໍມີຂໍໍມູນ';

          // Add filtered data to employeeData
          employeeData.add({
            'name': employeeName,
            'checkIn': checkInTime,
            'checkOut': checkOutTime,
            'status': status,
            'date': formattedDate,
          });
        }
      }
    }



    Uint8List logoData = (await rootBundle.load('assets/icons/images.png'))
        .buffer.asUint8List();
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
                        '  ມະຫາວິທະຍາໄລສຸພານຸວົງ ຄະນະວິສະວະກໍາສາດ',
                        style: pw.TextStyle(
                          font: font1,
                          fontSize: 25,
                        ),
                      ),
                      pw.Text(
                        ' ລາຍງານຂໍ້ມູນປະຈໍາການ',
                        style: pw.TextStyle(
                          font: font1,
                          fontSize: 25,
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
                          'ລາຍງານປະຈໍາເດືອນ:  ${widget.dayDate != null ? DateFormat('dd MMMM ','lo').format(widget.dayDate!) : ''}', // Add appropriate value if needed
                          style: pw.TextStyle(
                            font: font1,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          'ລາຍງານມາປະຈໍາການ: ${widget.searchName}', // Add appropriate value if needed
                          style: pw.TextStyle(
                            font: font1,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          'ລາຍງານສະຖານະ: ${widget.searchStatus}', // Add appropriate value if needed
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
                      fontSize: 20,
                    ),
                    headers: ['ຊື່ ແລະ ນາມສະກຸນ','ວັນທີ /ເດືອນ', 'ເຂົ້າວຽກ', 'ອອກວຽກ', 'ສະຖານະ'],
                    data: employeeData.map((entry) =>
                    [
                      entry['name'].toString(),
                      entry['date'].toString(),
                      entry['checkIn'].toString(), // Display check-in time
                      entry['checkOut'].toString(), // Display check-out time
                      entry['status'].toString(), // Display status
                    ]).toList(),
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
