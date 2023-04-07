import 'dart:async';
import 'package:chatapp/auth/register_phone.dart';
import 'package:chatapp/const/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 6),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const RegisterPhone())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/amalo.jpeg"), fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("amalo", style: splashScreenText1),
              Text("connect with your friend", style: splashScreenText2),
              const SizedBox(height: 20),
              const SpinKitSpinningLines(
                lineWidth: 10,
                itemCount: 10,
                color: Colors.orange,
                size: 100.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
