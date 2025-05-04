import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class ReportNameRecord extends StatefulWidget {
  final String searchName;
  final DateTime? monthDate;

  const ReportNameRecord(
      {super.key, required this.searchName, required this.monthDate});

  @override
  State<ReportNameRecord> createState() => _ReportEmployeeState();
}

class _ReportEmployeeState extends State<ReportNameRecord> {
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

    for (var employeeDoc in employeeSnapshot.docs) {
      final employeeDataMap = employeeDoc.data() as Map<String, dynamic>;

      // ตรวจสอบว่าชื่อพนักงานตรงกับคำค้นหา
      final employeeName =
          employeeDataMap['name']?.toString().toLowerCase() ?? '';
      if (widget.searchName.isNotEmpty &&
          !employeeName.contains(widget.searchName.toLowerCase())) {
        continue; // ข้ามพนักงานนี้หากชื่อไม่ตรงกับคำค้นหา
      }

      // ดึงข้อมูล Record ภายในเอกสารพนักงาน
      final recordSnapshot =
          await employeeDoc.reference.collection('Record').get();

      for (var recordDoc in recordSnapshot.docs) {
        final recordData = recordDoc.data() as Map<String, dynamic>;

        // ดึงข้อมูลที่เกี่ยวข้องจาก Record
        final checkInTime = recordData['checkIn'] ?? 'ບໍມີຂໍໍມູນ';
        final checkOutTime = recordData['checkOut'] ?? 'ບໍມີຂໍໍມູນ';
        final status = recordData['status'] ?? 'ບໍມີຂໍໍມູນ';

        Timestamp? dateTimestamp = recordData['date'];
        DateTime? recordDate = dateTimestamp?.toDate();

        // ตรวจสอบว่า Record ตรงกับเดือนที่เลือกหรือไม่
        bool matchesMonth = true;
        if (widget.monthDate != null && recordDate != null) {
          matchesMonth = recordDate.year == widget.monthDate!.year &&
              recordDate.month == widget.monthDate!.month;
        }

        if (matchesMonth) {
          String formattedDate = recordDate != null
              ? DateFormat.MMMMEEEEd().format(recordDate)
              : 'ບໍມີຂໍໍມູນ';

          // เพิ่มข้อมูลที่กรองแล้วลงใน employeeData
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
                        '  ມະຫາວິທະຍາໄລສຸພານຸວົງ ຄະນະວິສະວະກໍາສາດ',
                        style: pw.TextStyle(
                          font: font1,
                          fontSize: 25,
                        ),
                      ),
                       pw.Text(
                        '   ຄະນະວິສະວະກໍາສາດ',
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
                      // Update the following fields accordingly
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          'ລາຍງານປະຈໍາເດືອນ:  ${widget.monthDate != null ? DateFormat('dd MMMM ', 'lo').format(widget.monthDate!) : ''}', // Add appropriate value if needed
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
                      'ວັນທີ /ເດືອນ',
                      'ເຂົ້າວຽກ',
                      'ອອກວຽກ',
                      'ສະຖານະ'
                    ],
                    data: employeeData
                        .map((entry) => [
                              entry['name'].toString(),
                              entry['date'].toString(),
                              entry['checkIn']
                                  .toString(), // Display check-in time
                              entry['checkOut']
                                  .toString(), // Display check-out time
                              entry['status'].toString(), // Display status
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
