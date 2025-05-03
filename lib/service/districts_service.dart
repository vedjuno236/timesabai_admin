import 'package:admin_timesabai/models/provinces_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiServiceDis {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ProvincesModel>> fetchProvinces() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Provinces').get();

      return snapshot.docs.map((doc) {
        return ProvincesModel(
          id: doc.id,
          name: doc['name'] ?? 'Unnamed provinces',
        );
      }).toList();
    } catch (e) {
      print('Error fetching provinces: $e');
      return [];
    }
  }
}
