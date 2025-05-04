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

  const ReportDayRecord(
      {super.key,
      required this.searchName,
      required this.searchStatus,
      required this.dayDate});

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
    final font1 =
        pw.Font.ttf(await rootBundle.load('assets/fonts/BoonHome-400.ttf'));

    // Fetch employees from Firestore
    final QuerySnapshot employeeSnapshot =
        await FirebaseFirestore.instance.collection('Employee').get();

    List<Map<String, dynamic>> employeeData = [];

    // Get the date to filter (current date or widget.dayDate)
    final targetDate = widget.dayDate ?? DateTime.now();
    final formattedTargetDate = DateFormat.MMMMEEEEd().format(targetDate);

    // Loop through each employee document
    for (var employeeDoc in employeeSnapshot.docs) {
      final employeeDataMap = employeeDoc.data() as Map<String, dynamic>;
      final employeeName = employeeDataMap['name'] ?? 'ບໍ່ມີຂໍ້ມູນ';

      // Check if we're searching by name
      if (widget.searchName.isNotEmpty && employeeName != widget.searchName) {
        continue; // Skip if name doesn't match
      }

      // Fetch employee records from the 'Record' subcollection for the target date
      final recordSnapshot = await employeeDoc.reference
          .collection('Record')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(targetDate.year, targetDate.month, targetDate.day)))
          .where('date',
              isLessThan: Timestamp.fromDate(DateTime(
                  targetDate.year, targetDate.month, targetDate.day + 1)))
          .get();

      bool hasRecord = false;

      // Loop through records to find matching date and status
      for (var recordDoc in recordSnapshot.docs) {
        final recordData = recordDoc.data() as Map<String, dynamic>;
        final checkInTime = recordData['checkIn'] ?? 'ບໍ່ມີຂໍ້ມູນ';
        final checkOutTime = recordData['checkOut'] ?? 'ບໍ່ມີຂໍ້ມູນ';
        final status = recordData['status'] ?? 'ບໍ່ມີຂໍ້ມູນ';

        // Check if status matches search criteria
        if (widget.searchStatus.isNotEmpty && status != widget.searchStatus) {
          continue; // Skip if status doesn't match
        }

        hasRecord = true;

        // Add record data
        employeeData.add({
          'name': employeeName,
          'checkIn': checkInTime,
          'checkOut': checkOutTime,
          'status': status,
          'date': formattedTargetDate,
        });
      }

      if (!hasRecord) {
        // Only add the employee if searchStatus is empty or matches "ຂາດວຽກ"
        if (widget.searchStatus.isEmpty || widget.searchStatus == 'ຂາດວຽກ') {
          employeeData.add({
            'name': employeeName,
            'checkIn': '----/----',
            'checkOut': '----/----',
            'status': 'ຂາດວຽກ',
            'date': formattedTargetDate,
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
                        '  ຄະນະວິສະວະກໍາສາດ',
                        style: pw.TextStyle(
                          font: font1,
                          fontSize: 20,
                        ),
                      ),
                      pw.Text(
                        ' ລາຍງານຂໍ້ມູນປະຈໍາການ',
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
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          'ລາຍງານປະຈໍາເດືອນ: ${DateFormat('dd MMMM ', 'lo').format(targetDate)}',
                          style: pw.TextStyle(
                            font: font1,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          'ລາຍງານມາປະຈໍາການ: ${widget.searchName.isEmpty ? 'ທັງໝົດ' : widget.searchName}',
                          style: pw.TextStyle(
                            font: font1,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          'ລາຍງານສະຖານະ: ${widget.searchStatus.isEmpty ? 'ທັງໝົດ' : widget.searchStatus}',
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
                // Table displaying employee data with conditional status color
                pw.Center(
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    defaultColumnWidth: pw.IntrinsicColumnWidth(),
                    defaultVerticalAlignment:
                        pw.TableCellVerticalAlignment.middle,
                    children: [
                      // Header row
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'ຊື່ ແລະ ນາມສະກຸນ',
                              style: pw.TextStyle(font: font1, fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'ວັນທີ /ເດືອນ',
                              style: pw.TextStyle(font: font1, fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'ເຂົ້າວຽກ',
                              style: pw.TextStyle(font: font1, fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'ອອກວຽກ',
                              style: pw.TextStyle(font: font1, fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'ສະຖານະ',
                              style: pw.TextStyle(font: font1, fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      // Data rows
                      ...employeeData.map(
                        (entry) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                entry['name'].toString(),
                                style: pw.TextStyle(font: font1, fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                entry['date'].toString(),
                                style: pw.TextStyle(font: font1, fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                entry['checkIn'].toString(),
                                style: pw.TextStyle(font: font1, fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                entry['checkOut'].toString(),
                                style: pw.TextStyle(font: font1, fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                entry['status'].toString(),
                                style: pw.TextStyle(
                                  font: font1,
                                  fontSize: 10,
                                  color: entry['status'] == 'ຂາດວຽກ'
                                      ? PdfColors.red
                                      : PdfColors.black,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
