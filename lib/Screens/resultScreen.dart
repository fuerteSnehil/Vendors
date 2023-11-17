import 'dart:convert';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vendors/Screens/printerScreen.dart';
import 'package:vendors/Utils/constants.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class ResultScreen extends StatefulWidget {
  final String qrResult;
  final String vehicleName;
  final String punchInTime;
  final String amountType;
  final String date;
  final String amount;
  final String currentTime;
  // final String amount120;
  // final String amountMoreThen120;
  final String vehicleNo;

  const ResultScreen(
      {required this.qrResult,
      required this.vehicleName,
      required this.punchInTime,
      required this.amountType,
      required this.date,
      required this.amount,
      required this.currentTime,
      // required this.amount120,
      // required this.amountMoreThen120,
      required this.vehicleNo,
      super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey qrkey = GlobalKey();
  final blueThermalPrinter = BlueThermalPrinter.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Punch Out',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
        ),
        body: Container(
          color: Colors.white,
          height: double.infinity,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset(
                        'assets/parking.webp',
                        scale: 7,
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
                ),
                const Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Colors.grey,
                  thickness: 1,
                ),
                Text(
                  widget.amountType + " PARKING",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2),
                ),
                Text(
                  widget.vehicleName,
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                // Text(
                //   'Vehicle No : ' + widget.vehicleNo,
                //   style: TextStyle(fontSize: 18, color: Colors.black54),
                // ),
                Text(
                  widget.date,
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                Text(
                  'From : ' + widget.punchInTime,
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                Text(
                  'To : ' + widget.currentTime,
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                Text(
                  '${widget.amountType} : ' + '₹${widget.amount}',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: RepaintBoundary(
                    key: qrkey,
                    child: QrImageView(data: widget.vehicleNo),
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
        ));
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
    content.writeln('${widget.amountType} PARKING');
    content.writeln(widget.vehicleName);
    content.writeln(widget.date);
    content.writeln(widget.punchInTime);
    content.writeln('To:- ${widget.currentTime}');
    content.writeln(widget.amount);
    content.writeln('');
    content.writeln('QR Code:');
    // content.writeln(widget.qrResult);

    // Convert the content to bytes
    return Uint8List.fromList(utf8.encode(content.toString()));
  }
}
