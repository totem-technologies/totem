import 'package:flutter/material.dart';

import '../components/widgets/themed_raised_button.dart';

class ButtonsScreen extends StatelessWidget {
  const ButtonsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var buttons = [
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
        ];
        return Center(
            child:
                Wrap(direction: Axis.vertical, spacing: 20, children: buttons));
      },
    );
  }
}
