// import 'dart:convert';
// import 'dart:io';

// // ignore: unnecessary_import
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:parkeasy/Models/usermodel.dart';
// import 'package:parkeasy/Screens/otpScreen.dart';
// import 'package:parkeasy/Screens/priceScreen.dart';
// import 'package:parkeasy/Utils/utils.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';

// class AuthProvider extends ChangeNotifier {
//   bool _isSignedIn = false;
//   bool get isSignedIn => _isSignedIn;
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//   String? _uid;
//   String get uid => _uid!;
//   UserModel? _userModel;
//   UserModel get userModel => _userModel!;
//   // String _verificationId = "";
//   // int? _resendToken;
//   String? _userName;
//   String get userName => _userName!;

//   String? _userEmail;
//   String get userEmail => _userEmail!;

//   String? _dob;
//   String get dateOfBirth => _dob!;

//   String? _profilePic;
//   String get profilePic => _profilePic!;

//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
//   final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   AuthProvider() {
//     checkSign();
//   }

//   void checkSign() async {
//     final SharedPreferences s = await SharedPreferences.getInstance();
//     _isSignedIn = s.getBool("is_signedin") ?? false;
//     notifyListeners();
//   }

//   Future setSignIn() async {
//     final SharedPreferences s = await SharedPreferences.getInstance();
//     s.setBool("is_signedin", true);
//     _isSignedIn = true;
//     notifyListeners();
//   }

