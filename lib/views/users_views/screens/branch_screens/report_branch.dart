import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportBranch extends StatefulWidget {
  final String docId; // Assuming you're passing document ID as a String
  ReportBranch({required this.docId});

  @override
  State<ReportBranch> createState() => _ReportBranchState();
}

class _ReportBranchState extends State<ReportBranch> {
  late String _name;
  final formattedDateTime = DateFormat.yMMMMEEEEd().format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      canChangeOrientation: false,
      build: (format) => generateDocument(format),
    );
  }

  Future<Map<String, dynamic>> _getDepartmentData(String departmentId) async {
    // Fetch the department document based on departmentId
    final departmentDoc = await FirebaseFirestore.instance
        .collection('Department')
        .doc(departmentId)
        .get();

    // Return the department name (or any other fields you need)
    return {
      'name': departmentDoc.data()?['name'] ?? 'Unknown',
    };
  }

  Future<Uint8List> generateDocument(PdfPageFormat format) async {
    final doc = pw.Document(pageMode: PdfPageMode.outlines);

    // Load custom font
    final font1 = pw.Font.ttf(await rootBundle.load('assets/fonts/BoonHome-400.ttf'));

    // Fetch data from Firestore
    final QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('Branch').get();

    // Fetch department names for each branch
    final List<Map<String, dynamic>> branchData = await Future.wait(querySnapshot.docs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;
      final departmentData = await _getDepartmentData(data['departmentId']);

      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'departmentName': departmentData['name'], // Get department name
      };
    }).toList());

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
                        headers: ['ລະຫັດ', 'ສາຂາ', 'ພາກວິຊາ'],
                        data: branchData
                            .map((entry) => [
                          entry['id'].toString(),
                          entry['name'].toString(),
                          entry['departmentName'].toString(),
                        ]).toList(),
                      ),
                    ),
                  ]));
        },
      ),
    );
    return doc.save();
  }
}
