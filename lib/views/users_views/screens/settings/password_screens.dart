import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordScreens extends StatefulWidget {
  const PasswordScreens({super.key});

  @override
  State<PasswordScreens> createState() => _PasswordScreensState();
}

class _PasswordScreensState extends State<PasswordScreens> {
  final _emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(
                'ລະຫັດຈະສົ່ງໄປທາງ Email ຂອງທ່ານ',
                style: GoogleFonts.notoSansLao(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF577DF4),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF577DF4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ປ່ຽນລະຫັດຜ່ານ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        cursorColor: Colors.blue,
                        style: GoogleFonts.notoSansLao(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black45,
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: "ອີເມວ",
                          hintStyle: GoogleFonts.notoSansLao(
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.black45,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.black12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
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
                                  passwordReset();

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
                              ? const SpinKitCircle(
                                  color: Colors.white,
                                  size: 30.0,
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
                                      'ປ່ຽນລະຫັດຜ່ານ',
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
          ],
        ),
      ),
    );
  }
}
