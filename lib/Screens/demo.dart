// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class QrScreen extends StatefulWidget {
//   final String vehicleId;

//   const QrScreen({required this.vehicleId, Key? key}) : super(key: key);

//   @override
//   _QrScreenState createState() => _QrScreenState();
// }

// class _QrScreenState extends State<QrScreen> {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//   Map<String, dynamic>? vehicleData;

//   final GlobalKey qrkey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     fetchVehicleData();
//   }

//   Future<void> fetchVehicleData() async {
//     try {
//       DocumentSnapshot documentSnapshot = await firestore
//           .collection('vehicles')
//           .doc(widget.vehicleId)
//           .get();
//       if (documentSnapshot.exists) {
//         vehicleData = documentSnapshot.data() as Map<String, dynamic>;
//         setState(() {});
//       } else {
//         print('Vehicle data with ID ${widget.vehicleId} does not exist.');
//       }
//     } catch (e) {
//       print('Error fetching vehicle data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.amber,
//         title: const Text(
//           'Receipt Details',
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//       body: vehicleData != null
//           ? Container(
//               color: Colors.white,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // ... existing code ...

//                   Padding(
//                     padding: const EdgeInsets.only(
//                         left: 10, right: 10, top: 4, bottom: 4),
//                     child: SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           primary: Colors.amber,
//                           onPrimary: Colors.black,
//                         ),
//                         onPressed: () {
//                           _selectPrinterAndPrint();
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(MdiIcons.printer),
//                             const SizedBox(width: 3),
//                             const Text('Print Receipt'),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : const Center(
//               child: CircularProgressIndicator(
//               color: Colors.amber,
//               backgroundColor: Colors.black,
//             )),
//     );
//   }

//   Future<void> _selectPrinterAndPrint() async {
//     final devices = await BlueThermalPrinter.instance.getBondedDevices();

//     final selectedDevice = await _showBluetoothDeviceSelectionDialog(devices);

//     if (selectedDevice != null) {
//       await printReceipt(selectedDevice);
//     }
//   }

//   Future<BluetoothDevice?> _showBluetoothDeviceSelectionDialog(
//       List<BluetoothDevice> devices) async {
//     return await showDialog<BluetoothDevice>(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: Text('Select Bluetooth Printer'),
//           content: Column(
//             children: devices
//                 .map(
//                   (device) => ListTile(
//                     title: Text('${device.name}'),
//                     onTap: () {
//                       Navigator.of(dialogContext).pop(device);
//                     },
//                   ),
//                 )
//                 .toList(),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> printReceipt(BluetoothDevice selectedDevice) async {
//     final content = _generatePrintContent();

//     final isConnected = await BlueThermalPrinter.instance.connect(selectedDevice);

//     if (isConnected) {
//       await BlueThermalPrinter.instance.write(content);
//       await BlueThermalPrinter.instance.disconnect();
//     } else {
//       print('Failed to connect to the printer');
//     }
//   }

//   String _generatePrintContent() {
//     return '''
// AirPort Parking,\n
// Rajkot
// ${vehicleData!['amountType']} PARKING
// ${widget.vehicleId}
// ₹ ${vehicleData!['amount30Min']}
// ${vehicleData!['punchInTime']}
    
// THANK YOU AND LUCKY ROAD !
// ''';
//   }
// }
