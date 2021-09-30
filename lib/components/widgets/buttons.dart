import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:totem/components/constants.dart';

class TotemButton extends StatefulWidget {
  const TotemButton(
      {required this.onButtonPressed,
      required this.buttonText,
      this.icon,
      Key? key})
      : super(key: key);

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
    var alignment = MainAxisAlignment.center;
    var children = <Widget>[
      Text(
        widget.buttonText,
        style: darkBlue16NormalTextStyle,
      )
    ];
    if (widget.icon != null) {
      alignment = MainAxisAlignment.spaceBetween;
      var iconWidget = enabled
          ? Icon(
              widget.icon,
              size: 30,
              color: Colors.black,
            )
          : const SpinKitPulse(
              color: Colors.black,
              size: 23.0,
            );
      children.add(iconWidget);
    }
    return InkWell(
      onTap: () {
        if (!enabled) {
          return;
        }
        start();
        widget.onButtonPressed(stop);
        Timer(const Duration(seconds: 10), () {
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
          mainAxisAlignment: alignment,
          children: children,
        ),
      ),
    );
  }
}

class TotemContinueButton extends StatelessWidget {
  const TotemContinueButton({
    Key? key,
    required this.onButtonPressed,
    required this.buttonText,
  }) : super(key: key);
  final Function(Function stop) onButtonPressed;
  final String buttonText;
  @override
  Widget build(BuildContext context) {
    return TotemButton(
        onButtonPressed: onButtonPressed,
        buttonText: buttonText,
        icon: Icons.arrow_forward);
  }
}
