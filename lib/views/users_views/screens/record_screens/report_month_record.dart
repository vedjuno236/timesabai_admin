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
      final employeeDataMap = employeeDoc.data();
      final employeeName = employeeDataMap['name'] ?? 'ບໍ່ມີຂໍ້ມູນ';

      // Filter by name if provided
      if (widget.searchName.isNotEmpty && employeeName != widget.searchName) {
        continue;
      }

      final recordSnapshot =
          await employeeDoc.reference.collection('Record').get();
      final records = recordSnapshot.docs;

      for (int i = 0; i < lastDayOfMonth.day; i++) {
        final currentDate = firstDayOfMonth.add(Duration(days: i));

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
          final status = data['status'] ?? 'ບໍ່ມີຂໍ້ມູນ';

          // Filter by status if provided
          if (widget.searchStatus.isNotEmpty && status != widget.searchStatus) {
            continue;
          }

          employeeData.add({
            'name': employeeName,
            'date': DateFormat.MMMMEEEEd('lo').format(currentDate),
            'checkIn': data['checkIn'] ?? '----/----',
            'checkOut': data['checkOut'] ?? '----/----',
            'status': status,
          });
        } else {
          final isWeekend =
              currentDate.weekday == 6 || currentDate.weekday == 7;
          employeeData.add({
            'name': employeeName,
            'date': DateFormat.MMMMEEEEd('lo').format(currentDate),
            'checkIn': '----/----',
            'checkOut': '----/----',
            'status': isWeekend ? 'ວັນພັກ' : 'ຂາດວຽກ',
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
                    'ລາຍງານປະຈໍາເດືອນ:  ${widget.monthDate != null ? DateFormat(' MMMM ', 'lo').format(widget.monthDate!) : ''}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 15,
                    ),
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'ລາຍງານມາປະຈໍາການ: ${widget.searchName}',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                    ),
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'ລາຍງານສະຖານະ: ${widget.searchStatus}',
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
            border: pw.TableBorder.all(), // Add borders to the table
            columnWidths: {
              0: pw.FlexColumnWidth(2), // Name
              1: pw.FlexColumnWidth(2), // Date
              2: pw.FlexColumnWidth(1), // CheckIn
              3: pw.FlexColumnWidth(1), // CheckOut
              4: pw.FlexColumnWidth(1), // Status
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
                        fontSize: 14,
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
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'ເຂົ້າ',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'ອອກ',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'ສະຖານະ',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 14,
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
                        style: pw.TextStyle(font: font, fontSize: 12),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        e['date'],
                        style: pw.TextStyle(font: font, fontSize: 12),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        e['checkIn'],
                        style: pw.TextStyle(font: font, fontSize: 12),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        e['checkOut'],
                        style: pw.TextStyle(font: font, fontSize: 12),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        e['status'],
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 12,
                          color: e['status'] == 'ວັນພັກ'
                              ? PdfColors.blue
                              : e['status'] == 'ຂາດວຽກ'
                                  ? PdfColors.red
                                  : PdfColors.black,
                        ),
                        textAlign: pw.TextAlign.left,
                      ),
                    )
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
