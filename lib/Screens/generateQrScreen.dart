import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the date and time formatting library
import 'package:vendors/Screens/homeScreen.dart';
import 'package:vendors/Screens/receiptDetalScreen.dart';
import 'package:vendors/Screens/vehicleTypes.dart';
import 'package:vendors/Utils/constants.dart';

class GenerateQrScreen extends StatefulWidget {
  final String phoneNo;
  final String vehicleName;
  final String amount30Min;
  final String amount120Min;
  final String amountMoreThan120Min;
  const GenerateQrScreen(
      {required this.phoneNo,
      required this.vehicleName,
      required this.amount30Min,
      required this.amount120Min,
      required this.amountMoreThan120Min,
      super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  // Create TextEditingController for the text fields
   TextEditingController mytext = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  TextEditingController textEditingController3 = TextEditingController();

  // Create a variable to store the selected radio option
  int selectedRadio = 1;
  bool isTapped = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Function to handle radio button selection
  void handleRadioValueChange(int? value) {
    if (value != null) {
      setState(() {
        selectedRadio = value;
      });
    }
  }

  @override
  void initState() {
    textEditingController2 = TextEditingController(text: widget.vehicleName);
    textEditingController3 = TextEditingController(text: widget.amount30Min);
    super.initState();
  }

  Future<void> uploadDataToFirestore() async {
    final vehicleNumber = mytext.text;

    if (vehicleNumber.isNotEmpty) {
      final documentData = {
        'vehicleName': widget.vehicleName,
        'amount30Min': widget.amount30Min,
        'amount120Min': widget.amount120Min,
        'amountMoreThan120Min': widget.amountMoreThan120Min,
        'vehicleNo': vehicleNumber,
        'amountType': selectedRadio == 1
            ? 'PAID'
            : selectedRadio == 2
                ? 'DUE'
                : 'FIX',
        'punchInTime': getCurrentTime(),
        'date': getCurrentDate(),
      };

      await firestore
          .collection('vehicles')
          .doc(vehicleNumber)
          .set(documentData);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QrScreen(
                    vehicleId: vehicleNumber,
                    // vehicleName: widget.vehicleName,
                    // amount: widget.amount30Min,
                    // paymentType: ,
                  )));
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: Border.all(
            color: Colors.amber,
          ),
          shadowColor: Colors.black,
          title: const Text('Error'),
          content: const Text('Please enter a valid Vehicle Number.'),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, foregroundColor: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  Future<void> _uploadDataAndReset() async {
    await uploadDataToFirestore();
    Provider.of<VehicleProvider>(context, listen: false)
        .resetUpdateVehicleTypeValue();
  }
  String getCurrentTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yy/MM/dd hh:mm a');
    return formatter.format(now);
  }

  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('d MMMM y');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(phoneNo: widget.phoneNo)));
          },
        ),
        backgroundColor: Colors.amber,
        title: const Text(
          'Receipt',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/info.gif',
                  scale: 1,
                ),
                const Text(
                  'Please provide these details to generate receipt -',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.2),
                ),
                TextField(
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 10,
                  cursorColor: Colors.amber,
                  controller: textEditingController1,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Number',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                VehicleTypeScreen(phoneNo: widget.phoneNo)));
                    setState(() {
                      isTapped = true;
                    });
                  },
                  child: TextField(
                    enabled: false,
                    controller: textEditingController2,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                    decoration: InputDecoration(
                      labelText: "Vehicle type",
                      suffixIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: textEditingController3,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        handleRadioValueChange(
                            1); // Set the selectedRadio to 1 when 'PAID' is tapped
                      },
                      child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        child: Row(
                          children: [
                            Radio(
                              activeColor: Colors.black,
                              value: 1,
                              groupValue: selectedRadio,
                              onChanged: handleRadioValueChange,
                            ),
                            const Text('PAID'),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        handleRadioValueChange(2);
                      },
                      child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        child: Row(
                          children: [
                            Radio(
                              activeColor: Colors.black,
                              value: 2,
                              groupValue: selectedRadio,
                              onChanged: handleRadioValueChange,
                            ),
                            const Text('DUE'),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        handleRadioValueChange(3);
                      },
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: Row(
                          children: [
                            Radio(
                              activeColor: Colors.black,
                              value: 3,
                              groupValue: selectedRadio,
                              onChanged: handleRadioValueChange,
                            ),
                            const Text(
                              'FIX',
                              style:
                                  TextStyle(fontSize: 15, letterSpacing: 1.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          primary: amber,
                          onPrimary: Colors.black,
                        ),
                        onPressed: () {
                          uploadDataToFirestore();
                        },
                        child: Text(
                          'Generate Receipt',
                          style: TextStyle(letterSpacing: 1, fontSize: 17),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
