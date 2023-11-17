import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendors/Screens/homeScreen.dart';
import 'package:vendors/Screens/loginScreen.dart';
import 'package:vendors/Utils/constants.dart';
import 'package:vendors/Utils/utils.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String myPhone;

  const OtpScreen({
    required this.verificationId,
    required this.myPhone,
    super.key,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 120,
            ),
            Image(
              image: AssetImage('assets/man.gif'),
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "We have sent the verification code to your mobile number",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    height: 1.0,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.2),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "+91${widget.myPhone}",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      height: 1.0,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
                padding: const EdgeInsets.only(right: 20, left: 20),
                child: TextField(
                  cursorColor: primaryColor,
                  controller: otpController,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (value) {
                    setState(() {
                      otpController.text = value;
                    });
                  },
                  maxLength: 6,
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  enableSuggestions: true,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: InputDecoration(
                    hintText: "Enter OTP",
                    hintStyle: TextStyle(fontWeight: FontWeight.w500),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.black38),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 224, 169, 4)),
                    ),
                    suffixIcon: otpController.text.length == 6
                        ? Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: amber,
                            ),
                            child: const Icon(
                              Icons.done,
                              color: Colors.black,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                )),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    primary: amber, // Background color
                    onPrimary: Colors.black, // Text Color (Foreground color)
                  ),
                  onPressed: () {
                    verifyOTP(otpController.text);
                  },
                  child: Text(
                    'Verify OTP',
                    style: TextStyle(
                      letterSpacing: 1.2,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Text(
                  'Edit phone number?',
                  style: TextStyle(color: Colors.black),
                ))
          ],
        ),
      ),
    );
  }

  void verifyOTP(String otp) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('myPhone', widget.myPhone);
        await prefs.setBool('isLogged', true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              phoneNo: widget.myPhone,
            ),
          ),
        );
      } else {
        // Incorrect OTP, show a snackbar
        showSnackBar(context, 'Incorrect OTP');
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      showSnackBar(context, 'Error verifying OTP');
    }
  }
}
