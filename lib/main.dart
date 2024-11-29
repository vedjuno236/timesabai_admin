import 'package:admin_timesabai/service/notification/firebase_notification.dart';
import 'package:admin_timesabai/service/notification/notificationhelper.dart';
import 'package:admin_timesabai/views/users_views/screens/login_screens/login.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
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
      locale: const Locale('lo', 'LA'), // Setting default locale
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
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    });
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

            // DefaultTextStyle(
            //   style: const TextStyle(
            //     fontSize: 40.0,
            //   ),
            //   child: AnimatedTextKit(
            //     animatedTexts: [
            //       WavyAnimatedText(
            //         "Engineering",
            //         textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
            //               fontFamily: "OrangesPersonalUseBold",
            //               fontSize: 30,
            //             ),
            //       ),
            //     ],
            //     isRepeatingAnimation: true,
            //   ),
            // )
            
            WidgetMask(
              blendMode: BlendMode.srcATop,
              childSaveLayer: true,
              mask: Image.network("https://i.ytimg.com/vi/hHKsY5V6ATo/maxresdefault.jpg",fit: BoxFit.cover,),
              child: const Text("E F N",style: TextStyle(fontSize: 100,fontWeight: FontWeight.w900),),
            )
          ],
        ),
      ),
    );
  }
}
