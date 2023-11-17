import 'package:flutter/material.dart';
import 'package:vendors/Utils/constants.dart';

import 'package:vendors/widgets/screen.dart';

class CPI extends StatelessWidget {
  final double size;
  final Color? color;
  const CPI(this.size, {this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Screen(context).infinity,
      alignment: Alignment.center,
      child: SizedBox.square(
        dimension: size,
        child: CircularProgressIndicator(color: color ?? theme),
      ),
    );
  }
}
