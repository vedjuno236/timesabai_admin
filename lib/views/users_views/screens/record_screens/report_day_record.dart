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
  final DateTime? dayDate;

  const ReportDayRecord(
      {super.key, required this.searchName, required this.dayDate});

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
      bool matchesName = true;
      // Check if we're searching by name
      if (widget.searchName.isNotEmpty &&
          !employeeName
              .toLowerCase()
              .contains(widget.searchName.toLowerCase())) {
        matchesName = false;
      }

      final recordSnapshot = await employeeDoc.reference
          .collection('Record')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(targetDate.year, targetDate.month, targetDate.day)))
          .where('date',
              isLessThan: Timestamp.fromDate(DateTime(
                  targetDate.year, targetDate.month, targetDate.day + 1)))
          .get();
      final leaveSnapshot =
          await employeeDoc.reference.collection('Leave').get();

      bool hasRecord = false;
      bool isOnLeave = false;
      for (var leaveDoc in leaveSnapshot.docs) {
        final leaveData = leaveDoc.data() as Map<String, dynamic>;
        final leaveStart = (leaveData['fromDate'] as Timestamp?)?.toDate();
        final leaveEnd = (leaveData['toDate'] as Timestamp?)?.toDate();

        if (leaveStart != null && leaveEnd != null) {
          if (targetDate.isAfter(leaveStart.subtract(Duration(days: 1))) &&
              targetDate.isBefore(leaveEnd.add(Duration(days: 1)))) {
            isOnLeave = true;
            break;
          }
        }
      }
      for (var recordDoc in recordSnapshot.docs) {
        final recordData = recordDoc.data() as Map<String, dynamic>;

        // Check and replace missing or empty data with '----/----'
        final clockInAM = (recordData['clockInAM'] == null ||
                recordData['clockInAM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
                (recordData['clockInAM'] is String &&
                    recordData['clockInAM'].isEmpty))
            ? '------'
            : recordData['clockInAM'];
        final clockOutAM = (recordData['clockOutAM'] == null ||
                recordData['clockOutAM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
                (recordData['clockOutAM'] is String &&
                    recordData['clockOutAM'].isEmpty))
            ? '------'
            : recordData['clockOutAM'];
        final clockInPM = (recordData['clockInPM'] == null ||
                recordData['clockInPM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
                (recordData['clockInPM'] is String &&
                    recordData['clockInPM'].isEmpty))
            ? '------'
            : recordData['clockInPM'];
        final clockOutPM = (recordData['clockOutPM'] == null ||
                recordData['clockOutPM'] == 'ບໍ່ມີຂໍ້ມູນ' ||
                (recordData['clockOutPM'] is String &&
                    recordData['clockOutPM'].isEmpty))
            ? '------'
            : recordData['clockOutPM'];
        // Determine status based on clockInAM and clockInPM
        String status = recordData['status'] ?? 'ບໍ່ມີຂໍ້ມູນ';

        if (isOnLeave) {
          if (clockInAM == '------' &&
              clockOutAM == '------' &&
              clockInPM == '------' &&
              clockOutPM == '------') {
            status = 'ລາພັກ';
          } else if ((clockInAM != '------' && clockOutAM != '------') ||
              (clockInPM != '------' && clockOutPM != '------')) {
            status = 'ລາພັກ 1 ຕອນ'; // Partial leave day
          }
        } else if ((clockInAM == '------' &&
                (clockOutAM != '------' || clockOutPM != '------')) ||
            (clockInPM == '------' &&
                (clockOutAM != '------' || clockOutPM != '------'))) {
          status = 'ມາວຽກ1ຕອນ';
        }
        print('  Final status: $status');

        hasRecord = true;

        if (widget.searchName.isEmpty ||
            employeeName
                .toLowerCase()
                .contains(widget.searchName.toLowerCase())) {
          employeeData.add({
            'name': employeeName,
            'clockInAM': clockInAM,
            'clockOutAM': clockOutAM,
            'clockInPM': clockInPM,
            'clockOutPM': clockOutPM,
            'status': status,
            'date': formattedTargetDate,
          });
        }
      }

      if (!hasRecord) {
        if (widget.searchName.isEmpty || widget.searchName == 'ຂາດວຽກ') {
          employeeData.add({
            'name': employeeName,
            'clockInAM': '------',
            'clockOutAM': '------',
            'clockInPM': '------',
            'clockOutPM': '------',
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
                          'ລາຍງານສະຖານະ: ${widget.searchName.isEmpty ? 'ທັງໝົດ' : widget.searchName}',
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
                              'ເຂົ້າວຽກເຊົ້າ',
                              style: pw.TextStyle(font: font1, fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'ອອກວຽກເຊົ້າ',
                              style: pw.TextStyle(font: font1, fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'ເຂົ້າວຽກແລງ',
                              style: pw.TextStyle(font: font1, fontSize: 10),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'ອອກວຽກແລງ',
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
                                entry['clockInAM'].toString(),
                                style: pw.TextStyle(font: font1, fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                entry['clockOutAM'].toString(),
                                style: pw.TextStyle(font: font1, fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                entry['clockInPM'].toString(),
                                style: pw.TextStyle(font: font1, fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                entry['clockOutPM'].toString(),
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
                                  color: entry['status'] == 'ວັນພັກ'
                                      ? PdfColors.blue
                                      : entry['status'] == 'ຂາດວຽກ'
                                          ? PdfColors.red
                                          : entry['status'] == 'ມາວຽກຊ້າ'
                                              ? PdfColors.pink
                                              : entry['status'] == 'ມາວຽກ1ຕອນ'
                                                  ? PdfColors.blueAccent
                                                  : entry['status'] == 'ລາພັກ'
                                                      ? PdfColors.green
                                                      : entry['status'] ==
                                                              'ລາພັກ 1 ຕອນ'
                                                          ? PdfColors
                                                              .greenAccent
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
