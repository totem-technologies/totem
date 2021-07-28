import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constance.dart';

class TotemButton extends StatefulWidget {
  TotemButton(
      {required this.onButtonPressed,
      required this.buttonText,
      required this.showArrow, this.icon = null});

  final Function(Function stop) onButtonPressed;
  final String buttonText;
  final bool showArrow;
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
          mainAxisAlignment: widget.showArrow
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            Text(
              widget.buttonText,
              style: darkBlue16NormalTextStyle,
            ),
            widget.showArrow ? iconWidget : SizedBox(),
          ],
        ),
      ),
    );
    /*Container(
        width: MediaQuery.of(context).size.width * .5,
        child: RawMaterialButton(
          fillColor: enabled ? TotemColors.amber : Colors.grey[700],
          splashColor: Colors.amberAccent,
          onPressed: () {
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
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.text,
                  maxLines: 1,
                  style: TextStyle(color: Colors.black),
                ),
                iconWidget
              ],
            ),
          ),
        ))*/
  }
}
