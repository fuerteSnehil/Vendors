import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendors/Screens/collectionScreen.dart';
import 'package:vendors/Screens/loginScreen.dart';
import 'package:vendors/Screens/generateQrScreen.dart';
import 'package:vendors/Screens/scannerScreen.dart';
import 'package:vendors/Screens/totalVehicles.dart';
import 'package:vendors/Utils/constants.dart';

class HomeScreen extends StatefulWidget {
  final String phoneNo;
  const HomeScreen({required this.phoneNo, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Map<String, dynamic> vendorData = {};

  @override
  void initState() {
    super.initState();

    fetchVendorData();
  }

  // Method to fetch vendor data
  Future<void> fetchVendorData() async {
    final phoneNumber = widget.phoneNo;

    try {
      final DocumentSnapshot doc =
          await firestore.collection('vendors').doc(phoneNumber).get();
      print('Fetched Data: ${doc.data()}');
      print('Phone Number: $phoneNumber');
      if (doc.exists) {
        setState(() {
          vendorData = doc.data() as Map<String, dynamic>;
        });
      } else {
        print('Vendor document not found');
      }
    } catch (e) {
      print('Error fetching vendor data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          automaticallyImplyLeading: false,
          title: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: "ParkEasy\n",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.2,
                    fontSize: 18,
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
          actions: [
            IconButton(
              icon: Icon(
                MdiIcons.helpCircle,
                color: Colors.black,
                size: 21,
              ),
              onPressed: () {
                // Implement the action for the first icon.
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.black,
                size: 21,
              ),
              onPressed: () {
                // Implement the action for the second icon.
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.black,
                size: 21,
              ),
              onPressed: () {
                // Implement the action for the third icon.
              },
            ),
          ],
          bottom: TabBar(
            indicatorPadding: const EdgeInsets.only(left: 25, right: 25),
            indicatorWeight: 1.4,
            labelStyle:
                const TextStyle(letterSpacing: 2, fontWeight: FontWeight.w500),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black45,
            splashBorderRadius: BorderRadius.circular(30),
            // splashFactory: InkSparkle.splashFactory,

            dividerColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: const [
              Tab(
                text: "DASHBOARD",
              ),
              Tab(text: "PROFILE"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // The content for Tab 1
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ScannerScreen()));
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.asset(
                                'assets/scan.png',
                                scale: 6,
                              ),
                              const Text(
                                'Scan QR',
                                style: TextStyle(
                                    letterSpacing: 1,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (contaxt) => GenerateQrScreen(
                                        phoneNo: widget.phoneNo,
                                        vehicleName: '',
                                        amount30Min: '',
                                        amount120Min: '',
                                        amountMoreThan120Min: '',
                                      )));
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.asset(
                                'assets/qr.png',
                                scale: 6,
                              ),
                              const Text(
                                'Generate QR',
                                style: TextStyle(
                                    letterSpacing: 1,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset(
                              'assets/car.png',
                              scale: 6,
                            ),
                            const Text(
                              'Add Vehicle',
                              style: TextStyle(
                                  letterSpacing: 1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                        width: MediaQuery.of(context).size.width * 0.33,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TodayTotalVehiclesScreen()));
                          },
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Image.asset(
                                    'assets/vehicles.jpg',
                                  ),
                                ),
                                const Text(
                                  'Total Vehicle',
                                  style: TextStyle(
                                      letterSpacing: 1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>TodayCollectionScreen()));
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.asset(
                                'assets/collection.png',
                                scale: 4,
                              ),
                              const Text(
                                'Collections',
                                style: TextStyle(
                                    letterSpacing: 1,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Text(widget.phoneNo),
                  ],
                )
              ],
            ),

            // The content for Tab 2

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/details.gif',
                  scale: 1,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .02,
                ),
                Text(
                  'Admin UID : ${vendorData['adminUid']}',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .01,
                ),
                Text(
                  'Name : ${vendorData['name']}',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .01,
                ),
                Text(
                  'Phone No : ${vendorData['phoneNumber']}',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                ),
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          backgroundColor: Colors.amber),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Log Out',
                            style: TextStyle(fontSize: 17, color: Colors.black),
                          ),
                          Icon(
                            MdiIcons.logout,
                            color: Colors.black,
                          )
                        ],
                      ),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext) {
                            return Dialog(
                                // backgroundColor: Colors.amber.shade100,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        50.0)), //this right here
                                child: SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text(
                                          "You want to log out?",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: amber),
                                              child: const Text("Cancel",
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              child: const Text(
                                                "Logout",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              onPressed: () async {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                await prefs.setBool(
                                                    'isLogged', false);
                                                FirebaseAuth.instance.signOut();
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginScreen(),
                                                    ));
                                              },
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
