import 'package:admin_timesabai/service/notification/firebase_notification.dart';
import 'package:admin_timesabai/service/notification/notificationhelper.dart';
import 'package:admin_timesabai/views/users_views/screens/home_screens/home_screens.dart';
import 'package:admin_timesabai/views/users_views/screens/login_screens/login.dart';
import 'package:admin_timesabai/views/users_views/screens/login_screens/register_screens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:widget_mask/widget_mask.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    // Future.delayed(const Duration(seconds: 5), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => Login()),
    //   );
    // });
  }

 Future<void> _checkTokenAndNavigate() async {
    // Retrieve the token (this is a placeholder, replace with actual token retrieval logic)
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

    if (token == null || token.isEmpty) {
      // Navigate to Login if token is null
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } else {
      // Navigate to HomeScreens if token is valid
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreens()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
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
