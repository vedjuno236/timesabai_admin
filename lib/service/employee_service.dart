import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retrieves a stream of employees filtered by [searchText].
  Stream<List<Employee>> searchEmployees(String searchText) {
    // If searchText is empty, we can return all employees
    if (searchText.isEmpty) {
      return _firestore.collection('Employee').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Employee.fromFirestore(doc)).toList();
      });
    }

    return _firestore.collection('Employee').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Employee.fromFirestore(doc))
          .where((employee) =>
          employee.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  /// Retrieves a department by [departmentId].
  Future<Department?> getDepartment(String departmentId) async {
    try {
      final doc = await _firestore.collection('Department').doc(departmentId).get();
      return doc.exists ? Department.fromFirestore(doc) : null;
    } catch (e) {
      // Handle error (e.g., log the error or rethrow)
      print('Error fetching department: $e');
      return null;
    }
  }

  /// Retrieves a position by [positionId].
  Future<Position?> getPosition(String positionId) async {
    try {
      final doc = await _firestore.collection('Position').doc(positionId).get();
      return doc.exists ? Position.fromFirestore(doc) : null;
    } catch (e) {
      // Handle error (e.g., log the error or rethrow)
      print('Error fetching position: $e');
      return null;
    }
  }


  Future<void> deleteEmployee(String employeeId) async {
    try {
      await _firestore.collection('Employee').doc(employeeId).delete();
      print('Employee with id $employeeId deleted successfully');
    } catch (e) {
      print('Error deleting employee: $e');
    }
  }
}

class Employee {
  final String id;
  final String employeeId;
  final String name;
  final String profileImage;
  final String departmentId;
  final String positionId;
  final String dateOfBirth;
  final String phone;
  final String password;

  Employee({
    required this.employeeId,
    required this.id,
    required this.password,
    required this.name,
    required this.profileImage,
    required this.departmentId,
    required this.positionId,
    required this.dateOfBirth,
    required this.phone,
  });

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    return Employee(
      id: doc.id,
      name: doc['name'] ?? '',
      password: doc['password'] ?? '',
      employeeId: doc['id'] ?? '',
      profileImage: doc['profileImage'] ?? '',
      departmentId: doc['departmentId'] ?? '',
      positionId: doc['positionId'] ?? '',
      dateOfBirth: doc['dateOfBirth'] ?? '',
      phone: doc['phone'] ?? '',
    );
  }
}

class Department {
  final String id;
  final String name;

  Department({required this.id, required this.name});

  factory Department.fromFirestore(DocumentSnapshot doc) {
    return Department(
      id: doc.id,
      name: doc['name'] ?? '',
    );
  }
}

class Position {
  final String id;
  final String name;

  Position({required this.id, required this.name});

  factory Position.fromFirestore(DocumentSnapshot doc) {
    return Position(
      id: doc.id,
      name: doc['name'] ?? '',
    );
  }
}
