import 'package:flutter/material.dart';

class VehicleProvider extends ChangeNotifier {
  String vehicleValue = '';

 

  String get updateVehicleTypeValue => vehicleValue;



  void updateVehicleType(String newText) {
    vehicleValue = newText;
    notifyListeners();
  }
    void resetUpdateVehicleTypeValue() {
    vehicleValue = '';
    notifyListeners();
  }


}