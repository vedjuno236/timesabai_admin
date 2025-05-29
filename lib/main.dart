import 'package:admin_timesabai/service/notification/firebase_notification.dart';
import 'package:admin_timesabai/service/notification/notificationhelper.dart';
import 'package:admin_timesabai/views/users_views/screens/home_screens/home_screens.dart';
import 'package:admin_timesabai/views/users_views/screens/login_screens/login.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
  null,
    [
      NotificationChannel(
        channelKey: 'key1',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        playSound: true,
        enableLights: true,
        enableVibration: true,
        importance: NotificationImportance.High,
      )
    ],
  );

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  await NotificationHelper.init();
  await LocalNotificationService().requestPermission();
  await LocalNotificationService().init();
  Intl.defaultLocale = 'lo_LA';

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    notificationHandler();
  }

  void notificationHandler() {
    FirebaseMessaging.onMessage.listen((event) async {
      print(event.notification!.title);
      LocalNotificationService().showNotification(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Admin',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FC),
        useMaterial3: true,
      ),
      locale: const Locale('lo', 'LA'),
      supportedLocales: const [
        Locale('lo', 'LA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  
  }

 Future<void> _checkTokenAndNavigate() async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

    if (token == null || token.isEmpty) {
    
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>const Login()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreens()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Lottie.network(
              "https://lottie.host/402b2330-0d9b-47e3-b998-73536ecd1af2/3yE7yI8AH9.json",
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
