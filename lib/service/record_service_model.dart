// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class FirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   // Method to search employees by status
//   Future<List<Employee>> getEmployeesWithRecords({String? status}) async {
//     final employeesSnapshot = await _db.collection('Employee').get();
//     List<Employee> employees = [];
//
//     for (var employeeDoc in employeesSnapshot.docs) {
//       CollectionReference<Map<String, dynamic>> recordsRef = employeeDoc.reference.collection('Record');
//
//       Query<Map<String, dynamic>> query = recordsRef;
//       if (status != null && status.isNotEmpty) {
//         query = recordsRef
//             .where('status', isGreaterThanOrEqualTo: status) // search condition
//             .where('status', isLessThanOrEqualTo: status + '\uf8ff');
//       }
//
//       final recordsSnapshot = await query.get();
//       List<Record> records = recordsSnapshot.docs.map((recordDoc) {
//         return Record(
//           checkIn: recordDoc['checkIn'] ?? '',
//           checkOut: recordDoc['checkOut'] ?? '',
//           status: recordDoc['status'] ?? '',
//           checkInLocation: recordDoc['checkInLocation'] ?? '',
//           checkOutLocation: recordDoc['checkOutLocation'] ?? '',
//         );
//       }).toList();
//
//
//       if (records.isNotEmpty) {
//         employees.add(Employee(
//           id: employeeDoc.id,
//           name: employeeDoc['name'] ?? '',
//           records: records,
//         ));
//       }
//     }
//
//     return employees;
//   }
// }
//
// class Employee {
//   final String id;
//   final String name;
//   final List<Record> records;
//
//   Employee({
//     required this.id,
//     required this.name,
//     required this.records,
//   });
// }
//
// class Record {
//   final String checkIn;
//   final String checkOut;
//   final String status;
//   final  String checkInLocation;
//   final  String checkOutLocation;
//
//   Record({
//     required this.checkIn,
//     required this.checkOut,
//     required this.status,
//     required this.checkInLocation,
//     required this.checkOutLocation,
//
//   });
// }
