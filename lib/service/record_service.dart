

import 'package:cloud_firestore/cloud_firestore.dart';

class RecordService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> getUsers() async {
    QuerySnapshot usersSnapshot = await _db.collection('Employee').get();
    return usersSnapshot.docs;
  }

  Future<List<DocumentSnapshot>> getUserMessages(String userId) async {
    QuerySnapshot messagesSnapshot = await _db
        .collection('Employee')
        .doc(userId)
        .collection('Record')
        .get();
    return messagesSnapshot.docs;
  }

  Future<void> addMessage(
      String userId,
      String checkIn,
      String checkOut,
      Timestamp date,
      String status,
      String checkOutLocation,
      String checkInLocation,
      ) async {
    await _db.collection('Employee').doc(userId).collection('Record').add({
      'checkIn': checkIn,
      'checkOut': checkOut,
      'date': date,
      'checkOutLocation': checkOutLocation,
      'checkInLocation': checkInLocation,
      'status': status,
    });
  }
  Future<List<DocumentSnapshot>> searchRecordsInSubCollection(String userId, String searchText) async {
    var result = await _db
        .collection('Employee')
        .doc(userId)
        .collection('Record')
        .where('status', isGreaterThanOrEqualTo: searchText)
          .where('status', isLessThanOrEqualTo: '$searchText\uf8ff')
        .get();
    return result.docs;
  }
}



