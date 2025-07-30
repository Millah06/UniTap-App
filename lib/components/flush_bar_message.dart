import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../constraints/constants.dart';

class FlushBarMessage {

  static void showFlushBar({required BuildContext context,
    required String message,  String ? title, Icon ? icon}) {
    Flushbar(
      message: message,
      title: title,
      borderRadius: BorderRadius.circular(12),
      duration: Duration(seconds: 1),
      icon: icon ?? Icon(Icons.check_circle, color: Color(0xFF21D3ED),),
      backgroundColor: kErrorBackground,
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

}
