import 'package:admin_timesabai/service/notification/firebase_notification.dart';
import 'package:admin_timesabai/views/users_views/screens/leave_screens/employee_levae_screen.dart';
import 'package:admin_timesabai/views/users_views/screens/settings/password_screens.dart';
import 'package:admin_timesabai/views/widget/loading_platform/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:status_alert/status_alert.dart';

import '../../../../components/backGroun.dart';
import '../home_screens/home_screens.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  bool isLoading = false;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomProgressHUD(
        key: UniqueKey(),
        inAsyncCall: isLoading,
        opacity: .7,
        child: BackGround(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.2),
                    Text(
                      'ມະຫາວິທະຍາໄລ ສຸພານຸວົງ',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'ຄະນະວິສະວະກໍາສາດ',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'ປ້ອນອີເມວ',
                        style: GoogleFonts.notoSansLao(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: emailController,
                      cursorColor: Colors.white,
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      decoration: InputDecoration(
                        hintText: "ອີເມວ",
                        hintStyle: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'ປ້ອນລະຫັດຜ່ານ',
                        style: GoogleFonts.notoSansLao(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      obscureText: _isObscure3,
                      controller: passwordController,
                      cursorColor: Colors.white,
                      style: GoogleFonts.notoSansLao(
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      decoration: InputDecoration(
                        hintText: "ລະຫັດຜ່ານ",
                        hintStyle: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.key_sharp,
                          color: Colors.white,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure3
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure3 = !_isObscure3;
                            });
                          },
                          color: Colors.white,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PasswordScreens(),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: const Text(
                          'Forget your password?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    SizedBox(
                      height: 60,
                      width: 600,
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await Future.delayed(
                                    const Duration(seconds: 2));
                                signIn(context, emailController.text,
                                    passwordController.text);
                                setState(() {
                                  isLoading = false;
                                });
                              },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          side: const BorderSide(color: Colors.blueGrey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            // ? const SpinKitCircle(
                            //     color: Colors.white,
                            //     size: 30.0,
                            //   )
                            ? Text(
                                'ກໍາລັງເຂົ້າສູ່ລະບົບ.....',
                                style: GoogleFonts.notoSansLao(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    'ເຂົ້າສູ່ລະບົບ',
                                    style: GoogleFonts.notoSansLao(
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void route(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        String role =
            documentSnapshot.get('rool'); // Check correct field name 'rool'

        if (role == "ບໍລິຫານ") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreens(),
            ),
          );
        } else if (role == "ຄະນະບໍດີ" || role == "ຄະນະບໍດີ") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeLeaveSerceen(),
            ),
          );
        } else {
          print('Unknown role: $role');
        }
      } else {
        print('Document does not exist in the database');
      }
    }).catchError((error) {
      print('Error fetching user data: $error');
    });
  }

  void signIn(BuildContext context, String email, String password) async {
    final _localNotificationService = LocalNotificationService();

    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Input Error'),
            content: Text('Please enter both email and password.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return; // Exit early if fields are empty
    }

    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        StatusAlert.show(
          context,
          duration: Duration(milliseconds: 1000),
          subtitle: 'ເຂົ້າສູ່ລະບົບສໍາເລັດ.',
          subtitleOptions: StatusAlertTextConfiguration(
            style: GoogleFonts.notoSansLao(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          configuration: IconConfiguration(icon: Icons.done),
          maxWidth: 300,
        );

        await _localNotificationService.requestPermission();
        await _localNotificationService.uploadFCM();

        route(context);
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred. Please try again.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password. Please try again.';
        }

        StatusAlert.show(
          context,
          duration: Duration(seconds: 2),
          subtitle: 'ການເຂົ້າສູ່ລະບົບລົ້ມຫຼ້ຽວ',
          subtitleOptions: StatusAlertTextConfiguration(
            style: GoogleFonts.notoSansLao(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          configuration: IconConfiguration(icon: Icons.error_outline_sharp),
          maxWidth: 260,
        );
      }
    }
  }
}
