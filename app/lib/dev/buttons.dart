import 'package:flutter/material.dart';
import 'package:totem/components/widgets/slider_button.dart';

import '../components/widgets/themed_raised_button.dart';

class ButtonsScreen extends StatelessWidget {
  const ButtonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var buttons = [
          const SizedBox(
            height: 200,
          ),
          ThemedRaisedButton(
            child: const Text('Simple button!'),
            onPressed: () {},
          ),
          ThemedRaisedButton(
            onPressed: () {},
            busy: true,
            child: const Text('Busy button!'),
          ),
          ThemedRaisedButton(
            onPressed: () {},
            label: "Label button!",
          ),
          ThemedRaisedButton(
            onPressed: () {},
            padding: const EdgeInsets.only(left: 100),
            child: const Text("Padded button!"),
          ),
          SliderButton(
            action: (controller) async {
              controller.loading(); //starts loading animation
              await Future.delayed(const Duration(seconds: 3));
              controller.success(); //starts success animation
              await Future.delayed(const Duration(seconds: 3));
              controller.reset();
            },
          ),
        ]
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: e,
                ))
            .toList();
        return Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: buttons),
        ));
      },
    );
  }
}
