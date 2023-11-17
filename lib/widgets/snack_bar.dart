import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        content,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.amber,
      showCloseIcon: true,
      closeIconColor: Colors.black,
    ),
  );
}
