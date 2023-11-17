// ignore_for_file: file_names

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendors/Screens/homeScreen.dart';

import 'package:vendors/Screens/loginScreen.dart';
import 'package:vendors/Utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();

    // Add a delay before navigating to the LoginScreen.
    Timer(const Duration(seconds: 3), () async {
      checkLoginStatus();
    });
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogged = prefs.getBool('isLogged') ?? false;
    String myPhone = prefs.getString('myPhone') ?? '';

    if (isLogged) {
      // User is already logged in, navigate to HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            phoneNo: myPhone,
          ),
        ),
      );
    } else {
      // User is not logged in, navigate to LoginScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.amber));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Container(
        color: Colors.amber,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/car.gif'),
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            SizedBox(
              height: 20,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: "ParkEasy\n",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.2,
                      fontSize: 30,
                    ),
                  ),
                  TextSpan(
                    text: 'Mr.',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.2,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: "Vendors",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
          ],
        )),
      )),
    );
  }
}
