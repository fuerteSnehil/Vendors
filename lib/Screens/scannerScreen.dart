import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vendors/Screens/resultScreen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class BarcodeData {
  final BarcodeCapture barcodeCapture;

  BarcodeData(this.barcodeCapture);
}

FirebaseFirestore firestore = FirebaseFirestore.instance;

class _ScannerScreenState extends State<ScannerScreen> {
  var getResult = '';
  var getVehicleName = '';
  var getPunchInTime = '';
  var getAmountType = '';
  var getDate = '';
  var getamount = '';
  var getVehicleNo = '';
  var getamoun120 = '';
  var getamountMorethen120 = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'QR Scanner',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Place the QR code inside the area',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Tap the button to open QR scanner',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .07,
                      width: MediaQuery.of(context).size.width * .5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(letterSpacing: 2, fontSize: 17),
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          scanQRCode();
                        },
                        child: const Text('Scan QR'),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (!mounted) return;

      // Fetch vehicle data based on the scanned QR code result
      await fetchVehicleData(qrCode);
    } on PlatformException {
      setState(() {
        getResult = 'Failed to scan QR Code.';
      });
    }
  }

  Future<void> fetchVehicleData(String qrCode) async {
    try {
      DocumentSnapshot documentSnapshot =
          await firestore.collection('vehicles').doc(qrCode).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? vehicleData =
            documentSnapshot.data() as Map<String, dynamic>;

        final vehicleName = vehicleData['vehicleName'];
        final punchInTime = vehicleData['punchInTime'];
        final amountType = vehicleData['amountType'];
        final date = vehicleData['date'];
        final amount30 = vehicleData['amount30Min'];
        final vehicleNo = vehicleData['vehicleNo'];
        final amount120 = vehicleData['amount120Min'];
        final amountMoreThan120 = vehicleData['amountMoreThan120Min'];

        // Format the current time
        final currentTime = DateTime.now();

        // Parse punch-in time from string to DateTime
        final punchInDateTime =
            DateFormat('yy/MM/dd hh:mm a').parse(punchInTime);

        // Calculate the time difference
        final timeDifference = currentTime.difference(punchInDateTime);

        // Determine the amount based on the time difference
        String parkingAmount;
        if (timeDifference.inMinutes <= 30) {
          parkingAmount = amount30;
        } else if (timeDifference.inMinutes <= 120) {
          parkingAmount = amount120;
        } else {
          // Calculate the amount for every hour beyond 120 minutes
          int additionalHours = (timeDifference.inMinutes - 120) ~/ 60;
          double additionalAmount =
              additionalHours * double.parse(amountMoreThan120);
          parkingAmount =
              (double.parse(amount120) + additionalAmount).toString();
        }

        setState(() {
          getVehicleName = '$vehicleName';
          getPunchInTime = '$punchInTime';
          getAmountType = '$amountType';
          getDate = '$date';
          getamount = '$amount30';
          getResult = vehicleName;
          getVehicleNo = vehicleNo;
          getamoun120 = amount120;
          getamountMorethen120 = amountMoreThan120;
        });

        // Format the current time
        final formattedCurrentTime =
            DateFormat('yy/MM/dd hh:mm a').format(currentTime);

        // Store the formatted current time in Firestore
        await firestore.collection('vehicles').doc(qrCode).update({
          'lastScannedTime': formattedCurrentTime,
        });

        // Navigate to ResultScreen and pass the result along with the current time
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              qrResult: getResult,
              vehicleName: getVehicleName,
              punchInTime: getPunchInTime,
              amountType: getAmountType,
              date: getDate,
              amount: parkingAmount, // Pass the determined amount
              currentTime: formattedCurrentTime,
              vehicleNo: getVehicleNo,
            ),
          ),
        );
      } else {
        setState(() {
          getResult = 'Vehicle data not found for QR code: $qrCode';
        });
      }
    } catch (e) {
      setState(() {
        getResult = 'Error fetching vehicle data: $e';
      });
    }
  }
}
