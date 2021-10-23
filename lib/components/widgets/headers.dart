import 'package:flutter/material.dart';

class TotemHeader extends StatelessWidget {
  const TotemHeader({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 40),
        child: Center(
          child: Column(
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 40,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: 100,
                  height: 6,
                  decoration: BoxDecoration(
                      color: const Color(0xffffcc59),
                      border: Border.all(),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                ),
              )
            ],
          ),
        ));
  }
}
