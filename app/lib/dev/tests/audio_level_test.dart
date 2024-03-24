import 'package:flutter/material.dart';
import 'package:totem/app/circle/components/circle_muted_indicator.dart';

class AudioLevelTest extends StatefulWidget {
  const AudioLevelTest({super.key});

  @override
  State<StatefulWidget> createState() => AudioLevelTestState();
}

class AudioLevelTestState extends State<AudioLevelTest> {
  double currentVolume = 0.0;
  // StreamType selectedStreamType = 0.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 200,
                    color: Colors.white,
                    child: const CircleMutedIndicator(),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            color: Colors.grey,
            child: const SafeArea(
                top: true, bottom: false, child: SizedBox(height: 25)),
          ),
        )
      ],
    );
  }
}
