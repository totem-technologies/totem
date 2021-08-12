import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem/components/constants.dart';


class TotemButton extends StatefulWidget {
  TotemButton(
      {required this.onButtonPressed,
      required this.buttonText, this.icon = null});

  final Function(Function stop) onButtonPressed;
  final String buttonText;
  final IconData? icon;

  @override
  _TotemButtonState createState() => _TotemButtonState();
}

class _TotemButtonState extends State<TotemButton> {
  bool enabled = true;

  void start() {
    setState(() {
      enabled = false;
    });
  }

  void stop() {
    if (mounted) {
      setState(() {
        enabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var iconWidget = enabled
        ? Icon(
            widget.icon ?? Icons.arrow_forward,
            size: 30,
            color: Colors.black,
          )
        : SpinKitPulse(
            color: Colors.black,
            size: 23.0,
          );
    return InkWell(
      onTap: () {
        if (!enabled) {
          return;
        }
        start();
        widget.onButtonPressed(stop);
        Timer(Duration(seconds: 10), () {
          // Re-enable after a timeout incase stop is never called.
          stop();
        });
      },
      child: Container(
        height: 60.h,
        width: 230.w,
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        decoration: BoxDecoration(
            color: enabled ? yellowColor : Colors.grey[700],
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.buttonText,
              style: darkBlue16NormalTextStyle,
            ),
            iconWidget ,
          ],
        ),
      ),
    );

  }
}


class TotemContinueButton extends StatefulWidget {
  TotemContinueButton(
      {required this.onButtonPressed,
        required this.buttonText,
        });

  final Function(Function stop) onButtonPressed;
  final String buttonText;


  @override
  _TotemContinueButtonState createState() => _TotemContinueButtonState();
}

class _TotemContinueButtonState extends State<TotemContinueButton> {
  bool enabled = true;

  void start() {
    setState(() {
      enabled = false;
    });
  }

  void stop() {
    if (mounted) {
      setState(() {
        enabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        if (!enabled) {
          return;
        }
        start();
        widget.onButtonPressed(stop);
        Timer(Duration(seconds: 10), () {
          // Re-enable after a timeout incase stop is never called.
          stop();
        });
      },
      child: Container(
        height: 60.h,
        width: 230.w,
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        decoration: BoxDecoration(
            color: enabled ? yellowColor : Colors.grey[700],
            borderRadius: BorderRadius.circular(20)),
        child:   Text(
          widget.buttonText,
          style: darkBlue16NormalTextStyle,
        ),
      ),
    );
  }
}
