import 'package:admin_timesabai/views/users_views/screens/login_screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  // Set the default locale for the Intl package
  Intl.defaultLocale = 'lo_LA';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const Login(),
    );
  }
}