//   // signin
//   void signInWithPhone(BuildContext context, String phoneNumber) async {
//     try {
//       await _firebaseAuth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
//           // Automatically sign in the user if verification is completed
//           await _firebaseAuth.signInWithCredential(phoneAuthCredential);
//         },
//         verificationFailed: (FirebaseAuthException authException) {
//           // Handle verification failure
//           showSnackBar(
//               context, "Verification Failed: ${authException.message}");
//         },
//         codeSent: (String verificationId, int? forceResendingToken) {
//           // Navigate to the OTP screen when code is sent
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OtpScreen(
//                 // verificationId: verificationId,
//                 // myPhone: phoneNumber,
//               ),
//             ),
//           );
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           showSnackBar(context, "Verification code auto-retrieval timed out");
//         },
//       );
//     } on FirebaseAuthException catch (e) {
//       showSnackBar(context, "Firebase Authentication Error: ${e.message}");
//     } catch (e) {
//       showSnackBar(context, "An error occurred: $e");
//     }
//   }

//   // verify otp
//   void verifyOtp({
//     required BuildContext context,
//     required String verificationId,
//     required String userOtp,
//     required Function onSuccess,
//   }) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       PhoneAuthCredential creds = PhoneAuthProvider.credential(
//           verificationId: verificationId, smsCode: userOtp);
//       User? user = (await _firebaseAuth.signInWithCredential(creds)).user;
//       if (user != null) {
//         _uid = user.uid;
//         onSuccess();
//       }
//       _isLoading = false;
//       notifyListeners();
//     } on FirebaseAuthException catch (e) {
//       showSnackBar(context, e.message.toString());
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // DATABASE OPERTAIONS
//   Future<bool> checkExistingUser() async {
//     if (_firebaseAuth.currentUser == null) {
//       return false; // User is not authenticated.
//     }
//     userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
//     DocumentSnapshot snapshot = await _firebaseFirestore
//         .collection("Admins")
//         .doc(userModel.phoneNumber)
//         .get();
//     if (snapshot.exists) {
//       print("USER EXISTS");
//       print("checking value is true");
//       return true;
//     } else {
//       print("checking value is true");
//       print("NEW USER");
//       return false;
//     }
//   }

//   void saveUserDataToFirebase({
//     required BuildContext context,
//     required UserModel userModel,
//     required Function onSuccess,
//   }) async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       // userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
//       userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;

//       _userModel = userModel;
//       // uploading to database
//       await _firebaseFirestore
//           .collection("Admins")
//           .doc(userModel.phoneNumber)
//           .set(userModel.toMap())
//           .then((value) {
//         onSuccess();
//         _isLoading = false;
//         notifyListeners();
//       });
//     } on FirebaseAuthException catch (e) {
//       showSnackBar(context, e.message.toString());
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Future<String> storeFileToStorage(String ref, File file) async {
//   //   UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
//   //   TaskSnapshot snapshot = await uploadTask;
//   //   String downloadUrl = await snapshot.ref.getDownloadURL();
//   //   return downloadUrl;
//   // }

//   Future getDataFromFirestore() async {
//     userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;

//     _userModel = userModel;
//     print("testing uid ");
//     print(_firebaseAuth.currentUser!.uid);
//     await _firebaseFirestore
//         .collection("Admins")
//         .doc(userModel.phoneNumber)
//         .get()
//         .then((DocumentSnapshot snapshot) {
//       // _userModel = UserModel(
//       //   name: snapshot['name'],
//       //   email: snapshot['email'],
//       //   //createdAt: snapshot['createdAt'],
//       //   dob: snapshot['dob'],
//       //   //uid: snapshot['uid'],
//       //   profilePic: snapshot['profilePic'],
//       //   phoneNumber: snapshot['phoneNumber'],
//       // );
//       //  _uid = userModel.uid;

//       _userName = snapshot['name'];
//       _userEmail = snapshot['email'];
//       _dob = snapshot['dob'];

//       notifyListeners();
//     });

//     print(_userName);
//     print(_userEmail);
//     print(_dob);
//   }

//   // STORING DATA LOCALLY
//   Future saveUserDataToSP() async {
//     SharedPreferences s = await SharedPreferences.getInstance();
//     await s.setString("user_model", jsonEncode(userModel.toMap()));
//   }

//   Future getDataFromSP() async {
//     SharedPreferences s = await SharedPreferences.getInstance();
//     String data = s.getString("user_model") ?? '';
//     _userModel = UserModel.fromMap(jsonDecode(data));
//     //   _uid = _userModel!.uid;
//     notifyListeners();
//   }

//   Future userSignOut() async {
//     SharedPreferences s = await SharedPreferences.getInstance();
//     await _firebaseAuth.signOut();
//     _isSignedIn = false;
//     notifyListeners();
//     s.clear();
//   }

//   // Future<void> setamount(String uid, String vehicle, String amount) async {

//   //   try {
//   //     String vehicleId = const Uuid().v1();
//   //     if (vehicle.isEmpty) {
//   //       await _firebaseFirestore
//   //           .collection("users")
//   //           .doc(uid)
//   //           .collection("vehicle")
//   //           .doc(vehicleId)
//   //           .set({'vehicleName': vehicle, 'amount': amount});
//   //     } else {
//   //       print('Text is empty');
//   //     }
//   //   } catch (e) {
//   //     print(e.toString());
//   //   }
//   // }
//   Future<void> createSubcollection(
//     UserModel userModel,
//     BuildContext context,
//     String vehicleName,
//     String amount30,
//     String amount120,
//     String amountMoreThan120,
//   ) async {
//     if (vehicleName.isEmpty) {
//       showSnackBar(context, "Please Enter a vehicle name");
//       return;
//     }

//     try {
//       User? user = _auth.currentUser;

//       if (user != null) {
//         final String uid = user.uid;
//         print("Checking " + userModel.phoneNumber);
//         // Create a subcollection named "vehicles" inside the user's document
//         CollectionReference vehiclesCollection = _firestore
//             .collection('Admins')
//             .doc(userModel.phoneNumber)
//             .collection('vehicles');

//         // Add a new document to the "vehicles" subcollection
//         await vehiclesCollection.add({
//           'name': vehicleName,
//           'amount30Min': amount30,
//           'amount120Min': amount120,
//           'amountMoreThan120Min': amountMoreThan120,
//         });

//         print('Subcollection document created successfully.');
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => PriceScreen(uid)));
//       } else {
//         print('User is not logged in.');
//       }
//     } catch (e) {
//       print('Error creating subcollection document: $e');
//     }
//   }
// }
