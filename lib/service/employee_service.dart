import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Employee>> searchEmployees(String searchText) {
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

  Future<Department?> getDepartment(String departmentId) async {
    try {
      final doc =
          await _firestore.collection('Department').doc(departmentId).get();
      return doc.exists ? Department.fromFirestore(doc) : null;
    } catch (e) {
      print('Error fetching department: $e');
      return null;
    }
  }

  Future<Position?> getPosition(String positionId) async {
    try {
      final doc = await _firestore.collection('Position').doc(positionId).get();
      return doc.exists ? Position.fromFirestore(doc) : null;
    } catch (e) {
      print('Error fetching position: $e');
      return null;
    }
  }

  Future<Agency?> getAgency(String agencyId) async {
    try {
      final doc = await _firestore.collection('Agencies').doc(agencyId).get();
      return doc.exists ? Agency.fromFirestore(doc) : null;
    } catch (e) {
      print('Error fetching agency: $e');
      return null;
    }
  }

  Future<Ethnicity?> getEthnicity(String ethnicityId) async {
    try {
      final doc =
          await _firestore.collection('Ethnicity').doc(ethnicityId).get();
      return doc.exists ? Ethnicity.fromFirestore(doc) : null;
    } catch (e) {
      print('Error fetching agency: $e');
      return null;
    }
  }

  Future<Provinces?> getProvince(String provincesId) async {
    try {
      final doc =
          await _firestore.collection('Provinces').doc(provincesId).get();
      return doc.exists ? Provinces.fromFirestore(doc) : null;
    } catch (e) {
      print('Error:$e');
      return null;
    }
  }

  Future<Citys?> getCity(String city) async {
    try {
      final doc = await _firestore.collection('Districts').doc(city).get();
      return doc.exists ? Citys.fromFirestore(doc) : null;
    } catch (e) {
      print('Error:$e');
      return null;
    }
  }

  Future<Branch?> getBranch(String branchId) async {
    try {
      final doc = await _firestore.collection('Branch').doc(branchId).get();
      return doc.exists ? Branch.fromFirestore(doc) : null;
    } catch (e) {
      print('Error:$e');
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
  final String branchId;
  final String positionId;
  final String dateOfBirth;
  final String phone;
  final String password;
  final String agenciesId;
  final String ethnicityId;
  final String provincesId;
  final String city;

  Employee({
    required this.employeeId,
    required this.id,
    required this.password,
    required this.name,
    required this.profileImage,
    required this.departmentId,
    required this.branchId,
    required this.positionId,
    required this.dateOfBirth,
    required this.phone,
    required this.agenciesId,
    required this.ethnicityId,
    required this.provincesId,
    required this.city,
  });

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
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
      agenciesId: data?['agenciesId'] ?? '',
      ethnicityId: data?['ethnicityId'] ?? '',
      provincesId: data?['provincesId'] ?? '',
      city: data?['city'] ?? '',
      branchId: data?['branchId'] ?? '',
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

class Agency {
  final String id;
  final String name;

  Agency({required this.id, required this.name});

  factory Agency.fromFirestore(DocumentSnapshot doc) {
    return Agency(
      id: doc.id,
      name: doc['name'] ?? '',
    );
  }
}

class Ethnicity {
  final String id;
  final String name;

  Ethnicity({required this.id, required this.name});

  factory Ethnicity.fromFirestore(DocumentSnapshot doc) {
    return Ethnicity(
      id: doc.id,
      name: doc['name'] ?? '',
    );
  }
}

class Provinces {
  final String id;
  final String name;

  Provinces({required this.id, required this.name});

  factory Provinces.fromFirestore(DocumentSnapshot doc) {
    return Provinces(
      id: doc.id,
      name: doc['name'] ?? '',
    );
  }
}

class Citys {
  final String id;
  final String name;

  Citys({required this.id, required this.name});

  factory Citys.fromFirestore(DocumentSnapshot doc) {
    return Citys(
      id: doc.id,
      name: doc['name'] ?? '',
    );
  }
}

class Branch {
  final String id;
  final String name;

  Branch({required this.id, required this.name});

  factory Branch.fromFirestore(DocumentSnapshot doc) {
    return Branch(
      id: doc.id,
      name: doc['name'] ?? '',
    );
  }
}
