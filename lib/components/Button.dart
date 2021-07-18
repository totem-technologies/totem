import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

import './colors.dart';

class TotemButton extends StatefulWidget {
  TotemButton(
      {required this.onPressed,
      required this.text,
      this.icon = Icons.arrow_forward});
  final Function(Function stop) onPressed;
  final String text;
  final IconData icon;

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
            widget.icon,
            color: Colors.black,
          )
        : SpinKitPulse(
            color: Colors.black,
            size: 23.0,
          );
    return Container(
        width: MediaQuery.of(context).size.width * .5,
        child: RawMaterialButton(
          fillColor: enabled ? TotemColors.amber : Colors.grey[700],
          splashColor: Colors.amberAccent,
          onPressed: () {
            if (!enabled) {
              return;
            }
            start();
            widget.onPressed(stop);
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
        ));
  }
}
