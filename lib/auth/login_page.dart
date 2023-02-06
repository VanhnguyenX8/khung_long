import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Đăng Nhập"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chào mừng bạn đến với trò chơi Khủng Long',
              style: GoogleFonts.mulish(
                  textStyle: const TextStyle(fontSize: 25),
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                AuthService().signInWithGoogle();
              },
              child: Text(
                'Đăng Nhập',
                style: GoogleFonts.mulish(
                    textStyle: const TextStyle(fontSize: 20),
                    color: Colors.blue,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
