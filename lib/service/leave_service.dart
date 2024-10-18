import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LeaveService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> getUsers({String searchText = ''}) async {
    QuerySnapshot usersSnapshot;

    if (searchText.isNotEmpty) {
      usersSnapshot = await _db
          .collection('Employee')
          .where('name', isGreaterThanOrEqualTo: searchText)
          .where('name', isLessThanOrEqualTo: '$searchText\uf8ff')
          .get();
    } else {
      usersSnapshot = await _db.collection('Employee').get();
    }

    return usersSnapshot.docs;
  }

  Future<List<DocumentSnapshot>> getUserMessages(String userId, {String? date}) async {
    Query query = _db
        .collection('Employee')
        .doc(userId)
        .collection('Leave');

    if (date != null) {
      query = query.where('date', isEqualTo: DateFormat('dd MMMM yyyy').parse(date));
    }

    QuerySnapshot messagesSnapshot = await query.get();
    return messagesSnapshot.docs;
  }

  Future<void> addMessage(
      String userId,
      String name,
      Timestamp date,
      String daySummary,
      String leaveType,
      Timestamp fromDate,
      Timestamp toDate,
      String documentUrl,
      String imageUrl,
      String status,
      ) async {
    await _db.collection('Employee').doc(userId).collection('Leave').add({
      'name': name,
      'date': date,
      'daySummary': daySummary,
      'leaveType': leaveType,
      'fromDate': fromDate,
      'toDate': toDate,
      'status': status,
      'imageUrl': imageUrl,
    });
  }
}
