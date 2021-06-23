import 'package:flutter/material.dart';

class TotemHeader extends StatelessWidget {
  const TotemHeader({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 40),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
          ),
        ));
  }
}
