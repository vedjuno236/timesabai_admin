import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/department_model.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DepartmentModel>> fetchDepartments() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Department').get();

      return snapshot.docs.map((doc) {
        return DepartmentModel(
          id: doc.id,
          name: doc['name'] ?? 'Unnamed Department',
        );
      }).toList();
    } catch (e) {
      print('Error fetching departments: $e');
      return [];
    }
  }
}
