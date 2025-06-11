import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportMonthStatus extends StatefulWidget {
  final String searchstatus;
  final DateTime? Month;

  const ReportMonthStatus(
      {super.key, required this.searchstatus, required this.Month});

  @override
  State<ReportMonthStatus> createState() => _ReportEmployeeState();
}

class _ReportEmployeeState extends State<ReportMonthStatus> {
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

    // Fetch employees from Firestore
    final QuerySnapshot employeeSnapshot =
        await FirebaseFirestore.instance.collection('Employee').get();

    List<Map<String, dynamic>> employeeData = [];

    // Loop through each employee document
    for (var employeeDoc in employeeSnapshot.docs) {
      final employeeDataMap = employeeDoc.data() as Map<String, dynamic>;

      final employeeName = employeeDataMap['name'] ?? 'ບໍ່ມີຂໍ້ມູນ';

      final recordSnapshot =
          await employeeDoc.reference.collection('Record').get();

      for (var recordDoc in recordSnapshot.docs) {
        final recordData = recordDoc.data() as Map<String, dynamic>;

        final clockInAM = recordData['clockInAM'] ?? 'ບໍ່ມີຂໍ້ມູນ';
        final clockOutAM = recordData['clockOutAM'] ?? 'ບໍ່ມີຂໍ້ມູນ';
        final clockInPM = recordData['clockInPM'] ?? 'ບໍ່ມີຂໍ້ມູນ';
        final clockOutPM = recordData['clockOutPM'] ?? 'ບໍ່ມີຂໍ້ມູນ';
        final status = recordData['status'] ?? 'ບໍ່ມີຂໍ້ມູນ';
        final typeClockOut = recordData['type_clock_out'] ?? 'ບໍ່ມີຂໍ້ມູນ';
        final statusOutDoor = (recordData['status_out_door'] == null ||
                recordData['status_out_door'] == 'ບໍ່ມີຂໍ້ມູນ' ||
                (recordData['status_out_door'] is String &&
                    recordData['status_out_door'].trim().isEmpty))
            ? '------'
            : recordData['status_out_door'];

        bool matchesStatus = true;
        if (widget.searchstatus.isNotEmpty) {
          if (!status
                  .toLowerCase()
                  .contains(widget.searchstatus.toLowerCase()) &&
              !typeClockOut
                  .toLowerCase()
                  .contains(widget.searchstatus.toLowerCase())) {
            matchesStatus = false;
          }
        }

        if (matchesStatus) {
          Timestamp? date = recordData['date'];
          if (date != null) {
            DateTime recordDate = date.toDate();

            if (widget.Month != null) {
              if (recordDate.year != widget.Month!.year ||
                  recordDate.month != widget.Month!.month) {
                continue;
              }
            }

            employeeData.add({
              'name': employeeName,
              'date': DateFormat.MMMMEEEEd('lo').format(date.toDate()),
              'clockInAM': clockInAM,
              'clockOutAM': clockOutAM,
              'clockInPM': clockInPM,
              'clockOutPM': clockOutPM,
              'status': status,
              'status_out_door': statusOutDoor,

              'type_clock_out':
                  typeClockOut, // Add type_clock_out to employeeData
            });
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
            base: font,
            bold: font,
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
                          font: font,
                          fontSize: 25,
                        ),
                      ),
                      pw.Text(
                        'ຄະນະວິສະວະກໍາສາດ',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 20,
                        ),
                      ),
                      pw.Text(
                        ' ລາຍງານຂໍ້ມູນການອອກວຽກນອກ',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 18,
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
                          'ລາຍງານການລາພັກປະເດືອນ:  ${widget.Month != null ? DateFormat('MMMM yyyy', 'lo').format(widget.Month!) : ''}',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          'ລາຍງານສະຖານະ: ${widget.searchstatus}',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'ອອກວຽກນອກ',
                          style: pw.TextStyle(font: font, fontSize: 10),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2), // Name
                    1: pw.FlexColumnWidth(2), // Date
                    2: pw.FlexColumnWidth(1), // ClockInAM
                    3: pw.FlexColumnWidth(1), // ClockOutAM
                    4: pw.FlexColumnWidth(1), // ClockInPM
                    5: pw.FlexColumnWidth(1), // ClockOutPM
                    6: pw.FlexColumnWidth(1), // Status
                    7: pw.FlexColumnWidth(1), // Type Clock Out
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
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'ປະເພດການອອກວຽກ',
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
                            'ອອກວຽກນອກ',
                            style: pw.TextStyle(font: font, fontSize: 10),
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
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              e['clockOutPM'],
                              style: pw.TextStyle(font: font, fontSize: 10),
                              textAlign: pw.TextAlign.left,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
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
                                                    : e['status'] ==
                                                            'ລາພັກ 1 ຕອນ'
                                                        ? PdfColors.greenAccent
                                                        : PdfColors.black,
                              ),
                              textAlign: pw.TextAlign.left,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              e['type_clock_out'],
                              style: pw.TextStyle(font: font, fontSize: 10),
                              textAlign: pw.TextAlign.left,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              e['status_out_door'] != null &&
                                      e['status_out_door'] != 'null'
                                  ? e['status_out_door'].toString()
                                  : '------',
                              style: pw.TextStyle(font: font, fontSize: 10),
                              textAlign: pw.TextAlign.center,
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
        },
      ),
    );

    return doc.save();
  }
}
