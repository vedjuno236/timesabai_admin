import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Constants {
  static String BASE_URL = 'https://fcm.googleapis.com/fcm/send';
  static String KEY_SERVER = '5442ae2d-f7ff-448d-b276-e426d7b6a62e';
  static String SENDER_ID = '746385350148';
}

class NotificationService {
  Future<bool> pushNotification({
    required String title,
    required String body,
    required String token,
  }) async {
    Map<String, dynamic> payload = {
      'to': token,
      'notification': {
        'priority': 'high',
        'title': title,
        'body': body,
        'sound': 'default',
      }
    };

    String dataNotifications = jsonEncode(payload);

    try {
      var response = await http.post(
        Uri.parse(Constants.BASE_URL),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${Constants.KEY_SERVER}',
        },
        body: dataNotifications,
      );

      debugPrint(response.body.toString());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }
}
