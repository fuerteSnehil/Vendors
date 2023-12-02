import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vendors/Utils/constants.dart';
import 'package:vendors/widgets/printer.dart';

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

  void _openPrintDeviceOverlay() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Printer(
            vehicleID: widget.vehicleName,
            packingType: widget.amountType,
            amountObtained: widget.amount,
            punchInTime: widget.punchInTime,
            qrcode: widget.vehicleNo,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
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
                  "${widget.amountType} PARKING",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2),
                ),
                Text(
                  widget.vehicleName,
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
                // Text(
                //   'Vehicle No : ' + widget.vehicleNo,
                //   style: TextStyle(fontSize: 18, color: Colors.black54),
                // ),
                Text(
                  widget.date,
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
                Text(
                  'From : ${widget.punchInTime}',
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
                Text(
                  'To : ${widget.currentTime}',
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
                Text(
                  '${widget.amountType} : ' + '₹${widget.amount}',
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
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
                        foregroundColor: Colors.black,
                        backgroundColor: amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ), // Text Color (Foreground color)
                      ),
                      onPressed: _openPrintDeviceOverlay,
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
}
