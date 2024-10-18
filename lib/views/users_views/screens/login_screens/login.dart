import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:status_alert/status_alert.dart';
import '../../../../components/backGroun.dart';
import '../home_screens/home_screens.dart';
import '../record_screens/record_screens.dart';

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
      body: BackGround(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(  // Added SingleChildScrollView
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.1), // Adds some space at the top
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Document TimeSabi'.toUpperCase(),
                      style: GoogleFonts.notoSansLao(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'ອີເມວ',
                      prefixIcon: Icon(Icons.email_outlined),
                      labelStyle: GoogleFonts.notoSansLao(
                        fontSize: 18, fontWeight: FontWeight.w600, ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: _isObscure3,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.password),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure3 ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure3 = !_isObscure3;
                          });
                        },
                      ),
                      labelText: 'ລະຫັດຜ່ານ',
                      labelStyle: GoogleFonts.notoSansLao(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: const Text(
                      'Forget your password?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
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
                        signIn(context,
                            emailController.text, passwordController.text);
                        setState(() {
                          isLoading = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const SpinKitCircle(
                        color: Colors.white,
                        size: 30.0,
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send,color: Colors.white,),
                          const SizedBox(width: 20),
                          Text(
                            'Login',
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
    );
  }



  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    var kk = FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('rool') == "Admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  RecordScreens(),
            ),
          );
        }else{
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  HomeScreens(),
            ),
          );
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }


  void signIn(BuildContext context, String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        StatusAlert.show(
          context,
          duration: Duration(seconds: 2),
          title: 'Login Successful',
          configuration: IconConfiguration(icon: Icons.done),
          maxWidth: 260,
        );

        // Call the route function after the alert
        route();

      } on FirebaseAuthException catch (e) {
        String errorMessage = '';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        }

        if (errorMessage.isNotEmpty) {
          // Show error dialog if login fails
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Sign In Failed',
                  style: GoogleFonts.notoSansLao(),
                ),
                content: Text(
                  errorMessage,
                  style: GoogleFonts.notoSansLao(),
                ),
                actions: [
                  TextButton(
                    child: Text('OK', style: GoogleFonts.notoSansLao()),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

}









