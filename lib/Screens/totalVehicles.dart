import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendors/Utils/constants.dart';

class TodayTotalVehiclesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: amber,
        title: Text('Today Total Vehicles'),
      ),
      body: PunchedOutVehiclesList(),
    );
  }
}

class PunchedOutVehiclesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('PunchedOutVehicles').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: amber,
              backgroundColor: black,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No punched out vehicles found.'),
          );
        }

        // Extract the documents from the snapshot
        final List<DocumentSnapshot> documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> data =
                documents[index].data() as Map<String, dynamic>;

            return ListTile(
              title: Text(
                'Vehicle Name: ${data['vehicleName']}',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              subtitle: Text('Vehicle No: ${data['vehicleNo']}'),
            );
          },
        );
      },
    );
  }
}
//modify this code that it should display only todays 