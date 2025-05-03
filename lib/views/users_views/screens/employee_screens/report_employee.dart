import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../service/employee_service.dart';

class ReportEmployee extends StatefulWidget {
  final String docID;

  const ReportEmployee({super.key, required this.docID});

  @override
  State<ReportEmployee> createState() => _ReportEmployeeState();
}

class _ReportEmployeeState extends State<ReportEmployee> {
  final EmployeeService employeeService = EmployeeService();

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

    final font1 =
        pw.Font.ttf(await rootBundle.load('assets/fonts/BoonHome-400.ttf'));

    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Employee').get();

    final List<Map<String, String>> employeeData = await Future.wait(
      querySnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final department =
            await employeeService.getDepartment(data['departmentId']);
        final position = await employeeService.getPosition(data['positionId']);
        final agencyId = data['agenciesId'] as String?;
        final agency =
            agencyId != null ? await employeeService.getAgency(agencyId) : null;

        final ethnicityId = data['ethnicityId'] as String?;
        final ethnicity = ethnicityId != null
            ? await employeeService.getEthnicity(ethnicityId)
            : null;

        final provincesId = data['provincesId'] as String?;
        final provinces = provincesId != null
            ? await employeeService.getProvince(provincesId)
            : null;
        final city = data['city'] as String?;
        final citys = city != null ? await employeeService.getCity(city) : null;

        print("citys: ${citys?.name}");

        final branchId = data['branchId'] as String?;
        final branch =
            branchId != null ? await employeeService.getBranch(branchId) : null;

        print("branchId: ${branch?.name}");

        return {
          'id': data['id']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'name': data['name']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'gender': data['gender']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'status': data['status']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'village': data['village']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'dateOfBirth': data['dateOfBirth']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'phone': data['phone']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'department': department?.name ?? 'ບໍມີຂໍ້ມູນ',
          'position': position?.name ?? 'ບໍມີຂໍ້ມູນ',
          'email': data['email']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'career': data['career']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'nationality': data['nationality']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'qualification': data['qualification']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'responsible': data['responsible']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'graduated': data['graduated']?.toString() ?? 'ບໍມີຂໍ້ມູນ',
          'agency': agency?.name ?? 'ບໍມີຂໍ້ມູນ',
          'ethnicity': ethnicity?.name ?? 'ບໍມີຂໍ້ມູນ',
          'provinces': provinces?.name ?? '',
          'city': citys?.name ?? '',
          'branch': branch?.name ?? '',
        };
      }).toList(),
    );

    // Load logo image
    Uint8List logoData =
        (await rootBundle.load('assets/icons/images.png')).buffer.asUint8List();

    // Add content to the PDF
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
                          fontSize: 15,
                        ),
                      ),
                      pw.Text(
                        ' ລາຍງານຂໍ້ມູນພະນັກງານ',
                        style: pw.TextStyle(
                          font: font1,
                          fontSize: 15,
                        ),
                      ),
                      pw.Text(
                        'ວັນທີລາຍງານ : $formattedDateTime',
                        style: pw.TextStyle(
                          font: font1,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                // Table displaying employee data
                pw.Center(
                  child: pw.Table.fromTextArray(
                    context: context,
                    cellAlignment: pw.Alignment.center,
                    headerStyle: pw.TextStyle(
                      font: font1, // Use bold font for headers
                      fontSize: 8,
                    ),
                    headers: [
                      'ລະຫັດ',
                      'ຊື່',
                      'ເພດ',
                      'ວດປ',
                      'ເບິໂທ',
                      'ອີເມວ',
                      'ພາກ',
                      'ສາຂາ',
                      'ຕໍາແໜ່ງ',
                      'ສະຖານະພາບ',
                      'ວິຊາສະເພາະ',
                      'ສັນຊາດ',
                      'ລະດັບການສືກສາ',
                      'ໜ້າທີຮັບຜິດຊອບ',
                      'ສະຖານທີຈົບ',
                      'ພະແນກ',
                      'ຊົນເຜົ່າ',
                      'ແຂວງ',
                      'ເມືອງ',
                      'ບ້ານ',
                    ],
                    data: employeeData
                        .map((entry) => [
                              entry['id'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['name'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['gender'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['dateOfBirth'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['phone'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['email'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['department'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['branch'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['position'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['status'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['career'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['nationality'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['qualification'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['responsible'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['graduated'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['agency'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['ethnicity'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['provinces'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['city'] ?? 'ບໍມີຂໍ້ມູນ',
                              entry['village'] ?? 'ບໍມີຂໍ້ມູນ',
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
