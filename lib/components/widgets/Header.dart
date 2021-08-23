import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class TotemHeader extends StatelessWidget {
  const TotemHeader({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 10, bottom: 40),
        child: Center(
          child: Column(
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 40,
                  color: HexColor('#16182A'),
                  fontWeight: FontWeight.w700
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: 100,
                  height: 6,
                  decoration: BoxDecoration(
                      color: Color(0xffffcc59),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
              )
            ],
          ),
        ));
  }
}
