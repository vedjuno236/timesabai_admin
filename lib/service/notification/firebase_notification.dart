import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import this package

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> requestPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Notification permission not granted');
    }
  }

  Future<void> uploadFCM() async {
    try {

      User? _currentUser = FirebaseAuth.instance.currentUser;
      if (_currentUser == null) {
        throw Exception('User is not logged in');
      }


      String? token = await FirebaseMessaging.instance.getToken();
      print('getToken: $token');
      if (token != null) {
        await FirebaseFirestore.instance.collection('Users').doc(_currentUser.uid).set({
          'FCM': token,
        }, SetOptions(merge: true));
      }


      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        print('onTokenRefresh: $newToken');
        await FirebaseFirestore.instance.collection('Users').doc(_currentUser.uid).set({
          'FCM': newToken,
        }, SetOptions(merge: true));
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  Future<void> init() async {
    // Initialize settings for Android
    AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Combine settings for both Android and iOS (if needed)
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize the plugin with the settings
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  showNotification (RemoteMessage message ) async{
    AndroidNotificationDetails androidNotificationDetails= AndroidNotificationDetails(
      'id',
      'name',
      channelDescription: 'channelDescription',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    int notificationId =1;
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        notificationId,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
      payload: 'Not press'
    );
  }
}
