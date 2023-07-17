import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'my_colors.dart';

void showToast({required String message,})async
=> await Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: MyColors.lemon,
        textColor: Colors.black,
        fontSize: 12.0,
    );




