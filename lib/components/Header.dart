import 'package:flutter/material.dart';

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
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: 100,
                  height: 6,
                  decoration: BoxDecoration(
                      color: Color(0xffffcc59),
                      border: Border.all(),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                ),
              )
            ],
          ),
        ));
  }
}
