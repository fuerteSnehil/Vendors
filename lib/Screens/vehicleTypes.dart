import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendors/Screens/receiptScreen.dart';

class VehicleTypeScreen extends StatefulWidget {
  final String phoneNo;
  const VehicleTypeScreen({required this.phoneNo, Key? key}) : super(key: key);

  @override
  State<VehicleTypeScreen> createState() => _VehicleTypeScreenState();
}

class _VehicleTypeScreenState extends State<VehicleTypeScreen> {
  String? adminUid; // Variable to store the adminUid

  @override
  void initState() {
    super.initState();
    // Call a function to fetch the adminUid when the widget is created
    fetchAdminUid();
  }

  Future<void> fetchAdminUid() async {
    try {
      // Access the Firestore instance
      final firestore = FirebaseFirestore.instance;

      // Reference to the 'vendors' collection
      final vendorsCollection = firestore.collection('vendors');

      // Query for the document with the given phoneNo
      final vendorDocument = await vendorsCollection.doc(widget.phoneNo).get();

      if (vendorDocument.exists) {
        // Get the 'adminUid' field from the document
        final data = vendorDocument.data() as Map<String, dynamic>;
        final adminUid = data['adminUid'];

        setState(() {
          this.adminUid = adminUid;
        });
      } else {
        // Document doesn't exist
        // Handle this case according to your app's requirements
      }
    } catch (e) {
      // Handle any potential errors
      print('Error fetching adminUid: $e');
    }
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? selectedVehicleName;
  String? selectedAmount30Min;
  String? selectedAmount120Min;
  String? selectedAmountMoreThan120Min;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_ios_new),
        //   color: Colors.black,
        //   onPressed: () {
        //     Navigator.pop(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => GenerateQrScreen(
        //                   vehicleName: selectedVehicleName.toString(),
        //                   amount30Min: selectedAmount30Min.toString(),
        //                   amount120Min: selectedAmount120Min.toString(),
        //                   amountMoreThan120Min:
        //                       selectedAmountMoreThan120Min.toString(),
        //                   phoneNo: widget.phoneNo,
        //                 )));
        //   },
        // ),
        title: const Text(
          'Select vehicle',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('AllUsers')
            .doc(adminUid)
            .collection('vehicles')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
                backgroundColor: Colors.black,
              ),
            );
          }

          final documents = snapshot.data!.docs;

          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
              indent: 40,
              endIndent: 40,
            ),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              final vehicleName = document['name'];
              final amount30Min = document['amount30Min'];
              final amount120Min = document['amount120Min'];
              final amountMoreThan120Min = document['amountMoreThan120Min'];

              return GestureDetector(
                onTap: () {
                  // Store the selected vehicle details
                  selectedVehicleName = vehicleName;
                  selectedAmount30Min = amount30Min;
                  selectedAmount120Min = amount120Min;
                  selectedAmountMoreThan120Min = amountMoreThan120Min;

                  // Navigate to GenerateQrScreen with selected details
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenerateQrScreen(
                        vehicleName: selectedVehicleName.toString(),
                        amount30Min: selectedAmount30Min.toString(),
                        amount120Min: selectedAmount120Min.toString(),
                        amountMoreThan120Min:
                            selectedAmountMoreThan120Min.toString(),
                        phoneNo: widget.phoneNo,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: RichText(
                      text: TextSpan(children: <TextSpan>[
                    const TextSpan(
                        text: 'Vehicle name:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        )),
                    TextSpan(
                        text: ' $vehicleName',
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            letterSpacing: 1))
                  ])),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: TextSpan(children: <TextSpan>[
                        const TextSpan(
                            text: 'Charges for 30min:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            )),
                        TextSpan(
                            text: ' $amount30Min₹',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                letterSpacing: 1))
                      ])),
                      RichText(
                          text: TextSpan(children: <TextSpan>[
                        const TextSpan(
                            text: 'Charges for 120min:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            )),
                        TextSpan(
                            text: ' $amount120Min₹',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                letterSpacing: 1))
                      ])),
                      RichText(
                          text: TextSpan(children: <TextSpan>[
                        const TextSpan(
                            text: 'Charges after every hour of 120 min:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            )),
                        TextSpan(
                            text: ' $amountMoreThan120Min₹',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                letterSpacing: 1))
                      ])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
