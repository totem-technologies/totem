import 'package:flutter/material.dart';
import 'components/widgets/Header.dart';

class CircelPage extends StatelessWidget {
  const CircelPage({Key? key, required this.circleID}) : super(key: key);
  final String circleID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
            child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.grey[700],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              )
            ],
          ),
          TotemHeader(text: 'Circles'),
        ])),
      ),
    );
  }
}
