import 'dart:convert';
import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vendors/Screens/printerScreen.dart';
import 'package:vendors/Utils/constants.dart';

class QrScreen extends StatefulWidget {
  final String vehicleId;

  const QrScreen({required this.vehicleId, super.key});
  @override
  _QrScreenState createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? vehicleData;

  final GlobalKey qrkey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchVehicleData();
  }

  Future<void> fetchVehicleData() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('vehicles')
          .doc(
              widget.vehicleId) // Use the provided vehicleId as the document ID
          .get();
      if (documentSnapshot.exists) {
        vehicleData = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {});
      } else {
        // Handle the case where the document with the provided vehicleId doesn't exist.
        print('Vehicle data with ID ${widget.vehicleId} does not exist.');
      }
    } catch (e) {
      // Handle any potential errors
      print('Error fetching vehicle data: $e');
    }
  }

  final blueThermalPrinter = BlueThermalPrinter.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.amber,
        title: const Text(
          'Receipt Details',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: vehicleData != null
          ? Container(
              color: Colors.white,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset(
                          'assets/parking.webp',
                          scale: 6,
                        ),
                        const Column(
                          children: [
                            Text(
                              'AirPort Parking',
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2),
                            ),
                            Text(
                              'Rajkot',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Divider(
                      indent: 10,
                      endIndent: 10,
                      color: Colors.grey,
                      thickness: 1,
                    ),
                    Text(
                      '${vehicleData!['amountType']} PARKING',
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.1),
                    ),
                    Text(
                      'DATE : ${vehicleData!['date']}',
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.1),
                    ),
                    Text(
                      'Vehicle No: ${widget.vehicleId}',
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black45,
                          letterSpacing: 1.2),
                    ),
                    Text(
                      'Punch-in Time: ${vehicleData!['punchInTime']}',
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black45,
                          letterSpacing: 1.2),
                    ),
                    Text(
                      '${vehicleData!['amountType']} : ₹ ${vehicleData!['amount30Min']}',
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.1),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: RepaintBoundary(
                        key: qrkey,
                        child: QrImageView(data: widget.vehicleId),
                      ),
                    ),
                    const Divider(
                      indent: 10,
                      endIndent: 10,
                      color: Colors.grey,
                      thickness: 1,
                    ),
                    const Text(
                      'THANK YOU AND LUCKY ROAD !',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 4, bottom: 4),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            primary: amber, // Background color
                            onPrimary:
                                Colors.black, // Text Color (Foreground color)
                          ),
                          onPressed: () {
                            _selectPrinterAndPrint();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(MdiIcons.printer),
                              const SizedBox(
                                width: 3,
                              ),
                              const Text('Print Receipt')
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
            )
          : const Center(
              child: CircularProgressIndicator(
              color: Colors.amber,
              backgroundColor: Colors.black,
            )),
    );
  }

  Future<void> _selectPrinterAndPrint() async {
    // Discover available Bluetooth devices
    final devices = await blueThermalPrinter.getBondedDevices();

    // Capture the context outside the async function
    final selectedDevice = await _showBluetoothDeviceSelectionDialog(devices);

    if (selectedDevice != null) {
      // Connect to the selected Bluetooth printer
      final isConnected = await blueThermalPrinter.connect(selectedDevice);

      if (isConnected) {
        // Print the receipt
        await printReceipt();

        // Disconnect from the printer after printing
        blueThermalPrinter.disconnect();
      } else {
        print('Failed to connect to the printer');
      }
    }
  }

  Future<BluetoothDevice?> _showBluetoothDeviceSelectionDialog(
      List<BluetoothDevice> devices) async {
    // Display a dialog with available Bluetooth devices
    return await showDialog<BluetoothDevice>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Select Bluetooth Printer'),
          content: Column(
            children: devices
                .map((device) => ListTile(
                      title: Text('${device.name}'),
                      onTap: () {
                        Navigator.of(dialogContext).pop(device);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Future<void> printReceipt() async {
    // Create the content to be printed
    final content = _generatePrintContent();
    // Convert the Uint8List to String
    final contentString = String.fromCharCodes(content);

    // Print the content
    await blueThermalPrinter.write(contentString);
  }

  Uint8List _generatePrintContent() {
    // Customize the content based on your requirements
    final StringBuffer content = StringBuffer();
    content.writeln('AirPort Parking');
    content.writeln('Rajkot');
    content.writeln('${vehicleData!['amountType']} PARKING');
    content.writeln(widget.vehicleId);
    content.writeln('₹ ${vehicleData!['amount30Min']}');
    content.writeln('${vehicleData!['punchInTime']}');
    // content.writeln('To:- ${widget.currentTime}');
    content.writeln('');
    content.writeln('');
    content.writeln('QR Code:');
    // content.writeln(widget.qrResult);

    // Convert the content to bytes
    return Uint8List.fromList(utf8.encode(content.toString()));
  }
}
