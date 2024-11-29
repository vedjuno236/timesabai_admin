import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ReportDepartment extends StatefulWidget {
  final String docId; // Assuming you're passing document ID as a String
  ReportDepartment({required this.docId});

  @override
  State<ReportDepartment> createState() => _ReportDepartmentState();
}

class _ReportDepartmentState extends State<ReportDepartment> {
  late String _name;
  final formattedDateTime = DateFormat.yMMMMEEEEd().format(DateTime.now());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDateTime = DateFormat.yMMMMEEEEd().format(DateTime.now());
    return PdfPreview(
      canChangeOrientation: false,
      build: (format) => generateDocument(
        format,
      ),
    );
  }

  Future<Uint8List> generateDocument(PdfPageFormat format) async {
    final doc = pw.Document(pageMode: PdfPageMode.outlines);

    // Load custom font
    final font1 = pw.Font.ttf(await rootBundle.load('assets/fonts/BoonHome-400.ttf'));

    // Fetch data from Firestore
    final QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('Department').get();

    // Extract data from query snapshot
    final List<Map<String, dynamic>> busTypeData = querySnapshot.docs
        .map((doc) => {
      'id': doc.id, // Include the document ID
      ...doc.data() as Map<String, dynamic>, // Include other fields
    })
        .toList();
    Uint8List logoData = (await rootBundle.load('assets/icons/images.png')).buffer.asUint8List();

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
                            height: 100, // Explicit height for the container
                            child: pw.Image(
                              pw.MemoryImage(logoData),
                              fit: pw.BoxFit.contain,
                            ),
                          ),
                          pw.Text(
                            ' ຄະນະວິສະວະກໍາສາດ ມະຫາວິທະຍາໄລສຸພານຸວົງ ',
                            style: pw.TextStyle(
                              font: font1,
                              fontSize: 25,
                            ),
                          ),
                          pw.Text(
                            ' ລາຍງານຂໍ້ມູນພາກວິຊາ',
                            style: pw.TextStyle(
                              font: font1,
                              fontSize: 25,
                            ),
                          ),
                          pw.Text(
                            'ວັນທີລາຍງານ : $formattedDateTime',
                            style: pw.TextStyle(
                              font: font1,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    // Table displaying IDs and names
                    pw.Center(
                      child: pw.Table.fromTextArray(
                        context: context,
                        cellAlignment: pw.Alignment.center,
                        headerStyle: pw.TextStyle(
                          font: font1, // Use bold font for headers
                          fontSize: 20,
                        ),
                        headers: ['ລະຫັດ', 'ຊື່'],
                        data: busTypeData
                            .map((entry) =>
                        [entry['id'].toString(), entry['name'].toString()])
                            .toList(),
                      ),
                    ),
                  ]));
        },
      ),
    );

    return doc.save();
  }
}


