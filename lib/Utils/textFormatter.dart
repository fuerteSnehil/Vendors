import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UppercaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Use a regular expression to allow only uppercase letters and numbers
    final RegExp regExp = RegExp(r'^[A-Z0-9]*$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    } else {
      // Revert to the previous valid value if the new value is not valid
      return oldValue;
    }
  }
}
